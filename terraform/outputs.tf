output "tunnel_token" {
  description = "Tunnel token for cloudflared authentication"
  value = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.tunnel_token
  sensitive = true
}

output "tunnel_cname" {
  description = "Tunnel CNAME for DNS configuration"
  value = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.cname
}

output "tunnel_id" {
  description = "Tunnel ID"
  value = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.id
}
