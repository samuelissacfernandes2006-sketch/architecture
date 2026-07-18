aws_region   = "us-east-1"
aws_profile  = null
cluster_name = "dev-cluster"
environment  = "dev"
node_type    = "master-node"

# instance config
instance_count = 1
instance_type  = "t3.small"

# keep false unless SSH is needed.
allow_ssh         = true
ssh_allowed_cidrs = ["0.0.0.0/0"]
ssh_key_name      = "EC2_DEV"

# argocd installation 
argocd_version   = "10.1.2"
argocd_namespace = "argocd"

# k3s configurations
enable_k3s  = true
k3s_version = "v1.35.0+k3s3"
k3s_token   = "tokentemporarioparateste"

#load balancer configs
load_balancer_type = "network"
load_balancer_internal = true

