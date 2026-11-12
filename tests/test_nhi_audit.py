import unittest

from scripts.nhi_audit import analyze_service_principals


class TestNHIAuditScanner(unittest.TestCase):
    def test_detects_unowned_and_static_secret_principals(self):
        sample_payload = [
            {
                "id": "sp-001",
                "displayName": "Legacy-Pipeline-App",
                "owners": [],
                "passwordCredentials": [{"customKeyIdentifier": "abc1234"}],
                "appRoleAssignments": [{"permissionName": "Directory.ReadWrite.All"}],
            },
            {
                "id": "sp-002",
                "displayName": "Hardened-WIF-App",
                "owners": ["user-001"],
                "passwordCredentials": [],
                "appRoleAssignments": [],
            },
        ]

        findings = analyze_service_principals(sample_payload)

        # Assert 3 findings on sp-001, 0 on sp-002
        self.assertEqual(len(findings), 3)
        severities = [f["severity"] for f in findings]
        self.assertIn("CRITICAL", severities)
        self.assertIn("HIGH", severities)
        self.assertIn("MEDIUM", severities)


if __name__ == "__main__":
    unittest.main()
