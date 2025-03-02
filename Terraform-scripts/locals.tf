locals {
  environment = var.environment
  env_configs = {
    dev = {
      ecr_repository_name = "react-app-dev"
      container_count    = 2
      container_cpu     = 256
      container_memory  = 512
    }
    staging = {
      ecr_repository_name = "react-app-staging"
      container_count    = 2
      container_cpu     = 512
      container_memory  = 1024
    }
    prod = {
      ecr_repository_name = "react-app-prod"
      container_count    = 4
      container_cpu     = 1024
      container_memory  = 2048
    }
  }

  # Get current environment config, default to dev if workspace doesn't exist
  current_env_config = lookup(local.env_configs, local.environment, local.env_configs["dev"])
} 