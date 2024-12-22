#!/bin/bash
LOAD_BALANCER_HOST=$(aws elbv2 describe-load-balancers --output text --query "LoadBalancers[0].DNSName")

if [ -n "$CONTROL_PLANE_HOST" ] && [ -n "$CONTROL_PLANE_PORT" ] && [ -n "$TOKEN" ] && [ -n "$CA_CERT_HASH" ]; then
  sudo kubeadm join "$CONTROL_PLANE_HOST":"$CONTROL_PLANE_PORT" --token "$TOKEN" --discovery-token-ca-cert-hash "$CA_CERT_HASH"
fi
