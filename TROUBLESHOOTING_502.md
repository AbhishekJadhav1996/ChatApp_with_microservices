# Troubleshooting 502 Bad Gateway Error

## Quick Diagnostic Steps

Run these commands to diagnose the issue:

```bash
# 1. Check if pods are running
kubectl get pods -n chat-app

# 2. Check frontend pod specifically
kubectl get pods -n chat-app -l app=frontend
kubectl describe pod -n chat-app -l app=frontend

# 3. Check frontend service endpoints
kubectl get endpoints frontend -n chat-app

# 4. Check if frontend pod is ready
kubectl get pods -n chat-app -l app=frontend -o jsonpath='{.items[0].status.conditions[*].status}'

# 5. Check frontend logs
kubectl logs -n chat-app -l app=frontend --tail=50

# 6. Check ingress status
kubectl describe ingress chatapp-ingress -n chat-app

# 7. Check Traefik logs
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik --tail=50

# 8. Test service connectivity from within cluster
kubectl run -it --rm test-frontend --image=busybox --restart=Never -n chat-app -- wget -qO- http://frontend:80/
```

## Common Causes and Fixes

### 1. Frontend Pod Not Ready

**Symptoms**: Pod shows `0/1 Ready` or `CrashLoopBackOff`

**Fix**:
```bash
# Check pod events
kubectl describe pod -n chat-app -l app=frontend

# Check logs
kubectl logs -n chat-app -l app=frontend

# Common issues:
# - Image pull errors: Rebuild and push image
# - Health check failures: Check if nginx is running on port 80
# - Resource limits: Check if pod has enough resources
```

### 2. Service Endpoints Empty

**Symptoms**: `kubectl get endpoints frontend -n chat-app` shows no endpoints

**Fix**:
```bash
# Check if service selector matches pod labels
kubectl get svc frontend -n chat-app -o yaml
kubectl get pods -n chat-app -l app=frontend --show-labels

# Ensure labels match:
# Service selector: app=frontend
# Pod labels: app=frontend
```

### 3. Frontend Pod Not Listening on Port 80

**Symptoms**: Pod is running but service can't connect

**Fix**:
```bash
# Test from inside the pod
kubectl exec -it -n chat-app deployment/frontend-deployment -- wget -qO- http://localhost:80/

# If this fails, nginx might not be running or configured incorrectly
# Check nginx config
kubectl exec -it -n chat-app deployment/frontend-deployment -- cat /etc/nginx/conf.d/default.conf

# Restart nginx in pod (if needed)
kubectl exec -it -n chat-app deployment/frontend-deployment -- nginx -s reload
```

### 4. Ingress Not Routing Correctly

**Symptoms**: Ingress exists but returns 502

**Fix**:
```bash
# Check ingress configuration
kubectl describe ingress chatapp-ingress -n chat-app

# Verify Traefik is running
kubectl get pods -n kube-system | grep traefik
kubectl get svc -n kube-system traefik

# Check Traefik logs for errors
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik --tail=100
```

### 5. Network Policy Blocking Traffic

**Symptoms**: Pods are ready but can't communicate

**Fix**:
```bash
# Check network policies
kubectl get networkpolicies -n chat-app

# Temporarily disable network policy to test
kubectl delete networkpolicy chat-app-network-policy -n chat-app

# If this fixes it, update network policy to allow Traefik traffic
```

### 6. Image Issues

**Symptoms**: Pod can't start or crashes

**Fix**:
```bash
# Rebuild frontend image
cd frontend
docker build -t abhishekjadhav1996/chatapp-frontend:latest .

# If using K3S on EC2, load image directly
docker save abhishekjadhav1996/chatapp-frontend:latest | sudo k3s ctr images import -

# Or push to registry and pull
docker push abhishekjadhav1996/chatapp-frontend:latest
kubectl rollout restart deployment/frontend-deployment -n chat-app
```

## Step-by-Step Fix

1. **Apply updated configurations**:
   ```bash
   kubectl apply -f k8s/frontend-service.yml
   kubectl apply -f k8s/frontend-deployment.yml
   kubectl apply -f k8s/ingress.yml
   ```

2. **Wait for pods to be ready**:
   ```bash
   kubectl wait --for=condition=ready pod -l app=frontend -n chat-app --timeout=300s
   ```

3. **Verify service endpoints**:
   ```bash
   kubectl get endpoints frontend -n chat-app
   # Should show IP addresses of frontend pods
   ```

4. **Test connectivity**:
   ```bash
   # From within cluster
   kubectl run -it --rm test --image=busybox --restart=Never -n chat-app -- wget -qO- http://frontend:80/
   
   # From Traefik pod
   kubectl exec -n kube-system -it deployment/traefik -- wget -qO- http://frontend.chat-app.svc.cluster.local:80/
   ```

5. **Check ingress routing**:
   ```bash
   kubectl describe ingress chatapp-ingress -n chat-app
   # Look for "Address" field - should show Traefik IP
   ```

## Quick Fix Script

Run the troubleshooting script:
```bash
chmod +x scripts/troubleshoot-502.sh
./scripts/troubleshoot-502.sh
```

## Still Not Working?

1. **Check if Traefik is accessible**:
   ```bash
   curl -v http://<EC2_PUBLIC_IP>/
   ```

2. **Check Traefik dashboard** (if enabled):
   ```bash
   kubectl port-forward -n kube-system svc/traefik 9000:9000
   # Access http://localhost:9000
   ```

3. **Verify security group allows port 80**:
   - EC2 Security Group should allow inbound traffic on port 80 from 0.0.0.0/0

4. **Check if frontend build includes all files**:
   ```bash
   kubectl exec -it -n chat-app deployment/frontend-deployment -- ls -la /usr/share/nginx/html/
   # Should see index.html, assets/, etc.
   ```
