#!/bin/bash

# Build Docker Images for All Microservices
# Usage: ./scripts/build-images.sh [registry] [tag]

set -e

REGISTRY=${1:-chatapp}
TAG=${2:-latest}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."

echo "🐳 Building Docker images..."
echo "Registry: $REGISTRY"
echo "Tag: $TAG"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Build Auth Service
echo -e "${YELLOW}Building Auth Service...${NC}"
docker build -t "$REGISTRY/auth-service:$TAG" "$PROJECT_DIR/services/auth-service"

# Build User Service
echo -e "${YELLOW}Building User Service...${NC}"
docker build -t "$REGISTRY/user-service:$TAG" "$PROJECT_DIR/services/user-service"

# Build Message Service
echo -e "${YELLOW}Building Message Service...${NC}"
docker build -t "$REGISTRY/message-service:$TAG" "$PROJECT_DIR/services/message-service"

# Build Socket Service
echo -e "${YELLOW}Building Socket Service...${NC}"
docker build -t "$REGISTRY/socket-service:$TAG" "$PROJECT_DIR/services/socket-service"

# Build API Gateway
echo -e "${YELLOW}Building API Gateway...${NC}"
docker build -t "$REGISTRY/api-gateway:$TAG" "$PROJECT_DIR/services/api-gateway"

# Build Frontend
echo -e "${YELLOW}Building Frontend...${NC}"
docker build -t "$REGISTRY/frontend:$TAG" "$PROJECT_DIR/frontend"

echo -e "${GREEN}✅ All images built successfully!${NC}"
echo ""
echo "Images:"
docker images | grep "$REGISTRY"

# If using Minikube, load images
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo ""
    echo "📦 Loading images into Minikube..."
    minikube image load "$REGISTRY/auth-service:$TAG"
    minikube image load "$REGISTRY/user-service:$TAG"
    minikube image load "$REGISTRY/message-service:$TAG"
    minikube image load "$REGISTRY/socket-service:$TAG"
    minikube image load "$REGISTRY/api-gateway:$TAG"
    minikube image load "$REGISTRY/frontend:$TAG"
    echo -e "${GREEN}✅ Images loaded into Minikube${NC}"
fi

