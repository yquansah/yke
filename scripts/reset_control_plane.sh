#!/bin/bash
if [ -n "$POD_CIDR" ]; then
  for hostname in $(aws ec2 describe-instances --filters "Name=tag:Component,Values=control-plane-node" --output text --query "Reservations[0].Instances[0].PublicIpAddress" | xargs); do
    ssh ubuntu@"$hostname" <<"EOF"
#!/bin/bash
sudo kubeadm reset --force
EOF
  done
else
  echo "Please provide POD_CIDR environment variable."
  exit 1
fi
