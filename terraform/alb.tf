#-------------------------------------------------------------------------------
# Application load balancer
data "aws_caller_identity" "current" {}

resource "aws_alb_target_group" "alb_tg_http" {
  name     = "${local.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.aws_ecs_vpc_id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    enabled             = true
    interval            = 30
    path                = var.aws_app_health_check_path
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_alb" "alb_appl" {
  name            = "${local.name}-alb"
  internal        = false
  subnets         = var.aws_ecs_app_subnets_id
  security_groups = [aws_security_group.sg_ecs.id]

}

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn  = aws_alb.alb_appl.arn
  port               = "443"
  protocol           = "HTTPS"
  ssl_policy         = var.aws_ecs_certificate_policy
  certificate_arn    = aws_acm_certificate.domain_cert.arn
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}


resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.alb_listener_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg_http.arn
  }

  condition {
    host_header {
      values = [var.aws_acm_domain_name]
    }
  }
}

resource "aws_route53_record" "route53_record_alb" {
      zone_id = var.aws_acm_zone_id
      name    = var.aws_acm_domain_name
      type    = "CNAME"
      ttl     = 300
      records = [aws_alb.alb_appl.dns_name]
  }
#-------------------------------------------------------------------------------