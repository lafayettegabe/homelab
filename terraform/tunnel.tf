resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "homelab-tunnel"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "homelab_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id
  
  config {
    ingress_rule {
      hostname = "ssh.imgabriel.dev"
      service  = "ssh://192.168.1.10:22"
    }
    ingress_rule {
      hostname = "*.imgabriel.dev"
      service  = "http://192.168.1.10:30080"
    }
    ingress_rule {
      hostname = "imgabriel.dev"
      service  = "http://192.168.1.10:30080"
    }
    ingress_rule {
      service = "http://192.168.1.10:30080"
    }
  }
}