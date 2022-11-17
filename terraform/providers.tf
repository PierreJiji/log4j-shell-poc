# NE PAS COMMITER CE FICHIER

terraform {

  required_providers {
    
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.38"
    }
  }
}

#-------------------------------------------------------------------------------

# Configure the aws provider

provider "aws" {
  access_key = "AKIA3QTODXHRM6UZQDPP"
  secret_key = "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"
  region     = var.aws_ecs_region
  default_tags {
    tags = {
      system = var.aws_ecs_application
      environment = var.aws_ecs_environment
    }
  }
}