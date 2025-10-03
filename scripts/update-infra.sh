#!/bin/bash
set -e

SERVER_IP="192.168.1.10"
SSH_KEY="infrastructure/secrets/homelab_ed25519"
USER="server1"

echo "🔧 Updating infrastructure configuration..."

ssh -i $SSH_KEY $USER@$SERVER_IP "cd homelab && git pull"

echo "🏗️  Rebuilding NixOS configuration..."
ssh -i $SSH_KEY $USER@$SERVER_IP "sudo nixos-rebuild switch"

echo "✅ Infrastructure update complete!"

