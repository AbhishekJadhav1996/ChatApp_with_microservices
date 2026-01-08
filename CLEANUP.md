# 🧹 Cleanup Old Deployments

If you have old microservice deployments (api-gateway, auth-service, user-service, message-service) that are failing, follow these steps to clean them up.

## Quick Cleanup

Run the cleanup script:

```bash
chmod +x scripts/cleanup-old-deployments.sh
./scripts/cleanup-old-deployments.sh
```

## Manual Cleanup

If you prefer to clean up manually:

```bash
# Delete old deployments
kubectl delete deployment api-gateway-deployment -n chat-app
kubectl delete deployment auth-service-deployment -n chat-app
kubectl delete deployment user-service-deployment -n chat-app
kubectl delete deployment message-service-deployment -n chat-app

# Delete old services
kubectl delete svc api-gateway -n chat-app
kubectl delete svc auth-service -n chat-app
kubectl delete svc user-service -n chat-app
kubectl delete svc message-service -n chat-app

# Delete old HPA resources
kubectl delete hpa api-gateway-hpa -n chat-app
kubectl delete hpa auth-service-hpa -n chat-app
kubectl delete hpa user-service-hpa -n chat-app
kubectl delete hpa message-service-hpa -n chat-app
```

## Verify Cleanup

After cleanup, you should only have these deployments:

```bash
kubectl get deployments -n chat-app
```

Expected output:
- backend-deployment
- socket-service-deployment
- frontend-deployment
- mongodb-deployment

## Fix Backend Restart Issue

The backend was restarting because it didn't have a `/health` endpoint. This has been fixed. To apply the fix:

1. **Rebuild the backend image** with the health endpoint:

```bash
docker build -t abhishekjadhav1996/chatapp-backend:latest ./backend
```

2. **Restart the backend deployment**:

```bash
kubectl rollout restart deployment/backend-deployment -n chat-app
```

Or update the image:

```bash
kubectl set image deployment/backend-deployment \
  chatapp-backend=abhishekjadhav1996/chatapp-backend:latest -n chat-app
```

3. **Check backend logs** to verify it's working:

```bash
kubectl logs -f deployment/backend-deployment -n chat-app
```

## Expected Final State

After cleanup and fix, all pods should be running:

```bash
kubectl get pods -n chat-app
```

Expected output:
- backend-deployment: 2/2 Running
- socket-service-deployment: 2/2 Running
- frontend-deployment: 1/1 Running
- mongodb-deployment: 1/1 Running

