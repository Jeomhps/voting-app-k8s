# voting-app-k8s

This guide explains how to deploy the Voting App using three different methods: plain Kubernetes manifests, Kustomize, and Helm. Each method includes steps to create a Kind cluster, set up namespaces, and deploy the application.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (for Kind)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (Kubernetes CLI)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) (Kubernetes in Docker)
- [Kustomize](https://kustomize.io/) (for Kustomize deployments)
- [Helm](https://helm.sh/docs/intro/install/) (for Helm deployments)
- A `kind-config.yaml` file to map NodePorts to host ports (see [Kind Configuration](#kind-configuration)).

---

## Repository Structure

```
voting-app/
├── k8s-specifications/
│   ├── dev/
│   └── staging/
├── kustomize/
│   ├── base/
│   └── overlays/
│       ├── dev/
│       └── staging/
└── helm-voting-app/
    ├── templates/
    ├── values/
    │   ├── dev.yaml
    │   └── staging.yaml
    └── values.yaml
```

---

## Kind Configuration

The kind-config.yaml file is provided in this repository to map NodePorts to host ports. Since Kind runs Kubernetes clusters inside Docker containers, NodePort services are not directly accessible from your host machine. To expose them, you need to explicitly map the container ports to host ports.
This configuration reflects the NodePort values defined in the manifests for each environment (dev and staging). The mappings are as follows:


- Dev environment:
  - 31010: Vote service
  - 31011: Result service

- Staging environment:
  - 31020: Vote service
  - 31021: Result service

If you modify these port mappings, make sure to update the corresponding NodePort values in your Kubernetes manifests or Helm values to maintain consistency.

---

## Deployment Methods

### 1. Plain Kubernetes Manifests

#### Step 1: Create the Kind cluster
```bash
kind create cluster --name voting-app --config kind-config.yaml
```

#### Step 2: Create namespaces
```bash
kubectl create namespace dev
kubectl create namespace staging
```

#### Step 3: Apply manifests
```bash
kubectl apply -f k8s-specifications/dev -n dev
kubectl apply -f k8s-specifications/staging -n staging
```

#### Access the application:
- Dev environment:
  - Vote: [http://localhost:31010](http://localhost:31010)
  - Result: [http://localhost:31011](http://localhost:31011)
- Staging environment:
  - Vote: [http://localhost:31020](http://localhost:31020)
  - Result: [http://localhost:31021](http://localhost:31021)

---

### 2. Kustomize

#### Step 1: Create the Kind cluster
```bash
kind create cluster --name voting-app-kustomize --config kind-config.yaml
```

#### Step 2: Create namespaces
```bash
kubectl create namespace dev
kubectl create namespace staging
```

#### Step 3: Apply Kustomize overlays
```bash
kubectl apply -k kustomize/overlays/dev
kubectl apply -k kustomize/overlays/staging
```

#### Access the application:
- Same ports as [plain manifests](#1-plain-kubernetes-manifests).

---

### 3. Helm

#### Step 1: Create the Kind cluster
```bash
kind create cluster --name voting-app-helm --config kind-config.yaml
kubectl config current-context
```

#### Step 2: Create namespaces
```bash
kubectl create namespace dev
kubectl create namespace staging
```

#### Step 3: Install Helm releases
```bash
helm install vote-dev ./helm-voting-app -f helm-voting-app/values/dev.yaml -n dev
helm install vote-staging ./helm-voting-app -f helm-voting-app/values/staging.yaml -n staging
```

#### Step 4: Upgrade a release (if needed)
```bash
helm upgrade vote-dev ./helm-voting-app -f helm-voting-app/values/dev.yaml -n dev
helm upgrade vote-staging ./helm-voting-app -f helm-voting-app/values/staging.yaml -n staging
```

#### Step 5: Helm management commands

- View release history:
  ```bash
  helm history vote-dev -n dev
  helm history vote-staging -n staging
  ```

- Rollback to a previous revision (e.g., revision 2):
  ```bash
  helm rollback vote-dev 2 -n dev
  helm rollback vote-staging 2 -n staging
  ```

- Uninstall a release (this removes the entire app and its history from the namespace):
  ```bash
  helm uninstall vote-dev -n dev
  helm uninstall vote-staging -n staging
  ```

#### Access the application:
- Same ports as [plain manifests](#1-plain-kubernetes-manifests).

---

## Testing and Debugging

### Verify deployments
```bash
kubectl get pods,services -n dev
kubectl get pods,services -n staging
```

For Helm:
```bash
helm list -n dev
helm list -n staging
```

### View logs
```bash
kubectl logs -l app=vote -n dev
kubectl logs -l app=result -n staging
```

### Port-forwarding (if NodePorts are not working)
```bash
kubectl port-forward svc/vote 8080:80 -n dev
kubectl port-forward svc/result 8081:80 -n staging
```

---

## Cleanup

Delete the Kind clusters when done:

```bash
kind delete cluster --name voting-app
kind delete cluster --name voting-app-kustomize
kind delete cluster --name voting-app-helm
```

---

## Notes

- If using custom Docker images, load them into the Kind cluster:
  ```bash
  kind load docker-image your-image:tag --name voting-app-helm
  ```
- Customize `helm-voting-app/values/dev.yaml` and `helm-voting-app/values/staging.yaml` for environment-specific configurations.

---

## Further Reading

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Helm Documentation](https://helm.sh/docs/)
