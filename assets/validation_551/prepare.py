"""Reuse #309 inputs and add #310 paired dispatch observations in a fresh directory."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--runtime',type=Path)
    args=parser.parse_args()
    command=[sys.executable,'-X','utf8',str(HERE.parent/'validation_550/prepare.py'),'--directory',args.directory]
    if args.runtime: command+=['--runtime',str(args.runtime)]
    subprocess.run(command,cwd=ROOT,check=True)
    out=ROOT/'build'/args.directory
    with zipfile.ZipFile(out/'quick.pk3') as z: members={n:z.read(n) for n in z.namelist()}
    # Preserve real reserves when testing interruption by an equipment change.
    audit=members['probe.zs'].decode('utf-8')
    audit=audit.replace('bool isolated=true)','bool isolated=true,bool refill=true)')
    audit=audit.replace('User.CurrentAir=User.DerivedStats.MaximumAir;User.CurrentAnima=User.DerivedStats.MaximumAnima;',
        'if(refill){User.CurrentAir=User.DerivedStats.MaximumAir;User.CurrentAnima=User.DerivedStats.MaximumAnima;}')
    members['probe.zs']=audit.encode('utf-8')
    members['ZSCRIPT']+=b'#include "dispatch.zs"\n'
    members['dispatch.zs']=(HERE/'probe.zs').read_bytes()
    members['MAPINFO']=members['MAPINFO'].replace(b'AddEventHandlers="CA309Probe"',b'AddEventHandlers="CA309Probe","CA310Probe"')
    with zipfile.ZipFile(out/'quick.pk3','w',zipfile.ZIP_STORED) as z:
        for n,b in sorted(members.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
    # Type, input, distance, charged, resource-empty, expected native animation.
    cases=[(0,'attack',80,0,0,1),(0,'altattack',80,0,0,1),
        (13,'attack',80,0,0,1),(13,'altattack',80,0,0,1),
        (12,'zoom',80,0,0,1),(2,'attack',256,0,0,1),(2,'altattack',256,0,0,0),
        (1,'attack',256,0,0,1),(1,'altattack',256,1,0,1),
        (17,'attack',256,0,0,1),(18,'altattack',256,0,0,1),(19,'attack',256,1,0,1),
        (6,'altattack',80,0,0,1),(6,'altattack',512,0,0,1),
        (21,'attack',256,0,0,0),(21,'altattack',256,0,0,0),(22,'attack',256,0,0,0),
        (0,'attack',80,0,1,2),(1,'attack',256,0,1,2),(9,'altattack',80,0,0,2)]
    start='wait 100; netevent c309_setup; wait 35; '
    finish='netevent c309_done; wait 35; quit\n'
    for i,(kind,button,distance,charged,empty,expect) in enumerate(cases):
        line=f'netevent c309_equip {kind} 1 0; wait 70; '
        if charged: line+='+reload; wait 1; -reload; wait 70; '
        if kind==22: line+='+altattack; wait 35; -altattack; '
        hold=35 if kind==21 else 1
        line+=f'netevent c310_begin {i} {distance} {empty}; +{button}; wait {hold}; -{button}; wait 100; netevent c310_end {expect}; '
        tail=f'exec pair-{i+1:02d}.cfg\n' if i+1<len(cases) else finish
        (out/f'pair-{i:02d}.cfg').write_text(line+tail,encoding='utf-8')
    (out/'paired.cfg').write_text(start+'exec pair-00.cfg\n',encoding='utf-8')
    (out/'sweep.cfg').write_text(start+'netevent c309_equip 12 1 0; wait 70; netevent c310_begin 4 80 0; +zoom; wait 1; -zoom; wait 100; netevent c310_end 1; '+finish,encoding='utf-8')
    (out/'authority.cfg').write_text(start+'netevent c309_equip 0 1 0; wait 70; netevent c310_authority 0; '+finish,encoding='utf-8')
    (out/'two-pawns.cfg').write_text(start+'addbot; wait 70; netevent c309_equip 0 1 0; wait 70; netevent c310_authority 1; '+finish,encoding='utf-8')
    # A separate current-only addon can reference the newly introduced service.
    guards=dict(members)
    guards['ZSCRIPT']+=b'#include "guards.zs"\n'
    guards['guards.zs']=(HERE/'guards.zs').read_bytes()
    guards['MAPINFO']=guards['MAPINFO'].replace(b'"CA309Probe","CA310Probe"',b'"CA309Probe","CA310Probe","CA310Guards"')
    with zipfile.ZipFile(out/'guards.pk3','w',zipfile.ZIP_STORED) as z:
        for n,b in sorted(guards.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
    (out/'guards.cfg').write_text(start+'netevent c310_guards; '+finish,encoding='utf-8')
    for kind in (0,1):
        seed=start+f'netevent c309_equip {kind} 1 0; wait 70; netevent c310_begin 100 80 0; +attack; wait 1; -attack; '
        for stop in ('stun','death'):
            event='c309_stun' if stop=='stun' else 'c310_death'
            check='c310_cancelled' if stop=='stun' else 'c310_dead_checked'
            (out/f'{stop}-{kind}.cfg').write_text(seed+f'netevent {event}; wait 100; netevent {check}; netevent c310_no_hit; '+finish,encoding='utf-8')
        if kind==1:
            (out/'switch-cast.cfg').write_text(seed+'netevent c310_switch_cast; wait 100; netevent c310_cancelled; netevent c310_no_hit; '+finish,encoding='utf-8')
    manifest_guard=hashlib.sha256((out/'guards.pk3').read_bytes()).hexdigest()
    manifest=json.loads((out/'manifest.json').read_text(encoding='utf-8'))
    manifest['fixture_sha256']=hashlib.sha256((out/'quick.pk3').read_bytes()).hexdigest()
    manifest['script_hashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.glob('*.cfg'))}
    manifest['paired_cases']=cases
    manifest['guards_sha256']=manifest_guard
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Prepared #310 paired observations; reused #309 scripts and runner unchanged.')

if __name__=='__main__':main()
