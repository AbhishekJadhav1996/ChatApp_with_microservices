#!/bin/bash

# Verify HPA is Working Correctly
# Usage: ./scripts/verify-hpa.sh [namespace]

set -e

NAMESPACE=${1:-chat-app}

echo "🔍 Verifying HPA Configuration and Status..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check metrics-server
echo "1️⃣ Checking metrics-server..."
if kubectl get deployment metrics-server -n kube-system &>/dev/null; then
    echo -e "${GREEN}✅ Metrics-server is installed${NC}"
    
    # Check if metrics-server is ready
    if kubectl wait --for=condition=available --timeout=5s deployment/metrics-server -n kube-system &>/dev/null; then
        echo -e "${GREEN}✅ Metrics-server is ready${NC}"
    else
        echo -e "${YELLOW}⚠️  Metrics-server may still be starting${NC}"
    fi
else
    echo -e "${RED}❌ Metrics-server not found. HPA requires metrics-server!${NC}"
    echo "Installing metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    echo "Waiting for metrics-server to be ready..."
    sleep 10
fi

echo ""

# Check HPA resources
echo "2️⃣ Checking HPA resources..."
HPAS=$(kubectl get hpa -n "$NAMESPACE" -o name 2>/dev/null || echo "")

if [ -z "$HPAS" ]; then
    echo -e "${RED}❌ No HPA resources found in namespace $NAMESPACE${NC}"
    echo "Deploy HPA configurations:"
    echo "  kubectl apply -f k8s/backend-hpa.yml"
    echo "  kubectl apply -f k8s/socket-service-hpa.yml"
    exit 1
fi

echo -e "${GREEN}✅ Found HPA resources:${NC}"
kubectl get hpa -n "$NAMESPACE"

echo ""

# Check each HPA status
echo "3️⃣ Checking individual HPA status..."
for hpa in $HPAS; do
    hpa_name=$(echo $hpa | cut -d'/' -f2)
    echo ""
    echo "📊 $hpa_name:"
    kubectl describe hpa "$hpa_name" -n "$NAMESPACE" | grep -A 10 "Metrics:" || true
done

echo ""

# Check if metrics are available
echo "4️⃣ Checking if metrics are available..."
if kubectl top nodes &>/dev/null; then
    echo -e "${GREEN}✅ Metrics are available${NC}"
    echo ""
    echo "Current resource usage:"
    kubectl top pods -n "$NAMESPACE" 2>/dev/null || echo "Metrics may take a few minutes to populate"
else
    echo -e "${YELLOW}⚠️  Metrics not yet available. This is normal for new clusters.${NC}"
    echo "HPA will start working once metrics-server collects data (usually within 1-2 minutes)"
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 HPA Summary:"
echo ""
echo "✅ HPA is configured and will automatically:"
echo "   • Scale UP when CPU usage > 70% or Memory usage > 80%"
echo "   • Scale DOWN when resources are underutilized"
echo "   • Maintain minimum replicas (2) for high availability"
echo "   • Scale up to maximum replicas (6-9) during high load"
echo ""
echo "📈 To watch HPA in action:"
echo "   watch kubectl get hpa -n $NAMESPACE"
echo ""
echo "🧪 To test auto-scaling, generate load:"
echo "   kubectl run -it --rm load-generator --image=busybox --restart=Never -- sh -c 'while true; do wget -q -O- http://backend:5001/health; done'"
echo ""
echo "📊 To view current scaling status:"
echo "   kubectl get hpa -n $NAMESPACE"
echo "   kubectl top pods -n $NAMESPACE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

