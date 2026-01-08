#!/bin/bash

# Health Check Script for All Services
# Usage: ./scripts/health-check.sh [namespace]

set -e

NAMESPACE=${1:-chat-app}

echo "🏥 Health Check for namespace: $NAMESPACE"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_service() {
    local service=$1
    local port=$2
    
    echo -n "Checking $service... "
    
    # Get service IP
    local ip=$(kubectl get svc "$service" -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    
    if [ -z "$ip" ]; then
        echo -e "${RED}❌ Service not found${NC}"
        return 1
    fi
    
    # Test health endpoint
    if kubectl run -it --rm "health-check-$service-$(date +%s)" \
        --image=curlimages/curl \
        --restart=Never \
        --quiet \
        -- curl -sf "http://$ip:$port/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Healthy${NC}"
        return 0
    else
        echo -e "${RED}❌ Unhealthy${NC}"
        return 1
    fi
}

# Check all services
check_service "backend" "5001"
check_service "socket-service" "5004"

echo ""
echo "📊 Pod Status:"
kubectl get pods -n "$NAMESPACE" -o wide

echo ""
echo "📈 HPA Status:"
kubectl get hpa -n "$NAMESPACE"

echo ""
echo "🌐 Service Endpoints:"
kubectl get endpoints -n "$NAMESPACE"

