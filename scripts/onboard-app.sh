#!/bin/bash
# =============================================================================
# onboard-app.sh — Onboard a new application to Vault via AppRole
# Usage: ./onboard-app.sh <app-name>
#
# This script automates the PAM onboarding workflow:
#   1. Creates a least-privilege policy scoped to the app's secret path
#   2. Creates an AppRole role bound to that policy
#   3. Generates Role ID and Secret ID credentials
#   4. Validates the credentials by performing a test login
# =============================================================================
set -euo pipefail

APP_NAME=${1:?"Usage: onboard-app.sh <app-name>"}

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"

echo "============================================"
echo " Vault App Onboarding: ${APP_NAME}"
echo "============================================"

# Step 1: Create a scoped policy for this application
echo ""
echo "==> [1/4] Creating least-privilege policy: ${APP_NAME}-policy"
vault policy write "${APP_NAME}-policy" - <<EOF
# Auto-generated policy for ${APP_NAME}
# Grants read-only access to app-specific secrets
path "secret/data/${APP_NAME}/*" {
  capabilities = ["read"]
}
path "secret/metadata/${APP_NAME}/*" {
  capabilities = ["list"]
}
EOF

# Step 2: Create an AppRole role for this application
echo "==> [2/4] Creating AppRole role: ${APP_NAME}"
vault write "auth/approle/role/${APP_NAME}" \
  token_policies="${APP_NAME}-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=24h \
  secret_id_num_uses=1

# Step 3: Retrieve credentials
echo "==> [3/4] Generating credentials"
ROLE_ID=$(vault read -field=role_id "auth/approle/role/${APP_NAME}/role-id")
SECRET_ID=$(vault write -field=secret_id -f "auth/approle/role/${APP_NAME}/secret-id")

echo "    Role ID:    ${ROLE_ID}"
echo "    Secret ID:  [generated — deliver via secure channel]"

# Step 4: Validate login
echo "==> [4/4] Validating AppRole login..."
LOGIN_RESULT=$(vault write -format=json auth/approle/login \
  role_id="${ROLE_ID}" \
  secret_id="${SECRET_ID}")

CLIENT_TOKEN=$(echo "${LOGIN_RESULT}" | jq -r '.auth.client_token')
TOKEN_POLICIES=$(echo "${LOGIN_RESULT}" | jq -r '.auth.policies | join(", ")')
TOKEN_TTL=$(echo "${LOGIN_RESULT}" | jq -r '.auth.lease_duration')

echo ""
echo "============================================"
echo " Onboarding Complete"
echo "============================================"
echo " App:        ${APP_NAME}"
echo " Policies:   ${TOKEN_POLICIES}"
echo " Token TTL:  ${TOKEN_TTL}s"
echo " Status:     SUCCESS"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Store secrets:  vault kv put secret/${APP_NAME}/config key=value"
echo "  2. Deliver Role ID and Secret ID to the app team securely"
echo "  3. App authenticates:  vault write auth/approle/login role_id=... secret_id=..."
