## Admin Policy — PAM Team Members Only
## Full administrative access to Vault for platform management.
## This policy should be tightly restricted to senior engineers.

# Manage secrets engines (mount/unmount)
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage audit devices
path "sys/audit/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# View Vault health and status
path "sys/health" {
  capabilities = ["read", "sudo"]
}

# Manage leases (revoke app tokens, etc.)
path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Full access to KV secrets engine
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to transit engine
path "transit/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
