#!/bin/bash
if [ ! -f "../scripts/admin.conf" ]; then
  echo "admin.conf is not found, please run init_control_plane.sh first."
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "Helm is not installed, please install Helm first."
  exit 1
fi

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argo-cd argo/argo-cd --version 7.7.11 --namespace argocd --create-namespace --kubeconfig ../scripts/admin.conf
