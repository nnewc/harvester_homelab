provider "rancher2" {
  alias = "bootstrap"
  api_url   = var.rancher_api_url
  bootstrap = true
  insecure = true
}

resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap
  initial_password = var.rancher_bootstrap_password
  password = var.rancher_admin_password
  telemetry = true
}