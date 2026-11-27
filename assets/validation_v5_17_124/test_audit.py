"""Run with a local two-player GZDoom save, engine resource archive and Caelum PK3.

python test_audit.py <two-player.zds> <gzdoom.pk3> <caelum_argenteum_dev.pk3>
"""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import sqlite3
import struct
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT), str(ROOT / 'assets/generators'), str(ROOT / 'assets/validation_v5_12_6')]
from campaign_fixture import independent_world
from caelum_campaigns import Campaigns, pack, personal_record, unpack
from caelum_profile_graph import NativeSchema, PersonalGraph
from caelum_profiles import ProfileError, ProfileStore
from caelum_sessions import Sessions, participant_lock, watch
import caelum_standalone as standalone
from generate_cartography_catalogue import blob_checksum
from source_integrity import matches_source_digest


class RecoveryTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.store = ProfileStore(self.root / 'profiles.sqlite3', create=True)
        self.addCleanup(self.store.close)
        self.worlds = Campaigns(self.store, adapter)
        self.sessions = Sessions(self.worlds)

    def vacant(self, name):
        members, map_name, level = unpack(independent_world(seed, name))
        for slot in range(2):
            personal_record(level, slot)['ProfileCommitted'] = 0
        return self.worlds.register(name, pack(members, map_name, level))

    def test_vacancies_are_retained_and_cannot_change_world(self):
        head = self.vacant('first')
        other = self.vacant('other')
        original = self.store.anchor(head['snapshot'])
        members, name, level = unpack(original)
        level['players'].pop()
        truncated = pack(members, name, level)
        for bad in (truncated, self.store.anchor(other['snapshot'])):
            with self.assertRaises(ProfileError):
                self.worlds.checkpoint('first', bad, 0)
            self.assertEqual(self.worlds.head('first'), head)
        # Simulate a coordinator that already accepted the truncated file.
        with self.store.transaction():
            bad_id = self.store._snapshot(truncated, 0)
            self.store.connection.execute('UPDATE campaigns SET snapshot=? WHERE identity=?', (bad_id, 'first'))
        restored = self.worlds.checkpoint('first', original, 0)
        self.assertEqual(restored['snapshot'], head['snapshot'])
        # The same repair is safe if an old coordinator mixed two vacant worlds.
        with self.store.transaction():
            self.store.connection.execute('UPDATE campaigns SET snapshot=? WHERE identity=?', (other['snapshot'], 'first'))
        self.assertEqual(self.worlds.checkpoint('first', original, restored['revision'])['snapshot'], head['snapshot'])

    def test_legacy_desync_can_recover_to_its_last_good_checkpoint(self):
        head = self.worlds.register('world', seed)
        good = self.store.anchor(head['snapshot'])
        members, name, level = unpack(good)
        level['players'][1]['inconsistant'] = 72
        desynced = pack(members, name, level)
        with self.assertRaisesRegex(ProfileError, 'desynchronization'):
            self.worlds.checkpoint('world', desynced, 0)
        with self.store.transaction():
            bad_id = self.store._snapshot(desynced, 0)
            self.store.connection.execute('UPDATE campaigns SET snapshot=? WHERE identity=?', (bad_id, 'world'))
        with self.assertRaisesRegex(ProfileError, 'desynchronization'):
            self.sessions.prepare('world', {}, 'refused')
        self.assertEqual(self.worlds.checkpoint('world', good, 0)['snapshot'], head['snapshot'])
        self.assertEqual(self.store.anchor(bad_id), desynced)

    def test_failed_export_and_failed_commit_allow_retry(self):
        self.worlds.register('world', seed)
        share = self.root / 'share'
        share.mkdir()
        sentinel = share / 'mine.txt'
        sentinel.write_text('mine')
        with self.assertRaises(FileExistsError):
            self.sessions.prepare('world', {}, 'occupied', directory=share)
        self.assertEqual(sentinel.read_text(), 'mine')
        # A concurrent reader prevents COMMIT after the invitation was written.
        db = self.store.connection
        db.execute('PRAGMA busy_timeout=25')
        reader = sqlite3.connect(self.store.path)
        try:
            reader.execute('BEGIN')
            reader.execute('SELECT * FROM campaigns').fetchall()
            with self.assertRaises(sqlite3.OperationalError):
                self.sessions.prepare('world', {}, 'busy', directory=self.root / 'retry')
        finally:
            reader.close()
        self.assertFalse((self.root / 'retry').exists())
        self.assertEqual(db.execute('SELECT COUNT(*) FROM campaign_locks').fetchone()[0], 0)
        self.assertEqual(db.execute('SELECT COUNT(*) FROM network_sessions').fetchone()[0], 0)
        self.sessions.prepare('world', {}, 'ready', directory=self.root / 'retry')
        self.assertEqual(json.loads((self.root / 'retry/session.json').read_bytes())['token'], 'ready')

    def test_invalid_transfer_slots_keep_custody(self):
        head = self.worlds.register('world', seed)
        target = self.vacant('dest')
        identity = personal_record(unpack(self.store.anchor(head['snapshot']))[2], 0)['ExternalProfileId']
        for slot in (-1, 2, 8):
            with self.assertRaises(ProfileError):
                self.worlds.stage(identity, 'dest', slot, 'bad')
        self.assertEqual(self.worlds.head('dest'), target)
        self.assertEqual(self.store.get(identity).campaign, 'world')

    def test_failed_admission_and_post_admission_exit(self):
        sessions = Mock()
        sessions.get.return_value = {'request': {'nonce': 12}}
        process = Mock(returncode=0)
        process.poll.return_value = 0
        path = self.root / 'engine.log'
        path.write_text('CA_SESSION READY peer=0 nonce=123\n')
        self.assertEqual(watch(process, self.root, sessions, 't', 0), 1)
        sessions.failed_start.assert_called_once_with('t', 0)
        sessions.finished.assert_not_called()
        sessions.reset_mock()
        path.write_text('CA_SESSION READY peer=0 nonce=12\nCA_SESSION REJECT peer=1\n')
        self.assertEqual(watch(process, self.root, sessions, 't', 0), 1)
        sessions.finished.assert_called_once_with('t', 0)
        sessions.failed_start.assert_not_called()
        sessions.publish.assert_not_called()

    def test_guest_slot_released_after_failed_or_completed_attempt(self):
        with participant_lock(self.root, 1):
            with self.assertRaises(ProfileError), participant_lock(self.root, 1):
                self.fail('second launch admitted')
        with participant_lock(self.root, 1):
            self.assertTrue((self.root / 'peer1.lock').is_file())


class ToolTests(unittest.TestCase):
    def test_guest_handles_invalid_shapes_and_prints_real_invitation(self):
        selection = dict(role=1, mode=0, preset=0, players=2, port=5029, venue=0, host='localhost', session='')
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = root / 'invite.json'
            selection['session'] = str(path)
            data = dict(revision=2, mode=0, venue=0, players=2, port=5029, palomo=0)
            for i, bad in enumerate([None, [], 0, 'data', {}, {**data, 'players': True},
                                     {**data, 'mode': '0'}, {**data, 'manifest': []}]):
                path.write_text(json.dumps(bad))
                with self.subTest(value=bad), self.assertRaises((ProfileError, ValueError)):
                    standalone.prepare(selection, root / str(i), root, root, [root])
            path.write_text(json.dumps(data))
            def call(command):
                if '+logfile' in command and not getattr(call, 'sent', False):
                    call.sent = True
                    Path(command[command.index('+logfile') + 1]).write_text(
                        standalone.MARKER + f'1|0|0|2|5029|0|localhost|{path}\n')
                return 0
            (root / 'game.ini').touch()
            output = io.StringIO()
            with patch.object(standalone.subprocess, 'call', side_effect=call), \
                 patch.object(standalone, 'prepare', return_value=(['engine'], data)), contextlib.redirect_stdout(output):
                standalone.run_menu(root, root, [root], root / 'game.ini', root / 'guest')
            self.assertIn('Session: ' + str(path.resolve()), output.getvalue())

    def test_legacy_reload_pins_engine_iwad_and_package(self):
        spec = importlib.util.spec_from_file_location('terminal', ROOT / 'assets/validation_v5_17_123/sessions.py')
        terminal = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(terminal)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            previous = root / 'build/author-889/old'
            previous.mkdir(parents=True)
            engine, iwad, addon, ini, cfg, save = [previous / n for n in ('engine','iwad','addon','game.ini','start.cfg','save.zds')]
            for item in (engine, iwad, addon, ini, cfg, save):
                item.write_bytes(item.name.encode())
            out = previous.parent / 'next'
            command = [str(engine), '-iwad',str(iwad),'-file',str(addon),'-config',str(ini),
                       '-savedir',str(previous),'+logfile',str(previous/'log'),'+exec',str(cfg)]
            data = dict(issue=889, command=command, packages={str(addon):terminal.sha(addon)}, engine_sha256=terminal.sha(engine))
            terminal.write_json(previous / 'session.json', data)
            expected = terminal.sha(iwad)
            with patch.object(terminal, 'ROOT', root), patch.object(terminal, 'no_engine'):
                with self.assertRaisesRegex(ValueError, 'original-iwad'):
                    terminal.reload_session(previous, save, out)
                for item in (engine, iwad, addon):
                    original = item.read_bytes()
                    item.write_bytes(original + b'!')
                    with self.assertRaises(ValueError):
                        terminal.reload_session(previous, save, out, original_iwad_sha256=expected)
                    self.assertFalse(out.exists())
                    item.write_bytes(original)
                record = terminal.reload_session(previous, save, out, original_iwad_sha256=expected)
                self.assertEqual(record['iwad_sha256'], expected)
                self.assertEqual((out / 'restore.zds').read_bytes(), save.read_bytes())

    def test_source_integrity_and_missing_map_diagnostic(self):
        with tempfile.TemporaryDirectory() as tmp:
            text = Path(tmp) / 'source.obj'
            text.write_bytes(b'one\ntwo\n')
            digest = hashlib.sha256(b'one\r\ntwo\r\n').hexdigest()
            self.assertTrue(matches_source_digest(text, digest))
            binary = text.rename(text.with_suffix('.wad'))
            self.assertFalse(matches_source_digest(binary, digest))
            text.write_bytes(b'one\nchanged\n')
            self.assertFalse(matches_source_digest(text, digest))
        with self.assertRaisesRegex(ValueError, 'Missing TEXTMAP: example.wad'):
            blob_checksum(struct.pack('<4sii', b'PWAD', 0, 12), 'example.wad')

    @unittest.skipUnless(os.name == 'nt', 'requires Windows cmd.exe and Windows PowerShell')
    def test_native_batch_path_with_exclamation(self):
        with tempfile.TemporaryDirectory() as tmp:
            project = Path(tmp) / 'Caelum ! test'
            project.mkdir()
            (project / 'engine.exe').touch()
            (project / 'iwad.wad').touch()
            source = (ROOT / 'run_dev.bat').read_text()
            # Supply local stand-ins for the two installation-specific filenames.
            for variable, filename in [('GZDOOM_EXE','engine.exe'), ('DOOM2_IWAD','iwad.wad')]:
                source = re.sub(r'set "' + variable + r'=[^"]+"',
                                lambda _: f'set "{variable}=!PROJECT_ROOT!{filename}"', source)
            (project / 'run_dev.bat').write_text(source, encoding='utf-8')
            (project / 'build_dev.ps1').write_text(
                "[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'flags.txt'), ($args -join ','))")
            (project / 'caelum_standalone.py').write_text(
                "from pathlib import Path\nimport sys, json\n"
                "Path(__file__).with_name('launch.json').write_text(json.dumps(sys.argv[1:]))\n")
            flags = re.findall(r'if /I "%~1"=="(--legacy-[^"]+)"', source, flags=re.I)
            run = subprocess.run([os.environ['COMSPEC'], '/d', '/c', 'run_dev.bat', *flags],
                                 cwd=project, input='\n', text=True, capture_output=True, timeout=60)
            self.assertEqual(run.returncode, 0, run.stdout + run.stderr)
            self.assertEqual(len((project / 'flags.txt').read_text(encoding='utf-8-sig').split(',')), 13)
            argv = json.loads((project / 'launch.json').read_text())
            self.assertEqual(Path(argv[argv.index('--package')+1]), project / 'build/caelum_argenteum_dev.pk3')
            self.assertEqual(Path(argv[argv.index('--config')+1]), project / 'build/gzdoom.ini')

    def test_batch_forwards_all_legacy_switches(self):
        builder = (ROOT / 'build_dev.ps1').read_text()
        batch = (ROOT / 'run_dev.bat').read_text()
        required = set(re.findall(r'\[switch\]\$(Legacy\w+)', builder))
        exposed = set(re.findall(r'set "BUILD_MAP_OPTION=!BUILD_MAP_OPTION! -(Legacy\w+)"', batch))
        self.assertEqual(required, exposed)
        self.assertEqual(len(required), 13)
        self.assertLess(batch.index('DisableDelayedExpansion'), batch.index('%~dp0'))
        self.assertLess(batch.index('%~dp0'), batch.index('EnableDelayedExpansion'))
        self.assertNotIn('%PROJECT_ROOT%', batch)


if __name__ == '__main__':
    save, engine_resource, package = map(Path, sys.argv[1:4])
    seed = save.read_bytes()
    adapter = PersonalGraph(NativeSchema(engine_resource, package))
    unittest.main(argv=[sys.argv[0]], verbosity=2)
