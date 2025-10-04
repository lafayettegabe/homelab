variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:Edit and Account:Cloudflare Tunnel:Edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}