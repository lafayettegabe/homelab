#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "🚀 Deploying applications to homelab K8s cluster..."

echo "📦 Deploying base resources..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/base/namespace.yaml
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/base/rbac.yaml

echo "💾 Deploying storage..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/storage/storage-class.yaml

echo "🌐 Deploying networking..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/networking/nginx-ingress-controller.yaml
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/networking/ingress.yaml

echo "☁️  Deploying Cloudflare tunnel..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/networking/cloudflare-tunnel.yaml

echo "📊 Deploying monitoring..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/monitoring/prometheus.yaml

echo "🎯 Deploying applications..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl apply -f -" < applications/apps/hello-world.yaml

echo "✅ Deployment complete!"
echo "🔍 Checking status..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl get pods -A"

echo ""
echo "🌐 Applications accessible via:"
echo "   - Hello World: https://hello.$DOMAIN"
echo "   - Prometheus: https://prometheus.$DOMAIN"

