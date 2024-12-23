#!/bin/bash
LOAD_BALANCER_HOST=$(aws elbv2 describe-load-balancers --output text --query "LoadBalancers[0].DNSName")
LOAD_BALANCER_PORT=6443

if [ -n "$TOKEN" ] && [ -n "$CA_CERT_HASH" ]; then
  for hostname in $(aws ec2 describe-instances --filters "Name=tag:Component,Values=worker-node" --output text --query "Reservations[].Instances[].PublicIpAddress"); do
    ssh ubuntu@"$hostname" \
      "LOAD_BALANCER_HOST=$LOAD_BALANCER_HOST LOAD_BALANCER_PORT=$LOAD_BALANCER_PORT TOKEN=$TOKEN CA_CERT_HASH=$CA_CERT_HASH bash -s" <<"EOF"
#!/bin/bash
sudo kubeadm join "$LOAD_BALANCER_HOST:$LOAD_BALANCER_PORT" --token "$TOKEN" --discovery-token-ca-cert-hash "$CA_CERT_HASH"
EOF
  done
else
  echo "Either TOKEN or CA_CERT_HASH is not defined."
fi
