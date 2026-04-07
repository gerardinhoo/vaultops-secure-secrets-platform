#!/bin/bash
# =============================================================================
# demo-transit.sh — Demonstrate Vault Transit Engine (Encryption-as-a-Service)
#
# Shows: encrypt, decrypt, and key rotation using the transit secrets engine.
# This simulates protecting sensitive data (e.g., payment info) without
# applications needing to manage encryption keys directly.
# =============================================================================
set -euo pipefail

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"

echo "============================================"
echo " Vault Transit Engine Demo"
echo "============================================"

# Step 1: Encrypt sensitive data
PLAINTEXT=$(echo -n "4111-1111-1111-1111" | base64)
echo ""
echo "==> [1/4] Encrypting payment data..."
echo "    Plaintext:  4111-1111-1111-1111"
CIPHERTEXT=$(vault write -field=ciphertext transit/encrypt/payment-data plaintext="${PLAINTEXT}")
echo "    Ciphertext: ${CIPHERTEXT}"

# Step 2: Decrypt the data
echo ""
echo "==> [2/4] Decrypting payment data..."
DECRYPTED=$(vault write -field=plaintext transit/decrypt/payment-data ciphertext="${CIPHERTEXT}" | base64 --decode)
echo "    Decrypted:  ${DECRYPTED}"

# Step 3: Rotate the encryption key
echo ""
echo "==> [3/4] Rotating encryption key..."
vault write -f transit/keys/payment-data/rotate
KEY_VERSION=$(vault read -field=latest_version transit/keys/payment-data)
echo "    New key version: ${KEY_VERSION}"

# Step 4: Re-encrypt with new key (rewrapping)
echo ""
echo "==> [4/4] Rewrapping ciphertext with latest key version..."
NEW_CIPHERTEXT=$(vault write -field=ciphertext transit/rewrap/payment-data ciphertext="${CIPHERTEXT}")
echo "    Old ciphertext: ${CIPHERTEXT}"
echo "    New ciphertext: ${NEW_CIPHERTEXT}"

echo ""
echo "============================================"
echo " Transit Demo Complete"
echo "============================================"
echo " Key rotation and rewrapping ensures old ciphertext"
echo " is re-encrypted without exposing plaintext."
echo "============================================"
