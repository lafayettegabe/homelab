#!/bin/bash
set -e

SERVER_IP="192.168.1.10"
SSH_KEY="infrastructure/secrets/homelab_ed25519"
USER="server1"

echo "🚀 Deploying applications to homelab K8s cluster..."

echo "📦 Deploying base resources..."
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl apply -f -" < applications/base/namespace.yaml
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl apply -f -" < applications/base/rbac.yaml

echo "💾 Deploying storage..."
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl apply -f -" < applications/storage/storage-class.yaml

echo "🌐 Deploying networking..."
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl apply -f -" < applications/networking/ingress.yaml

echo "📊 Deploying monitoring..."
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl apply -f -" < applications/monitoring/prometheus.yaml

echo "🎯 Deploying applications..."
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl apply -f -" < applications/apps/hello-world.yaml

echo "✅ Deployment complete!"
echo "🔍 Checking status..."
ssh -i $SSH_KEY $USER@$SERVER_IP "kubectl get pods -A"

