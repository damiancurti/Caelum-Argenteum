"""Freeze production #325 checks; packages and private saves stay local."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('quick',ROOT/'assets/validation_5422/prepare.py')
quick=importlib.util.module_from_spec(spec);spec.loader.exec_module(quick)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory',required=True)
args=parser.parse_args()
args.draft=True
assert args.directory.startswith('issue325-') and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory)
out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
files={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
manifest={'runtime_sha256':quick.seal.shared.package(out/'production.pk3',files),
    'fixture_sha256':quick.seal.shared.package(out/'quick.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "quick.zs"\n#include "bag.zs"\n#include "rest.zs"\n'+(b'#include "effects.zs"\n' if args.draft else b''),
        'quick.zs':(ROOT/'assets/validation_5422/probe.zs').read_bytes(),
        'bag.zs':(ROOT/'assets/validation_5430/probe.zs').read_bytes(),
        'rest.zs':(HERE/'issue325-probe.zs').read_bytes(),
        **({'effects.zs':(HERE/'issue325-effects.zs').read_bytes()} if args.draft else {}),
        'maps/MAP99.wad':quick.seal.wad(),
        'MAPINFO':('GameInfo { AddEventHandlers="'+('CA325Effects' if args.draft else 'CA325Probe')+'" }\ncluster 99 { hub }\nmap MAP99 "Rest safety fixture" { cluster=99 nointermission sky1="SKY1",0 }\n').encode()
    })}
start=f'wait 100; netevent c325_seed {int(args.draft)}; wait 5; '
done='netevent c325_done; wait 5; quit\n'
scripts={'safety':start+'netevent c325_safety; '+done}
for support in ('bag','bed'):
    script=start+f'netevent c325_{support}open; wait 5; netevent c325_choose; wait 10; netevent c325_accelerate; '
    if args.draft:script+='wait 3; netevent c325_accelerated; wait 5; netevent c325_skipped; '
    scripts[support]=script+done
if args.draft:
    for name,event in [('cloud','c325_cloud'),('clearnegative','c325_clearnegative'),('ruloreset','c325_ruloreset'),('mapstation','c325_mapstation'),('mapfurniture','c325_mapfurniture')]:
        scripts[name]=start+'netevent '+event+'; '+done
    scripts['cloud']=start+'netevent c325_cloud; wait 70; netevent c325_cloudended; '+done
    lie='netevent c325_bagopen; wait 5; netevent c325_choose; wait 10; '
    for kind in range(6):
        scripts[f'effect{kind}']=start+f'netevent c325_effectseed {kind}; '+lie+'netevent c325_effectmark; netevent c325_accelerate; wait 3; netevent c325_effectcheck; netevent c325_accelerated; wait 5; netevent c325_effectcheck 1; netevent c325_skipped; '+done
    scripts['attack']=start+lie+'netevent c325_accelerate; wait 3; netevent c325_newattack; netevent c325_migratepain; '+done
    scripts['regeneration']=start+'netevent c325_regenseed; '+lie+'netevent c325_effectmark; netevent c325_accelerate; wait 3; netevent c325_regencheck; '+done
    scripts['forecast']=start+'netevent c325_forecast; '+done
    for mode in range(2):
        scripts[f'danger{mode}']=start+lie+'netevent c325_accelerate; wait 3; '+f'netevent c325_danger {mode}; wait 3; netevent c325_dangercheck {mode}; '+done
    scripts['save']=start+lie+'netevent c325_accelerate; wait 3; netevent c325_saveprep; save rest-current.zds; '+done
    scripts['load']='wait 10; '+done
    for mode in range(2):
        scripts[f'death{mode}']=start+lie+'netevent c325_accelerate; wait 3; '+f'netevent c325_die {mode}; '+done
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script,encoding='utf-8',newline='\n')
spec=importlib.util.spec_from_file_location('jump_map',ROOT/'assets/validation_5212/prepare.py')
jump_map=importlib.util.module_from_spec(spec);spec.loader.exec_module(jump_map)
frozen=ROOT/'assets/validation_5439/evidence/issue339-preview01'
members={p.relative_to(frozen/'quick.pk3.sources').as_posix():p.read_bytes() for p in (frozen/'quick.pk3.sources').rglob('*') if p.is_file()}
members.update({'maps/MAPQA.wad':jump_map.test_map(),'maps/MAPQB.wad':jump_map.test_map()})
manifest['jump_fixture_sha256']=quick.seal.shared.package(out/'jump.pk3',members)
for case in ('ascent','descent','immobilized'):(out/('jump-'+case+'.cfg')).write_bytes((frozen/(case+'.cfg')).read_bytes())
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(json.dumps(manifest))
