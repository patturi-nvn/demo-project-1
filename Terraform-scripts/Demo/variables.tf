variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_tags" {
  type = map(string)
}

variable "public_SNs" {
  type = list(string)
}

variable "private_SNs" {
  type = list(string)
}

variable "jump_server" {
  type = object({
    ami = string
    instance_type = string
    associate_public_ip_address = bool
  })
}

variable "jenkins_server" {
  type = object({
    ami = string
    instance_type = string
    associate_public_ip_address = bool
  })
}

variable "ecr_names" {
  type = set(string)
}

variable "ecs" {
  type = object({
    cluster_name = string
    task_definition_name = string
    cpu = number
    memory = number
    service_name = string
    container_count = number
    tg_name = string
    lb_name = string
  })
}