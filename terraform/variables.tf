#-------------------------------------------------------------------------------
# Configure the Amazon Elastic Container Service (Amazon ECS) variables
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# General 
variable "aws_ecs_application" {
  type = string
  description = "The application's name."
  sensitive = false
}

variable "aws_ecs_environment" {
  type = string
  description = "The deployment environment (dev, prod). Default = \"dev\"."
  sensitive = false
  default = "dev"
}

variable "aws_ecs_region" {
  type = string
  description = "The AWS region where resources are created."
  sensitive = false
}

variable "aws_ecs_force_deploy" {
  type = bool
  description = "Enable to force a new task deployment of the service. "
  sensitive = false
}

#-------------------------------------------------------------------------------
# Network
variable "aws_ecs_vpc_id" {
  type = string
  description = "Identifier of the VPC in which to create the target group."
  sensitive = false
}

variable "aws_ecs_app_subnets_id" {
  description = "Subnets associated with the task or service."
  sensitive = false
}

#-------------------------------------------------------------------------------
# Cluster ECS - Services & tasks
variable "aws_ecs_image_app_tag" {
  type = string
  description = "Tag of the image to deploy."
  sensitive = false
  default = "latest"
}

variable "aws_ecs_image_app" {
  type = string
  description = "Image to deploy"
  sensitive = false
}

variable "aws_ecs_app_port" {
  type = number
  description = "Port of the container to expose on the EC2 instance"
  sensitive = false
}

variable "aws_ecs_certificate_policy" {
  type = string
  description = "Name of the SSL Policy for the listener."
  sensitive = false
}

variable "aws_ecs_certificate_arn" {
  type = string
  description = "ARN of the default SSL server certificate."
  sensitive = false
}

variable "aws_app_health_check_path" {
  type        = string
  description = "Destination for the health check requests."
  sensitive   = false
  default     = "/"
}

variable "aws_ecs_cpu" {
  type = number
  description = "Number of cpu units used by the task."
  sensitive = false
}

variable "aws_ecs_memory" {
  type = number
  description = "Amount (in MiB) of memory used by the task."
  sensitive = false
}

#-------------------------------------------------------------------------------
# Cluster ECS - Services & tasks
variable "aws_acm_domain_name" {
  type = string
  description = "The address of your domain"
  sensitive = false
}

variable "aws_acm_zone_id" {
  type = string
  description = "The Route53 zone ID"
  sensitive = false
}

