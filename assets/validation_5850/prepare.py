"""Build private physical-contamination fixtures and a source-overlay probe."""
from pathlib import Path
import argparse, subprocess, zipfile, struct
R=Path(__file__).resolve().parents[2]
H=Path(__file__).resolve().parent
W=R/'build/issue502-adapters'
BASE=R/'build/issue502-physical/final49a/caelum_argenteum_dev.pk3'

def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','35c5ff4e','--name-only','--','src'],cwd=R,text=True,stderr=subprocess.DEVNULL).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:
        pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))
# Keep the original diagnostic geometry; allow tent setup on its first floor.
raw=(R/'assets/validation_5826/away.wad').read_bytes()
count,offset=struct.unpack_from('<ii',raw,4);arena=bytearray(b'PWAD'+struct.pack('<ii',count,0));directory=[]
for i in range(count):
    start,size,name=struct.unpack_from('<ii8s',raw,offset+i*16);blob=raw[start:start+size]
    if name.rstrip(b'\0')==b'TEXTMAP':blob=blob.replace(b'texturefloor="CMST01"',b'texturefloor="CMGR01A"',1)
    directory.append((len(arena),len(blob),name));arena.extend(blob)
offset=len(arena)
for row in directory:arena.extend(struct.pack('<ii8s',*row))
struct.pack_into('<i',arena,8,offset)
pack(W/'checks.pk3',{
    'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502AdapterChecks"}\ncluster 8549 {hub}\nmap MAP01 "Physical contact" {cluster=8549}\nmap CPH502B "Away" {cluster=8549}\n',
    'maps/MAP01.wad':bytes(arena),
    'maps/CPH502B.wad':bytes(arena)})
for case in ['catalogue','tent','seed','resume']:
    suffix='; save adapter-current' if case=='seed' else ''
    (W/(case+'.cfg')).write_text(f'wait 105; netevent ca502a_{case}{suffix}; wait 10; quit\n')
print('Prepared physical-contact fixtures')

(W/'hub.cfg').write_text('wait 105; netevent ca502a_seed; netevent ca502a_away; wait 35; netevent ca502a_home; wait 35; netevent ca502a_resume; wait 10; quit\n')
(W/'absent.cfg').write_text('wait 105; netevent ca502a_npcprepare; wait 3; netevent ca502a_absent; wait 10; quit\n')

with zipfile.ZipFile(W/'checks.pk3') as z:current={n:z.read(n) for n in z.namelist()}
legacy=dict(current);legacy['checks.zs']=(H/'legacy.zs').read_bytes()
pack(W/'legacy-checks.pk3',legacy);pack(W/'bridge/legacy-checks.pk3',current)
(W/'legacyseed.cfg').write_text('wait 105; netevent ca502a_legacyseed; save adapter-prior49; wait 10; quit\n')
(W/'legacyload.cfg').write_text('wait 105; netevent ca502a_legacyload; wait 10; quit\n')

(W/"contact.cfg").write_text("wait 105; netevent ca502a_prepare; wait 3; netevent ca502a_contact; wait 3; netevent ca502a_separated; wait 5; quit\n")
