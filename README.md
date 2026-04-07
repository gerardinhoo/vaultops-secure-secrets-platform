# VaultOps: Vault Administration & Secrets Management Platform

## Overview

VaultOps demonstrates **hands-on HashiCorp Vault administration** — not just usage. It covers the full lifecycle of operating a Vault deployment: infrastructure-as-code provisioning, RBAC policy governance, application onboarding via AppRole, encryption-as-a-service with the Transit engine, audit logging, and operational health monitoring.

This project simulates real-world workflows aligned with **Privileged Access Management (PAM)** and **Identity & Access Management (IAM)** practices.

---

## Features

- **RBAC Policy Hierarchy** — Tiered admin/operator/app policies enforcing least privilege and separation of duties
- **AppRole Authentication** — Machine-to-machine auth for automated application onboarding
- **Transit Secrets Engine** — Encryption-as-a-service with key rotation and ciphertext rewrapping
- **Audit Logging** — File-based audit device for compliance visibility and incident triage
- **Terraform Automation** — All Vault configuration (policies, auth, secrets engines, audit) managed as code
- **Operational Health Checks** — Script to assess seal status, auth methods, secrets engines, and token inventory
- **Application Onboarding Script** — End-to-end onboarding: policy creation → AppRole role → credential generation → login validation

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Terraform (IaC)                       │
│  Policies · AppRole Auth · Transit Engine · Audit       │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                  HashiCorp Vault (Docker)                │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │ KV v2    │  │ Transit  │  │ AppRole  │  │ Audit  │  │
│  │ Secrets  │  │ Encrypt  │  │ Auth     │  │ Log    │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘  │
└─────────────────────────────────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
     Admin Policy  Operator Policy  App Policy
     (PAM team)    (L2 support)     (services)
```

---

## Tech Stack

- HashiCorp Vault
- Terraform (Vault provider)
- Docker / Docker Compose
- Bash scripting
- jq

---

## Quick Start

```bash
# 1. Start Vault
docker-compose up -d
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

# 2. Apply Terraform configuration
cd terraform && terraform init && terraform apply -auto-approve && cd ..

# 3. Onboard an application
chmod +x scripts/*.sh
./scripts/onboard-app.sh payments-api

# 4. Demo transit encryption
./scripts/demo-transit.sh

# 5. Run health check
./scripts/vault-health.sh
```

---

## Project Structure

```
VaultOps/
├── docker-compose.yml          # Vault server (Docker)
├── terraform/
│   └── main.tf                 # All Vault config as IaC
├── policies/
│   ├── admin-policy.hcl        # Full admin (PAM team)
│   ├── operator-policy.hcl     # Read-only ops (L2 support)
│   ├── app-policy.hcl          # Least-privilege app access
│   └── transit-policy.hcl      # Encrypt/decrypt privileges
└── scripts/
    ├── onboard-app.sh          # End-to-end app onboarding
    ├── demo-transit.sh         # Transit encrypt/decrypt/rotate
    └── vault-health.sh         # Operational health check
```

---

## RBAC Policy Model

**Admin Policy** (`admin-policy.hcl`)
- Full access to sys/, auth/, secrets engines, and audit
- Assigned to: PAM team senior engineers

**Operator Policy** (`operator-policy.hcl`)
- Read-only system access, health checks, token introspection
- Assigned to: On-call engineers, L2 support

**App Policy** (`app-policy.hcl`)
- Read-only access to scoped secret paths
- Assigned to: Application service accounts via AppRole

**Transit Policy** (`transit-policy.hcl`)
- Encrypt/decrypt operations on specific keys
- Supports separation of encrypt vs. decrypt privileges

---

## Key Workflows

### Application Onboarding (AppRole)
```bash
./scripts/onboard-app.sh <app-name>
```
Automates: policy creation → AppRole role → credential generation → login validation

### Transit Encryption (Encryption-as-a-Service)
```bash
./scripts/demo-transit.sh
```
Demonstrates: encrypt → decrypt → key rotation → ciphertext rewrapping

### Operational Health Check
```bash
./scripts/vault-health.sh
```
Checks: seal status, audit devices, auth methods, secrets engines, token count
