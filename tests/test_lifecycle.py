"""Verify receipts retain ownership across failures and never claim pre-existing packages."""
from importlib.machinery import SourceFileLoader
from importlib.util import module_from_spec, spec_from_loader
from pathlib import Path
import json
import tempfile
import unittest
from unittest.mock import patch
import subprocess

SCRIPT = Path(__file__).resolve().parents[1] / 'bin/envconfig-lifecycle'


class LifecycleTests(unittest.TestCase):
    def setUp(self):
        loader = SourceFileLoader('lifecycle_test', str(SCRIPT))
        spec = spec_from_loader(loader.name, loader)
        self.mod = module_from_spec(spec)
        loader.exec_module(self.mod)
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.mod.HOME = self.base
        self.mod.STATE = self.base / 'receipt.json'
        self.mod.PROJECT = self.base / 'repo'

    def test_failed_install_reconciliation_owns_only_additions(self):
        before = dict(brew=True, formulae=['existing'], taps=['old/tap'], npm=['prettier'],
                      backups=[], hook=None, submodules=[])
        after = dict(brew=True, formulae=['existing', 'new', 'dependency'], taps=['old/tap', 'new/tap'],
                     npm=['prettier', 'pnpm', 'npm'], backups=[], hook='.githooks', submodules=['humanize'])
        state = dict(project=str(self.mod.PROJECT), pending=before)
        with patch.object(self.mod, 'snapshot', return_value=after):
            self.mod.reconcile(state)
        self.assertEqual(state['formulae'], ['dependency', 'new'])
        self.assertEqual(state['npm'], ['pnpm'])
        self.assertEqual(state['taps'], ['new/tap'])
        self.assertEqual(state['submodules'], ['humanize'])
        self.assertTrue(state['installed_hook'])
        self.assertNotIn('pending', state)

    def test_uninstall_removes_only_receipted_packages(self):
        self.mod.save(dict(project=str(self.mod.PROJECT), npm=['pnpm'], formulae=['new'], taps=['new/tap']))
        calls = []
        with patch.object(self.mod, 'npm_inventory', return_value=['pnpm', 'prettier']), \
             patch.object(self.mod, 'brew_inventory', return_value={'formulae':['new', 'existing'], 'taps':['new/tap','old/tap']}), \
             patch.object(self.mod, 'run', side_effect=lambda args, **kwargs: calls.append(args)):
            self.assertEqual(self.mod.uninstall(), 0)
        self.assertIn(['npm','uninstall','--global','pnpm'], calls)
        self.assertIn(['brew','uninstall','--formula','new'], calls)
        self.assertIn(['brew','untap','new/tap'], calls)
        self.assertNotIn('existing', sum(calls, []))
        self.assertFalse(self.mod.STATE.exists())

    def fail_brew(self, args):
        if args[0] == 'brew':
            raise subprocess.CalledProcessError(1, 'brew')

    def test_failed_package_removal_retains_receipt_for_retry(self):
        self.mod.save(dict(project=str(self.mod.PROJECT), formulae=['new']))
        with patch.object(self.mod, 'brew_inventory', return_value={'formulae':['new']}), \
             patch.object(self.mod, 'run', side_effect=lambda args, **kwargs: self.fail_brew(args)):
            with self.assertRaises(subprocess.CalledProcessError):
                self.mod.uninstall()
        self.assertEqual(json.loads(self.mod.STATE.read_text())['formulae'], ['new'])

    def test_restores_relative_skills_root_migration(self):
        harness = self.base / '.claude'
        original = harness / 'skills'
        original.mkdir(parents=True)
        previous = self.base / 'previous-skills'
        previous.mkdir()
        (previous / 'custom').mkdir()
        (original / 'custom').symlink_to(previous / 'custom')
        backup = harness / 'skills-backup-123'
        backup.mkdir()
        saved = backup / 'skills'
        saved.symlink_to('../previous-skills')
        receipt = backup / 'restore.json'
        receipt.write_text(json.dumps({'original':str(original),'backup':str(saved),'symlink_target':'../previous-skills'}))
        state = dict(project=str(self.mod.PROJECT), backups=[str(receipt)])
        self.mod.restore_skill_backups(state)
        self.assertEqual(original.resolve(), previous)
        self.assertFalse(backup.exists())

    def test_bootstrap_brew_preserves_subsequent_packages(self):
        self.mod.save(dict(project=str(self.mod.PROJECT), installed_brew=True))
        with patch.object(self.mod.shutil, 'which', return_value='/brew'), \
             patch.object(self.mod, 'brew_inventory', return_value={'formulae':['later-package']}), \
             patch.object(self.mod, 'run'):
            with self.assertRaisesRegex(RuntimeError, 'other packages'):
                self.mod.uninstall()
        self.assertTrue(self.mod.STATE.exists())


if __name__ == '__main__':
    unittest.main()
