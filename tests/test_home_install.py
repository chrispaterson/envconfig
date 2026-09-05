"""Install and uninstall against temporary homes without package operations."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class HomeInstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.repo = self.base / 'checkout with spaces'
        self.home = self.base / 'home with spaces'
        self.repo.mkdir()
        self.home.mkdir()
        for name in ['install', 'uninstall', 'lib/home-links.sh', 'bin/install-agent-skills']:
            target = self.repo / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(REPO / name, target)
        for name in ['.profile', '.gitconfig', 'AGENTS.md']:
            (self.repo / name).write_text('public defaults')
        skill = self.repo / 'agents/skills/remember'
        skill.mkdir(parents=True)
        (skill / 'SKILL.md').write_text('---\nname: remember\ndescription: Remember.\n---\n')
        self.env = dict(os.environ, HOME=str(self.home), GIT_CONFIG_NOSYSTEM='1',
                        GIT_CONFIG_GLOBAL=os.devnull)

    def run_script(self, name, *args):
        return subprocess.run(['bash', str(self.repo / name), *args], cwd=self.base,
                              env=self.env, capture_output=True, text=True)

    def test_repeat_install_and_uninstall_restore_dotfiles(self):
        (self.home / '.profile').write_text('personal profile')
        first = self.run_script('install', '--links-only')
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(self.run_script('install', '--links-only').returncode, 0)
        self.assertEqual((self.home / '.envconfig-backups/.profile').read_text(), 'personal profile')
        self.assertTrue((self.home / 'CLAUDE.md').is_symlink())
        result = self.run_script('uninstall')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.home / '.profile').read_text(), 'personal profile')
        self.assertFalse((self.home / 'CLAUDE.md').is_symlink())
        self.assertFalse((self.home / '.agents/skills/remember').is_symlink())
        self.assertEqual(self.run_script('uninstall').returncode, 0)

    def test_preserves_private_git_configuration_and_unrelated_links(self):
        (self.home / '.gitconfig').write_text('private include')
        self.assertEqual(self.run_script('install', '--links-only').returncode, 0)
        target = self.base / 'other-profile'
        target.write_text('other')
        (self.home / '.profile').unlink()
        (self.home / '.profile').symlink_to(target)
        private = self.home / '.agents/skills/work'
        private.symlink_to(self.base / 'private-skill')
        self.assertEqual(self.run_script('uninstall').returncode, 0)
        self.assertEqual((self.home / '.gitconfig').read_text(), 'private include')
        self.assertEqual((self.home / '.profile').resolve(), target)
        self.assertTrue(private.is_symlink())

    def test_retires_only_owned_legacy_agents_alias(self):
        (self.home / 'agents').symlink_to(self.repo / 'agents')
        self.assertEqual(self.run_script('install', '--links-only').returncode, 0)
        self.assertFalse((self.home / 'agents').is_symlink())
        self.assertTrue((self.repo / 'agents/skills/remember/SKILL.md').exists())
        (self.home / 'agents').mkdir()
        (self.home / 'agents/keep').write_text('keep')
        self.assertEqual(self.run_script('install', '--links-only').returncode, 0)
        self.assertEqual((self.home / 'agents/keep').read_text(), 'keep')

    def test_never_copies_old_bin_into_checkout(self):
        (self.home / 'bin').mkdir()
        (self.home / 'bin/private-script').write_text('private')
        self.assertEqual(self.run_script('install', '--links-only').returncode, 0)
        self.assertFalse((self.repo / 'bin/private-script').exists())
        self.assertEqual((self.home / '.envconfig-backups/bin/private-script').read_text(), 'private')

    def test_legacy_backups_restore_dotfiles_without_overwrite(self):
        (self.repo / '.bak').mkdir()
        (self.repo / '.bak/.profile').write_text('legacy')
        (self.home / '.profile').write_text('replacement')
        self.assertEqual(self.run_script('uninstall').returncode, 0)
        self.assertEqual((self.home / '.profile').read_text(), 'replacement')
        self.assertEqual((self.repo / '.bak/.profile').read_text(), 'legacy')
        (self.home / '.profile').unlink()
        self.assertEqual(self.run_script('uninstall').returncode, 0)
        self.assertEqual((self.home / '.profile').read_text(), 'legacy')

    def test_backup_collision_preserves_both_versions(self):
        (self.home / '.profile').write_text('current')
        (self.home / '.envconfig-backups').mkdir()
        (self.home / '.envconfig-backups/.profile').write_text('original')
        self.assertNotEqual(self.run_script('install', '--links-only').returncode, 0)
        self.assertEqual((self.home / '.profile').read_text(), 'current')
        self.assertEqual((self.home / '.envconfig-backups/.profile').read_text(), 'original')

    def test_invalid_arguments_do_not_install(self):
        self.assertNotEqual(self.run_script('install', '--unknown').returncode, 0)
        self.assertFalse((self.home / '.profile').exists())
        self.assertNotEqual(self.run_script('uninstall', '--unknown').returncode, 0)


if __name__ == '__main__':
    unittest.main()
