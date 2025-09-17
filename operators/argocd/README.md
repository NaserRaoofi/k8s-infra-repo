# ArgoCD Helm Chart Setup

This directory contains the configuration for deploying ArgoCD using Helm in your Kubernetes cluster.

## Prerequisites

1. **AWS CLI configured** with proper credentials
2. **kubectl installed** and configured
3. **Helm 3.x installed**
4. **Access to EKS cluster** `my-project-dev-eks`

## Cluster Access Issue Resolution

Based on the cluster configuration, your cluster has an IAM access issue. To resolve this:

### Option 1: Update EKS Cluster Auth (Recommended)

```bash
# Add your IAM user to the EKS cluster's aws-auth ConfigMap
kubectl patch configmap/aws-auth -n kube-system --type merge -p '{"data":{"mapUsers":"- userarn: arn:aws:iam::817100478429:user/sirwan\n  username: sirwan\n  groups:\n  - system:masters"}}'
```

### Option 2: Use IAM Role (Alternative)

If you have access to the IAM role that created the cluster, assume that role:

```bash
# Find the role from your Terraform state or AWS console
aws sts assume-role --role-arn "arn:aws:iam::817100478429:role/your-eks-admin-role" --role-session-name eks-access
```

## Installation Steps

### 1. Ensure Cluster Access

First, make sure you can access your EKS cluster:

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-project-dev-eks

# Test cluster access
kubectl cluster-info
kubectl get nodes
```

### 2. Install ArgoCD using the Script

```bash
cd k8s-infra/operators/argocd
./install.sh
```

### 3. Manual Installation (Alternative)

If the script doesn't work, install manually:

```bash
# Add Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --values values/dev.yaml \
  --version 8.3.9 \
  --wait
```

## Access ArgoCD

### 1. Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. Port Forward to Access UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 3. Open Browser

- URL: https://localhost:8080
- Username: admin
- Password: (from step 1)

### Ingress Access (if configured)

- URL: http://argocd-dev.example.com
- Update your `/etc/hosts` file or DNS to point to your ingress controller

## Configuration

### Values Files

- `values.yaml` - Base configuration
- `values/dev.yaml` - Development environment overrides

### Key Configuration Areas

- **Resources**: CPU/Memory limits for all components
- **Ingress**: External access configuration
- **RBAC**: Role-based access control
- **Redis**: Caching and session storage
- **Notifications**: Alert configuration

## Useful Commands

```bash
# Check ArgoCD status
kubectl get pods -n argocd

# View ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Scale components
kubectl scale deployment argocd-server --replicas=2 -n argocd

# Upgrade ArgoCD
helm upgrade argocd . -n argocd -f values.yaml -f values/dev.yaml
```

## Troubleshooting

### Common Issues

1. **Pods not starting**: Check resource limits and node capacity
2. **Ingress not working**: Verify ingress controller is installed
3. **Permission errors**: Check RBAC configuration

### Debug Commands

```bash
# Check all resources
kubectl get all -n argocd

# Describe problematic pods
kubectl describe pod <pod-name> -n argocd

# Check events
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

## Security Notes

- Default configuration uses insecure mode for development
- Change admin password after installation
- Configure OIDC/LDAP for production use
- Use TLS certificates for external access

## Links

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)
- [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
