aws_region   = "us-east-1"
aws_profile  = null
cluster_name = "dev-cluster"
environment  = "dev"
enable_cluster = true

# instance config
instance_count = 1
instance_type  = "t3.small"

# k3s bootstrap
enable_k3s  = true
k3s_version = "v1.35.0+k3s3"

# keep false unless SSH is needed.
allow_ssh         = true
ssh_allowed_cidrs = ["0.0.0.0/0"]
ssh_key_name      = "EC2_DEV"

# argocd installation 
argocd_version   = "10.1.2"
argocd_namespace = "argocd"