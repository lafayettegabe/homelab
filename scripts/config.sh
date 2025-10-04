#!/bin/bash
# Configuration file for homelab scripts

export SERVER_IP="${SERVER_IP:-192.168.1.10}"
export SSH_KEY="${SSH_KEY:-infrastructure/secrets/homelab_ed25519}"
export SERVER_USER="${SERVER_USER:-server1}"

export DOMAIN="${DOMAIN:-imgabriel.dev}"

export AWS_PROFILE="${AWS_PROFILE:-gabe}"

if [ -f "scripts/config.local.sh" ]; then
    source scripts/config.local.sh
fi
