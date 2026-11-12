# Entra ID Non-Human Identity (NHI) Hardening & Governance Engine (WIP)

A secure, declarative Infrastructure-as-Code (IaC) and automated auditing framework designed to eliminate static credentials and enforce **Zero Standing Privileges (ZSP)** across Microsoft Entra ID Workload Identities (Service Principals, App Registrations, and Managed Identities).

---

## 🏗️ Architecture & Security Rationale

In modern cloud environments, non-human identities outnumber human users by orders of magnitude. Traditional automation relies on static, long-lived `client_secrets` stored in environment variables or repository configuration files—making them prime targets for credential harvesting and lateral movement.

This project implements a **secretless, shift-left governance model**:

1. **Workload Identity Federation (WIF):** Replaces static client secrets with short-lived OpenID Connect (OIDC) tokens exchanged dynamically between GitHub Actions and Entra ID.
2. **Strict Subject Scoping:** Enforces precise repository and environment-level claims (`repo:org/repo:environment:production`) to prevent branch spoofing and unauthorized pull request execution.
3. **Automated Threat Auditing:** Features a custom Python Graph API security scanner (`nhi_audit.py`) that detects orphaned service principals, aging credentials, and over-privileged application permissions (`Directory.ReadWrite.All`) before they reach production.

