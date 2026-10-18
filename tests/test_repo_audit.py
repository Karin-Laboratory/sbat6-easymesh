#!/usr/bin/env python3
"""Small offline checks for this public documentation repository."""
from pathlib import Path
import re
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RepositoryAudit(unittest.TestCase):
    def test_internal_markdown_links_exist(self):
        broken = []
        for md in ROOT.rglob("*.md"):
            if ".git" in md.parts:
                continue
            text = md.read_text(encoding="utf-8")
            for target in re.findall(r"\[[^]]*\]\(([^)]+)\)", text):
                if target.startswith(("https://", "http://", "mailto:", "#")):
                    continue
                path = target.split("#", 1)[0]
                if path and not (md.parent / path).resolve().exists():
                    broken.append(f"{md.relative_to(ROOT)} -> {target}")
        self.assertEqual([], broken)

    def test_no_firmware_or_image_artifacts(self):
        forbidden = {".bin", ".img", ".ubi", ".squashfs", ".rootfs", ".elf"}
        files = [p.relative_to(ROOT).as_posix() for p in ROOT.rglob("*")
                 if p.is_file() and ".git" not in p.parts and p.suffix.lower() in forbidden]
        self.assertEqual([], files)

    def test_diagnostic_is_read_only_by_contract(self):
        script = (ROOT / "scripts/sbat6-diagnose.sh").read_text(encoding="utf-8")
        self.assertTrue(script.startswith("#!/bin/sh\n"))
        self.assertNotRegex(script, r"\buci\s+(set|add|delete|commit|revert)\b")
        self.assertNotRegex(script, r"\b(ifup|ifdown|reboot|poweroff|killall|iptables\s+-[IFDX])\b")
        self.assertNotRegex(script, r"/etc/init\.d/[^\s]+\s+(restart|reload|stop|start)")
        self.assertNotRegex(script, r"(?m)^\s*(cat|sed|awk|grep)\s+.*(/etc/shadow|/etc/passwd)")
        self.assertIn("for cmd in getrole agent_list dump_topology dump_topology_v1 bh_info bh_conn_status bh_conn_type", script)
        self.assertIn("SSID", script)

    def test_diagnostic_parses_reported_role_and_topology_forms(self):
        script = ROOT / "scripts/sbat6-diagnose.sh"
        fixture = ROOT / "tests/fixtures/mapd-success-report.txt"
        run = subprocess.run(["sh", str(script), "--self-test", str(fixture)],
                             check=True, text=True, capture_output=True, timeout=5)
        self.assertIn("agent_role=Agent", run.stdout)
        self.assertIn("controller_role=Controller", run.stdout)
        self.assertIn("distances=1", run.stdout)
        self.assertIn("medium=6G", run.stdout)
        self.assertIn("bh_status=1 bh_type=4", run.stdout)
        self.assertEqual("", run.stderr)

    def test_diagnostic_fixture_is_identifier_free(self):
        fixture = (ROOT / "tests/fixtures/mapd-success-report.txt").read_text(encoding="utf-8")
        self.assertNotRegex(fixture, r"\b(?:\d{1,3}\.){3}\d{1,3}\b")
        self.assertNotRegex(fixture, r"(?i)\b(?:[0-9a-f]{2}:){5}[0-9a-f]{2}\b")
        self.assertNotRegex(fixture, r"(?i)(?:ssid|psk|password)\s*[=:]")

    def test_shell_syntax_and_stdout_only_execution(self):
        script = ROOT / "scripts/sbat6-diagnose.sh"
        subprocess.run(["sh", "-n", str(script)], check=True)
        # Run only on CI/development host, never on a target; check it exits safely.
        run = subprocess.run(["sh", str(script)], check=True, text=True,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
        self.assertIn("read-only diagnostic", run.stdout)
        self.assertEqual("", run.stderr)


if __name__ == "__main__":
    unittest.main()
