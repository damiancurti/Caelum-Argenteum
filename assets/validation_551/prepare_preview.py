"""Prepare the requested #310 interactive preview with explicit Spanish controls."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory',required=True)
args=parser.parse_args()
subprocess.run([sys.executable,'-X','utf8',str(HERE/'prepare.py'),'--directory',args.directory],cwd=ROOT,check=True)
out=ROOT/'build'/args.directory
with zipfile.ZipFile(out/'quick.pk3') as z: members={n:z.read(n) for n in z.namelist()}
probe=members['probe.zs'].decode('utf-8')
probe=probe.replace('(320,-160,0)','(80,-64,0)').replace('(320,160,0)','(80,64,0)')
probe=probe.replace('#309: F6 espada | F7 varita | F8 escopeta | F9 guanteletes',
                    '#310: F6 espada | F7 varita | F8 alabarda | F9 jabalina')
probe=probe.replace('Manten R: una sola carga. Suelta y pulsa para iniciar otra.',
                    'R: cargar. Botones izquierdo/derecho: ataques.')
probe=probe.replace('Escopeta vacia: manten disparo. Debe recargar y disparar.',
                    'Alabarda: boton central barre. F11: carabina.')
probe=probe.replace('Boton izquierdo/derecho: ataques. F10: reiniciar la prueba.',
                    'Prueba cambiar de arma durante una carga. F10 reinicia.')
members['probe.zs']=probe.encode('utf-8')
with zipfile.ZipFile(out/'quick.pk3','w',zipfile.ZIP_STORED) as z:
    for n,b in sorted(members.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
script='wait 100; language es; use_mouse true; netevent c309_manual; '
for key,kind in (('f6',0),('f7',1),('f8',12),('f9',6),('f11',2)):
    script+=f'bind {key} "netevent c309_equip {kind} 1 0"; '
script+='bind f10 "map MAP99; exec manual.cfg"; bind r +reload; bind mouse1 +attack; bind mouse2 +altattack; bind mouse3 +zoom; con_notifytime 0; wait 70; screenshot author-preview.png; netevent c309_done;\n'
(out/'manual.cfg').write_text(script,encoding='utf-8')
manifest=json.loads((out/'manifest.json').read_text(encoding='utf-8'))
manifest['fixture_sha256']=hashlib.sha256((out/'quick.pk3').read_bytes()).hexdigest()
manifest['script_hashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.glob('*.cfg'))}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('Prepared a visible training room and #310 controls; runtime unchanged.')
