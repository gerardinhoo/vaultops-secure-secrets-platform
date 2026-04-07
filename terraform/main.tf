terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root"
}

# ---------------------------------------------------------------------------
# Audit Device — logs every Vault operation for compliance and triage
# ---------------------------------------------------------------------------
resource "vault_audit" "file" {
  type = "file"
  options = {
    file_path = "/vault/logs/audit.log"
  }
}

# ---------------------------------------------------------------------------
# RBAC Policies — tiered access: admin > operator > app
# ---------------------------------------------------------------------------
resource "vault_policy" "admin_policy" {
  name   = "admin-policy"
  policy = file("${path.module}/../policies/admin-policy.hcl")
}

resource "vault_policy" "operator_policy" {
  name   = "operator-policy"
  policy = file("${path.module}/../policies/operator-policy.hcl")
}

resource "vault_policy" "app_policy" {
  name   = "app-policy"
  policy = file("${path.module}/../policies/app-policy.hcl")
}

resource "vault_policy" "transit_policy" {
  name   = "transit-policy"
  policy = file("${path.module}/../policies/transit-policy.hcl")
}

# ---------------------------------------------------------------------------
# AppRole Auth — machine-to-machine authentication for app onboarding
# ---------------------------------------------------------------------------
resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "web_app" {
  backend        = vault_auth_backend.approle.path
  role_name      = "web-app"
  token_policies = [vault_policy.app_policy.name]
  token_ttl      = 3600    # 1 hour
  token_max_ttl  = 14400   # 4 hours
}

# ---------------------------------------------------------------------------
# Transit Secrets Engine — encryption-as-a-service
# ---------------------------------------------------------------------------
resource "vault_mount" "transit" {
  path = "transit"
  type = "transit"
}

resource "vault_transit_secret_backend_key" "payment" {
  backend = vault_mount.transit.path
  name    = "payment-data"
  type    = "aes256-gcm96"
}
