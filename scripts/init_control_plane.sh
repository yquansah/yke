#!/bin/bash
HOSTNAME=$(aws ec2 describe-instances --filters "Name=tag:Component,Values=control-plane-node" --output text --query "Reservations[].Instances[].PublicIpAddress")
LOAD_BALANCER_HOST=$(aws elbv2 describe-load-balancers --output text --query "LoadBalancers[0].DNSName")
LOAD_BALANCER_PORT=6443

ssh ubuntu@"$HOSTNAME" \
  "LOAD_BALANCER_HOST=$LOAD_BALANCER_HOST LOAD_BALANCER_PORT=$LOAD_BALANCER_PORT bash -s" <<"EOF" >init_output.txt
  #!/bin/bash
  NODENAME=$(hostname -s)
  sudo kubeadm init --control-plane-endpoint="$LOAD_BALANCER_HOST:$LOAD_BALANCER_PORT" --apiserver-cert-extra-sans="$LOAD_BALANCER_HOST" --pod-network-cidr="192.168.0.0/16" --node-name "$NODENAME" --ignore-preflight-errors Swap
  sudo kubectl create --kubeconfig=/etc/kubernetes/admin.conf -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
  sudo kubectl create --kubeconfig=/etc/kubernetes/admin.conf -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml
  sudo cp /etc/kubernetes/admin.conf admin.conf
  sudo chown ubuntu:ubuntu admin.conf
EOF

scp ubuntu@"$HOSTNAME":admin.conf .
