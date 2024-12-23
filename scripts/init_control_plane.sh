#!/bin/bash
HOSTNAME=$(aws ec2 describe-instances --filters "Name=tag:Component,Values=control-plane-node" --output text --query "Reservations[].Instances[].PublicIpAddress")
LOAD_BALANCER_HOST=$(aws elbv2 describe-load-balancers --output text --query "LoadBalancers[0].DNSName")
LOAD_BALANCER_PORT=6443

if [ -n "$POD_CIDR" ]; then
  ssh ubuntu@"$HOSTNAME" \
    "LOAD_BALANCER_HOST=$LOAD_BALANCER_HOST LOAD_BALANCER_PORT=$LOAD_BALANCER_PORT POD_CIDR=$POD_CIDR bash -s" <<"EOF" >init_output.txt
#!/bin/bash
NODENAME=$(hostname -s)
sudo kubeadm init --control-plane-endpoint="$LOAD_BALANCER_HOST:$LOAD_BALANCER_PORT" --apiserver-cert-extra-sans="$LOAD_BALANCER_HOST" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/manifests/calico.yaml
EOF
else
  echo "Please provide POD_CIDR environment variable."
  exit 1
fi
