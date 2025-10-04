resource "cloudflare_zero_trust_access_application" "homelab_ssh" {
  account_id                 = var.cloudflare_account_id
  name                       = "Homelab SSH"
  domain                     = "ssh.imgabriel.dev"
  type                       = "self_hosted"
  session_duration           = "24h"
  auto_redirect_to_identity  = false
  
  app_launcher_visible = true
}

resource "cloudflare_zero_trust_access_policy" "homelab_ssh_allow_all" {
  application_id = cloudflare_zero_trust_access_application.homelab_ssh.id
  account_id     = var.cloudflare_account_id
  name           = "Allow All"
  precedence     = 1
  decision       = "allow"
  
  include {
    everyone = true
  }
}