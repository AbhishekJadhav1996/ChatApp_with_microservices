# 🚀 Production-Grade Microservices Chat Application

A modern, scalable real-time chat application built with microservices architecture, featuring stunning UI, Kubernetes orchestration, and production-grade deployment strategies.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Microservices Architecture](#microservices-architecture)
- [Production Features](#production-features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Deployment Strategies](#deployment-strategies)
- [Monitoring & Scaling](#monitoring--scaling)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview

```
┌─────────────┐
│   Frontend  │ (React + TailwindCSS)
│   (Port 80) │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│         API Gateway (Port 5000)          │
└──────┬──────────────────────────────────┘
       │
       ├──────────┬──────────┬──────────┬──────────┐
       ▼          ▼          ▼          ▼          ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│   Auth   │ │   User   │ │ Message  │ │  Socket  │ │ MongoDB  │
│ Service  │ │ Service  │ │ Service  │ │ Service  │ │          │
│  :5001   │ │  :5002   │ │  :5003   │ │  :5004   │ │  :27017  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
```

## ✨ Features

### Application Features
- ✅ **Real-time Messaging**: Instant message delivery using Socket.io
- ✅ **User Authentication**: Secure JWT-based authentication
- ✅ **Profile Management**: Upload and update profile pictures
- ✅ **Online Status**: Real-time online/offline user tracking
- ✅ **Modern UI**: Stunning design with gradients, animations, and glassmorphism effects
- ✅ **Responsive Design**: Works seamlessly on all devices

### Production Features
- ✅ **Microservices Architecture**: 5 independent services
- ✅ **Horizontal Pod Autoscaling (HPA)**: Auto-scales up to 300% (2-9 replicas)
- ✅ **Zero-Downtime Deployments**: Rolling updates with maxSurge and maxUnavailable
- ✅ **Blue-Green Deployments**: Instant rollback capability
- ✅ **Canary Releases**: Gradual traffic shifting
- ✅ **Resource Limits**: CPU and memory constraints
- ✅ **Health Probes**: Liveness, Readiness, and Startup probes
- ✅ **Pod Disruption Budgets**: Ensures high availability
- ✅ **Network Policies**: Secure inter-service communication
- ✅ **Fault Tolerance**: Multiple replicas with health checks

## 🛠️ Tech Stack

### Frontend
- **React 18** - UI framework
- **TailwindCSS** - Styling
- **DaisyUI** - Component library
- **Zustand** - State management
- **Socket.io Client** - Real-time communication
- **Axios** - HTTP client

### Backend (Microservices)
- **Node.js 18** - Runtime
- **Express** - Web framework
- **MongoDB** - Database
- **Socket.io** - WebSocket server
- **JWT** - Authentication
- **Cloudinary** - Image storage

### Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **Nginx** - Reverse proxy
- **HPA** - Auto-scaling
- **Ingress** - Load balancing

## 🔧 Microservices Architecture

### 1. **Auth Service** (Port 5001)
- Handles user authentication (signup, login, logout)
- JWT token generation and validation
- User session management

### 2. **User Service** (Port 5002)
- User profile management
- Get users list for sidebar
- Profile picture uploads

### 3. **Message Service** (Port 5003)
- Message CRUD operations
- Image message handling
- Integrates with Socket Service for real-time updates

### 4. **Socket Service** (Port 5004)
- WebSocket connections management
- Online user tracking
- Real-time message broadcasting

### 5. **API Gateway** (Port 5000)
- Single entry point for all API requests
- Routes requests to appropriate services
- Handles CORS and cookie forwarding

## 🚀 Production Features

### Horizontal Pod Autoscaler (HPA) - **Fully Automatic**
- ✅ **Automatic Scaling**: No manual intervention required - HPA works continuously
- **Scaling Range**: 2-6 replicas (Auth, User, Gateway), 2-9 replicas (Message, Socket)
- **Scaling Triggers**: CPU (70%) and Memory (80%) utilization
- **Scaling Speed**: Up to 100% increase per 15 seconds
- **Scale Down**: 50% decrease per 60 seconds with 5-minute stabilization
- **How it Works**: 
  - Metrics-server collects resource usage every 15 seconds
  - HPA controller evaluates metrics every 15 seconds
  - Pods are automatically created/deleted based on load
  - No manual scaling needed - completely hands-off!

### Zero-Downtime Rolling Deployments
- **Strategy**: RollingUpdate
- **maxSurge**: 2 pods (allows new pods before terminating old ones)
- **maxUnavailable**: 0 (ensures at least one pod is always available)

### Health Probes
- **Liveness Probe**: Restarts unhealthy pods
- **Readiness Probe**: Routes traffic only to ready pods
- **Startup Probe**: Handles slow-starting containers

### Resource Management
- **CPU Requests**: 100-200m
- **CPU Limits**: 500-1000m
- **Memory Requests**: 128-256Mi
- **Memory Limits**: 512Mi-1Gi

## 📦 Prerequisites

### Required Software
- **Docker** (v20.10+)
- **Docker Compose** (v2.0+)
- **Kubernetes** (v1.24+) - For production deployment
- **kubectl** - Kubernetes CLI
- **Node.js** (v18+) - For local development
- **Git** - Version control

### Kubernetes Cluster Options
- **Local/EC2**: K3S (lightweight Kubernetes - recommended for EC2)
- **Local**: Kind, or Docker Desktop Kubernetes
- **Cloud**: AWS EKS, Google GKE, Azure AKS
- **Ingress Controller**: NGINX Ingress Controller

## 🏃 Quick Start

### Option 1: Docker Compose (Development)

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/full-stack_chatApp.git
cd full-stack_chatApp
```

2. **Build and start all services**
```bash
docker-compose -f docker-compose.microservices.yml up -d --build
```

3. **Access the application**
- Frontend: http://localhost
- API Gateway: http://localhost:5000
- Health Checks:
  - Auth Service: http://localhost:5001/health
  - User Service: http://localhost:5002/health
  - Message Service: http://localhost:5003/health
  - Socket Service: http://localhost:5004/health

### Option 2: Local Development

1. **Start MongoDB**
```bash
docker run -d -p 27017:27017 --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  mongo:7
```

2. **Start each service** (in separate terminals)
```bash
# Auth Service
cd services/auth-service
npm install
npm run dev

# User Service
cd services/user-service
npm install
npm run dev

# Message Service
cd services/message-service
npm install
npm run dev

# Socket Service
cd services/socket-service
npm install
npm run dev

# API Gateway
cd services/api-gateway
npm install
npm run dev

# Frontend
cd frontend
npm install
npm run dev
```

## ☸️ Kubernetes Deployment

> **🚀 Deploying on EC2?** See the comprehensive [K3S-DEPLOYMENT.md](./K3S-DEPLOYMENT.md) guide for:
> - Complete EC2 instance setup
> - Security group port configuration
> - K3S installation and configuration
> - Step-by-step deployment instructions
> - Troubleshooting guide

### Step 1: Prepare Kubernetes Cluster

#### For K3S (Recommended for EC2):
```bash
# Install K3S
curl -sfL https://get.k3s.io | sh -

# Configure kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
export KUBECONFIG=~/.kube/config

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Install Metrics Server (if not included)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**📖 For detailed EC2 setup instructions, see [K3S-DEPLOYMENT.md](./K3S-DEPLOYMENT.md)**

#### For Docker Desktop:
- Enable Kubernetes in Docker Desktop settings
- Install NGINX Ingress Controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

### Step 2: Build Docker Images

Build images for all services:

```bash
# Build and tag images
docker build -t abhishekjadhav1996/chatapp-auth-service:latest ./services/auth-service
docker build -t abhishekjadhav1996/chatapp-user-service:latest ./services/user-service
docker build -t abhishekjadhav1996/chatapp-message-service:latest ./services/message-service
docker build -t abhishekjadhav1996/chatapp-socket-service:latest ./services/socket-service
docker build -t abhishekjadhav1996/chatapp-api-gateway:latest ./services/api-gateway
docker build -t abhishekjadhav1996/chatapp-frontend:latest ./frontend

# For K3S on EC2, images are available locally after building
# For production, push images to Docker Hub or ECR (see K3S-DEPLOYMENT.md)
```

### Step 3: Create Secrets

```bash
# Create namespace
kubectl apply -f k8s/namespace.yml

# Create secrets (update with your actual values)
kubectl create secret generic chatapp-secrets \
  --from-literal=jwt='your-jwt-secret-key' \
  --from-literal=cloudinary-cloud-name='your-cloud-name' \
  --from-literal=cloudinary-api-key='your-api-key' \
  --from-literal=cloudinary-api-secret='your-api-secret' \
  -n chat-app
```

### Step 4: Deploy MongoDB

```bash
kubectl apply -f k8s/mongodb-pv.yml
kubectl apply -f k8s/mongodb-pvc.yml
kubectl apply -f k8s/mongodb-deployment.yml
kubectl apply -f k8s/mongodb-service.yml
```

### Step 5: Deploy Microservices

```bash
# Deploy all services
kubectl apply -f k8s/auth-service-deployment.yml
kubectl apply -f k8s/auth-service-service.yml
kubectl apply -f k8s/user-service-deployment.yml
kubectl apply -f k8s/user-service-service.yml
kubectl apply -f k8s/message-service-deployment.yml
kubectl apply -f k8s/message-service-service.yml
kubectl apply -f k8s/socket-service-deployment.yml
kubectl apply -f k8s/socket-service-service.yml
kubectl apply -f k8s/api-gateway-deployment.yml
kubectl apply -f k8s/api-gateway-service.yml
```

### Step 6: Deploy Frontend

```bash
kubectl apply -f k8s/frontend-deployment.yml
kubectl apply -f k8s/frontend-service.yml
```

### Step 7: Configure Ingress

```bash
kubectl apply -f k8s/ingress.yml
kubectl apply -f k8s/socket-service-ingress.yml
```

### Step 8: Enable Auto-Scaling (Automatic)

**HPA is automatically enabled during deployment!** The deployment script automatically applies HPA configurations. HPA will:

- ✅ **Automatically scale UP** when CPU > 70% or Memory > 80%
- ✅ **Automatically scale DOWN** when resources are underutilized
- ✅ **Work continuously** - no manual intervention needed
- ✅ **Maintain high availability** with minimum 2 replicas

To verify HPA is working:
```bash
# Check HPA status
kubectl get hpa -n chat-app

# Watch HPA in real-time
watch kubectl get hpa -n chat-app

# View detailed HPA metrics
kubectl describe hpa auth-service-hpa -n chat-app
```

**Note:** HPA requires metrics-server. The deployment script automatically installs it if missing.

### Step 9: Configure Pod Disruption Budgets

```bash
kubectl apply -f k8s/pod-disruption-budget.yml
```

### Step 10: Apply Network Policies

```bash
kubectl apply -f k8s/network-policy.yml
```

### Step 11: Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n chat-app

# Check services
kubectl get svc -n chat-app

# Check HPA status
kubectl get hpa -n chat-app

# Check ingress
kubectl get ingress -n chat-app

# View logs
kubectl logs -f deployment/auth-service-deployment -n chat-app
```

### Step 12: Access Application

```bash
# Get ingress external IP or NodePort
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Or get ingress hostname
kubectl get ingress -n chat-app

# For K3S on EC2, access via:
# http://<EC2_PUBLIC_IP>:<NODEPORT> or http://your-domain.com
# See K3S-DEPLOYMENT.md for detailed access instructions
```

## 🔄 Deployment Strategies

### Rolling Update (Default)

The default deployment uses RollingUpdate strategy:

```bash
# Update image
kubectl set image deployment/auth-service-deployment \
  auth-service=abhishekjadhav1996/chatapp-auth-service:v1.1.0 -n chat-app

# Watch rollout
kubectl rollout status deployment/auth-service-deployment -n chat-app

# Rollback if needed
kubectl rollout undo deployment/auth-service-deployment -n chat-app
```

### Blue-Green Deployment

1. **Deploy Green Version**
```bash
# Update blue-green-deployment.yml with new image version
kubectl apply -f k8s/blue-green-deployment.yml
```

2. **Switch Traffic**
```bash
# Update service selector to point to green
kubectl patch svc auth-service -n chat-app -p '{"spec":{"selector":{"version":"green"}}}'
```

3. **Rollback to Blue** (if needed)
```bash
kubectl patch svc auth-service -n chat-app -p '{"spec":{"selector":{"version":"blue"}}}'
```

### Canary Deployment

1. **Deploy Canary Version**
```bash
# Update canary-deployment.yml with new image
kubectl apply -f k8s/canary-deployment.yml
```

2. **Monitor Canary** (25% traffic)
```bash
# Check canary pod logs
kubectl logs -f deployment/auth-service-canary -n chat-app

# Check metrics
kubectl top pods -n chat-app
```

3. **Promote to Stable** (if successful)
```bash
# Scale up canary, scale down stable
kubectl scale deployment/auth-service-canary --replicas=3 -n chat-app
kubectl scale deployment/auth-service-stable --replicas=0 -n chat-app
```

## 📊 Monitoring & Scaling

### Check HPA Status

```bash
# View HPA details
kubectl describe hpa auth-service-hpa -n chat-app

# Watch HPA in real-time
watch kubectl get hpa -n chat-app
```

### Manual Scaling

```bash
# Scale a deployment manually
kubectl scale deployment/auth-service-deployment --replicas=4 -n chat-app
```

### Resource Usage

```bash
# View resource usage
kubectl top pods -n chat-app
kubectl top nodes

# View resource limits
kubectl describe pod <pod-name> -n chat-app
```

### Load Testing

```bash
# Install hey (load testing tool)
# macOS: brew install hey
# Linux: wget https://github.com/rakyll/hey/releases/download/v0.1.4/hey_linux_amd64

# Test API Gateway
hey -n 10000 -c 100 http://<ingress-ip>/api/auth/check

# Monitor HPA scaling
watch kubectl get hpa -n chat-app
```

## 🔍 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n chat-app

# Describe pod for details
kubectl describe pod <pod-name> -n chat-app

# Check logs
kubectl logs <pod-name> -n chat-app

# Check events
kubectl get events -n chat-app --sort-by='.lastTimestamp'
```

### Services Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n chat-app

# Test service connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -qO- http://auth-service:5001/health
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl top nodes

# Verify HPA configuration
kubectl describe hpa auth-service-hpa -n chat-app

# Check resource usage
kubectl top pods -n chat-app
```

### Database Connection Issues

```bash
# Check MongoDB pod
kubectl get pods -l app=mongodb -n chat-app

# Check MongoDB logs
kubectl logs -l app=mongodb -n chat-app

# Test MongoDB connection
kubectl run -it --rm mongo-client --image=mongo:7 --restart=Never -- \
  mongo mongodb://mongoadmin:secret@mongodb:27017/dbname?authSource=admin
```

### Ingress Not Working

```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress status
kubectl describe ingress chatapp-ingress -n chat-app

# Test ingress
curl -H "Host: chat-tws.com" http://<ingress-ip>/
```

## 📈 Performance Optimization

### Resource Tuning

Adjust resource requests/limits based on your workload:

```yaml
resources:
  requests:
    memory: "256Mi"  # Increase for high traffic
    cpu: "200m"
  limits:
    memory: "1Gi"    # Increase for high traffic
    cpu: "1000m"
```

### HPA Tuning

Adjust HPA thresholds for faster/slower scaling:

```yaml
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      averageUtilization: 60  # Lower = scale earlier
```

### Database Optimization

- Enable MongoDB replica set for high availability
- Configure connection pooling
- Add indexes for frequently queried fields

## 🔐 Security Best Practices

1. **Secrets Management**: Use Kubernetes Secrets or external secret managers
2. **Network Policies**: Restrict inter-pod communication
3. **RBAC**: Implement role-based access control
4. **TLS**: Enable TLS for all services
5. **Image Scanning**: Scan Docker images for vulnerabilities
6. **Resource Limits**: Prevent resource exhaustion attacks

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Microservices Patterns](https://microservices.io/patterns/)
- [HPA Best Practices](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License.

---

**Built with ❤️ using Microservices Architecture and Kubernetes**
