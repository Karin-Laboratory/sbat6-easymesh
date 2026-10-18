import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class SshStdinExample(unittest.TestCase):
    def test_diagnostic_is_sent_to_remote_shell_stdin_without_target_file(self):
        with tempfile.TemporaryDirectory() as temp:
            temp_path = Path(temp)
            fake_ssh = temp_path / "ssh"
            fake_ssh.write_text(
                "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$SSH_ARGS_OUT\"\n"
                "cat > \"$SSH_STDIN_OUT\"\n",
                encoding="utf-8",
            )
            fake_ssh.chmod(0o755)

            env = os.environ.copy()
            env.update(
                {
                    "PATH": f"{temp_path}:{env.get('PATH', '')}",
                    "TARGET_IP": "192.0.2.10",  # documentation-only TEST-NET address
                    "DIAG_SCRIPT": str(ROOT / "scripts/sbat6-diagnose.sh"),
                    "SSH_ARGS_OUT": str(temp_path / "args"),
                    "SSH_STDIN_OUT": str(temp_path / "stdin"),
                }
            )
            snippet = 'ssh "root@${TARGET_IP}" \'sh -s\' < "$DIAG_SCRIPT"'
            subprocess.run(["sh", "-c", snippet], env=env, check=True, timeout=5)

            self.assertEqual(
                (temp_path / "args").read_text(encoding="utf-8").splitlines(),
                ["root@192.0.2.10", "sh -s"],
            )
            self.assertEqual(
                (temp_path / "stdin").read_bytes(),
                (ROOT / "scripts/sbat6-diagnose.sh").read_bytes(),
            )
            self.assertFalse((temp_path / "sbat6-diagnose.sh").exists())


if __name__ == "__main__":
    unittest.main()
