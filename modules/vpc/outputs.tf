output "vpc_id"               { value = module.vpc.vpc_id }
output "private_subnet_ids"   { value = module.vpc.private_subnets }
output "public_subnet_ids"    { value = module.vpc.public_subnets }
output "control_plane_sg_id"  { value = aws_security_group.eks_control_plane.id }
