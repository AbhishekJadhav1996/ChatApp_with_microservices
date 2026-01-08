# 🚀 Production Deployment Guide

This guide provides detailed step-by-step instructions for deploying the Chat Application to production using Kubernetes.

## 🎯 Quick Links

- **For K3S on EC2**: See [K3S-DEPLOYMENT.md](./K3S-DEPLOYMENT.md) for complete EC2 setup, security group configuration, and K3S-specific instructions
- **For other Kubernetes clusters**: Follow this guide

## 📋 Pre-Deployment Checklist

- [ ] Kubernetes cluster (v1.24+) is running
  - **K3S on EC2**: See [K3S-DEPLOYMENT.md](./K3S-DEPLOYMENT.md) for installation
  - **Other clusters**: Ensure cluster is accessible via kubectl
- [ ] kubectl is configured and connected to cluster
- [ ] Docker images are built and pushed to registry (or available locally for K3S)
- [ ] Ingress controller is installed (NGINX Ingress recommended)
- [ ] Metrics Server is installed (required for HPA)
- [ ] MongoDB credentials are ready
- [ ] Cloudinary credentials are ready
- [ ] JWT secret is generated
- [ ] **For EC2**: Security groups configured with required ports (see [K3S-DEPLOYMENT.md](./K3S-DEPLOYMENT.md))

## 🏗️ Step-by-Step Deployment

### Phase 1: Infrastructure Setup

#### 1.1 Create Namespace

```bash
kubectl apply -f k8s/namespace.yml
```

Verify:
```bash
kubectl get namespace chat-app
```

#### 1.2 Create Secrets

```bash
# Generate base64 encoded secrets
echo -n 'your-jwt-secret' | base64
echo -n 'your-cloudinary-cloud-name' | base64
echo -n 'your-cloudinary-api-key' | base64
echo -n 'your-cloudinary-api-secret' | base64

# Update k8s/secrets.yml with encoded values, then apply
kubectl apply -f k8s/secrets.yml
```

Or create directly:
```bash
kubectl create secret generic chatapp-secrets \
  --from-literal=jwt='your-jwt-secret-key' \
  --from-literal=cloudinary-cloud-name='your-cloud-name' \
  --from-literal=cloudinary-api-key='your-api-key' \
  --from-literal=cloudinary-api-secret='your-api-secret' \
  -n chat-app
```

Verify:
```bash
kubectl get secrets -n chat-app
```

### Phase 2: Database Deployment

#### 2.1 Deploy MongoDB Persistent Volume

```bash
kubectl apply -f k8s/mongodb-pv.yml
kubectl apply -f k8s/mongodb-pvc.yml
```

Verify:
```bash
kubectl get pv
kubectl get pvc -n chat-app
```

#### 2.2 Deploy MongoDB

```bash
kubectl apply -f k8s/mongodb-deployment.yml
kubectl apply -f k8s/mongodb-service.yml
```

Wait for MongoDB to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=mongodb -n chat-app --timeout=300s
```

Verify:
```bash
kubectl get pods -l app=mongodb -n chat-app
kubectl logs -l app=mongodb -n chat-app
```

### Phase 3: Microservices Deployment

#### 3.1 Deploy Auth Service

```bash
kubectl apply -f k8s/auth-service-deployment.yml
kubectl apply -f k8s/auth-service-service.yml
kubectl apply -f k8s/auth-service-hpa.yml
```

Wait for pods:
```bash
kubectl wait --for=condition=ready pod -l app=auth-service -n chat-app --timeout=300s
```

Verify:
```bash
kubectl get pods -l app=auth-service -n chat-app
kubectl get svc auth-service -n chat-app
kubectl get hpa auth-service-hpa -n chat-app
```

#### 3.2 Deploy User Service

```bash
kubectl apply -f k8s/user-service-deployment.yml
kubectl apply -f k8s/user-service-service.yml
kubectl apply -f k8s/user-service-hpa.yml
```

Wait and verify:
```bash
kubectl wait --for=condition=ready pod -l app=user-service -n chat-app --timeout=300s
kubectl get pods -l app=user-service -n chat-app
```

#### 3.3 Deploy Message Service

```bash
kubectl apply -f k8s/message-service-deployment.yml
kubectl apply -f k8s/message-service-service.yml
kubectl apply -f k8s/message-service-hpa.yml
```

Wait and verify:
```bash
kubectl wait --for=condition=ready pod -l app=message-service -n chat-app --timeout=300s
kubectl get pods -l app=message-service -n chat-app
```

#### 3.4 Deploy Socket Service

```bash
kubectl apply -f k8s/socket-service-deployment.yml
kubectl apply -f k8s/socket-service-service.yml
kubectl apply -f k8s/socket-service-hpa.yml
```

Wait and verify:
```bash
kubectl wait --for=condition=ready pod -l app=socket-service -n chat-app --timeout=300s
kubectl get pods -l app=socket-service -n chat-app
```

#### 3.5 Deploy API Gateway

```bash
kubectl apply -f k8s/api-gateway-deployment.yml
kubectl apply -f k8s/api-gateway-service.yml
kubectl apply -f k8s/api-gateway-hpa.yml
```

Wait and verify:
```bash
kubectl wait --for=condition=ready pod -l app=api-gateway -n chat-app --timeout=300s
kubectl get pods -l app=api-gateway -n chat-app
```

### Phase 4: Frontend Deployment

#### 4.1 Deploy Frontend

```bash
kubectl apply -f k8s/frontend-deployment.yml
kubectl apply -f k8s/frontend-service.yml
```

Wait and verify:
```bash
kubectl wait --for=condition=ready pod -l app=frontend -n chat-app --timeout=300s
kubectl get pods -l app=frontend -n chat-app
```

### Phase 5: Networking & Ingress

#### 5.1 Deploy Ingress

```bash
kubectl apply -f k8s/ingress.yml
kubectl apply -f k8s/socket-service-ingress.yml
```

Verify:
```bash
kubectl get ingress -n chat-app
```

#### 5.2 Configure DNS (if using custom domain)

Update your DNS records to point to the ingress IP:
```bash
# Get ingress IP
kubectl get ingress -n chat-app

# Add A record: chat-tws.com -> <ingress-ip>
```

### Phase 6: High Availability & Fault Tolerance

**Note:** HPA is automatically deployed with each service (in Phase 3). It starts working immediately and requires no manual configuration!

#### 6.1 Verify HPA is Working

```bash
# Check HPA status
kubectl get hpa -n chat-app

# Verify metrics-server is installed (required for HPA)
kubectl get deployment metrics-server -n kube-system

# If metrics-server is missing, install it:
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Watch HPA in action
watch kubectl get hpa -n chat-app
```

#### 6.2 Deploy Pod Disruption Budgets

```bash
kubectl apply -f k8s/pod-disruption-budget.yml
```

Verify:
```bash
kubectl get pdb -n chat-app
```

#### 6.3 Deploy Network Policies

```bash
kubectl apply -f k8s/network-policy.yml
```

Verify:
```bash
kubectl get networkpolicies -n chat-app
```

### Phase 7: Verification & Testing

#### 7.1 Check All Resources

```bash
# Check all pods
kubectl get pods -n chat-app

# Check all services
kubectl get svc -n chat-app

# Check all deployments
kubectl get deployments -n chat-app

# Check HPA
kubectl get hpa -n chat-app

# Check ingress
kubectl get ingress -n chat-app
```

#### 7.2 Test Health Endpoints

```bash
# Get service IPs
AUTH_IP=$(kubectl get svc auth-service -n chat-app -o jsonpath='{.spec.clusterIP}')
USER_IP=$(kubectl get svc user-service -n chat-app -o jsonpath='{.spec.clusterIP}')
MESSAGE_IP=$(kubectl get svc message-service -n chat-app -o jsonpath='{.spec.clusterIP}')
SOCKET_IP=$(kubectl get svc socket-service -n chat-app -o jsonpath='{.spec.clusterIP}')
GATEWAY_IP=$(kubectl get svc api-gateway -n chat-app -o jsonpath='{.spec.clusterIP}')

# Test from within cluster
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- \
  curl http://$AUTH_IP:5001/health
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- \
  curl http://$GATEWAY_IP:5000/health
```

#### 7.3 Test Application

1. Access frontend via ingress
2. Create a test account
3. Send test messages
4. Verify real-time updates

## 🔄 Update Deployment

### Rolling Update

```bash
# Update image
kubectl set image deployment/auth-service-deployment \
  auth-service=abhishekjadhav1996/chatapp-auth-service:v1.1.0 -n chat-app

# Watch rollout
kubectl rollout status deployment/auth-service-deployment -n chat-app

# Check rollout history
kubectl rollout history deployment/auth-service-deployment -n chat-app

# Rollback if needed
kubectl rollout undo deployment/auth-service-deployment -n chat-app
```

### Blue-Green Deployment

1. Deploy green version:
```bash
kubectl apply -f k8s/blue-green-deployment.yml
```

2. Test green version:
```bash
kubectl port-forward svc/auth-service-green 5001:5001 -n chat-app
# Test locally
```

3. Switch traffic:
```bash
kubectl patch svc auth-service -n chat-app \
  -p '{"spec":{"selector":{"version":"green"}}}'
```

4. Monitor and rollback if needed:
```bash
kubectl patch svc auth-service -n chat-app \
  -p '{"spec":{"selector":{"version":"blue"}}}'
```

## 📊 Monitoring Commands

### Check Pod Status

```bash
# All pods
kubectl get pods -n chat-app -o wide

# Pods with resource usage
kubectl top pods -n chat-app

# Detailed pod info
kubectl describe pod <pod-name> -n chat-app
```

### Check HPA

```bash
# HPA status
kubectl get hpa -n chat-app

# HPA details
kubectl describe hpa auth-service-hpa -n chat-app

# Watch HPA
watch kubectl get hpa -n chat-app
```

### Check Logs

```bash
# Single pod logs
kubectl logs <pod-name> -n chat-app

# Deployment logs
kubectl logs -f deployment/auth-service-deployment -n chat-app

# All pods logs
kubectl logs -l app=auth-service -n chat-app --tail=100
```

### Check Events

```bash
# Recent events
kubectl get events -n chat-app --sort-by='.lastTimestamp'

# Filter by resource
kubectl get events -n chat-app --field-selector involvedObject.name=auth-service-deployment
```

## 🧹 Cleanup

### Remove All Resources

```bash
# Delete all resources in namespace
kubectl delete all --all -n chat-app

# Delete namespace (removes everything)
kubectl delete namespace chat-app

# Delete persistent volumes
kubectl delete pv mongodb-pv
```

## 🚨 Troubleshooting

### Pods in CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name> -n chat-app --previous

# Check events
kubectl describe pod <pod-name> -n chat-app

# Common issues:
# - Wrong image tag
# - Missing secrets
# - Database connection issues
# - Resource limits too low
```

### Services Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n chat-app

# Test service from pod
kubectl run -it --rm test --image=busybox --restart=Never -- \
  wget -qO- http://auth-service:5001/health

# Check service selector matches pod labels
kubectl describe svc auth-service -n chat-app
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl top nodes

# If metrics not available, install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check HPA events
kubectl describe hpa auth-service-hpa -n chat-app
```

## 📈 Performance Tuning

### Adjust Resource Limits

Edit deployment files and update:
```yaml
resources:
  requests:
    memory: "256Mi"  # Increase for high traffic
    cpu: "200m"
  limits:
    memory: "1Gi"    # Increase for high traffic
    cpu: "1000m"
```

Then apply:
```bash
kubectl apply -f k8s/auth-service-deployment.yml
```

### Adjust HPA Thresholds

Edit HPA files and update:
```yaml
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      averageUtilization: 60  # Lower = scale earlier
```

Then apply:
```bash
kubectl apply -f k8s/auth-service-hpa.yml
```

## ✅ Post-Deployment Checklist

- [ ] All pods are running
- [ ] All services are accessible
- [ ] HPA is configured and working
- [ ] Health endpoints respond correctly
- [ ] Frontend is accessible via ingress
- [ ] Real-time messaging works
- [ ] User authentication works
- [ ] Profile uploads work
- [ ] Monitoring is set up
- [ ] Logs are being collected
- [ ] Backup strategy is in place

---

**Congratulations! Your production-grade microservices chat application is now deployed! 🎉**

