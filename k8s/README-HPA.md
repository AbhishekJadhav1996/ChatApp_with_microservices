# 📈 Horizontal Pod Autoscaler (HPA) - Automatic Scaling

## ✅ HPA is Fully Automatic!

**No manual intervention required!** HPA works continuously and automatically scales your pods based on load.

## 🚀 How It Works

1. **Metrics Collection**: Metrics-server collects CPU and memory usage every 15 seconds
2. **HPA Evaluation**: HPA controller evaluates metrics every 15 seconds
3. **Automatic Scaling**: Pods are automatically created/deleted based on thresholds
4. **Zero Configuration**: Once deployed, HPA works hands-free!

## 📊 Scaling Behavior

### Scale UP Triggers
- **CPU Usage** > 70% average across all pods
- **Memory Usage** > 80% average across all pods
- **Scale Speed**: Up to 100% increase per 15 seconds
- **Max Pods**: 6 (Auth/User/Gateway) or 9 (Message/Socket)

### Scale DOWN Triggers
- **CPU Usage** < 70% average across all pods
- **Memory Usage** < 80% average across all pods
- **Scale Speed**: 50% decrease per 60 seconds
- **Stabilization**: 5-minute window before scaling down
- **Min Pods**: Always maintains 2 replicas for high availability

## 🔍 Verify HPA is Working

### Quick Check
```bash
# View all HPA status
kubectl get hpa -n chat-app

# Watch HPA in real-time
watch kubectl get hpa -n chat-app
```

### Detailed Check
```bash
# Check specific HPA
kubectl describe hpa auth-service-hpa -n chat-app

# Verify metrics-server is installed
kubectl get deployment metrics-server -n kube-system

# Check current resource usage
kubectl top pods -n chat-app
```

### Run Verification Script
```bash
./scripts/verify-hpa.sh
```

## 🧪 Test Auto-Scaling

### Generate Load to Trigger Scaling

```bash
# Generate load on API Gateway
kubectl run -it --rm load-generator \
  --image=busybox \
  --restart=Never \
  -- sh -c 'while true; do wget -q -O- http://api-gateway:5000/health; done'

# In another terminal, watch HPA scale
watch kubectl get hpa -n chat-app

# Watch pods being created
watch kubectl get pods -n chat-app
```

### Stop Load Test
```bash
# Delete load generator
kubectl delete pod load-generator -n chat-app

# Watch HPA scale down (after 5 minutes)
watch kubectl get hpa -n chat-app
```

## 📋 HPA Configuration

### Current Settings

| Service | Min Replicas | Max Replicas | CPU Threshold | Memory Threshold |
|---------|-------------|--------------|---------------|------------------|
| Auth Service | 2 | 6 | 70% | 80% |
| User Service | 2 | 6 | 70% | 80% |
| Message Service | 2 | 9 | 70% | 80% |
| Socket Service | 2 | 9 | 70% | 80% |
| API Gateway | 2 | 6 | 70% | 80% |

### Adjust Thresholds

Edit the HPA YAML files to change thresholds:

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

## ⚠️ Troubleshooting

### HPA Not Scaling

1. **Check metrics-server**:
```bash
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
```

2. **Verify resource requests are set**:
```bash
kubectl describe deployment auth-service-deployment -n chat-app | grep -A 5 "Requests:"
```

3. **Check HPA status**:
```bash
kubectl describe hpa auth-service-hpa -n chat-app
```

### Metrics Not Available

If `kubectl top pods` shows "no metrics available":
- Wait 1-2 minutes for metrics-server to collect data
- Verify metrics-server pod is running:
```bash
kubectl get pods -n kube-system | grep metrics-server
```

### Install Metrics-Server

If metrics-server is missing:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## 🎯 Best Practices

1. **Always set resource requests** - HPA needs requests to calculate percentages
2. **Monitor HPA behavior** - Use `watch kubectl get hpa` to observe scaling
3. **Test scaling** - Generate load to verify HPA responds correctly
4. **Adjust thresholds** - Fine-tune based on your workload patterns
5. **Set appropriate limits** - Prevent pods from consuming too many resources

## 📚 Additional Resources

- [Kubernetes HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
- [HPA Best Practices](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-best-practices/)

---

**Remember: HPA works automatically - just deploy and let it handle scaling! 🚀**

