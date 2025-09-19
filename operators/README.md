# Operators Chart - App-of-Apps Pattern# Kubernetes Operators

This Helm chart implements the **App-of-Apps pattern** for managing all Kubernetes operators via ArgoCD.This directory contains infrastructure operators that extend Kubernetes functionality and manage complex applications.

## 🏗️ Structure## Available Operators

```### 🚀 **ArgoCD** (`argocd/`)

operators/

├── chart/ # Generic Helm chart- GitOps continuous delivery operator

│ ├── Chart.yaml # Chart metadata- Manages application deployments from Git repositories

│ ├── values.yaml # Default configuration- Self-managing ArgoCD installation

│ └── templates/- **Status**: ✅ Installed and configured

│ └── argocd-applications.yaml # ArgoCD Application template

├── values/ # Operator-specific values### ⚖️ **AWS Load Balancer Controller** (`aws-load-balancer-controller/`)

│ ├── argocd.yaml # ArgoCD Helm values

│ └── aws-load-balancer-controller.yaml # AWS LB Controller values- Manages AWS Application Load Balancers (ALB) and Network Load Balancers (NLB)

├── operators-app.yaml # Main App-of-Apps Application- Integrates with AWS EKS for ingress traffic

└── README.md # This file- Supports advanced routing and SSL termination

````

### 🌐 **External DNS** (`external-dns/`)

## 🚀 Usage

- Automatically manages DNS records for services and ingresses

### Deploy All Operators- Integrates with AWS Route53, CloudFlare, and other DNS providers

```bash- Synchronizes Kubernetes resources with external DNS

kubectl apply -f operators-app.yaml

```### 🔒 **Cert Manager** (`cert-manager/`)



### Enable/Disable Operators- Automates TLS certificate management

Edit `chart/values.yaml`:- Integrates with Let's Encrypt, AWS ACM, and other certificate authorities

```yaml- Handles certificate renewal and rotation

operators:

  cert-manager:## Structure

    enabled: true  # Enable cert-manager

  external-dns:Each operator directory should contain:

    enabled: false # Disable external-dns

````

operator-name/

### Add New Operator├── namespace.yaml # Dedicated namespace

1. Add operator configuration to `chart/values.yaml`:├── values.yaml # Helm chart values

````yaml├── operator-app.yaml           # ArgoCD Application

operators:└── rbac.yaml                  # RBAC policies (if needed)

  my-new-operator:```

    enabled: true

    namespace: my-operator## Installation Order

    syncWave: "2"

    helm:Recommended installation sequence:

      repoURL: https://charts.example.com

      chart: my-operator1. **ArgoCD** - Core GitOps operator (✅ Installed)

      version: 1.0.02. **Cert Manager** - Certificate management foundation

```3. **AWS Load Balancer Controller** - Ingress traffic management

4. **External DNS** - DNS automation

2. Create values file: `values/my-new-operator.yaml`

## Best Practices

## 🎯 Features

1. **Dedicated namespaces** for each operator

- ✅ **Centralized Management**: All operators in one place2. **RBAC policies** with minimal required permissions

- ✅ **Sync Waves**: Control deployment order  3. **Resource limits** and monitoring

- ✅ **Multi-Source**: Helm charts + Git repository values4. **High availability** configurations for production

- ✅ **Automated Sync**: GitOps-native operation5. **Regular updates** and security patches

- ✅ **Environment Support**: Easy prod/dev/staging configurations
- ✅ **Selective Deployment**: Enable/disable operators easily

## 🔧 Configuration

### Global Settings
- `global.gitRepo`: Your Git repository URL
- `global.argocdNamespace`: ArgoCD namespace
- `global.syncPolicy`: Default sync behavior

### Per-Operator Settings
- `enabled`: Whether to deploy this operator
- `namespace`: Target namespace
- `syncWave`: Deployment order (lower numbers deploy first)
- `helm`: Helm chart configuration
- `labels/annotations`: Custom metadata

## 📋 Migration from Individual Apps

To migrate from individual ArgoCD Applications:

1. **Deploy the operators chart**:
   ```bash
   kubectl apply -f operators-app.yaml
````

2. **Verify all applications are created**:

   ```bash
   kubectl get applications -n argocd
   ```

3. **Remove old individual Applications** (optional):
   ```bash
   kubectl delete application argocd -n argocd
   kubectl delete application aws-load-balancer-controller -n argocd
   ```

## 🛡️ Best Practices

1. **Use Sync Waves**: Control deployment order with `syncWave`
2. **Test Changes**: Use `helm template` to preview changes
3. **Version Control**: Tag chart versions for releases
4. **Environment Values**: Use separate values files for different environments
5. **Monitoring**: Watch ArgoCD UI for application health

## 🔍 Troubleshooting

### Check Application Status

```bash
kubectl get applications -n argocd
kubectl describe application operators -n argocd
```

### Validate Helm Template

```bash
helm template operators chart/ --debug
```

### Force Sync

```bash
kubectl patch application operators -n argocd --type merge -p '{"operation":{"sync":{"prune":true}}}'
```
