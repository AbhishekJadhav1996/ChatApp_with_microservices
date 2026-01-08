# Traefik Ingress Configuration for K3S

## Overview

This application uses **Traefik** as the ingress controller (K3S default). The ingress configuration routes traffic as follows:

- `/socket.io` → Socket Service (Port 5004) - WebSocket connections
- `/api` → Backend Service (Port 5001) - REST API endpoints  
- `/` → Frontend Service (Port 80) - React SPA

## Ingress Configuration

The `k8s/ingress.yml` file is configured for Traefik with the following key settings:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: chatapp-ingress
  namespace: chat-app
  labels:
    app: chatapp
  annotations:
    # Traefik WebSocket support
    traefik.ingress.kubernetes.io/websocket-services: "socket-service"
    # Route via HTTP entrypoint
    traefik.ingress.kubernetes.io/router.entrypoints: "web"
spec:
  ingressClassName: traefik
  rules:
  - http:
      paths:
        # Socket.io WebSocket - must be first (most specific)
        - path: "/socket.io"
          pathType: Prefix
          backend:
            service:
              name: socket-service
              port:
                number: 5004
        # Backend API - must be before frontend to match /api first
        - path: "/api"
          pathType: Prefix
          backend:
            service:
              name: backend
              port:
                number: 5001
        # Frontend - must be last to catch all other routes
        - path: "/"
          pathType: Prefix
          backend:
            service:
              name: frontend
              port:
                number: 80
```

## Important Notes

### Path Ordering
The paths are ordered from most specific to least specific:
1. `/socket.io` - WebSocket connections
2. `/api` - API endpoints
3. `/` - Frontend (catches everything else)

This ensures that `/api` and `/socket.io` requests are routed correctly before falling through to the frontend.

### Frontend Nginx Configuration
The frontend nginx.conf has been updated to **remove proxy rules** for `/api` and `/socket.io` since Traefik handles all routing. The frontend nginx now only serves static files.

### WebSocket Support
Traefik automatically handles WebSocket upgrades for the socket-service when the `websocket-services` annotation is set.

## Deployment

```bash
# Apply ingress configuration
kubectl apply -f k8s/ingress.yml

# Verify ingress
kubectl get ingress -n chat-app

# Check Traefik status
kubectl get pods -n kube-system | grep traefik
kubectl get svc -n kube-system traefik
```

## Accessing the Application

After deployment, access your application via:

- **Frontend**: `http://<EC2_PUBLIC_IP>/`
- **Backend API**: `http://<EC2_PUBLIC_IP>/api`
- **WebSocket**: `ws://<EC2_PUBLIC_IP>/socket.io`

## Troubleshooting

### 502 Bad Gateway Errors

If you see 502 errors:

1. **Check if services are running**:
   ```bash
   kubectl get pods -n chat-app
   kubectl get svc -n chat-app
   ```

2. **Check Traefik logs**:
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
   ```

3. **Verify ingress routing**:
   ```bash
   kubectl describe ingress chatapp-ingress -n chat-app
   ```

4. **Check frontend pod logs**:
   ```bash
   kubectl logs -n chat-app -l app=frontend
   ```

5. **Verify frontend is serving static files**:
   ```bash
   kubectl exec -it -n chat-app deployment/frontend-deployment -- ls -la /usr/share/nginx/html
   ```

### Favicon.ico 502 Error

If you see 502 for favicon.ico:

1. **Rebuild frontend** to ensure favicon is included in dist:
   ```bash
   cd frontend
   docker build -t abhishekjadhav1996/chatapp-frontend:latest .
   ```

2. **Redeploy frontend**:
   ```bash
   kubectl rollout restart deployment/frontend-deployment -n chat-app
   ```

3. **Verify favicon exists in build**:
   ```bash
   kubectl exec -it -n chat-app deployment/frontend-deployment -- ls -la /usr/share/nginx/html/ | grep -i favicon
   ```

## Domain Configuration (Optional)

If you have a domain name:

1. Point your domain's A record to your EC2 Elastic IP or Public IP
2. Update `k8s/ingress.yml` to add a host rule:
   ```yaml
   rules:
   - host: yourdomain.com
     http:
       paths: [...]
   ```
3. Access via: `http://yourdomain.com`

