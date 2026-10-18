"""Reuse quick-item native launch infrastructure for issue #324 native autosave tests."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('quick',HERE.parent/'validation_5422/prepare.py')
quick=importlib.util.module_from_spec(spec);spec.loader.exec_module(quick)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
    if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in a.directory):p.error('Plain lowercase directory required')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    package=quick.seal.shared.package
    manifest={'runtime_sha256':package(out/'production.pk3',{f.relative_to(ROOT/'src').as_posix():f.read_bytes() for f in (ROOT/'src').rglob('*') if f.is_file()}),
        'fixture_sha256':package(out/'quick.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "quick.zs"\n#include "probe.zs"\n#include "legacy-data.zs"\n#include "legacy-probe.zs"\n',
            'quick.zs':(HERE.parent/'validation_5422/probe.zs').read_bytes(),'probe.zs':(HERE/'probe.zs').read_bytes(),
            'legacy-data.zs':(HERE.parent/'validation_5433/evidence/issue323-final02/data.zs').read_bytes(),
            'legacy-probe.zs':(HERE.parent/'validation_5433/probe.zs').read_bytes(),
            'maps/MAP99.wad':quick.seal.wad(),'maps/MAP98.wad':quick.seal.wad(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA324Probe" }\ncluster 99 { hub }\nmap MAP99 "Autosave fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Autosave hub" { cluster=99 nointermission sky1="SKY1",0 }\n'})}
    start='wait 70; netevent c324_seed; wait 3; netevent c324_release; wait 5; autosavecount 2; '
    done='event c324_done; wait 5; quit\n'
    commands={
        'timer.cfg':start+'event c324_arm; wait 70; event c324_saved; '+done,
        'pause.cfg':start+'pause; wait 5; event c324_arm; event c324_snapshot; wait 70; event c324_frozen; pause; wait 70; event c324_saved; '+done,
        'menu.cfg':start+'event c324_keepmenu; menu_main; wait 5; event c324_arm; event c324_snapshot; wait 70; event c324_frozen; event c324_closemenu; wait 70; event c324_saved; '+done,
        'console.cfg':start+'toggleconsole; wait 15; event c324_arm; event c324_snapshot; wait 70; event c324_frozen; toggleconsole; wait 70; event c324_saved; '+done,
        'checkpoint.cfg':start+'event c324_arm; netevent c324_checkpoint; wait 70; event c324_saved; '+done,
        'disabled.cfg':start+'disableautosave 2; event c324_arm; wait 70; event c324_saved; '+done,
        'defer.cfg':start+'netevent c324_defer; wait 35; event c324_snapshot; netevent c324_revive; wait 70; event c324_saved; '+done,
        'queued-death.cfg':start+'netevent c324_queueddeath; wait 35; netevent c324_rejected; event c324_snapshot; netevent c324_revive; wait 70; event c324_saved; '+done,
        'queued-travel.cfg':start+'event c324_arm; netevent c324_checkpoint; wait 1; changemap MAP98; wait 70; event c324_saved; '+done,
        'travel.cfg':start+'event c324_middle; wait 5; event c324_snapshot; changemap MAP98; wait 70; event c324_travelcheck; '+done,
        'travel-disabled.cfg':start+'disableautosave 1; event c324_middle; wait 5; event c324_snapshot; changemap MAP98; wait 70; event c324_travelcarry; '+done,
        'roundtrip.cfg':start+'event c324_middle; event c324_snapshot; changemap MAP98; wait 70; event c324_travelcheck; event c324_middle; event c324_snapshot; changemap MAP99; wait 70; event c324_travelcheck; '+done,
        'direct-travel.cfg':start+'event c324_arm; netevent c324_directtravel; wait 70; event c324_saved; '+done,
        'native.cfg':start+'event c324_middle; event c324_snapshot; netevent c324_native; wait 70; event c324_nativesaved; '+done,
        'native-paused.cfg':start+'event c324_middle; event c324_snapshot; pause; netevent c324_pending; netevent c324_native; wait 70; event c324_nativesaved; pause; wait 70; event c324_nativesaved; '+done,
        'cancel-travel.cfg':start+'disableautosave 1; event c324_arm; netevent c324_checkpoint; wait 2; changemap MAP98; wait 70; event c324_saved 2; '+done,
        'saved-travel.cfg':start+'disableautosave 1; event c324_arm; netevent c324_checkpoint; wait 3; changemap MAP98; wait 70; event c324_saved; '+done,
        'late-travel.cfg':start+'disableautosave 1; event c324_arm; event c324_latearm; netevent c324_checkpoint; wait 70; event c324_saved; '+done,
        'late-invalid.cfg':start+'event c324_arm; event c324_invalidarm; netevent c324_checkpoint; wait 35; netevent c324_newpending; netevent c324_revive; wait 70; event c324_saved 2; '+done,
        'consecutive.cfg':start+'event c324_middle; event c324_snapshot; netevent c324_native; wait 1; netevent c324_native; wait 70; event c324_nativesaved; '+done,
        'zero-slots.cfg':start+'autosavecount 0; event c324_arm; wait 70; event c324_saved; '+done,
        'fast.cfg':start+'event c324_snapshot; netevent c324_fast; wait 20; netevent c324_fastcheck; wait 1; event c324_fasttime; '+done,
        'manual-save.cfg':start+'event c324_middle; event c324_snapshot; storesavepic false; save manual.zds; wait 35; event c324_manualtime; '+done,
        'one-slot.cfg':start+'autosavecount 1; event c324_middle; event c324_snapshot; netevent c324_native; wait 35; event c324_nativesaved; event c324_middle; event c324_snapshot; netevent c324_native; wait 35; event c324_nativesaved; '+done,
        'slots.cfg':start+('netevent c324_checkpoint; wait 35; '*5)+done,
        'rulo.cfg':start+'netevent c324_rulo; wait 10; '+done,
        'reload.cfg':start+'event c324_arm; wait 70; event c324_saved; event c324_arm; load auto01.zds; wait 70; event c324_reloaded; '+done,
        'load.cfg':'wait 70; event c324_loaded; '+done,
        'long.cfg':start+'event c324_snapshot; wait 11200; event c324_longcheck; '+done,
        'manual.cfg':start+'netevent c282_manual; wait 5; event c324_arm 10000; event c324_done;\n'}
    for name,code in commands.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(manifest))

if __name__=='__main__':main()
