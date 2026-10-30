"""Overlay affected tracked sources and native motion checks on the final build."""
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
with zipfile.ZipFile(ROOT / 'build/issue430/full-checks.pk3') as archive:
    files = {name: archive.read(name) for name in archive.namelist()}
names = subprocess.check_output(['git', '-c', 'core.autocrlf=false', 'diff',
    '--name-only', '51f25169f8c4a5388f95f5910b50cc701ddcf194', '--', 'src'], cwd=ROOT, text=True).splitlines()
for name in names:
    if name != 'src/ZSCRIPT':
        files[name[4:]] = (ROOT / name).read_bytes()
# Measure the single bootstrap in private QA only, never in production.
k='caelum/world/CaelumSlidingDoor.zs'
t=files[k].decode('utf-8').replace('registry.Ready=true;registry.Rebuilds++;','registry.Ready=true;registry.Rebuilds++;double began=MSTimeF();').replace('while((current=CaelumSlidingDoorLeaf(iterator.Next()))!=null)registry.Add(current);','while((current=CaelumSlidingDoorLeaf(iterator.Next()))!=null)registry.Add(current);Console.Printf("CA430 PROFILE door_bootstrap_ms=%.6f leaves=%d",MSTimeF()-began,registry.Registered);')
files[k]=t.encode('utf-8')
checks = Path(__file__).with_name('motion_checks.zs')
if checks.exists():
    files['motion_checks.zs'] = checks.read_bytes()
    files['ZSCRIPT'] += b'\n#include "motion_checks.zs"\n'
    files['MAPINFO'] += b'\nGameInfo { AddEventHandlers="CA430MotionChecks" }\n'
with zipfile.ZipFile(ROOT / 'build/issue430/motion-checks.pk3', 'w') as archive:
    for name, data in sorted(files.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)

# A private flat MAP02 isolates actual prisoner states from unrelated maze combat.
import importlib.util
spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_595/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
files['maps/MAP02.wad']=room.wad()
with zipfile.ZipFile(ROOT/'build/issue430/prisoner-motion.pk3','w') as archive:
    for name,data in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
