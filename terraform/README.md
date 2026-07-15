# Terraform dev cluster (low cost)

This folder creates a small dev cluster on AWS using EC2 only.
The design goal is simple: test quickly, then destroy everything.

It can also bootstrap k3s automatically on the instance using Terraform `user_data`.

## What this project creates

- 1 to 2 EC2 instances (micro size only)
- 1 security group for the cluster
- Uses default VPC and default subnet from your AWS account

It does not create EKS, load balancer, NAT gateway, or databases.

## Why this is cost-aware


## Files explained


## Recommended workflow

1. Initialize Terraform:

```bash
terraform init
```

2. Authenticate and export temporary credentials for Terraform:

```bash
eval "$(aws configure export-credentials --profile default --format env)"
```

If your profile name is not `default`, replace it in the command.

3. Review your variables in `terraform.tfvars`:


4. Create resources:

```bash
terraform plan
terraform apply
```

5. Destroy resources when done:

```bash
terraform destroy -auto-approve
```

6. Run the post-destroy checklist:

```bash
./check_post_destroy.sh
```

If you use another cluster name or region:

```bash
./check_post_destroy.sh my-dev-cluster us-east-1
```

## k3s as code (automatic install)

The EC2 instance runs `user_data` during first boot, using the template at `scripts/k3s-init.sh.tpl`.

Variables to control bootstrap:


After `terraform apply`, validate bootstrap on the instance:

```bash
sudo tail -n 100 /var/log/k3s-bootstrap.log
sudo systemctl status k3s --no-pager
kubectl get nodes -o wide
```

To use kubectl from your machine, copy kubeconfig from instance:

```bash
scp ubuntu@<EC2_PUBLIC_IP>:/home/ubuntu/.kube/config ./k3s-kubeconfig
```

Then edit the server address in `k3s-kubeconfig` to your EC2 public IP and export:

```bash
export KUBECONFIG=$PWD/k3s-kubeconfig
kubectl get nodes
```

## Troubleshooting credentials

If `terraform plan` returns `No valid credential sources found`, run this first in the same shell and retry:

```bash
eval "$(aws configure export-credentials --profile default --format env)"
terraform plan
```

Reason: Terraform provider uses SDK-compatible environment credentials, while AWS CLI login mode may authenticate only the CLI until exported.

## How to read main.tf quickly


Formula used in resource count:

$$
count = enable\_cluster ? instance\_count : 0
$$

That means:

- If `enable_cluster = true`, instances are created according to `instance_count`.

- Allocated Elastic IP without running instance can be billed.
- Always run `terraform destroy` and then `./check_post_destroy.sh`.
