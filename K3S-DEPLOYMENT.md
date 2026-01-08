# 🚀 K3S Deployment Guide for EC2

Complete guide for deploying the Chat Application on AWS EC2 using K3S (lightweight Kubernetes).

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [EC2 Instance Setup](#ec2-instance-setup)
- [Security Group Configuration](#security-group-configuration)
- [K3S Installation](#k3s-installation)
- [Docker Image Management](#docker-image-management)
- [Deployment Steps](#deployment-steps)
- [Accessing the Application](#accessing-the-application)
- [Troubleshooting](#troubleshooting)
- [Maintenance & Updates](#maintenance--updates)

---

## 📦 Prerequisites

### Required Software on EC2 Instance

- **Ubuntu 20.04 LTS or later** (recommended)
- **Docker** (v20.10+)
- **kubectl** (v1.24+)
- **Git**
- **curl** or **wget**

### AWS Requirements

- EC2 instance with at least:
  - **2 vCPUs** (4+ recommended for production)
  - **4 GB RAM** (8 GB+ recommended for production)
  - **20 GB storage** (SSD recommended)
- Elastic IP (optional but recommended)
- Domain name (optional, for custom domain)

---

## 🖥️ EC2 Instance Setup

### Step 1: Launch EC2 Instance

1. **Go to AWS Console → EC2 → Launch Instance**
2. **Choose AMI**: Ubuntu Server 22.04 LTS (or 20.04 LTS)
3. **Instance Type**: 
   - **Development**: t3.medium (2 vCPU, 4 GB RAM)
   - **Production**: t3.large (2 vCPU, 8 GB RAM) or larger
4. **Storage**: 20 GB gp3 SSD (minimum)
5. **Security Group**: Create new or use existing (see Security Group Configuration below)
6. **Key Pair**: Create or select existing SSH key pair
7. **Launch Instance**

### Step 2: Connect to EC2 Instance

```bash
# Replace with your key file and instance IP
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### Step 3: Update System

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim
```

### Step 4: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add current user to docker group (to run docker without sudo)
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
docker --version
```

**Note**: You may need to log out and log back in for docker group changes to take effect.

### Step 5: Install kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

---

## 🔒 Security Group Configuration

### Required Ports for K3S and Application

Configure your EC2 Security Group with the following inbound rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | Your IP / 0.0.0.0/0 | SSH access (restrict to your IP for security) |
| HTTP | TCP | 80 | 0.0.0.0/0 | Frontend access via Ingress |
| HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS access (if using TLS) |
| Custom TCP | TCP | 6443 | Your IP / 0.0.0.0/0 | K3S API server (restrict if possible) |
| Custom TCP | TCP | 10250 | VPC CIDR / 10.0.0.0/16 | Kubelet API (internal only) |
| Custom TCP | TCP | 30000-32767 | 0.0.0.0/0 | NodePort Services range (if using NodePort) |
| Custom TCP | TCP | 5001 | 0.0.0.0/0 | Backend API (if exposing directly) |
| Custom TCP | TCP | 5004 | 0.0.0.0/0 | Socket Service (WebSocket) |

### Security Group Setup Steps

1. **Go to EC2 Console → Security Groups**
2. **Select your instance's security group**
3. **Click "Edit inbound rules"**
4. **Add the following rules**:

```
Rule 1: SSH
- Type: SSH
- Port: 22
- Source: Your IP address (recommended) or 0.0.0.0/0

Rule 2: HTTP
- Type: HTTP
- Port: 80
- Source: 0.0.0.0/0

Rule 3: HTTPS
- Type: HTTPS
- Port: 443
- Source: 0.0.0.0/0

Rule 4: K3S API Server
- Type: Custom TCP
- Port: 6443
- Source: Your IP or 0.0.0.0/0 (restrict if possible)

Rule 5: NodePort Range
- Type: Custom TCP
- Port: 30000-32767
- Source: 0.0.0.0/0

Rule 6: Backend API (Optional - if not using Ingress)
- Type: Custom TCP
- Port: 5001
- Source: 0.0.0.0/0

Rule 7: Socket Service (Optional - if not using Ingress)
- Type: Custom TCP
- Port: 5004
- Source: 0.0.0.0/0
```

### Security Best Practices

- **Restrict SSH (Port 22)** to your IP address only
- **Restrict K3S API (Port 6443)** to trusted IPs if possible
- **Use Ingress** instead of exposing services directly via NodePort
- **Enable HTTPS** with TLS certificates (Let's Encrypt recommended)
- **Use AWS WAF** for additional protection (optional)

---

## ☸️ K3S Installation

### Step 1: Install K3S

```bash
# Install K3S (single-node cluster)
curl -sfL https://get.k3s.io | sh -

# Verify K3S is running
sudo systemctl status k3s

# Check K3S version
k3s --version
```

### Step 2: Configure kubectl

```bash
# K3S automatically creates kubeconfig at /etc/rancher/k3s/k3s.yaml
# Copy it to your home directory
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Set KUBECONFIG environment variable
export KUBECONFIG=~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc

# Verify kubectl can connect
kubectl get nodes
kubectl get pods --all-namespaces
```

### Step 3: Verify Traefik Ingress Controller

K3S comes with Traefik by default, which is already configured and running:

```bash
# Verify Traefik is running
kubectl get pods -n kube-system | grep traefik

# Check Traefik service
kubectl get svc -n kube-system | grep traefik

# Traefik should be listening on port 80 and 443
# Access your application via http://<EC2_PUBLIC_IP> or your domain
```

**Note:** The ingress.yml file is configured for Traefik (K3S default). If you prefer NGINX Ingress, you'll need to:
1. Disable Traefik in K3S
2. Install NGINX Ingress Controller
3. Update ingress.yml annotations accordingly

### Step 4: Install Metrics Server (Required for HPA)

```bash
# K3S includes metrics-server, but verify it's running
kubectl get deployment metrics-server -n kube-system

# If not present, install it
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify metrics-server is working
kubectl top nodes
```

---

## 🐳 Docker Image Management

### Option 1: Build Images on EC2 (Recommended for Development)

```bash
# Clone the repository
git clone <your-repo-url>
cd Chat-App/ChatApp

# Build all images
./scripts/build-images.sh abhishekjadhav1996 latest

# Verify images
docker images | grep abhishekjadhav1996
```

### Option 2: Push to Docker Hub / ECR (Recommended for Production)

#### Using Docker Hub:

```bash
# Login to Docker Hub
docker login

# Images are already tagged with abhishekjadhav1996 during build
# If you built with a different tag, retag them:
# docker tag chatapp/backend:latest abhishekjadhav1996/chatapp-backend:latest
# docker tag chatapp/socket-service:latest abhishekjadhav1996/chatapp-socket-service:latest
# docker tag chatapp/frontend:latest abhishekjadhav1996/chatapp-frontend:latest

# Push images
docker push abhishekjadhav1996/chatapp-backend:latest
docker push abhishekjadhav1996/chatapp-socket-service:latest
docker push abhishekjadhav1996/chatapp-frontend:latest
```

#### Using AWS ECR:

```bash
# Install AWS CLI
sudo apt install -y awscli

# Configure AWS credentials
aws configure

# Create ECR repositories
aws ecr create-repository --repository-name chatapp/backend --region us-east-1
aws ecr create-repository --repository-name chatapp/socket-service --region us-east-1
aws ecr create-repository --repository-name chatapp/frontend --region us-east-1

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push images
ECR_REGISTRY=<your-account-id>.dkr.ecr.us-east-1.amazonaws.com

docker tag abhishekjadhav1996/chatapp-backend:latest $ECR_REGISTRY/chatapp/backend:latest
docker push $ECR_REGISTRY/chatapp/backend:latest

docker tag abhishekjadhav1996/chatapp-socket-service:latest $ECR_REGISTRY/chatapp/socket-service:latest
docker push $ECR_REGISTRY/chatapp/socket-service:latest

docker tag abhishekjadhav1996/chatapp-frontend:latest $ECR_REGISTRY/chatapp/frontend:latest
docker push $ECR_REGISTRY/chatapp/frontend:latest
```

### Update Kubernetes Manifests

If using a registry, update the image references in deployment files:

```bash
# Update image references in all deployment files (already configured for abhishekjadhav1996)
cd k8s
# Images are already configured to use abhishekjadhav1996/chatapp-* format
```

---

## 🚀 Deployment Steps

### Step 1: Clone Repository

```bash
cd ~
git clone <your-repo-url>
cd Chat-App/ChatApp
```

### Step 2: Create Namespace

```bash
kubectl apply -f k8s/namespace.yml
```

### Step 3: Create Secrets

```bash
# Create secrets with your actual values
kubectl create secret generic chatapp-secrets \
  --from-literal=jwt='your-super-secret-jwt-key-change-this' \
  --from-literal=cloudinary-cloud-name='your-cloudinary-cloud-name' \
  --from-literal=cloudinary-api-key='your-cloudinary-api-key' \
  --from-literal=cloudinary-api-secret='your-cloudinary-api-secret' \
  -n chat-app

# Verify secrets
kubectl get secrets -n chat-app
```

### Step 4: Deploy MongoDB

```bash
# Deploy MongoDB persistent volume and claim
kubectl apply -f k8s/mongodb-pv.yml
kubectl apply -f k8s/mongodb-pvc.yml

# Deploy MongoDB
kubectl apply -f k8s/mongodb-deployment.yml
kubectl apply -f k8s/mongodb-service.yml

# Wait for MongoDB to be ready
kubectl wait --for=condition=ready pod -l app=mongodb -n chat-app --timeout=300s

# Verify MongoDB
kubectl get pods -l app=mongodb -n chat-app
```

### Step 5: Deploy Microservices

```bash
# Deploy all services using the deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Or deploy manually:
# Deploy Backend (handles auth and messages APIs)
kubectl apply -f k8s/backend-deployment.yml
kubectl apply -f k8s/backend-service.yml
kubectl apply -f k8s/backend-hpa.yml

# Deploy Socket Service (WebSocket connections)
kubectl apply -f k8s/socket-service-deployment.yml
kubectl apply -f k8s/socket-service-service.yml
kubectl apply -f k8s/socket-service-hpa.yml
```

### Step 6: Deploy Frontend

```bash
kubectl apply -f k8s/frontend-deployment.yml
kubectl apply -f k8s/frontend-service.yml
```

### Step 7: Configure Ingress

```bash
# Update ingress.yml with your domain or IP
# Edit k8s/ingress.yml and update the host field

# Deploy ingress (routes /api to backend, /socket.io to socket-service, / to frontend)
kubectl apply -f k8s/ingress.yml

# Verify ingress
kubectl get ingress -n chat-app
```

### Step 8: Deploy Additional Resources

```bash
# Deploy Pod Disruption Budgets
kubectl apply -f k8s/pod-disruption-budget.yml

# Deploy Network Policies
kubectl apply -f k8s/network-policy.yml
```

### Step 9: Verify Deployment

```bash
# Check all pods
kubectl get pods -n chat-app

# Check services
kubectl get svc -n chat-app

# Check HPA
kubectl get hpa -n chat-app

# Check ingress
kubectl get ingress -n chat-app

# View logs
kubectl logs -f deployment/auth-service-deployment -n chat-app
```

---

## 🌐 Accessing the Application

### Option 1: Using Ingress (Recommended)

1. **Get Ingress External IP**:

```bash
# Get the external IP of the ingress controller
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Or get the NodePort
kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}'
```

2. **Access via EC2 Public IP**:

```
http://<EC2_PUBLIC_IP>:<NODEPORT>
```

3. **Configure DNS (Optional)**:

If you have a domain name:
- Point your domain's A record to your EC2 Elastic IP
- Update `k8s/ingress.yml` with your domain name
- Access via: `http://yourdomain.com`

### Option 2: Using Port Forwarding (For Testing)

```bash
# Forward frontend port
kubectl port-forward svc/frontend 8080:80 -n chat-app

# Access at http://localhost:8080
```

### Option 3: Using NodePort Services

If services are exposed via NodePort, access them directly:

```bash
# Get NodePort for frontend
kubectl get svc frontend -n chat-app

# Access at http://<EC2_PUBLIC_IP>:<NODEPORT>
```

---

## 🔧 Troubleshooting

### K3S Not Starting

```bash
# Check K3S status
sudo systemctl status k3s

# View K3S logs
sudo journalctl -u k3s -f

# Restart K3S
sudo systemctl restart k3s
```

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

### Ingress Not Working

```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress status
kubectl describe ingress chatapp-ingress -n chat-app

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Cannot Pull Images

```bash
# Check if images exist locally
docker images | grep abhishekjadhav1996

# If using registry, verify credentials
docker login

# Check image pull secrets
kubectl get secrets -n chat-app
```

### HPA Not Scaling

```bash
# Check metrics-server
kubectl top nodes
kubectl top pods -n chat-app

# Check HPA status
kubectl describe hpa auth-service-hpa -n chat-app

# Verify metrics-server is running
kubectl get deployment metrics-server -n kube-system
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

### Port Already in Use

```bash
# Check what's using a port
sudo netstat -tulpn | grep :6443

# Or use ss
sudo ss -tulpn | grep :6443
```

---

## 🔄 Maintenance & Updates

### Update Application

```bash
# Build new images
./scripts/build-images.sh abhishekjadhav1996 v1.1.0

# Update deployment
kubectl set image deployment/backend-deployment \
  chatapp-backend=abhishekjadhav1996/chatapp-backend:v1.1.0 -n chat-app

# Watch rollout
kubectl rollout status deployment/auth-service-deployment -n chat-app

# Rollback if needed
kubectl rollout undo deployment/auth-service-deployment -n chat-app
```

### Scale Services Manually

```bash
# Scale a service
kubectl scale deployment/auth-service-deployment --replicas=4 -n chat-app

# HPA will automatically adjust based on load
```

### Backup MongoDB

```bash
# Create backup pod
kubectl run mongodb-backup --image=mongo:7 --restart=Never -n chat-app -- \
  mongodump --host=mongodb:27017 --username=mongoadmin --password=secret \
  --authenticationDatabase=admin --out=/backup

# Copy backup from pod
kubectl cp chat-app/mongodb-backup:/backup ./mongodb-backup

# Cleanup
kubectl delete pod mongodb-backup -n chat-app
```

### Monitor Resources

```bash
# View resource usage
kubectl top nodes
kubectl top pods -n chat-app

# Watch HPA
watch kubectl get hpa -n chat-app

# View all resources
kubectl get all -n chat-app
```

### Cleanup

```bash
# Delete all resources in namespace
kubectl delete all --all -n chat-app

# Delete namespace
kubectl delete namespace chat-app

# Uninstall K3S (if needed)
sudo /usr/local/bin/k3s-uninstall.sh
```

---

## 📊 Performance Optimization

### Resource Recommendations

For production workloads, adjust resource limits in deployment files:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### HPA Tuning

Adjust HPA thresholds in HPA files for faster/slower scaling:

```yaml
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      averageUtilization: 60  # Lower = scale earlier
```

---

## 🔐 Security Best Practices

1. **Keep K3S Updated**: Regularly update K3S to latest version
2. **Use Secrets**: Never hardcode credentials in deployment files
3. **Restrict SSH**: Only allow SSH from trusted IPs
4. **Enable TLS**: Use Let's Encrypt for HTTPS
5. **Network Policies**: Use network policies to restrict pod communication
6. **Regular Backups**: Backup MongoDB data regularly
7. **Monitor Logs**: Set up log aggregation and monitoring
8. **Update Images**: Regularly update base images for security patches

---

## 📚 Additional Resources

- [K3S Documentation](https://docs.k3s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

---

## ✅ Deployment Checklist

- [ ] EC2 instance launched with appropriate size
- [ ] Security group configured with required ports
- [ ] Docker installed and configured
- [ ] K3S installed and running
- [ ] kubectl configured and working
- [ ] NGINX Ingress Controller installed
- [ ] Metrics Server installed and working
- [ ] Docker images built or pulled from registry
- [ ] Secrets created
- [ ] MongoDB deployed and running
- [ ] All microservices deployed
- [ ] Frontend deployed
- [ ] Ingress configured
- [ ] HPA verified and working
- [ ] Application accessible via browser
- [ ] Health checks passing
- [ ] Monitoring set up

---

**Congratulations! Your Chat Application is now running on K3S! 🎉**

For support or issues, check the troubleshooting section or review the logs.

