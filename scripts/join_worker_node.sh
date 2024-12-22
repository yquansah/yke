#!/bin/bash
HOSTNAME=$(hostname -s)

if [ -n "$CONTROL_PLANE_HOST" ] && [ -n "$CONTROL_PLANE_PORT" ] && [ -n "$TOKEN" ] && [ -n "$CA_CERT_HASH" ]; then
  sudo kubeadm join "$CONTROL_PLANE_HOST":"$CONTROL_PLANE_PORT" --token "$TOKEN" --discovery-token-ca-cert-hash "$CA_CERT_HASH"
fi
