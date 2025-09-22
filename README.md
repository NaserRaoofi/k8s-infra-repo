# Kubernetes Infrastructure Repository

A comprehensive GitOps infrastructure setup using ArgoCD App-of-Apps pattern for managing Kubernetes operators and applications.

## 🏗️ Architecture Overview

This repository implements the **App-of-Apps pattern** using ArgoCD to manage a complete Kubernetes infrastructure stack:

```
operators-app.yaml (App-of-Apps)
├── ArgoCD (GitOps Controller + Ingress)
├── AWS Load Balancer Controller (ALB Management)
├── Cert Manager (SSL Certificates) - [Commented for future use]
└── External DNS (Route53 Integration) - [Commented for future use]
```

## 📁 Repository Structure

```
├── operators/                    # Main App-of-Apps implementation
│   ├── operators-app.yaml       # 🎯 Main entry point - deploys everything
│   ├── chart/                   # Generic Helm chart for operators
│   │   ├── Chart.yaml           # Helm chart metadata
│   │   ├── values.yaml          # Operator configuration (enable/disable)
│   │   └── templates/
│   │       ├── argocd-applications.yaml      # Creates ArgoCD apps
│   │       └── additional-resources.yaml     # Namespaces and ingresses
│   └── values/                  # Operator-specific Helm values
│       ├── argocd.yaml          # ArgoCD custom configuration
│       └── aws-load-balancer-controller.yaml # ALB Controller config
├── scripts/
│   └── bootstrap.sh             # 🚀 One-time setup script
└── clusters/                    # Environment-specific configurations (legacy)
    └── dev/
```

## 🚀 Quick Start

### Prerequisites

1. **EKS Cluster**: `my-project-dev-eks` with proper IAM roles
2. **kubectl** configured: `aws eks update-kubeconfig --region us-east-1 --name my-project-dev-eks`
3. **VPC Configuration**: `vpc-0845b7ed5ceac1a19` with properly tagged subnets
4. **IAM Role**: `dev-my-project-alb-controller-role` with ALB permissions
5. **Helm** repositories configured
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm repo add eks https://aws.github.io/eks-charts
   helm repo add jetstack https://charts.jetstack.io
   helm repo add external-dns https://kubernetes-sigs.github.io/external-dns
   helm repo update
   ```

### 🎯 One-Command Deployment

```bash
# Bootstrap ArgoCD and deploy all operators
./scripts/bootstrap.sh
```

**Or manually:**

```bash
# 1. Install ArgoCD with custom configuration
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --values operators/values/argocd.yaml

# 2. Deploy App-of-Apps (manages everything else)
kubectl apply -f operators/operators-app.yaml
```

## 🛠️ Infrastructure Components

### Core Operators

| Component                        | Purpose                    | Status       | Access                                     |
| -------------------------------- | -------------------------- | ------------ | ------------------------------------------ |
| **ArgoCD**                       | GitOps Controller          | ✅ Deployed  | `https://argocd.dev.babak.naserraoofi.com` |
| **AWS Load Balancer Controller** | ALB/NLB Management         | ✅ Deployed  | Internal Controller                        |
| **Cert Manager**                 | SSL Certificate Management | 🟡 Commented | Ready for future use                       |
| **External DNS**                 | Route53 DNS Automation     | 🟡 Commented | Ready for future use                       |

### Sync Wave Order

```
Wave -10: operators-app (App-of-Apps)
Wave -5:  Namespaces
Wave 1:   ArgoCD
Wave 2:   AWS Load Balancer Controller
Wave 3:   [Future: Cert Manager, External DNS]
Wave 4+:  Applications and additional resources
```

## ⚙️ Configuration

### Environment Configuration

Current setup is configured for:

- **AWS Account:** `817100478429`
- **Region:** `us-east-1`
- **VPC:** `vpc-0845b7ed5ceac1a19`
- **Cluster:** `my-project-dev-eks`
- **Domain:** `babak.naserraoofi.com`

### Enabling/Disabling Operators

Edit [`operators/chart/values.yaml`](operators/chart/values.yaml):

```yaml
operators:
  argocd:
    enabled: true # Core component - keep enabled
  aws-load-balancer-controller:
    enabled: true # Required for ALB ingresses
  cert-manager:
    enabled: false # Currently commented out
  external-dns:
    enabled: false # Currently commented out
```

### Customizing Operator Configuration

Each operator has its dedicated values file in [`operators/values/`](operators/values/):

- **ArgoCD:** [`argocd.yaml`](operators/values/argocd.yaml)
- **ALB Controller:** [`aws-load-balancer-controller.yaml`](operators/values/aws-load-balancer-controller.yaml)
- **Cert Manager:** [`cert-manager.yaml`](operators/values/cert-manager.yaml)
- **External DNS:** [`external-dns.yaml`](operators/values/external-dns.yaml)

## 🔄 GitOps Workflow

### How Updates Work

1. **Update Configuration:** Modify values in `operators/chart/values.yaml` or `operators/values/*.yaml`
2. **Commit & Push:**
   ```bash
   git add .
   git commit -m "feat: update operator configuration"
   git push origin main
   ```
3. **Auto-Sync:** ArgoCD automatically detects changes and applies them (every 3 minutes)

### Manual Sync

```bash
# Force sync specific application
kubectl patch application operators -n argocd -p '{"operation":{"sync":{}}}' --type=merge

# Or use ArgoCD CLI
argocd app sync operators
```

## 🔐 Required IAM Permissions

### ALB Controller IAM Role

The IAM role `dev-my-project-alb-controller-role` needs comprehensive ELB permissions. See the [complete policy](operators/values/aws-load-balancer-controller.yaml#L20) in the values file.

Key permissions include:

- `elasticloadbalancing:*`
- `ec2:Describe*`
- `ec2:CreateSecurityGroup`
- `ec2:CreateTags`

### External DNS IAM Role

For Route53 integration, External DNS needs:

- `route53:ChangeResourceRecordSets`
- `route53:ListHostedZones`
- `route53:ListResourceRecordSets`

## 🌐 Accessing Services

### ArgoCD UI

```bash
# Access via ingress (after ALB is ready)
https://argocd.dev.babak.naserraoofi.com

# Or port-forward for immediate access
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access: https://localhost:8080
```

### Get ArgoCD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## 🐛 Troubleshooting

### Common Issues

1. **ALB Not Created**

   - Check IAM permissions for ALB Controller
   - Verify VPC and subnet configurations
   - Check ALB Controller logs: `kubectl logs -n aws-load-balancer-system deployment/aws-load-balancer-controller`

2. **App-of-Apps Not Syncing**

   - Check ArgoCD application status: `kubectl get applications -n argocd`
   - View detailed status: `kubectl describe application operators -n argocd`

3. **Helm Template Errors**
   - Test locally: `helm template operators/chart --values operators/chart/values.yaml`
   - Check template syntax in `operators/chart/templates/`

### Useful Commands

```bash
# Check all applications
kubectl get applications -n argocd

# Check operator pods
kubectl get pods -n aws-load-balancer-system
kubectl get pods -n cert-manager
kubectl get pods -n external-dns

# Check ingresses
kubectl get ingress -A

# View ALB Controller events
kubectl get events -n aws-load-balancer-system --sort-by='.lastTimestamp'
```

## 🏷️ Releases

- **v1.0.0** - Initial App-of-Apps implementation with ArgoCD, ALB Controller, Cert Manager, and External DNS

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test in dev environment
4. Submit a pull request

## 📚 Documentation

- [ArgoCD App-of-Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Cert Manager](https://cert-manager.io/docs/)
- [External DNS](https://github.com/kubernetes-sigs/external-dns)

---

**🎯 This infrastructure is production-ready and follows GitOps best practices!**
