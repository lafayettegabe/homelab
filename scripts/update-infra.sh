#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "🔧 Updating infrastructure configuration..."

ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "cd homelab && git pull"

echo "🏗️  Rebuilding NixOS configuration..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "sudo nixos-rebuild switch"

echo "✅ Infrastructure update complete!"

