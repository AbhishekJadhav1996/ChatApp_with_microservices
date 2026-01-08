# ⚡ Quick Start Guide

## 🚀 Fastest Way to Deploy

### 1. Build All Images
```bash
./scripts/build-images.sh
```

### 2. Deploy Everything
```bash
./scripts/deploy.sh
```

### 3. Check Health
```bash
./scripts/health-check.sh
```

## 📋 Manual Deployment (Step by Step)

### Prerequisites
```bash
# Verify kubectl is configured
kubectl cluster-info

# Verify namespace exists
kubectl get namespace chat-app
```

### Create Secrets
```bash
kubectl create secret generic chatapp-secrets \
  --from-literal=jwt='your-jwt-secret' \
  --from-literal=cloudinary-cloud-name='your-cloud-name' \
  --from-literal=cloudinary-api-key='your-api-key' \
  --from-literal=cloudinary-api-secret='your-api-secret' \
  -n chat-app
```

### Deploy All Services
```bash
# MongoDB
kubectl apply -f k8s/mongodb-pv.yml
kubectl apply -f k8s/mongodb-pvc.yml
kubectl apply -f k8s/mongodb-deployment.yml
kubectl apply -f k8s/mongodb-service.yml

# Microservices
kubectl apply -f k8s/auth-service-deployment.yml
kubectl apply -f k8s/auth-service-service.yml
kubectl apply -f k8s/auth-service-hpa.yml

kubectl apply -f k8s/user-service-deployment.yml
kubectl apply -f k8s/user-service-service.yml
kubectl apply -f k8s/user-service-hpa.yml

kubectl apply -f k8s/message-service-deployment.yml
kubectl apply -f k8s/message-service-service.yml
kubectl apply -f k8s/message-service-hpa.yml

kubectl apply -f k8s/socket-service-deployment.yml
kubectl apply -f k8s/socket-service-service.yml
kubectl apply -f k8s/socket-service-hpa.yml

kubectl apply -f k8s/backend-deployment.yml
kubectl apply -f k8s/backend-service.yml
kubectl apply -f k8s/backend-hpa.yml

# Frontend
kubectl apply -f k8s/frontend-deployment.yml
kubectl apply -f k8s/frontend-service.yml

# Networking
kubectl apply -f k8s/ingress.yml
kubectl apply -f k8s/socket-service-ingress.yml

# High Availability
kubectl apply -f k8s/pod-disruption-budget.yml
kubectl apply -f k8s/network-policy.yml
```

### Verify Deployment
```bash
# Check pods
kubectl get pods -n chat-app

# Check services
kubectl get svc -n chat-app

# Check HPA
kubectl get hpa -n chat-app

# Check ingress
kubectl get ingress -n chat-app
```

## 🔍 Common Commands

### View Logs
```bash
kubectl logs -f deployment/auth-service-deployment -n chat-app
kubectl logs -f deployment/user-service-deployment -n chat-app
kubectl logs -f deployment/message-service-deployment -n chat-app
kubectl logs -f deployment/socket-service-deployment -n chat-app
kubectl logs -f deployment/backend-deployment -n chat-app
```

### Scale Manually
```bash
kubectl scale deployment/backend-deployment --replicas=4 -n chat-app
```

### Update Image
```bash
kubectl set image deployment/backend-deployment \
  chatapp-backend=abhishekjadhav1996/chatapp-backend:v1.1.0 -n chat-app
```

### Rollback
```bash
kubectl rollout undo deployment/backend-deployment -n chat-app
```

### Port Forward (for testing)
```bash
kubectl port-forward svc/backend 5001:5001 -n chat-app
kubectl port-forward svc/frontend 80:80 -n chat-app
```

## 🐳 Docker Compose (Development)

```bash
docker-compose -f docker-compose.microservices.yml up -d --build
```

Access:
- Frontend: http://localhost
- Backend API: http://localhost:5001

## 📊 Monitoring

### Check Resource Usage
```bash
kubectl top pods -n chat-app
kubectl top nodes
```

### Watch HPA
```bash
watch kubectl get hpa -n chat-app
```

### Describe Resources
```bash
kubectl describe deployment/backend-deployment -n chat-app
kubectl describe hpa backend-hpa -n chat-app
kubectl describe pod <pod-name> -n chat-app
```

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete all --all -n chat-app

# Delete namespace (removes everything)
kubectl delete namespace chat-app
```

## 🆘 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n chat-app
kubectl logs <pod-name> -n chat-app --previous
```

### Services Not Accessible
```bash
kubectl get endpoints -n chat-app
kubectl describe svc <service-name> -n chat-app
```

### HPA Not Scaling (HPA Works Automatically!)
```bash
# HPA works automatically - no manual intervention needed!
# View HPA status
kubectl get hpa -n chat-app

# Watch HPA scale in real-time
watch kubectl get hpa -n chat-app

# Verify metrics-server (required for HPA)
kubectl get deployment metrics-server -n kube-system

# Check current resource usage
kubectl top pods -n chat-app

# View detailed HPA metrics
kubectl describe hpa backend-hpa -n chat-app
```

**HPA automatically scales pods based on load - no manual commands needed!**

---

For detailed documentation, see [README.md](README.md) and [DEPLOYMENT.md](DEPLOYMENT.md)

