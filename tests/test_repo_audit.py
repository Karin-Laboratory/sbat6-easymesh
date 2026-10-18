#!/usr/bin/env python3
"""Small offline checks for this public documentation repository."""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def github_heading_slug(heading):
    heading = re.sub(r"`([^`]*)`", r"\1", heading).strip().lower()
    heading = re.sub(r"<[^>]+>", "", heading)
    heading = re.sub(r"[^\w\- ]", "", heading, flags=re.UNICODE)
    return heading.replace(" ", "-")


class RepositoryAudit(unittest.TestCase):
    def test_internal_markdown_links_exist(self):
        broken = []
        anchors = {}
        for md in ROOT.rglob("*.md"):
            if ".git" in md.parts:
                continue
            text = md.read_text(encoding="utf-8")
            slugs = set()
            for line in text.splitlines():
                heading = re.match(r"^#{1,6}\s+(.+?)\s*#*\s*$", line)
                if heading:
                    slugs.add(github_heading_slug(heading.group(1)))
            anchors[md.resolve()] = slugs
            for target in re.findall(r"\[[^]]*\]\(([^)]+)\)", text):
                if target.startswith(("https://", "http://", "mailto:", "#")):
                    continue
                path = target.split("#", 1)[0]
                if path and not (md.parent / path).resolve().exists():
                    broken.append(f"{md.relative_to(ROOT)} -> {target}")
        for md in ROOT.rglob("*.md"):
            if ".git" in md.parts:
                continue
            for target in re.findall(r"\[[^]]*\]\(([^)]+)\)", md.read_text(encoding="utf-8")):
                if target.startswith(("https://", "http://", "mailto:")):
                    continue
                path, _, fragment = target.partition("#")
                dest = (md.parent / path).resolve() if path else md.resolve()
                if fragment and dest in anchors and fragment not in anchors[dest]:
                    broken.append(f"{md.relative_to(ROOT)} -> missing anchor {target}")
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
        self.assertIn("iptables-input-rule-count", script)
        self.assertIn("knos-easymesh-enabled", script)
        self.assertIn("mld-band-indices", script)
        self.assertIn("SSID", script)

    def test_diagnostic_parses_reported_role_and_topology_forms(self):
        script = ROOT / "scripts/sbat6-diagnose.sh"
        fixture = ROOT / "tests/fixtures/mapd-success-report.txt"
        run = subprocess.run(["sh", str(script), "--self-test", str(fixture)],
                             check=True, text=True, capture_output=True, timeout=5)
        self.assertIn("agent_role=Agent", run.stdout)
        self.assertIn("agent_text_role=Agent", run.stdout)
        self.assertIn("controller_role=Controller", run.stdout)
        self.assertIn("distances=0 1 2", run.stdout)
        self.assertIn("medium=6G", run.stdout)
        self.assertIn("unrelated_medium=unknown", run.stdout)
        self.assertIn("bh_status=1 bh_type=4", run.stdout)
        self.assertIn("invalid_bh_status=unknown empty_cli=unavailable", run.stdout)
        self.assertIn("mlo_bands=1 2", run.stdout)
        self.assertIn("mlo_ref_counts=2", run.stdout)
        self.assertIn("empty_role=unknown", run.stdout)
        self.assertEqual("", run.stderr)

    def test_diagnostic_fixture_is_identifier_free(self):
        fixture = (ROOT / "tests/fixtures/mapd-success-report.txt").read_text(encoding="utf-8")
        self.assertNotRegex(fixture, r"\b(?:\d{1,3}\.){3}\d{1,3}\b")
        self.assertNotRegex(fixture, r"(?i)\b(?:[0-9a-f]{2}:){5}[0-9a-f]{2}\b")
        self.assertNotRegex(fixture, r"(?i)(?:ssid|psk|password)\s*[=:]")

    def test_execution_examples_do_not_reuse_historical_ips_or_angle_hosts(self):
        for path in ROOT.rglob("*.md"):
            source = path.read_text(encoding="utf-8")
            self.assertNotIn("root@<", source, str(path))
            for block in re.findall(r"```(?:sh|bash|shell)\s*\n(.*?)```", source, flags=re.S):
                self.assertNotRegex(block, r"\b192\.168\.3\.(?:1|2|13|223|247)\b", str(path))
                self.assertNotRegex(block, r"<[^>]+>", str(path))

    def test_quickstart_uses_ssh_stdin_without_scp(self):
        guide = (ROOT / "docs/24-easymesh-quickstart.md").read_text(encoding="utf-8")
        self.assertIn("TARGET_IP=''", guide)
        self.assertIn('ssh "root@${TARGET_IP}" \'sh -s\' < scripts/sbat6-diagnose.sh', guide)
        self.assertNotIn("scp scripts/sbat6-diagnose.sh", guide)

    def test_documented_shell_blocks_parse_with_posix_sh_and_busybox(self):
        busybox = shutil.which("busybox")
        blocks = []
        for path in ROOT.rglob("*.md"):
            if ".git" in path.parts:
                continue
            source = path.read_text(encoding="utf-8")
            blocks.extend((path, match.group(1)) for match in
                          re.finditer(r"```(?:sh|bash|shell)\s*\n(.*?)```", source, flags=re.S))
        self.assertGreater(len(blocks), 0)
        for path, block in blocks:
            subprocess.run(["sh", "-n"], input=block, text=True, check=True,
                           capture_output=True, timeout=5)
            if busybox:
                subprocess.run([busybox, "ash", "-n"], input=block, text=True,
                               check=True, capture_output=True, timeout=5)

    def test_shell_syntax_and_stdout_only_execution(self):
        script = ROOT / "scripts/sbat6-diagnose.sh"
        subprocess.run(["sh", "-n", str(script)], check=True)
        busybox = shutil.which("busybox")
        if busybox:
            subprocess.run([busybox, "ash", "-n", str(script)], check=True)
            fixture = ROOT / "tests/fixtures/mapd-success-report.txt"
            with tempfile.TemporaryDirectory() as temp:
                temp_path = Path(temp)
                applet_dir = temp_path / "busybox-applets"
                applet_dir.mkdir()
                for applet in ("awk", "sed", "tr", "sort"):
                    (applet_dir / applet).symlink_to(busybox)
                busybox_script = temp_path / "sbat6-diagnose.sh"
                content = script.read_text(encoding="utf-8").replace(
                    "PATH=/sbin:/bin:/usr/sbin:/usr/bin",
                    f"PATH={applet_dir}:/sbin:/bin:/usr/sbin:/usr/bin",
                    1,
                )
                busybox_script.write_text(content, encoding="utf-8")
                subprocess.run([busybox, "ash", str(busybox_script), "--self-test", str(fixture)],
                               check=True, timeout=5, capture_output=True, text=True)
        # Run only on CI/development host, never on a target; check it exits safely.
        run = subprocess.run(["sh", str(script)], check=True, text=True,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
        self.assertIn("read-only diagnostic", run.stdout)
        self.assertEqual("", run.stderr)


if __name__ == "__main__":
    unittest.main()
