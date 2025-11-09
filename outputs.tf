output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
