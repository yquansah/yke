#!/bin/bash
HOSTNAME=$(aws ec2 describe-instances --filters "Name=tag:Component,Values=control-plane-node" --output text --query "Reservations[].Instances[].PublicIpAddress")

ssh ubuntu@"$HOSTNAME" <<"EOF"
#!/bin/bash
sudo kubeadm reset --force
EOF
