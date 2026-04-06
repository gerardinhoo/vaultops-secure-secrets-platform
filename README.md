# VaultOps: Secure Secrets & App Onboarding Platform

## Overview
VaultOps is a hands-on project demonstrating secure secrets management, policy enforcement, and application onboarding using HashiCorp Vault.

This project simulates real-world DevOps and security workflows aligned with Privileged Access Management (PAM) and Identity & Access Management (IAM) practices.

---

## 🚀 Features

- 🔐 Secure storage of secrets (API keys, DB credentials)
- 🛡️ Policy-based access control (least privilege)
- 🔑 Token-based authentication for applications
- ⚙️ Terraform automation for Vault configuration
- 🐳 Vault deployment using Docker
- 🔄 Simulated application onboarding workflow

---

## 🏗️ Architecture

1. Vault runs locally in Docker (dev mode)
2. KV secrets engine stores sensitive data
3. Policies define access control rules
4. Tokens simulate application identities
5. Terraform automates Vault configuration

---

## 🧱 Tech Stack

- HashiCorp Vault
- Terraform
- Docker
- CLI (Vault)

---

## 🔐 Example Workflow

### 1. Store Secrets
```bash
vault kv put secret/app/config \
  username="admin" \
  password="supersecret" \
  api_key="123456"