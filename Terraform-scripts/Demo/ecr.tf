# ECR Repository
resource "aws_ecr_repository" "app" {
  for_each = var.ecr_names
  
  name = each.value #"react-app-dev"
  force_delete = true
} 
