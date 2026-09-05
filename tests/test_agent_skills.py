"""Exercise shared skill installation against isolated home directories."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

INSTALLER = Path(__file__).resolve().parents[1] / 'bin' / 'install-agent-skills'


class AgentSkillsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.home = self.base / 'home with spaces'
        self.source = self.base / 'public skills'
        self.skill(self.source, 'remember')

    def skill(self, root, name):
        path = root / name
        path.mkdir(parents=True)
        (path / 'SKILL.md').write_text(f'---\nname: {name}\ndescription: Test skill.\n---\n')
        return path

    def run_install(self, *extra):
        return subprocess.run([sys.executable, str(INSTALLER), '--home', str(self.home),
                               '--source', str(self.source), *map(str, extra)],
                              capture_output=True, text=True)

    def test_shared_targets_support_resources_and_repeat_install(self):
        (self.source / 'remember' / 'reference.md').write_text('shared resource')
        (self.source / 'not-a-skill').mkdir()
        self.assertEqual(self.run_install().returncode, 0)
        for harness in ('.agents', '.claude'):
            link = self.home / harness / 'skills' / 'remember'
            self.assertEqual(link.resolve(), self.source / 'remember')
            self.assertEqual((link / 'reference.md').read_text(), 'shared resource')
            self.assertFalse((link.parent / 'not-a-skill').exists())
        self.assertIn('created 0 links', self.run_install().stdout)
        self.assertEqual(self.run_install('--check').returncode, 0)

    def test_check_is_read_only(self):
        self.assertNotEqual(self.run_install('--check').returncode, 0)
        self.assertFalse(self.home.exists())

    def test_conflicting_directory_stops_before_any_links(self):
        conflict = self.home / '.claude' / 'skills' / 'remember'
        conflict.mkdir(parents=True)
        marker = conflict / 'keep.txt'
        marker.write_text('keep')
        self.assertIn('Conflict', self.run_install().stderr)
        self.assertEqual(marker.read_text(), 'keep')
        self.assertFalse((self.home / '.agents').exists())

    def test_broken_link_is_preserved(self):
        conflict = self.home / '.claude' / 'skills' / 'remember'
        conflict.parent.mkdir(parents=True)
        conflict.symlink_to(self.base / 'missing')
        self.assertNotEqual(self.run_install().returncode, 0)
        self.assertTrue(conflict.is_symlink())
        self.assertFalse((self.home / '.agents').exists())

    def test_multiple_sources_and_duplicate_names(self):
        private = self.base / 'private'
        self.skill(private, 'work-skill')
        self.assertEqual(self.run_install('--source', private).returncode, 0)
        self.assertEqual((self.home / '.agents/skills/work-skill').resolve(), private / 'work-skill')
        self.skill(private, 'remember')
        self.assertIn('Duplicate skill', self.run_install('--source', private).stderr)
        self.assertEqual((self.home / '.claude/skills/remember').resolve(), self.source / 'remember')

    def test_missing_and_empty_sources_fail_without_changes(self):
        for source in [self.base / 'missing', self.base / 'empty']:
            if source.name == 'empty':
                source.mkdir()
            self.assertNotEqual(self.run_install('--source', source).returncode, 0)
            self.assertFalse(self.home.exists())

    def test_symlinked_discovery_parent_is_rejected(self):
        self.home.mkdir()
        target = self.base / 'tracked-config'
        target.mkdir()
        (self.home / '.claude').symlink_to(target, target_is_directory=True)
        self.assertIn('real directory', self.run_install().stderr)
        self.assertEqual(list(target.iterdir()), [])
        self.assertFalse((self.home / '.agents').exists())


if __name__ == '__main__':
    unittest.main()
