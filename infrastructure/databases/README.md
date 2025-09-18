# Database Infrastructure

This directory contains database services and storage solutions.

## Available Databases

### 🐘 **PostgreSQL** (`postgresql/`)

- Production-ready relational database
- High availability configurations
- Backup and recovery solutions

### 🔴 **Redis** (`redis/`)

- In-memory cache and session store
- Cluster and sentinel configurations
- Persistence options

## Structure

Each database directory should contain:

```
database-name/
├── namespace.yaml          # Dedicated namespace
├── values.yaml            # Helm chart values
├── database-app.yaml      # ArgoCD Application
└── backup-config.yaml     # Backup configurations
```

## Best Practices

1. **Separate namespaces** for each database
2. **Resource limits** and requests properly configured
3. **Persistent volumes** for data storage
4. **Backup strategies** implemented
5. **Security policies** (network policies, RBAC)
6. **Environment-specific sizing** (dev vs prod)
