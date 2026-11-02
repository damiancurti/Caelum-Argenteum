"""Check match isolation and native startup boundaries without launching a game."""
import json
from pathlib import Path
import sys
import unittest
import uuid

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
import caelum_standalone as launcher
from caelum_profiles import ProfileError


class StandaloneLauncherTests(unittest.TestCase):
    def setUp(self):
        self.root=ROOT/'build/issue597/python-tests'/uuid.uuid4().hex
        self.root.mkdir(parents=True)
        self.engine=self.root/'engine/gzdoom.exe';self.engine.parent.mkdir()
        for name in ('gzdoom.exe','gzdoom.pk3','game_support.pk3','game_widescreen_gfx.pk3'):
            (self.engine.parent/name).write_bytes(name.encode())
        self.iwad=self.root/'development.wad';self.iwad.write_bytes(b'private development dependency')
        import zipfile
        self.package=self.root/'runtime.pk3'
        with zipfile.ZipFile(self.package,'w') as z:
            z.writestr('KEYCONF','alias ca_controls_defaults "bind t +user3"\n')
            z.writestr('caelum/data/standalone.mapinfo','gameinfo { PlayerClasses="CaelumStandalonePlayer" }\n')
        self.selection=launcher.request(launcher.MARKER+'0|2|3|4|32480|1|127.0.0.1|')

    def test_fresh_host_and_guest_preserve_campaign_files(self):
        campaign=self.root/'campaign.zds';campaign.write_bytes(b'existing save sentinel')
        registry=self.root/'profiles.sqlite3';registry.write_bytes(b'existing registry sentinel')
        cmd,host=launcher.prepare(self.selection,self.root/'host',self.engine,self.iwad,[self.package])
        shared=self.root/'host/session.json'
        guest=self.selection|dict(role=1,mode=0,venue=0,preset=1,session=str(shared))
        command,joined=launcher.prepare(guest,self.root/'guest',self.engine,self.iwad,[self.package])
        self.assertEqual(host,joined)
        self.assertEqual(command[command.index('+ca_standalone_mode')+1],'3')
        self.assertEqual(command[command.index('+ca_standalone_preset')+1],'1')
        self.assertNotIn('-loadgame',cmd+command)
        self.assertNotIn('--store',cmd+command)
        self.assertEqual(campaign.read_bytes(),b'existing save sentinel')
        self.assertEqual(registry.read_bytes(),b'existing registry sentinel')
        self.assertNotEqual(cmd[cmd.index('-savedir')+1],command[command.index('-savedir')+1])

    def test_changed_package_prevents_join(self):
        launcher.prepare(self.selection,self.root/'host',self.engine,self.iwad,[self.package])
        self.package.write_bytes(b'changed runtime')
        with self.assertRaises(ProfileError):
            launcher.prepare(self.selection|dict(role=1,session=str(self.root/'host/session.json')),
                             self.root/'guest',self.engine,self.iwad,[self.package])
        self.assertFalse((self.root/'guest/command.json').exists())

    def test_existing_participant_directory_is_not_overwritten(self):
        launcher.prepare(self.selection,self.root/'host',self.engine,self.iwad,[self.package])
        before=(self.root/'host/session.json').read_bytes()
        with self.assertRaises(FileExistsError):
            launcher.prepare(self.selection,self.root/'host',self.engine,self.iwad,[self.package])
        self.assertEqual((self.root/'host/session.json').read_bytes(),before)

    def test_menu_rejects_shell_text_and_out_of_range_parameters(self):
        for value in ('0|0|0|2|32480|0|localhost;quit|','0|0|0|9|32480|0|localhost|',
                      '0|4|0|2|32480|0|localhost|','0|0|4|2|32480|0|localhost|',
                      '0|0|0|2|65535|0|localhost|','0|0|0|2|32480|0|localhost|a\nb'):
            with self.subTest(value=value),self.assertRaises(ValueError):
                launcher.request(launcher.MARKER+value)


if __name__=='__main__':unittest.main()
