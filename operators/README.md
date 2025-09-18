# Kubernetes Operators

This directory contains infrastructure operators that extend Kubernetes functionality and manage complex applications.

## Available Operators

### 🚀 **ArgoCD** (`argocd/`)

- GitOps continuous delivery operator
- Manages application deployments from Git repositories
- Self-managing ArgoCD installation
- **Status**: ✅ Installed and configured

### ⚖️ **AWS Load Balancer Controller** (`aws-load-balancer-controller/`)

- Manages AWS Application Load Balancers (ALB) and Network Load Balancers (NLB)
- Integrates with AWS EKS for ingress traffic
- Supports advanced routing and SSL termination

### 🌐 **External DNS** (`external-dns/`)

- Automatically manages DNS records for services and ingresses
- Integrates with AWS Route53, CloudFlare, and other DNS providers
- Synchronizes Kubernetes resources with external DNS

### 🔒 **Cert Manager** (`cert-manager/`)

- Automates TLS certificate management
- Integrates with Let's Encrypt, AWS ACM, and other certificate authorities
- Handles certificate renewal and rotation

## Structure

Each operator directory should contain:

```
operator-name/
├── namespace.yaml              # Dedicated namespace
├── values.yaml                # Helm chart values
├── operator-app.yaml           # ArgoCD Application
└── rbac.yaml                  # RBAC policies (if needed)
```

## Installation Order

Recommended installation sequence:

1. **ArgoCD** - Core GitOps operator (✅ Installed)
2. **Cert Manager** - Certificate management foundation
3. **AWS Load Balancer Controller** - Ingress traffic management
4. **External DNS** - DNS automation

## Best Practices

1. **Dedicated namespaces** for each operator
2. **RBAC policies** with minimal required permissions
3. **Resource limits** and monitoring
4. **High availability** configurations for production
5. **Regular updates** and security patches
