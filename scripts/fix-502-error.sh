#!/bin/bash

# Script to diagnose and fix 502 Bad Gateway errors

set -e

NAMESPACE="chat-app"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔍 Diagnosing 502 Bad Gateway Error..."
echo ""

# Step 1: Check pods
echo "1️⃣ Checking pods status..."
PODS=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
if [ "$PODS" -eq 0 ]; then
    echo -e "${RED}❌ No pods found in namespace $NAMESPACE${NC}"
    exit 1
fi

kubectl get pods -n $NAMESPACE
echo ""

# Check if any pods are not running
NOT_RUNNING=$(kubectl get pods -n $NAMESPACE --no-headers | grep -v Running | grep -v Completed | wc -l)
if [ "$NOT_RUNNING" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some pods are not running. Check logs:${NC}"
    kubectl get pods -n $NAMESPACE --no-headers | grep -v Running | grep -v Completed | awk '{print $1}' | while read pod; do
        echo "  kubectl logs -n $NAMESPACE $pod"
    done
    echo ""
fi

# Step 2: Check services
echo "2️⃣ Checking services..."
kubectl get svc -n $NAMESPACE
echo ""

# Step 3: Check endpoints
echo "3️⃣ Checking service endpoints..."
kubectl get endpoints -n $NAMESPACE
echo ""

# Check if endpoints are empty
EMPTY_ENDPOINTS=$(kubectl get endpoints -n $NAMESPACE -o json | jq -r '.items[] | select(.subsets == null or .subsets == []) | .metadata.name' 2>/dev/null || echo "")
if [ ! -z "$EMPTY_ENDPOINTS" ]; then
    echo -e "${RED}❌ Services with no endpoints (pods not matching selectors):${NC}"
    echo "$EMPTY_ENDPOINTS"
    echo ""
fi

# Step 4: Check network policy
echo "4️⃣ Checking network policy..."
NETPOL=$(kubectl get networkpolicy -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
if [ "$NETPOL" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Network policy found. Checking if it allows Traefik...${NC}"
    kubectl get networkpolicy -n $NAMESPACE
    echo ""
    echo "If 502 persists, try temporarily disabling network policy:"
    echo "  kubectl delete networkpolicy chat-app-network-policy -n $NAMESPACE"
    echo ""
fi

# Step 5: Check ingress
echo "5️⃣ Checking ingress..."
kubectl get ingress -n $NAMESPACE
echo ""
kubectl describe ingress chatapp-ingress -n $NAMESPACE | tail -20
echo ""

# Step 6: Check Traefik
echo "6️⃣ Checking Traefik status..."
TRF_POD=$(kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$TRF_POD" ]; then
    echo -e "${RED}❌ Traefik pod not found${NC}"
else
    echo "Traefik pod: $TRF_POD"
    kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik
    echo ""
fi

# Step 7: Test connectivity
echo "7️⃣ Testing service connectivity..."
if [ ! -z "$TRF_POD" ]; then
    echo "Testing from Traefik pod..."
    
    echo -n "  Frontend: "
    kubectl exec -n kube-system $TRF_POD -- wget -qO- --timeout=5 http://frontend.$NAMESPACE.svc.cluster.local:80 > /dev/null 2>&1 && echo -e "${GREEN}✓ OK${NC}" || echo -e "${RED}✗ FAILED${NC}"
    
    echo -n "  Backend: "
    kubectl exec -n kube-system $TRF_POD -- wget -qO- --timeout=5 http://backend.$NAMESPACE.svc.cluster.local:5001/health > /dev/null 2>&1 && echo -e "${GREEN}✓ OK${NC}" || echo -e "${RED}✗ FAILED${NC}"
    
    echo -n "  Socket Service: "
    kubectl exec -n kube-system $TRF_POD -- wget -qO- --timeout=5 http://socket-service.$NAMESPACE.svc.cluster.local:5004/health > /dev/null 2>&1 && echo -e "${GREEN}✓ OK${NC}" || echo -e "${RED}✗ FAILED${NC}"
    echo ""
fi

# Step 8: Recommendations
echo "📋 Recommendations:"
echo ""
echo "1. Apply updated network policy:"
echo "   kubectl apply -f k8s/network-policy.yml"
echo ""
echo "2. If network policy is blocking, temporarily disable it:"
echo "   kubectl delete networkpolicy chat-app-network-policy -n $NAMESPACE"
echo ""
echo "3. Restart deployments:"
echo "   kubectl rollout restart deployment/frontend-deployment -n $NAMESPACE"
echo "   kubectl rollout restart deployment/backend-deployment -n $NAMESPACE"
echo "   kubectl rollout restart deployment/socket-service-deployment -n $NAMESPACE"
echo ""
echo "4. Check Traefik logs:"
echo "   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik --tail=50"
echo ""
echo "5. Check frontend logs:"
echo "   kubectl logs -n $NAMESPACE -l app=frontend --tail=50"
echo ""

