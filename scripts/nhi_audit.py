#!/usr/bin/env python3
"""
Entra ID Non-Human Identity (NHI) Security Auditor
Scans Microsoft Graph API payloads for risky Service Principals,
unowned App Registrations, aging static secrets, and over-privileged roles.
"""

import logging
from typing import Any

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)

HIGH_RISK_GRAPH_PERMISSIONS = {
    "Directory.ReadWrite.All",
    "RoleManagement.ReadWrite.Directory",
    "AppRoleAssignment.ReadWrite.All",
    "Domain.ReadWrite.All",
}


def analyze_service_principals(
    sp_payloads: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """
    Analyzes Service Principal payloads for security violations:
    1. Unowned Service Principals
    2. Static Client Secrets present (Non-WIF)
    3. Over-privileged Graph API Application roles assigned
    """
    findings = []

    for sp in sp_payloads:
        sp_id = sp.get("id", "Unknown")
        display_name = sp.get("displayName", "Unnamed")
        owners = sp.get("owners", [])
        sp.get("keyCredentials", [])
        password_credentials = sp.get("passwordCredentials", [])
        app_roles = sp.get("appRoleAssignments", [])

        # Check 1: Unowned Service Principals (Orphaned Identities)
        if not owners:
            findings.append(
                {
                    "id": sp_id,
                    "name": display_name,
                    "severity": "MEDIUM",
                    "issue": "Orphaned Service Principal (No defined owners)",
                }
            )

        # Check 2: Presence of Static Password Credentials
        if password_credentials:
            findings.append(
                {
                    "id": sp_id,
                    "name": display_name,
                    "severity": "HIGH",
                    "issue": f"Static client secrets detected ({len(password_credentials)} active). Migrate to WIF/OIDC.",
                }
            )

        # Check 3: Excessive Application Permissions
        for role in app_roles:
            role_name = role.get("permissionName", "")
            if role_name in HIGH_RISK_GRAPH_PERMISSIONS:
                findings.append(
                    {
                        "id": sp_id,
                        "name": display_name,
                        "severity": "CRITICAL",
                        "issue": f"High-risk Application Permission assigned: {role_name}",
                    }
                )

    return findings


if __name__ == "__main__":
    logger.info(
        "NHI Audit Module loaded successfully. Integrate with live Graph API or test harness."
    )
