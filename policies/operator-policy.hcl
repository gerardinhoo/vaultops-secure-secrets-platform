## Operator Policy — On-Call / L2 Support Engineers
## Read-only access to system config. Can list secrets and troubleshoot,
## but cannot modify policies, auth methods, or seal/unseal Vault.

# Health checks for monitoring and triage
path "sys/health" {
  capabilities = ["read", "sudo"]
}

# List and read policies (cannot modify)
path "sys/policies/acl" {
  capabilities = ["list"]
}

path "sys/policies/acl/*" {
  capabilities = ["read"]
}

# View mounted secrets engines
path "sys/mounts" {
  capabilities = ["read"]
}

# View auth methods
path "sys/auth" {
  capabilities = ["read"]
}

# List secret metadata (cannot read secret values)
path "secret/metadata/*" {
  capabilities = ["list", "read"]
}

# Token introspection for troubleshooting
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/lookup" {
  capabilities = ["update"]
}

# View audit device configuration
path "sys/audit" {
  capabilities = ["read"]
}
