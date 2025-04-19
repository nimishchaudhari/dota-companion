resource "cloudflare_zone" "dota_companion_zone" {
  zone = var.domain_name
}

# DNS Records
resource "cloudflare_record" "app" {
  zone_id = cloudflare_zone.dota_companion_zone.id
  name    = "app"
  value   = var.app_lb_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "api" {
  zone_id = cloudflare_zone.dota_companion_zone.id
  name    = "api"
  value   = var.api_lb_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "grafana" {
  zone_id = cloudflare_zone.dota_companion_zone.id
  name    = "grafana"
  value   = var.grafana_lb_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "argocd" {
  zone_id = cloudflare_zone.dota_companion_zone.id
  name    = "argocd"
  value   = var.argocd_lb_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

# SSL/TLS Settings
resource "cloudflare_zone_settings_override" "dota_companion_settings" {
  zone_id = cloudflare_zone.dota_companion_zone.id
  
  settings {
    ssl                      = "full_strict"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    universal_ssl            = "on"
    browser_check            = "on"
    challenge_ttl            = 2700
    security_level           = "medium"
    brotli                   = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    security_header {
      enabled            = true
      include_subdomains = true
      max_age            = 31536000
      nosniff            = true
      preload            = true
    }
  }
}

# WAF Rules
resource "cloudflare_firewall_rule" "block_bad_bots" {
  zone_id     = cloudflare_zone.dota_companion_zone.id
  description = "Block bad bots"
  filter_id   = cloudflare_filter.block_bad_bots.id
  action      = "block"
}

resource "cloudflare_filter" "block_bad_bots" {
  zone_id     = cloudflare_zone.dota_companion_zone.id
  description = "Block bad bots by user agent"
  expression  = "(http.user_agent contains \"bot\" and not cf.client.bot) or http.user_agent contains \"scrape\" or http.user_agent contains \"crawler\" or http.user_agent contains \"spider\""
}

# Rate Limiting
resource "cloudflare_rate_limit" "api_rate_limit" {
  zone_id    = cloudflare_zone.dota_companion_zone.id
  threshold  = 100
  period     = 60
  match {
    request {
      url_pattern = "api.${var.domain_name}/*"
      schemes     = ["HTTP", "HTTPS"]
      methods     = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD"]
    }
  }
  action {
    mode    = "simulate"
    timeout = 300
    response {
      content_type = "application/json"
      body         = <<EOF
{
  "status": 429,
  "error": "Too many requests",
  "message": "Please try again later"
}
EOF
    }
  }
  disabled = false
  description = "API rate limiting"
}

# Page Rules
resource "cloudflare_page_rule" "api_cache" {
  zone_id  = cloudflare_zone.dota_companion_zone.id
  target   = "api.${var.domain_name}/v1/heroes*"
  priority = 1
  
  actions {
    cache_level = "cache_everything"
    edge_cache_ttl = 3600
  }
}

resource "cloudflare_page_rule" "app_cache" {
  zone_id  = cloudflare_zone.dota_companion_zone.id
  target   = "app.${var.domain_name}/static/*"
  priority = 2
  
  actions {
    cache_level = "cache_everything"
    edge_cache_ttl = 86400
    browser_cache_ttl = 86400
  }
}

# Workers Script for A/B Testing
resource "cloudflare_worker_script" "ab_testing" {
  name    = "dota-companion-ab-testing"
  content = file("${path.module}/workers/ab-testing.js")
}

resource "cloudflare_worker_route" "ab_testing_route" {
  zone_id     = cloudflare_zone.dota_companion_zone.id
  pattern     = "app.${var.domain_name}/experiment/*"
  script_name = cloudflare_worker_script.ab_testing.name
}
