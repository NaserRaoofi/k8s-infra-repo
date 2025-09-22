# Infrastructure Directory

This directory contains core infrastructure services that support your applications across all environments.

> **Note**: Currently focusing on essential operators (ArgoCD + ALB Controller). Infrastructure services below are planned for future implementation.

## Structure

### 📊 **databases/**

Database services and storage solutions:

- **postgresql/**: PostgreSQL database configurations
- **redis/**: Redis cache and session store
- **mysql/**: MySQL database (if needed)
- **mongodb/**: MongoDB NoSQL database (if needed)

### 📈 **monitoring/**

Observability and monitoring stack:

- **prometheus/**: Metrics collection and alerting
- **grafana/**: Dashboards and visualization
- **alertmanager/**: Alert routing and management
- **jaeger/**: Distributed tracing (if needed)

### 📝 **logging/**

Centralized logging infrastructure:

- **elasticsearch/**: Log storage and search
- **fluentd/**: Log collection and forwarding
- **kibana/**: Log visualization and analysis
- **logstash/**: Log processing pipeline (if needed)

### 🌐 **networking/**

Network infrastructure components:

- **istio/**: Service mesh (if needed)
- **nginx-ingress/**: Ingress controller
- **network-policies/**: Kubernetes network policies
- **cert-manager/**: TLS certificate management

## Usage

Each subdirectory should contain:

- `namespace.yaml`: Dedicated namespace for the service
- `values.yaml`: Helm chart values
- `<service>-app.yaml`: ArgoCD Application manifest
- `kustomization.yaml`: Kustomize configuration (if applicable)

## Environment Overrides

Environment-specific configurations should be managed through:

1. **ArgoCD Applications** with different value files per environment
2. **Kustomize overlays** in the `clusters/` directory
3. **Helm value files** with environment-specific settings
