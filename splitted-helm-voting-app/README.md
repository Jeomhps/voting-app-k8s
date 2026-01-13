# Splitted Helm Voting App

This directory contains a refactored version of the voting app Helm chart, split into individual microservice charts with a parent chart that manages dependencies.

## Structure

```
splitted-helm-voting-app/
├── charts/                  # Individual microservice charts
│   ├── vote/               # Vote microservice chart
│   ├── result/             # Result microservice chart
│   ├── worker/             # Worker microservice chart
│   ├── db/                 # PostgreSQL database chart
│   └── redis/              # Redis database chart
└── voting-app/             # Parent chart that depends on all microservices
    ├── Chart.yaml           # Main chart with dependencies
    ├── values.yaml          # Default values
    └── values/              # Environment-specific values
        ├── dev.yaml        # Development environment
        └── staging.yaml    # Staging environment
```

## Usage

### Install dependencies

```bash
cd splitted-helm-voting-app/voting-app
helm dependency update
```

### Install the application

For development environment:
```bash
helm install voting-app . -f values/dev.yaml
```

For staging environment:
```bash
helm install voting-app . -f values/staging.yaml
```

### Template rendering (dry-run)

```bash
# Development
helm template voting-app . -f values/dev.yaml

# Staging
helm template voting-app . -f values/staging.yaml
```

## Architecture Benefits

1. **Modularity**: Each microservice has its own chart with independent versioning
2. **Reusability**: Individual charts can be used independently or as part of the parent chart
3. **Maintainability**: Easier to update and manage individual components
4. **Environment management**: Centralized environment-specific configurations in the parent chart
5. **Dependency management**: Helm handles chart dependencies automatically

## Environment Differences

- **Development**: 1 replica for all services, specific NodePorts
- **Staging**: 3 vote replicas, 2 worker replicas, different NodePorts