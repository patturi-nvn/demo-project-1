provider "aws" {
  region = "us-east-2"  # Change this to your desired region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
} 