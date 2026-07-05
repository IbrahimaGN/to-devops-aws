terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend local par défaut pour le TP.
  # Pour un vrai contexte pro on utiliserait un backend S3 + DynamoDB (state partagé + lock).
  # backend "s3" {
  #   bucket         = "todo-medishop-tfstate"
  #   key            = "terraform.tfstate"
  #   region         = "eu-west-3"
  #   dynamodb_table = "todo-medishop-tflock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
