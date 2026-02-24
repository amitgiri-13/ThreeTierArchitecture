provider "cloudflare" {
  api_token = var.api_token
}

resource "cloudflare_dns_record" "root_dns" {
  zone_id = var.zone_id
  name    = "@"     
  type    = "CNAME"
  content   = module.alb.alb_dns_name

  proxied = true   
  ttl     = 1     
}