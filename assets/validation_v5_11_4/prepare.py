"""Build a focused companion overlay over the accepted formation package."""
from pathlib import Path
import argparse,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue430';OUT.mkdir(parents=True,exist_ok=True)
parser=argparse.ArgumentParser()
parser.add_argument('--full',action='store_true',help='Use the built runtime; package only the check handler.')
args=parser.parse_args()
names=subprocess.check_output(['git','-c','core.autocrlf=false','diff','85bf55503322aed7fffdb2189707058243c20f16','--name-only'],cwd=ROOT,text=True).splitlines()
names += ['src/caelum/data/CaelumCompanionData.zs','src/caelum/world/CaelumCompanions.zs','src/caelum/ui/CaelumCompanionUI.zs']
names += ['src/caelum/equipment/CaelumCompanionLoadout.zs']
names += ['src/caelum/equipment/CaelumCompanionRanged.zs']
files={n[4:]:(ROOT/n).read_bytes() for n in names if n.startswith('src/') and n!='src/ZSCRIPT'}
name='caelum/data/CaelumFormationData.zs'
files[name]=(ROOT/'src'/name).read_bytes()+b'\n#include "caelum/data/CaelumCompanionData.zs"\n#include "caelum/world/CaelumCompanions.zs"\n#include "caelum/ui/CaelumCompanionUI.zs"\n'
files[name]+=b'\n#include "caelum/equipment/CaelumCompanionLoadout.zs"\n'
files[name]+=b'\n#include "caelum/equipment/CaelumCompanionRanged.zs"\n'
if args.full:files={}
files['ZSCRIPT']=b'version "4.14"\n#include "checks.zs"\n#include "weapon_checks.zs"\n'
files['checks.zs']=(Path(__file__).parent/'checks.zs').read_bytes()
files['weapon_checks.zs']=(Path(__file__).parent/'weapon_checks.zs').read_bytes()
files['MAPINFO']=b'GameInfo { AddEventHandlers="CA430Checks", "CA430WeaponChecks" }\n'
with zipfile.ZipFile(OUT/('full-checks.pk3' if args.full else 'checks.pk3'),'w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared companion native fixture.')
