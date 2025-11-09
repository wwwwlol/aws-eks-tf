# **EKS Cluster with Terraform**  

## Overview

This Terraform configuration deploys a **fully functional Amazon EKS cluster** with:

| Component | Status |
|---------|--------|
| VPC with public & private subnets | Done |
| Single NAT Gateway (cost-effective) | Done |
| EKS Control Plane (public endpoint) | Done |
| 2 Worker Nodes in **private subnets** | Done |
| Auto-created node security group | Done |
| EKS-managed node group with autoscaling | Done |
| Cluster Autoscaler add-on | Done |
| Clean, modular structure | Done |

---

## Folder Structure

```
my-eks-cluster/
├── main.tf              # Root orchestrator
├── variables.tf         # Shared variables
├── outputs.tf           # Useful outputs
├── providers.tf         # AWS provider
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf 
│   │   ├── data.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── eks/
│       ├── main.tf      # EKS cluster + node group
│       ├── variables.tf
│       └── outputs.tf
│
└── terraform.tfvars     # (Optional) override defaults
```

---

## Key Features

| Feature | Details |
|-------|--------|
| **VPC** | `10.0.0.0/16` with 3 private + 3 public subnets |
| **AZs** | First 3 available in region |
| **NAT** | Single NAT Gateway → cost-effective |
| **EKS API** | Public endpoint (`cluster_endpoint_public_access = true`) |
| **Worker Nodes** | 2 × `t3.medium` in **private subnets** |
| **Security** | Nodes have **no public IP**, auto-SG with correct rules |
| **Scalability** | Node group: min 1, max 4 |
| **Add-ons** | Cluster Autoscaler enabled |

---

## Security Model

| Component | Access |
|---------|--------|
| **Control Plane** | Public HTTPS (443) – `kubectl` from anywhere |
| **Worker Nodes** | **Private only** – no public IP |
| **Node SG** | Auto-created: allows CP → nodes, node ↔ node, outbound |
| **Control Plane SG** | Allows `0.0.0.0/0 → 443` (tighten in prod) |


---

## How to Deploy

### 1. Clone & Enter Directory

```bash
git clone <your-repo>
cd my-eks-cluster
```

### 2. Initialize

```bash
terraform init
```

### 3. Review Plan

```bash
terraform plan -out=plan.out
```

### 4. Apply

```bash
terraform apply plan.out
```

---

## Post-Apply: Connect to Cluster

```bash
# Update kubeconfig
aws eks update-kubeconfig --name my-eks-prod --region us-east-1

# Verify nodes
kubectl get nodes -o wide
```

**Expected Output:**
```
NAME                                         STATUS   ROLES    AGE   VERSION           INTERNAL-IP
ip-10-0-1-100.us-east-1.compute.internal    Ready    <none>   2m    v1.30.x           10.0.1.100
ip-10-0-2-150.us-east-1.compute.internal    Ready    <none>   2m    v1.30.x           10.0.2.150
```

> **Note**: `INTERNAL-IP` proves nodes are in **private subnets**

---

## Outputs (After Apply)

| Output | Command |
|------|--------|
| Kubeconfig command | `terraform output -raw kubeconfig_command` |
| Cluster endpoint | `terraform output -raw cluster_endpoint` |

---

## Customize (Optional)

### Make Control Plane **Fully Private**

Edit `modules/eks/main.tf`:

```hcl
cluster_endpoint_public_access  = false
cluster_endpoint_private_access = true
```

> Requires VPC access (bastion, VPN, etc.)

---

### Change Node Type / Count

Edit `modules/eks/main.tf`:

```hcl
desired_size = 3
instance_types = ["m5.large"]
```

---

### Add More Add-ons

```hcl
cluster_addons = {
  coredns = {}
  kube-proxy = {}
  vpc-cni = {}
  aws-ebs-csi-driver = { most_recent = true }
}
```

---

## Cleanup

```bash
terraform destroy
```

---

## Security Hardening (Production)

| Action | Code |
|------|------|
| Restrict API to your IP | Replace `0.0.0.0/0` with `YOUR_IP/32` |
| Enable private endpoint | Set `public_access = false` |
| Use IAM roles for pods | Add `enable_irsa = true` |
| Enable encryption | Add `cluster_encryption_config` |

---

## Troubleshooting

| Issue | Fix |
|-----|-----|
| `kubectl` timeout | Check SG ingress 443, VPC DNS, NAT |
| Nodes not joining | Check node SG, CNI, IAM role |
| No internet in pods | Verify NAT Gateway + route tables |

---

## References

- [Terraform EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [VPC Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)