#!/bin/bash

# Cleanup script to remove old microservice deployments
# Usage: ./scripts/cleanup-old-deployments.sh [namespace]

set -e

NAMESPACE=${1:-chat-app}

echo "🧹 Cleaning up old microservice deployments..."
echo "Namespace: $NAMESPACE"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Delete old deployments
echo ""
echo "Deleting old deployments..."

OLD_DEPLOYMENTS=(
  "api-gateway-deployment"
  "auth-service-deployment"
  "user-service-deployment"
  "message-service-deployment"
)

for deployment in "${OLD_DEPLOYMENTS[@]}"; do
  if kubectl get deployment "$deployment" -n "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}Deleting $deployment...${NC}"
    kubectl delete deployment "$deployment" -n "$NAMESPACE" || true
  else
    echo -e "${GREEN}$deployment not found (already deleted)${NC}"
  fi
done

# Delete old services
echo ""
echo "Deleting old services..."

OLD_SERVICES=(
  "api-gateway"
  "auth-service"
  "user-service"
  "message-service"
)

for service in "${OLD_SERVICES[@]}"; do
  if kubectl get svc "$service" -n "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}Deleting service $service...${NC}"
    kubectl delete svc "$service" -n "$NAMESPACE" || true
  else
    echo -e "${GREEN}Service $service not found (already deleted)${NC}"
  fi
done

# Delete old HPA
echo ""
echo "Deleting old HPA resources..."

OLD_HPAS=(
  "api-gateway-hpa"
  "auth-service-hpa"
  "user-service-hpa"
  "message-service-hpa"
)

for hpa in "${OLD_HPAS[@]}"; do
  if kubectl get hpa "$hpa" -n "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}Deleting HPA $hpa...${NC}"
    kubectl delete hpa "$hpa" -n "$NAMESPACE" || true
  else
    echo -e "${GREEN}HPA $hpa not found (already deleted)${NC}"
  fi
done

echo ""
echo -e "${GREEN}✅ Cleanup completed!${NC}"
echo ""
echo "Current deployments:"
kubectl get deployments -n "$NAMESPACE"
echo ""
echo "Current pods:"
kubectl get pods -n "$NAMESPACE"

