📄 rollback.md — Terraform State & Rollback Strategy

markdown
Kopiëren
Bewerken
# VionX Terraform Rollback Plan

## 🧠 Purpose

This document outlines recovery strategies for misapplied Terraform deployments, especially for critical infrastructure defined in `terraform/platform`.

---

## ☁️ Backend: Azure Blob Storage

Terraform state is stored remotely at:

- **Resource Group:** `vionx-core-state`
- **Storage Account:** `vionxstatestorage`
- **Container:** `tfstate`
- **Blob Key:** `platform.terraform.tfstate`

---

## 🔐 Resilience Measures

| Mechanism                   | Status   |
|----------------------------|----------|
| Blob container soft delete | ✅ Enabled (7 days retention) |
| Terraform remote backend   | ✅ Configured |
| GitHub Actions CI plan     | ✅ Configured via `infra-plan.yml` |

---

## 🔁 Rollback Instructions

### Option 1: Revert Last Terraform Change

1. Identify the last known good commit SHA from GitHub.
2. Revert the repo using:
   ```bash
   git revert <commit-sha>
   git push origin main
Let CI run terraform apply again to restore the desired state.

Option 2: Restore .tfstate from Blob History
Visit the Azure Portal → Storage Account → tfstate container.

Enable "Show deleted blobs".

Locate the previous version of platform.terraform.tfstate.

Restore or download and manually upload via CLI.

bash
Kopiëren
Bewerken
az storage blob list \
  --account-name vionxstatestorage \
  --container-name tfstate \
  --include deleted \
  --auth-mode login
🚨 Caution
Never manually edit terraform.tfstate.

Always commit and push changes via GitHub PRs.

Monitor plan logs in CI before approving destructive changes.

📎 Related Files
.github/workflows/infra-plan.yml

terraform/platform/main.tf
