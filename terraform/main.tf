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

# Create policy via Terraform
resource "vault_policy" "app_policy" {
  name = "app-policy"

  policy = <<EOT
path "secret/data/app/*" {
  capabilities = ["read"]
}
EOT
}
