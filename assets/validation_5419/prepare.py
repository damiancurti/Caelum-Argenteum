"""Freeze Redemption runtime and focused deterministic native fixtures."""
from pathlib import Path
import argparse,importlib.util,json,zipfile,hashlib
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True);p.add_argument('--maps',type=Path,required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
with zipfile.ZipFile(a.maps) as z:entries={name:z.read(name) for name in ['maps/MAP99.wad','maps/MAP98.wad','maps/MAP97.wad']}
entries.update({'ZSCRIPT':b'version "4.14"\n#include "redemption.zs"\n',
    'redemption.zs':(HERE/'redemption.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA250Probe" }\ncluster 99 { hub }\nmap MAP99 "Redemption fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Redemption destination" { cluster=99 sky1="SKY1",0 }\nmap MAP97 "Redemption low ceiling" { cluster=99 sky1="SKY1",0 }\n'})
manifest={'runtime_sha256':room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}),
    'fixture_sha256':room.package(out/'redemption.pk3',entries),
    'reused_map_fixture_sha256':hashlib.sha256(a.maps.read_bytes()).hexdigest()}
start='wait 100; netevent c250_setup; wait 5; '
done='netevent c250_done; wait 2; quit\n'
scripts={
 'save-prep.cfg':start+'netevent c250_corpses; wait 40; +user4; wait 35; -user4; netevent c250_partial; save preparation.zds; wait 2; '+done,
 'load-prep.cfg':'wait 1; netevent c250_prep_loaded; wait 90; netevent c250_loaded_cast; '+done,
 'manual.cfg':'language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c250_manual; wait 5; netevent c250_manual_corpses"; bind f7 "netevent c250_ready"; bind f8 "netevent c250_manual_late"; bind f9 "changemap MAP98"; bind f10 "netevent c250_manual_journey"; wait 100; netevent c250_manual; wait 5; netevent c250_manual_corpses; netevent c250_done;\n',
 'preview.cfg':'language es; con_notifytime 0; wait 100; netevent c250_manual; wait 5; netevent c250_manual_corpses; wait 40; screenshot before.png; +user4; wait 110; -user4; netevent c250_cast; screenshot active.png; wait 360; screenshot expired.png; '+done,
 'defense.cfg':start+'netevent c250_defense; '+done,
 'casting.cfg':start+'netevent c250_corpses; wait 40; +user4; wait 35; -user4; netevent c250_partial; wait 2; +user4; wait 2; -user4; netevent c250_cancel; wait 5; +user4; wait 110; -user4; netevent c250_cast; '+done,
 'player.cfg':start+'netevent c250_player; '+done,
 'combat.cfg':start+'netevent c250_native; wait 5; netevent c250_follow; wait 140; netevent c250_followed; wait 280; netevent c250_combat; '+done,
 'contract.cfg':start+'netevent c250_corpses; wait 40; netevent c250_release; wait 30; netevent c250_before; wait 6; netevent c250_after; wait 40; netevent c250_expire; '+done,
 'cure.cfg':start+'netevent c250_cure; '+done,
 'renew.cfg':start+'netevent c250_renew; '+done,
 'friendly.cfg':start+'netevent c250_friendly; '+done,
 'fit.cfg':start+'netevent c250_fit; '+done,
 'journey.cfg':start+'netevent c250_seed; netevent c250_journey; '+done,
 'death.cfg':start+'netevent c250_seed; netevent c250_kill_caster; wait 2; netevent c250_dead_caster; '+done,
 'save.cfg':start+'netevent c250_seed; wait 10; save redemption.zds; wait 2; '+done,
 'load.cfg':'wait 1; netevent c250_loaded; changemap MAP98; wait 10; netevent c250_loaded; netevent c250_placed; changemap MAP99; wait 10; netevent c250_loaded; '+done,
 'pending.cfg':start+'netevent c250_seed; changemap MAP97; wait 40; netevent c250_loaded; netevent c250_pending; save pending.zds; wait 2; '+done,
 'pending-load.cfg':'wait 1; netevent c250_loaded; netevent c250_pending; changemap MAP98; wait 10; netevent c250_loaded; netevent c250_placed; '+done,
 'pending-expire.cfg':'wait 1; netevent c250_loaded; netevent c250_pending; wait 400; netevent c250_pending_expired; '+done,
}
for name,code in scripts.items():(out/name).write_bytes(code.encode())
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest))
