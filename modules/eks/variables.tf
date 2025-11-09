variable "cluster_name"          { type = string }
variable "vpc_id"                { type = string }
variable "private_subnet_ids"    { type = list(string) }
variable "control_plane_sg_id"   { type = string }
