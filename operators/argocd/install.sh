#!/bin/bash
set -e

# ArgoCD Installation Script for Development Environment
# This script installs ArgoCD using Helm in the my-project-dev-eks cluster

echo "=== ArgoCD Installation Script ==="
echo "Installing ArgoCD in development environment..."

# Check if kubectl is configured
echo "Checking kubectl configuration..."
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: kubectl is not properly configured or cluster is not accessible"
    echo "Please ensure you have access to the Kubernetes cluster"
    echo "Run: aws eks update-kubeconfig --region us-east-1 --name my-project-dev-eks"
    exit 1
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is not installed"
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Add ArgoCD Helm repository
echo "Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace for ArgoCD
echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD using Helm
echo "Installing ArgoCD..."
helm upgrade --install argocd argo/argo-cd \
    --namespace argocd \
    --values values/dev.yaml \
    --version 8.3.9 \
    --wait \
    --timeout 10m

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=ready --timeout=300s statefulset/argocd-application-controller -n argocd

# Get ArgoCD admin password
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=== ArgoCD Installation Complete ==="
echo "Namespace: argocd"
echo "Admin Username: admin"
echo "Admin Password: $ARGOCD_PASSWORD"
echo ""
echo "To access ArgoCD:"
echo "1. Port forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Open browser: https://localhost:8080"
echo "3. Login with admin/$ARGOCD_PASSWORD"
echo ""
echo "To get the password again:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
