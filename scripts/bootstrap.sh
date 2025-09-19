#!/bin/bash
set -e

echo "🚀 Bootstrapping ArgoCD App-of-Apps Infrastructure..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is configured
echo -e "${BLUE}Checking kubectl configuration...${NC}"
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ kubectl is not configured or cluster is not reachable"
    exit 1
fi

# Check if argo helm repo is configured
echo -e "${BLUE}Checking Helm repositories...${NC}"
if ! helm repo list | grep -q "argo.*https://argoproj.github.io/argo-helm"; then
    echo "❌ ArgoCD Helm repository is not configured"
    echo "Please run: helm repo add argo https://argoproj.github.io/argo-helm"
    exit 1
fi

# Update helm repos
echo -e "${BLUE}Updating Helm repositories...${NC}"
helm repo update

# Create argocd namespace if it doesn't exist
echo -e "${BLUE}Creating argocd namespace...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD using Helm with our custom values
echo -e "${BLUE}Installing ArgoCD using Helm...${NC}"
helm install argocd argo/argo-cd \
  --namespace argocd \
  --values operators/values/argocd.yaml \
  --wait \
  --timeout 10m

# Wait for ArgoCD server to be ready
echo -e "${BLUE}Waiting for ArgoCD server to be ready...${NC}"
kubectl wait --for condition=available --timeout=300s deployment/argocd-server -n argocd

# Apply the App-of-Apps
echo -e "${BLUE}Deploying App-of-Apps...${NC}"
kubectl apply -f operators/operators-app.yaml

# Wait for operators app to be created
echo -e "${BLUE}Waiting for operators application to be created...${NC}"
kubectl wait --for condition=available --timeout=300s application/operators -n argocd || true

echo -e "${GREEN}✅ Bootstrap completed successfully!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "   1. Monitor deployment: kubectl get applications -n argocd"
echo "   2. Check operator pods: kubectl get pods -A"
echo "   3. Access ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   4. Get ArgoCD admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo -e "${GREEN}🎉 All operators will be deployed automatically via App-of-Apps pattern!${NC}"
echo -e "${BLUE}🌐 ArgoCD will be accessible at: https://argocd.dev.babak.naserraoofi.com${NC}"
