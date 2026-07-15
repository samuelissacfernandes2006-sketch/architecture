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

- `enable_cluster = false` by default
- `instance_count` is limited to 1..2
- `instance_type` is set to `t3.micro` for this setup
- Root disk is 8 GB and `delete_on_termination = true`
- SSH is closed by default (`allow_ssh = false`)

## Files explained

- `terraform.tf`: Terraform and provider versions
- `main.tf`: Provider, AMI lookup, network defaults, security group, EC2 nodes
- `variables.tf`: Input variables and cost guardrails
- `outputs.tf`: Useful outputs after apply
- `terraform.tfvars`: Your local values
- `check_post_destroy.sh`: Post-destroy checklist to verify possible billable leftovers
- `scripts/k3s-init.sh.tpl`: Instance bootstrap script template that installs k3s

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

- Keep `instance_count = 1`
- Keep `instance_type = "t3.micro"`
- Keep `allow_ssh = false` unless needed

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

- `enable_k3s = true`: enables k3s installation
- `k3s_version = "v1.30.2+k3s1"`: pins k3s version for reproducibility
- `k3s_token = null`: optional token override (sensitive variable)

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

- Provider region comes from variable `aws_region`.
- Ubuntu AMI is discovered dynamically with `data "aws_ami"`.
- Default VPC and default subnet are reused to keep network simple.
- Security group opens only egress by default.
- SSH ingress is optional and controlled by `allow_ssh`.
- EC2 count depends on `enable_cluster` and `instance_count`.

Formula used in resource count:

$$
count = enable\_cluster ? instance\_count : 0
$$

That means:

- If `enable_cluster = false`, nothing is created.
- If `enable_cluster = true`, instances are created according to `instance_count`.

## Important billing notes

- Free tier has monthly limits. If you exceed limits, charges can happen.
- Stopped instances can still keep EBS volumes billable.
- Allocated Elastic IP without running instance can be billed.
- Always run `terraform destroy` and then `./check_post_destroy.sh`.
