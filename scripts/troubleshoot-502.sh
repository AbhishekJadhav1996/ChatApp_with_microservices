#!/bin/bash

# Troubleshooting script for 502 Bad Gateway errors
# Usage: ./scripts/troubleshoot-502.sh

set -e

NAMESPACE="chat-app"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔍 Troubleshooting 502 Bad Gateway Error"
echo "=========================================="
echo ""

# Check if namespace exists
echo "1. Checking namespace..."
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo -e "${GREEN}✅ Namespace '$NAMESPACE' exists${NC}"
else
    echo -e "${RED}❌ Namespace '$NAMESPACE' does not exist${NC}"
    exit 1
fi
echo ""

# Check pods status
echo "2. Checking pod status..."
kubectl get pods -n "$NAMESPACE"
echo ""

# Check frontend pod specifically
echo "3. Checking frontend pod details..."
FRONTEND_POD=$(kubectl get pods -n "$NAMESPACE" -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$FRONTEND_POD" ]; then
    echo -e "${RED}❌ No frontend pod found${NC}"
else
    echo -e "${GREEN}✅ Frontend pod: $FRONTEND_POD${NC}"
    echo ""
    echo "Pod status:"
    kubectl get pod "$FRONTEND_POD" -n "$NAMESPACE" -o wide
    echo ""
    echo "Pod events:"
    kubectl describe pod "$FRONTEND_POD" -n "$NAMESPACE" | tail -20
    echo ""
    echo "Pod logs:"
    kubectl logs "$FRONTEND_POD" -n "$NAMESPACE" --tail=50 || echo "Could not fetch logs"
fi
echo ""

# Check services
echo "4. Checking services..."
kubectl get svc -n "$NAMESPACE"
echo ""

# Check frontend service endpoints
echo "5. Checking frontend service endpoints..."
kubectl get endpoints frontend -n "$NAMESPACE" || echo "No endpoints found"
echo ""

# Check ingress
echo "6. Checking ingress configuration..."
kubectl get ingress -n "$NAMESPACE"
echo ""
kubectl describe ingress chatapp-ingress -n "$NAMESPACE" || echo "Ingress not found"
echo ""

# Check Traefik
echo "7. Checking Traefik ingress controller..."
kubectl get pods -n kube-system | grep traefik || echo "Traefik pod not found"
kubectl get svc -n kube-system | grep traefik || echo "Traefik service not found"
echo ""

# Test connectivity from within cluster
echo "8. Testing frontend service connectivity..."
FRONTEND_POD=$(kubectl get pods -n "$NAMESPACE" -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ ! -z "$FRONTEND_POD" ]; then
    echo "Testing from frontend pod..."
    kubectl exec -n "$NAMESPACE" "$FRONTEND_POD" -- wget -qO- http://localhost:80/ || echo "Failed to connect to localhost:80"
    echo ""
fi

# Test service DNS
echo "9. Testing service DNS resolution..."
kubectl run -it --rm test-connection --image=busybox --restart=Never -n "$NAMESPACE" -- wget -qO- http://frontend:80/ || echo "Failed to connect via service DNS"
echo ""

# Check network policies
echo "10. Checking network policies..."
kubectl get networkpolicies -n "$NAMESPACE" || echo "No network policies found"
echo ""

echo "=========================================="
echo "Troubleshooting complete!"
echo ""
echo "Common fixes:"
echo "1. If pods are not ready: kubectl describe pod <pod-name> -n $NAMESPACE"
echo "2. If endpoints are empty: Check service selector matches pod labels"
echo "3. If ingress not working: kubectl logs -n kube-system -l app.kubernetes.io/name=traefik"
echo "4. Rebuild and redeploy: ./scripts/build-images.sh abhishekjadhav1996 latest && kubectl rollout restart deployment/frontend-deployment -n $NAMESPACE"
