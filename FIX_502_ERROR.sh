#!/bin/bash
# Fix 502 Bad Gateway Error - Step by Step

echo "🔍 Step 1: Checking pod status..."
kubectl get pods -n chat-app

echo ""
echo "🔍 Step 2: Checking service endpoints..."
kubectl get endpoints -n chat-app

echo ""
echo "🔍 Step 3: Checking ingress status..."
kubectl describe ingress chatapp-ingress -n chat-app

echo ""
echo "🔍 Step 4: Checking Traefik status..."
kubectl get pods -n kube-system | grep traefik
kubectl get svc -n kube-system traefik

echo ""
echo "✅ Step 5: Applying updated network policy (allows Traefik from kube-system)..."
kubectl apply -f k8s/network-policy.yml

echo ""
echo "✅ Step 6: Restarting frontend deployment..."
kubectl rollout restart deployment/frontend-deployment -n chat-app

echo ""
echo "⏳ Step 7: Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n chat-app --timeout=60s || echo "⚠️  Frontend pod not ready yet"

echo ""
echo "🔍 Step 8: Checking Traefik logs (last 20 lines)..."
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik --tail=20

echo ""
echo "✅ Done! Check if 502 error is resolved."
echo "If still getting 502, check the troubleshooting guide: TROUBLESHOOTING_502.md"

