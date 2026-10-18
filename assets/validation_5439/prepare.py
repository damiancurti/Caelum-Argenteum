"""Freeze matched native voluntary-jump wall fixtures without shipping packages."""
from pathlib import Path
import argparse
import importlib.util
import json
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True)
p.add_argument('--baseline',action='store_true')
a=p.parse_args()
assert a.directory.startswith('issue339-') and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in a.directory)
spec=importlib.util.spec_from_file_location('old',ROOT/'assets/validation_5212/prepare.py')
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
probe=(HERE/'probe.zs').read_text(encoding='utf-8')
if a.baseline:
    subprocess.run(['git','archive','--format=zip',f'--output={out/"baseline-source.pk3"}','29c7dcb2:src'],check=True,cwd=ROOT)
    with zipfile.ZipFile(out/'baseline-source.pk3') as z: members={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
    probe=probe.replace('return User.VoluntaryJumpActive;','return false;').replace('bool Updated() { return true; }','bool Updated() { return false; }')
    probe=re.sub(r'// CANDIDATE_CONTROL_BEGIN.*?// CANDIDATE_CONTROL_END','',probe,flags=re.S)
else: members={f.relative_to(ROOT/'src').as_posix():f.read_bytes() for f in (ROOT/'src').rglob('*') if f.is_file()}
fixture={'ZSCRIPT':b'version "4.14"\n#include "quick.zs"\n#include "probe.zs"\n',
    'CVARINFO':b'server bool ca339_preview=false;\n',
    'LANGUAGE':('[enu default]\nCA339_PREVIEW_0="Jump-wall test: run toward the wall and jump (Space).";\nCA339_PREVIEW_1="Try rising and descending. F6 restarts this isolated test.";\nCA339_PREVIEW_2="M opens the map; L shows/hides the full legend.";\n[es esp]\nCA339_PREVIEW_0="Prueba: corre hacia la pared y salta (Espacio).";\nCA339_PREVIEW_1="Prueba al subir y bajar. F6 reinicia este escenario aislado.";\nCA339_PREVIEW_2="M abre el mapa; L muestra/oculta toda la leyenda.";\n').encode(),
    'quick.zs':(ROOT/'assets/validation_5422/probe.zs').read_bytes(),'probe.zs':probe.encode(),
    'maps/MAPQA.wad':old.test_map(),'maps/MAPQB.wad':old.test_map(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA339Probe" }\ncluster 99 { hub }\nmap MAPQA "Voluntary jump fixture" { cluster=99 nointermission }\nmap MAPQB "Jump travel" { cluster=99 nointermission }\n'}
manifest={'runtime_sha256':old.package(out/'production.pk3',members),'fixture_sha256':old.package(out/'quick.pk3',fixture),'baseline':a.baseline}
for mode,name in enumerate(['ascent','descent','fall','push','excess','immobilized']):
    code=f'wait 100; netevent c339_start {mode}; wait 3; '
    if mode not in (2,3): code+='+jump; wait 3; -jump; '
    code+='wait 180; quit\n'
    (out/(name+'.cfg')).write_text(code,encoding='utf-8',newline='\n')
start='wait 100; netevent c339_persist; wait 5; +jump; wait 4; -jump; '
scripts={'save':start+'storesavepic false; save jump.zds; netevent c339_airborne; wait 70; quit\n',
    'load':'wait 1; netevent c339_airborne; wait 60; netevent c339_landed; wait 5; quit\n',
    'legacy':'wait 1; netevent c339_legacy; wait 60; netevent c339_landed; wait 5; quit\n',
    'controls':start+'netevent c339_controls; wait 10; quit\n',
    'travel':start+'changemap MAPQB; wait 15; netevent c339_landed; wait 5; quit\n'}
scripts['native']='wait 100; netevent c339_runup; +forward; wait 70; netevent c339_ready; +jump; wait 3; -jump; wait 100; -forward; wait 5; quit\n'
rules=(ROOT/'assets/validation_5219/checks.zs').read_text(encoding='utf-8').replace('CA211 ','CA282 ').replace('DONE failures=%d passes=%d",Failures,Passes','DONE passes=%d failures=%d",Passes,Failures')
manifest['rules_sha256']=old.package(out/'rules.pk3',{'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':rules.encode(),'maps/MAPQA.wad':old.test_map(),'MAPINFO':b'GameInfo { AddEventHandlers="CA211Checks" }\n'})
scripts['rules']='wait 100; quit\n'
scripts['manual']='wait 100; language es; bind SPACE +jump; bind F6 "map MAPQA"; bind M togglemap; unmapbind M; bind L ca_map_legend; ca339_preview true; map MAPQA; wait 50; netevent c339_previewcheck;\n'
scripts['preview-smoke']=scripts['manual'].strip()+' screenshot quick-preview.png; wait 5; map MAPQA; wait 50; netevent c339_previewcheck; wait 5; quit\n'
for name,code in scripts.items():(out/(name+'.cfg')).write_text(code,encoding='utf-8',newline='\n')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest))
