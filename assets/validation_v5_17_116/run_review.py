"""Open the dedicated final-review MAP02 candidate with disposable saves.

F1 cycles nine inspection viewpoints; ordinary movement and native save/load
remain available. Placement grants diagnostic invulnerability/notarget. This
launcher is for the consolidated author session, not automated acceptance.
"""
from pathlib import Path
import argparse,hashlib,importlib.util,json,subprocess,zipfile

ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--overlay',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--interactive',action='store_true',required=True)
a=p.parse_args()
assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
old=ROOT/'assets/validation_v5_17_102/run_material_views.py'
spec=importlib.util.spec_from_file_location('retained_sewer_views',old)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
points=module.cameras()+json.loads((Path(__file__).parent/'cameras.json').read_text())['rows']
base=module.fixture(out,points)
with zipfile.ZipFile(base) as z:members={n:z.read(n) for n in z.namelist()}
source=members['probe.zs'].decode()
old='Place(View);View++;';assert source.count(old)==1
source=source.replace(old,f'Place(View);View=(View+1)%{len(points)};')
members['probe.zs']=source.encode()
probe=out/'review.pk3'
with zipfile.ZipFile(probe,'x') as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),data)
config=out/'review.ini'
config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\n',encoding='utf-8',newline='\n')
commands=out/'start.cfg'
commands.write_text('bind F1 "netevent ca847_next"; wait 140; netevent ca847_next\n',encoding='utf-8',newline='\n')
command=[str(module.ENGINE),'-noautoload','-iwad',str(module.IWAD),'-file',str(a.runtime.resolve(strict=True)),str(a.overlay.resolve(strict=True)),str(probe),'-config',str(config),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),'+map','MAP02','+exec',str(commands)]
record=dict(issue=875,author_acceptance=False,runtime_sha256=module.digest(a.runtime),overlay_sha256=module.digest(a.overlay),command=command,cameras=points,qualification=__doc__)
(out/'review-session.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Dedicated candidate review. F1 cycles: '+', '.join(r['name'] for r in points)+'.')
print('Walk normally between views. Save/load through the native menu. Saves stay in '+str(out)+'.')
print('Do not load a campaign save into this geometry candidate.')
raise SystemExit(subprocess.call(command,cwd=out))
