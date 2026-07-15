#!/usr/bin/env bash
set -euo pipefail

# Post-destroy cost checklist for a low-cost dev environment.
# Usage:
#   ./check_post_destroy.sh [cluster_name] [region]
# Optional env vars:
#   AWS_PROFILE, AWS_REGION

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="${ROOT_DIR}/terraform.tfvars"

read_tfvars_value() {
  local key="$1"
  if [[ -f "${TFVARS_FILE}" ]]; then
    grep -E "^${key}[[:space:]]*=" "${TFVARS_FILE}" | head -n1 | sed -E 's/^[^=]+=\s*"?([^"#]+)"?.*$/\1/' | xargs || true
  fi
}

DEFAULT_CLUSTER="$(read_tfvars_value cluster_name)"
DEFAULT_REGION="$(read_tfvars_value aws_region)"

CLUSTER_NAME="${1:-${DEFAULT_CLUSTER:-dev-cluster}}"
REGION="${2:-${AWS_REGION:-${DEFAULT_REGION:-us-east-1}}}"

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI not found. Install AWS CLI first."
  exit 1
fi

echo "Running post-destroy checklist"
echo "Cluster name: ${CLUSTER_NAME}"
echo "Region: ${REGION}"
if [[ -n "${AWS_PROFILE:-}" ]]; then
  echo "AWS profile: ${AWS_PROFILE}"
fi

echo

HAS_FINDINGS=0

check_result() {
  local title="$1"
  local query_cmd="$2"

  local output
  output="$(eval "${query_cmd}")"

  if [[ -z "${output}" || "${output}" == "None" ]]; then
    printf '[OK] %s\n' "${title}"
  else
    printf '[WARN] %s\n' "${title}"
    echo "${output}" | sed 's/^/  - /'
    HAS_FINDINGS=1
  fi
}

check_result \
  "EC2 instances with cluster tag still alive" \
  "aws ec2 describe-instances --region '${REGION}' --filters Name=tag:Name,Values='${CLUSTER_NAME}-node-*' Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name,Name:Tags[?Key==\`Name\`]|[0].Value}' --output text"

check_result \
  "Security groups with cluster name" \
  "aws ec2 describe-security-groups --region '${REGION}' --filters Name=group-name,Values='${CLUSTER_NAME}-sg' --query 'SecurityGroups[].{Id:GroupId,Name:GroupName}' --output text"

check_result \
  "EBS volumes tagged for cluster" \
  "aws ec2 describe-volumes --region '${REGION}' --filters Name=tag:Name,Values='${CLUSTER_NAME}-node-*' Name=status,Values=available,in-use --query 'Volumes[].{Id:VolumeId,State:State,Size:Size}' --output text"

check_result \
  "Elastic IPs allocated in this region" \
  "aws ec2 describe-addresses --region '${REGION}' --query 'Addresses[].{AllocationId:AllocationId,PublicIp:PublicIp,InstanceId:InstanceId}' --output text"

check_result \
  "NAT Gateways still present" \
  "aws ec2 describe-nat-gateways --region '${REGION}' --filter Name=state,Values=available,pending,failed --query 'NatGateways[].{Id:NatGatewayId,State:State}' --output text"

check_result \
  "Load balancers still present (ALB/NLB)" \
  "aws elbv2 describe-load-balancers --region '${REGION}' --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code}' --output text 2>/dev/null || true"

check_result \
  "Classic load balancers still present" \
  "aws elb describe-load-balancers --region '${REGION}' --query 'LoadBalancerDescriptions[].LoadBalancerName' --output text 2>/dev/null || true"

check_result \
  "EKS clusters still present" \
  "aws eks list-clusters --region '${REGION}' --query 'clusters[]' --output text 2>/dev/null || true"

check_result \
  "RDS instances still present" \
  "aws rds describe-db-instances --region '${REGION}' --query 'DBInstances[].{Id:DBInstanceIdentifier,Status:DBInstanceStatus}' --output text 2>/dev/null || true"

echo
if [[ "${HAS_FINDINGS}" -eq 0 ]]; then
  echo "Checklist complete: no obvious billable resources found in ${REGION}."
  exit 0
fi

echo "Checklist complete: review WARN items above to avoid ongoing costs."
exit 2
