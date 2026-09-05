"""Exercise the guard against a real Git index, without touching user files."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


CHECK = Path(__file__).resolve().parents[1] / "bin" / "check-agent-memory"


class MemoryGuardTests(unittest.TestCase):
    def setUp(self):
        self.env = dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM='1')
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git("init", "-q")
        self.memory = self.root / "agents/memory/test note.md"
        self.memory.parent.mkdir(parents=True)
        self.memory.write_text("Synthetic memory for an isolated test.\n")

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.root, check=True, capture_output=True, env=self.env
        )

    def check(self, cwd=None):
        return subprocess.run(
            ["sh", str(CHECK)], cwd=cwd or self.root, capture_output=True, env=self.env
        ).returncode

    def test_normal_skill_and_untracked_memory_are_allowed(self):
        skill = self.root / "agents/skills/example/SKILL.md"
        skill.parent.mkdir(parents=True)
        skill.write_text("Example skill.\n")
        self.git("add", "agents/skills")
        self.assertEqual(self.check(), 0)

    def test_forced_addition_is_rejected(self):
        (self.root / ".gitignore").write_text("/agents/memory/\n")
        self.git("add", "-f", "agents/memory/test note.md")
        self.assertEqual(self.check(), 1)

    def test_subdirectory_invocation_checks_repository_root(self):
        self.git("add", "agents/memory")
        self.assertEqual(self.check(self.root / "agents"), 1)

    def test_staged_removal_preserves_local_memory(self):
        self.git("add", "agents/memory")
        self.git("rm", "--cached", "agents/memory/test note.md")
        self.assertEqual(self.check(), 0)
        self.assertEqual(
            self.memory.read_text(), "Synthetic memory for an isolated test.\n"
        )


if __name__ == "__main__":
    unittest.main()
