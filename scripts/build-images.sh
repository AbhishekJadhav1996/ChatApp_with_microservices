#!/bin/bash

# Build Docker Images for All Microservices
# Usage: ./scripts/build-images.sh [registry] [tag]

set -e

REGISTRY=${1:-abhishekjadhav1996}
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

# Build Backend (handles auth and messages APIs)
echo -e "${YELLOW}Building Backend...${NC}"
docker build -t "$REGISTRY/chatapp-backend:$TAG" "$PROJECT_DIR/backend"

# Build Socket Service (WebSocket connections)
echo -e "${YELLOW}Building Socket Service...${NC}"
docker build -t "$REGISTRY/chatapp-socket-service:$TAG" "$PROJECT_DIR/services/socket-service"

# Build Frontend
echo -e "${YELLOW}Building Frontend...${NC}"
docker build -t "$REGISTRY/chatapp-frontend:$TAG" "$PROJECT_DIR/frontend"

echo -e "${GREEN}✅ All images built successfully!${NC}"
echo ""
echo "Images:"
docker images | grep "$REGISTRY"

# For K3S on EC2, images are available locally after building
# For production, push images to Docker Hub or ECR
echo ""
echo "💡 Next steps:"
echo "   - For K3S: Images are ready to use locally"
echo "   - For production: Push images to Docker Hub or ECR"
echo "   - See K3S-DEPLOYMENT.md for detailed instructions"

