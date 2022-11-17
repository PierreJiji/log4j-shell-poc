#-------------------------------------------------------------------------------
# ECS cluster
locals {
  name = "${var.aws_ecs_application}-${var.aws_ecs_environment}"
}

resource "aws_ecs_cluster" "ecs" {
  name = "${local.name}-ecs"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}


#-------------------------------------------------------------------------------
# ECS task definitions
locals {
  task_name = "${local.name}-app-task"
}

data "template_file" "app_tf" {
  template = file("${path.module}/tasks/log4j_task_definition.json")
  vars = {
    ecs_region           = var.aws_ecs_region
    app_image            = "${aws_ecr_repository.ecr_repo.repository_url}:${var.aws_ecs_image_app_tag}"
    app_host_port        = var.aws_ecs_app_port
    ecs_awslogs_group    = "/ecs/${local.task_name}"
    ecs_container_name   = "${local.name}-container"
    
  }
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = local.task_name
  container_definitions    = data.template_file.app_tf.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.aws_ecs_cpu
  memory                   = var.aws_ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
}

#-------------------------------------------------------------------------------
# ECS service

/* Simply specify the family to find the latest ACTIVE revision in that family */
data "aws_ecs_task_definition" "app_task" {
  task_definition = aws_ecs_task_definition.app_task.family
  depends_on = [aws_ecs_task_definition.app_task]
}

resource "aws_ecs_service" "app_service" {
  name                               = "${local.name}-app-service"
  cluster                            = aws_ecs_cluster.ecs.id
  task_definition                    = "${aws_ecs_task_definition.app_task.family}:${max("${aws_ecs_task_definition.app_task.revision}", "${data.aws_ecs_task_definition.app_task.revision}")}"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  launch_type                        = "FARGATE"
  force_new_deployment               = var.aws_ecs_force_deploy
  network_configuration {
     subnets         = var.aws_ecs_app_subnets_id
     security_groups = [aws_security_group.sg_ecs.id]
     assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.alb_tg_http.arn
    container_name   = "${local.name}-container"
    container_port   = var.aws_ecs_app_port
  }
  depends_on = [ aws_ecs_task_definition.app_task, aws_lb_listener.alb_listener_https, aws_alb.alb_appl, aws_alb_target_group.alb_tg_http ]
}
