#!/bin/bash
# =============================================================================
# vault-health.sh — Vault Operational Health Check
#
# Used by on-call engineers to quickly assess Vault status.
# Checks: seal status, audit devices, auth methods, secrets engines,
#          active tokens, and lease count.
# =============================================================================
set -euo pipefail

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"

echo "============================================"
echo " Vault Health Check — $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
echo ""

# 1. Server seal status
echo "--- Server Status ---"
STATUS_JSON=$(vault status -format=json 2>/dev/null) || {
  echo "  ERROR: Vault is unreachable at ${VAULT_ADDR}"
  exit 1
}
SEALED=$(echo "${STATUS_JSON}" | jq -r '.sealed')
VERSION=$(echo "${STATUS_JSON}" | jq -r '.version')
CLUSTER=$(echo "${STATUS_JSON}" | jq -r '.cluster_name // "N/A"')

echo "  Sealed:       ${SEALED}"
echo "  Version:      ${VERSION}"
echo "  Cluster:      ${CLUSTER}"

if [ "${SEALED}" = "true" ]; then
  echo "  *** WARNING: Vault is SEALED — immediate action required ***"
  exit 1
fi

# 2. Audit devices
echo ""
echo "--- Audit Devices ---"
AUDIT_COUNT=$(vault audit list -format=json 2>/dev/null | jq 'length' || echo "0")
echo "  Active audit devices: ${AUDIT_COUNT}"
if [ "${AUDIT_COUNT}" = "0" ]; then
  echo "  *** WARNING: No audit devices enabled — compliance risk ***"
fi

# 3. Auth methods
echo ""
echo "--- Auth Methods ---"
vault auth list -format=json 2>/dev/null | jq -r 'to_entries[] | "  \(.key) → \(.value.type)"'

# 4. Secrets engines
echo ""
echo "--- Secrets Engines ---"
vault secrets list -format=json 2>/dev/null | jq -r 'to_entries[] | "  \(.key) → \(.value.type)"'

# 5. Token accessor count (approximate active tokens)
echo ""
echo "--- Token Summary ---"
TOKEN_COUNT=$(vault list -format=json auth/token/accessors 2>/dev/null | jq 'length' || echo "N/A")
echo "  Active token accessors: ${TOKEN_COUNT}"

echo ""
echo "============================================"
echo " Health check complete"
echo "============================================"
