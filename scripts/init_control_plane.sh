#!/bin/bash
LOAD_BALANCER_HOST=$(aws elbv2 describe-load-balancers --output text --query "LoadBalancers[0].DNSName")
LOAD_BALANCER_PORT=6443

if [ -n "$POD_CIDR" ]; then
  for hostname in $(aws ec2 describe-instances --filters "Name=tag:Component,Values=control-plane-node" --output text --query "Reservations[0].Instances[0].PublicIpAddress" | xargs); do
    ssh ubuntu@"$hostname" \
      "LOAD_BALANCER_HOST=$LOAD_BALANCER_HOST LOAD_BALANCER_PORT=$LOAD_BALANCER_PORT POD_CIDR=$POD_CIDR bash -s" <<"EOF"
NODENAME=$(hostname -s)
sudo kubeadm init --control-plane-endpoint="$LOAD_BALANCER_HOST:$LOAD_BALANCER_PORT" --apiserver-cert-extra-sans="$LOAD_BALANCER_HOST" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap
EOF
  done
else
  echo "Please provide POD_CIDR environment variable."
  exit 1
fi
