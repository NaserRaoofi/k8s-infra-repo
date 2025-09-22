# Kubernetes Operators - App-of-Apps Pattern

This directory implements the **App-of-Apps GitOps pattern** for managing all Kubernetes operators via ArgoCD.

## 🏗️ Architecture

```
operators/
├── chart/                          # Generic Helm chart (App-of-Apps)
│   ├── Chart.yaml                  # Chart metadata
│   ├── values.yaml                 # Global configuration & operator settings
│   └── templates/
│       ├── argocd-applications.yaml    # ArgoCD Application generator
│       └── additional-resources.yaml   # Namespaces & ingresses
├── values/                         # Operator-specific Helm values
│   ├── argocd.yaml                # ArgoCD Helm chart values
│   ├── aws-load-balancer-controller.yaml
│   ├── cert-manager.yaml          # Cert Manager values
│   └── external-dns.yaml          # External DNS values
├── operators-app.yaml             # Main App-of-Apps Application
└── README.md                      # This file
```

## 🚀 Available Operators

### ✅ **ArgoCD**

- **Status**: ✅ Deployed & Healthy
- **URL**: `https://argocd.dev.babak.naserraoofi.com`
- **Purpose**: GitOps continuous delivery platform
- **Features**: Self-managing ArgoCD with ALB ingress

### ✅ **AWS Load Balancer Controller**

- **Status**: ✅ Deployed & Healthy
- **Purpose**: Manages AWS ALB/NLB for Kubernetes ingresses
- **Features**: Automatic ALB creation, SSL termination, VPC integration
- **VPC**: `vpc-0845b7ed5ceac1a19`

### 🟡 **Cert Manager**

- **Status**: 🟡 Commented Out (Available for Future Use)
- **Purpose**: Automated TLS certificate management
- **Features**: Let's Encrypt integration, automatic renewal

### 🟡 **External DNS**

- **Status**: 🟡 Commented Out (Available for Future Use)
- **Purpose**: Automated DNS record management
- **Domain**: `babak.naserraoofi.com`
- **Provider**: AWS Route53

Edit `chart/values.yaml`:- Integrates with Let's Encrypt, AWS ACM, and other certificate authorities

## 🚀 Quick Start

### 1. Bootstrap ArgoCD (First Time Only)

```bash
# Run the bootstrap script to install ArgoCD
./scripts/bootstrap.sh
```

### 2. Deploy All Operators

```bash
# Deploy the App-of-Apps
kubectl apply -f operators/operators-app.yaml

# Check status
kubectl get applications -n argocd
```

### 3. Access ArgoCD UI

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access via: https://argocd.dev.babak.naserraoofi.com
# Username: admin
```

## ⚙️ Configuration

### Enable/Disable Operators

Edit `chart/values.yaml`:

```yaml
operators:
  argocd:
    enabled: true # ✅ Core GitOps operator
  aws-load-balancer-controller:
    enabled: true # ✅ ALB management
  cert-manager:
    enabled: false # 🟡 Currently commented out
  external-dns:
    enabled: false # 🟡 Currently commented out
```

### Customize Operator Values

Edit individual operator values in `values/` directory:

- `values/argocd.yaml` - ArgoCD configuration
- `values/aws-load-balancer-controller.yaml` - ALB Controller settings
- `values/cert-manager.yaml` - Certificate manager settings
- `values/external-dns.yaml` - DNS provider configuration

### Sync Wave Order

Operators deploy in order based on `syncWave`:

1. **Wave -5**: Namespaces (automatic)
2. **Wave 1**: ArgoCD core services
3. **Wave 2**: Infrastructure operators (ALB Controller)
4. **Wave 3**: [Future: Cert Manager, External DNS]

## 🔧 Adding New Operators

1. **Add to values.yaml**:

```yaml
operators:
  my-new-operator:
    enabled: true
    namespace: my-operator-system
    syncWave: "3"
    helm:
      repoURL: https://charts.example.com
      chart: my-operator
      version: 1.0.0
```

2. **Create values file**: `values/my-new-operator.yaml`

3. **Commit and push** - ArgoCD auto-syncs changes!

## 🎯 GitOps Features

- ✅ **Centralized Management**: All operators managed from single source
- ✅ **Sync Waves**: Controlled deployment order (-5 → 1 → 2 → 3)
- ✅ **Multi-Source**: Official Helm charts + custom values from Git
- ✅ **Auto-Sync**: Changes in Git automatically deployed to cluster
- ✅ **Self-Healing**: Cluster drift automatically corrected
- ✅ **Environment Agnostic**: Same pattern for dev/staging/prod

## 🛡️ Best Practices

1. **Use Sync Waves**: Control deployment order with appropriate `syncWave` values
2. **Test Locally**: Preview changes with `helm template` before committing
3. **Version Control**: All configuration changes tracked in Git
4. **Minimal Permissions**: Each operator uses dedicated service accounts
5. **Resource Limits**: Set appropriate CPU/memory limits for production
6. **Monitoring**: Watch ArgoCD UI for application health status

## 🔍 Troubleshooting

### Check Application Status

```bash
# View all applications
kubectl get applications -n argocd

# Check specific operator status
kubectl describe application aws-load-balancer-controller -n argocd
```

### View Operator Logs

```bash
# ALB Controller logs
kubectl logs -n aws-load-balancer-system deployment/aws-load-balancer-controller

# Cert Manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

### Manual Sync

```bash
# Force sync specific operator
kubectl patch application operators -n argocd --type merge -p '{"operation":{"sync":{"prune":true}}}'
```

### Validate Helm Template

```bash
# Test chart locally
helm template operators chart/ --debug --dry-run
```

## 🚨 Common Issues

### ALB Controller Permissions

If ingress doesn't get ADDRESS, check IAM role permissions:

```bash
kubectl describe ingress -n argocd
# Look for AWS permission errors in events
```

### ArgoCD Sync Failures

```bash
# Check for template parsing errors
kubectl describe application operators -n argocd | grep -A 10 "ComparisonError"
```

### DNS Resolution

```bash
# Check external-dns logs for Route53 issues
kubectl logs -n external-dns deployment/external-dns
```

## 📚 References

- [ArgoCD App-of-Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Cert Manager Documentation](https://cert-manager.io/docs/)
- [External DNS Guide](https://github.com/kubernetes-sigs/external-dns)

## 🏷️ Current Configuration

- **Repository**: `https://github.com/NaserRaoofi/k8s-infra-repo`
- **Branch**: `main`
- **ArgoCD URL**: `https://argocd.dev.babak.naserraoofi.com`
- **Domain**: `babak.naserraoofi.com`
- **VPC**: `vpc-0845b7ed5ceac1a19`
- **Region**: `us-east-1`

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
