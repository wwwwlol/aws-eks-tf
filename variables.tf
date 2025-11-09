variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
