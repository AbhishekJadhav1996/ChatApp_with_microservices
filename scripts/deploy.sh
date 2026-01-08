#!/bin/bash

# Production Deployment Script for Chat App Microservices
# Usage: ./scripts/deploy.sh [namespace]

set -e

NAMESPACE=${1:-chat-app}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../k8s"

echo "🚀 Starting deployment to namespace: $NAMESPACE"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl.${NC}"
    exit 1
fi

if ! kubectl cluster-info &>/dev/null; then
    echo -e "${RED}❌ Kubernetes cluster not accessible. Please check your kubeconfig.${NC}"
    exit 1
fi

# Check for metrics-server (required for HPA)
echo "📊 Checking metrics-server (required for HPA)..."
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
    echo -e "${YELLOW}⚠️  Metrics-server not found. Installing metrics-server for HPA to work...${NC}"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Wait for metrics-server to be ready
    echo "⏳ Waiting for metrics-server to be ready..."
    sleep 10
    kubectl wait --for=condition=available --timeout=120s deployment/metrics-server -n kube-system || {
        echo -e "${YELLOW}⚠️  Metrics-server installation may take time. HPA will work once metrics-server is ready.${NC}"
    }
else
    echo -e "${GREEN}✅ Metrics-server is installed${NC}"
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f "$K8S_DIR/namespace.yml"

# Create secrets (if not exists)
echo "🔐 Checking secrets..."
if ! kubectl get secret chatapp-secrets -n "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}⚠️  Secrets not found. Please create them:${NC}"
    echo "kubectl create secret generic chatapp-secrets \\"
    echo "  --from-literal=jwt='your-jwt-secret' \\"
    echo "  --from-literal=cloudinary-cloud-name='your-cloud-name' \\"
    echo "  --from-literal=cloudinary-api-key='your-api-key' \\"
    echo "  --from-literal=cloudinary-api-secret='your-api-secret' \\"
    echo "  -n $NAMESPACE"
    read -p "Press enter after creating secrets..."
else
    echo -e "${GREEN}✅ Secrets exist${NC}"
fi

# Deploy MongoDB
echo "🍃 Deploying MongoDB..."
kubectl apply -f "$K8S_DIR/mongodb-pv.yml"
kubectl apply -f "$K8S_DIR/mongodb-pvc.yml"
kubectl apply -f "$K8S_DIR/mongodb-deployment.yml"
kubectl apply -f "$K8S_DIR/mongodb-service.yml"

echo "⏳ Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n "$NAMESPACE" --timeout=300s || true

# Deploy Backend (handles auth and messages APIs)
echo "🔧 Deploying Backend..."
kubectl apply -f "$K8S_DIR/backend-deployment.yml"
kubectl apply -f "$K8S_DIR/backend-service.yml"
echo "📈 Enabling automatic HPA for Backend (scales automatically based on load)..."
kubectl apply -f "$K8S_DIR/backend-hpa.yml"

# Deploy Socket Service
echo "🔌 Deploying Socket Service..."
kubectl apply -f "$K8S_DIR/socket-service-deployment.yml"
kubectl apply -f "$K8S_DIR/socket-service-service.yml"
echo "📈 Enabling automatic HPA for Socket Service (scales automatically based on load)..."
kubectl apply -f "$K8S_DIR/socket-service-hpa.yml"

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f "$K8S_DIR/frontend-deployment.yml"
kubectl apply -f "$K8S_DIR/frontend-service.yml"

# Deploy Ingress
echo "🌐 Deploying Ingress..."
kubectl apply -f "$K8S_DIR/ingress.yml"

# Deploy Pod Disruption Budgets
echo "🛡️  Deploying Pod Disruption Budgets..."
kubectl apply -f "$K8S_DIR/pod-disruption-budget.yml"

# Deploy Network Policies
echo "🔒 Deploying Network Policies..."
kubectl apply -f "$K8S_DIR/network-policy.yml"

# Wait for all deployments
echo "⏳ Waiting for all deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n "$NAMESPACE" || true
kubectl wait --for=condition=available --timeout=300s deployment/socket-service-deployment -n "$NAMESPACE" || true
kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n "$NAMESPACE" || true

# Display status
echo ""
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""
echo "📊 Deployment Status:"
kubectl get pods -n "$NAMESPACE"
echo ""
echo "🌐 Services:"
kubectl get svc -n "$NAMESPACE"
echo ""
echo "📈 HPA Status (Auto-scaling enabled - pods will scale automatically based on load):"
kubectl get hpa -n "$NAMESPACE"
echo ""
echo "💡 HPA will automatically:"
echo "   - Scale UP when CPU > 70% or Memory > 80%"
echo "   - Scale DOWN when resources are underutilized"
echo "   - Maintain minimum 2 replicas, scale up to max replicas as needed"
echo ""
echo "🔗 Ingress:"
kubectl get ingress -n "$NAMESPACE"
echo ""
echo "📊 To monitor HPA scaling in real-time:"
echo "   watch kubectl get hpa -n $NAMESPACE"
echo ""
echo "📝 To view logs: kubectl logs -f deployment/<service-name>-deployment -n $NAMESPACE"
echo "📋 To check status: kubectl get all -n $NAMESPACE"

