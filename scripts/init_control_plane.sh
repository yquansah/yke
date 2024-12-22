#!/bin/bash
HOSTNAME=$(hostname -s)

if [ -n "$CONTROL_PLANE_HOST" ] && [ -n "$CONTROL_PLANE_PORT" ] && [ -n "$POD_CIDR" ]; then
  sudo kubeadm init --control-plane-endpoint="$CONTROL_PLANE_HOST:$CONTROL_PLANE_PORT" --apiserver-cert-extra-sans="$CONTROL_PLANE_HOST" --pod-network-cidr="$POD_CIDR" --node-name "$NODENAME" --ignore-preflight-errors Swap
fi
