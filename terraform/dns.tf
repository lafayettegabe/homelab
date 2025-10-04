resource "cloudflare_record" "homelab_root" {
  zone_id = data.cloudflare_zone.imgabriel_dev.id
  name    = "@"
  content = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.cname
  type    = "CNAME"
  proxied = true
}


resource "cloudflare_record" "homelab_ssh" {
  zone_id = data.cloudflare_zone.imgabriel_dev.id
  name    = "ssh"
  content = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "homelab_wildcard" {
  zone_id = data.cloudflare_zone.imgabriel_dev.id
  name    = "*"
  content = cloudflare_zero_trust_tunnel_cloudflared.homelab_tunnel.cname
  type    = "CNAME"
  proxied = true
}