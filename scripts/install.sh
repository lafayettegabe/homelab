#!/bin/bash

set -e

echo "Homelab NixOS Setup Script"
echo "=============================="

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (sudo $0)"
    exit 1
fi

if [ ! -f "infrastructure/configuration.nix" ]; then
    echo "❌ Please run this script from the homelab directory"
    exit 1
fi

echo "📁 Current directory: $(pwd)"

if [ -d "/etc/nixos" ] && [ ! -L "/etc/nixos" ]; then
    echo "📦 Backing up existing /etc/nixos to /etc/nixos.backup.$(date +%Y%m%d_%H%M%S)"
    mv /etc/nixos /etc/nixos.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -L "/etc/nixos" ]; then
    echo "🔗 Removing existing symlink /etc/nixos"
    rm /etc/nixos
fi

echo "🔗 Creating symlink: $(pwd)/infrastructure -> /etc/nixos"
ln -sf "$(pwd)/infrastructure" /etc/nixos

if [ -L "/etc/nixos" ]; then
    echo "✅ Symlink created successfully"
    echo "📂 /etc/nixos -> $(readlink /etc/nixos)"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

echo "🧪 Testing NixOS configuration..."
if nixos-rebuild dry-run; then
    echo "✅ Configuration test passed"
else
    echo "❌ Configuration test failed"
    exit 1
fi

echo "🚀 Applying NixOS configuration..."
if nixos-rebuild switch; then
    echo "✅ Configuration applied successfully!"
    echo ""
    echo "🎉 Homelab setup complete!"
    echo "📋 Next steps:"
    echo "   - SSH is enabled with key authentication"
    echo "   - K8s is running (kubectl configured)"
    echo "   - Power management optimized for headless server"
    echo "   - Monitor disabled for power saving"
    echo ""
    echo "🔧 Useful commands:"
    echo "   - Check K8s: kubectl get nodes"
    echo "   - Check services: systemctl status k8s sshd"
    echo "   - Check power: powertop"
else
    echo "❌ Failed to apply configuration"
    exit 1
fi