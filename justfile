CLUSTER_PLAIN    := "voting-app"
CLUSTER_KUSTOMIZE := "voting-app-kustomize"
CLUSTER_HELM     := "voting-app-helm"

setup-cluster name:
    kind create cluster --name {{name}} --config kind-config.yaml
    kubectl create namespace dev
    kubectl create namespace staging

plain:
    just setup-cluster {{CLUSTER_PLAIN}}
    kubectl apply -f k8s-specifications/dev -n dev
    kubectl apply -f k8s-specifications/staging -n staging

kustomize:
    just setup-cluster {{CLUSTER_KUSTOMIZE}}
    kubectl apply -k kustomize/overlays/dev
    kubectl apply -k kustomize/overlays/staging

helm:
    just setup-cluster {{CLUSTER_HELM}}
    helm install vote-dev ./helm-voting-app -f helm-voting-app/values/dev.yaml -n dev
    helm install vote-staging ./helm-voting-app -f helm-voting-app/values/staging.yaml -n staging

clean:
    kind delete cluster --name {{CLUSTER_PLAIN}} || true
    kind delete cluster --name {{CLUSTER_KUSTOMIZE}} || true
    kind delete cluster --name {{CLUSTER_HELM}} || true
