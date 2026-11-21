"""Open the dedicated joinery review from retained native fixture sources.

F1 cycles the nine viewpoints. The diagnostic fixture grants invulnerability
and notarget. Native menus remain available; the completed #879 runtime is required.
Use only through the final consolidated author terminal; no automatic acceptance.
"""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
p=argparse.ArgumentParser(description=__doc__)
for n in ['runtime','overlay','output']:p.add_argument('--'+n,type=Path,required=True)
p.add_argument('--interactive',action='store_true',required=True)
a=p.parse_args()
assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
evidence=Path(__file__).parent/'evidence/views'
report=json.loads((evidence/'RESULTS.json').read_text())
source=(evidence/'probe.zs').read_text(encoding='utf-8')
old='Place(View);View++;';assert source.count(old)==1
source=source.replace(old,f'Place(View);View=(View+1)%{len(report["cameras"])};')
# Automatic menu dismissal was for image capture only; leave user menus usable.
start=source.index('    override void UiTick()');end=source.index('    override void WorldTick()',start)
source=source[:start]+source[end:]
probe=out/'review.pk3'
with zipfile.ZipFile(probe,'x') as z:
    z.writestr('ZSCRIPT','version "4.14.2"\n#include "probe.zs"\n')
    z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA866Views" }\n')
    z.writestr('probe.zs',source)
config=out/'review.ini'
config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\n',encoding='utf-8')
commands=out/'start.cfg';commands.write_text('bind F1 "netevent ca866_next"; wait 140; netevent ca866_next\n',encoding='utf-8')
command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(a.runtime.resolve(strict=True)),str(a.overlay.resolve(strict=True)),str(probe),'-config',str(config),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),'+map','MAP03','+exec',str(commands)]
record=dict(issue=878,author_acceptance=False,command=command,cameras=report['cameras'],runtime_sha256=hashlib.sha256(a.runtime.read_bytes()).hexdigest(),overlay_sha256=hashlib.sha256(a.overlay.read_bytes()).hexdigest(),qualification='Final terminal must supply the completed #879 production visibility fix. This interactive helper has no diagnostic class replacement; native menus remain usable.')
(out/'review-session.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print('F1 cycles house views. Walk and use doors normally; native menus remain available. Saves: '+str(out))
raise SystemExit(subprocess.call(command,cwd=out))
