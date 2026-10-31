"""Check backend routing without opening apps or starting project processes."""
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / 'project'
loader = importlib.machinery.SourceFileLoader('project_launcher', str(SOURCE))
spec = importlib.util.spec_from_loader(loader.name, loader)
launcher = importlib.util.module_from_spec(spec)
loader.exec_module(launcher)


class ProjectTests(unittest.TestCase):
    def command(self, flags, env=None):
        with patch.object(Path, 'is_dir', return_value=True):
            return launcher.build_command(launcher.parse(flags), Path('/tmp/Project $(touch nope)'), env or {})

    def test_rex_options_are_forwarded_as_arguments(self):
        cmd = self.command(['--rex', '--name', 'review', '--no-attach', '--client', 'anthill'])
        self.assertEqual(Path(cmd[0]).name, 'rex-project')
        self.assertEqual(cmd[1:], ['/tmp/Project $(touch nope)', '--name', 'review', '--no-attach', '--client', 'anthill'])

    def test_herdr_attaches_directly_in_plain_ghostty(self):
        cmd = self.command(['--herdr'], {'TERM_PROGRAM': 'ghostty'})
        self.assertEqual(Path(cmd[0]).name, 'herdr-project')

    def test_herdr_from_rex_or_herdr_opens_ghostty(self):
        for env in ({'REX_SESSION': 'session:existing'}, {'TERM_PROGRAM': 'ghostty', 'HERDR_ENV': '1'}, {}):
            with self.subTest(env=env):
                cmd = self.command(['--herdr', '--name', 'review'], env)
                self.assertEqual(cmd[:4], ['/usr/bin/open', '-na', '/Applications/Ghostty.app', '--args'])
                self.assertEqual(cmd[4], '--working-directory=/tmp/Project $(touch nope)')
                self.assertEqual(cmd[5:8], ['-e', '/bin/zsh', '-lic'])
                self.assertIn('unset HERDR_ENV REX_SESSION', cmd[8])
                self.assertEqual(Path(cmd[-4]).name, 'herdr-project')
                self.assertEqual(cmd[-3:], ['/tmp/Project $(touch nope)', '--name', 'review'])

    def test_headless_herdr_never_opens_an_app(self):
        cmd = self.command(['--herdr', '--no-attach'], {'REX_SESSION': 'session:existing'})
        self.assertEqual(Path(cmd[0]).name, 'herdr-project')
        self.assertEqual(cmd[-1], '--no-attach')

    def test_standalone_ghostty_keeps_existing_launcher(self):
        cmd = self.command(['--ghostty'])
        self.assertEqual(Path(cmd[0]).name, 'project-open')

    def test_unsupported_options_fail_before_launching(self):
        for flags in (['--herdr', '--client', 'anthill'], ['--ghostty', '--name', 'x'], ['--ghostty', '--no-attach']):
            with self.subTest(flags=flags), self.assertRaises(ValueError):
                self.command(flags)

    def test_no_terminal_requires_an_explicit_choice(self):
        with patch.object(launcher.sys.stdin, 'isatty', return_value=False):
            with self.assertRaisesRegex(ValueError, 'choose --rex'):
                launcher.choose()

    def test_picker_cancel_and_choice(self):
        with patch.object(launcher.sys.stdin, 'isatty', return_value=True), patch.object(launcher.shutil, 'which', return_value='/bin/fzf'):
            with patch.object(launcher.subprocess, 'run', return_value=subprocess.CompletedProcess([], 130, '')):
                self.assertIsNone(launcher.choose())
            with patch.object(launcher.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'Ghostty + Herdr\n')):
                self.assertEqual(launcher.choose(), 'herdr')

    def test_numbered_fallback(self):
        with patch.object(launcher.sys.stdin, 'isatty', return_value=True), patch.object(launcher.shutil, 'which', return_value=None), patch('builtins.input', return_value='1'), patch.object(launcher.sys, 'stderr'):
            self.assertEqual(launcher.choose(), 'rex')

    def test_real_dispatch_preserves_paths_git_root_and_exit_status(self):
        with tempfile.TemporaryDirectory(prefix='project-launcher-') as temporary:
            base = Path(temporary).resolve()
            binary = base / 'bin'
            binary.mkdir()
            shutil.copy2(SOURCE, binary / 'project')
            for name in ('rex-project', 'herdr-project', 'project-open'):
                helper = binary / name
                helper.write_text('#!' + sys.executable + '\nimport json, os, sys\nprint(json.dumps(sys.argv))\nsys.exit(int(os.environ.get("PROJECT_FIXTURE_EXIT", "0")))\n')
                helper.chmod(0o755)
            root = base / 'Project spaces $(touch INJECTED)'
            nested = root / 'nested'
            nested.mkdir(parents=True)
            subprocess.run(['git', 'init', '-q', str(root)], check=True)
            for flag, helper in (('--rex', 'rex-project'), ('--herdr', 'herdr-project'), ('--ghostty', 'project-open')):
                args = [str(binary / 'project'), flag, str(nested)]
                if flag == '--herdr':
                    args.append('--no-attach')
                result = subprocess.run(args, capture_output=True, text=True, check=True)
                invoked = json.loads(result.stdout)
                self.assertEqual(Path(invoked[0]).name, helper)
                self.assertEqual(invoked[1], str(root))
            self.assertFalse((root / 'INJECTED').exists())
            result = subprocess.run([str(binary / 'project'), '--rex', str(root)],
                                    env=dict(os.environ, PROJECT_FIXTURE_EXIT='7'), capture_output=True)
            self.assertEqual(result.returncode, 7)
            result = subprocess.run([str(binary / 'project'), str(root)], stdin=subprocess.DEVNULL, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('choose --rex', result.stderr)


if __name__ == '__main__':
    unittest.main()
