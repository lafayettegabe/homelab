#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "☁️  Deploying Cloudflare Tunnel to Kubernetes"
echo "=============================================="

if [ ! -f "terraform/tunnel-token.txt" ]; then
    echo "❌ Tunnel token not found. Please run:"
    echo "   cd terraform && AWS_PROFILE=$AWS_PROFILE terraform output -raw tunnel_token > tunnel-token.txt"
    exit 1
fi

echo "📤 Step 1: Copy token and manifests to server..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "mkdir -p ~/homelab/terraform ~/homelab/applications/networking"
scp -i $SSH_KEY terraform/tunnel-token.txt $SERVER_USER@$SERVER_IP:~/homelab/terraform/
scp -i $SSH_KEY applications/networking/cloudflare-tunnel.yaml $SERVER_USER@$SERVER_IP:~/homelab/applications/networking/

echo "✅ Step 2: Deploy cloudflared to Kubernetes on server..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "cd homelab && kubectl create namespace cloudflare-tunnel --dry-run=client -o yaml | kubectl apply -f -"

ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "cd homelab && kubectl create secret generic cloudflared-token \
    --from-file=TUNNEL_TOKEN=tunnel-token.txt \
    --namespace=cloudflare-tunnel \
    --dry-run=client -o yaml | kubectl apply -f -"

ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "cd homelab && kubectl apply -f applications/networking/cloudflare-tunnel.yaml"

echo "⏳ Step 3: Waiting for cloudflared to be ready..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "kubectl wait --for=condition=available --timeout=300s daemonset/cloudflared -n cloudflare-tunnel"

echo ""
echo "🎉 Cloudflare Tunnel setup complete!"
echo ""
echo "🌐 Your applications are now accessible via:"
echo "   - Hello World: https://hello.$DOMAIN"
echo "   - Prometheus: https://prometheus.$DOMAIN"
echo ""
echo "🔍 Check tunnel status:"
echo "   ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'kubectl logs -f daemonset/cloudflared -n cloudflare-tunnel'"
echo ""
echo "📊 Check tunnel metrics:"
echo "   ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'kubectl port-forward -n cloudflare-tunnel svc/cloudflared-metrics 2000:2000'"
echo "   # Then visit http://localhost:2000/metrics"
