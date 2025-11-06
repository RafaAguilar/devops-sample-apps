#!/usr/bin/env sh

# Setup traefik for non-TILT kubernetes setup
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

kubectl create namespace traefik

helm install traefik traefik/traefik \
  --namespace traefik \
  --set service.type=NodePort

kubectl port-forward svc/traefik -n traefik 8080:80 > /dev/null 2>&1 &

# Deploy mocked secrets
kubectl apply -f db-secret.yaml
kubectl apply -f p12-secret.yaml

# Create ingresses: apps helm chart should be deployed first
kubectl apply -f ingress.yaml