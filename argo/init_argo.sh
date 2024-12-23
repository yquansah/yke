#!/bin/bash
if command -v helm >/dev/null 2>&1; then
  echo "Helm is installed, proceeding with next steps..."
  helm repo add argo https://argoproj.github.io/argo-helm
  helm install argo-cd argo/argo-cd --version 7.7.11 --namespace argocd --create-namespace
else
  echo "Please install helm."
fi
