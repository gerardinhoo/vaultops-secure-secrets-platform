## Transit Policy — Encryption-as-a-Service Access
## Apps can encrypt data. Only authorized services can decrypt.
## Supports PCI/compliance patterns (encrypt at edge, decrypt in secure zone).

# Encrypt data using the payment-data key
path "transit/encrypt/payment-data" {
  capabilities = ["update"]
}

# Decrypt data — restrict to authorized services only
path "transit/decrypt/payment-data" {
  capabilities = ["update"]
}

# Read key configuration (rotation status, key version)
path "transit/keys/payment-data" {
  capabilities = ["read"]
}
