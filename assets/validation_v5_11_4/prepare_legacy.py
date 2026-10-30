"""Reuse the accepted campaign-save fixture without rewriting its original save."""
from pathlib import Path
import hashlib,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue430'
source=(ROOT/'assets/validation_v5_11_1/campaign.zs').read_text(encoding='utf-8')
source=source.replace('    void Verify()\n    {', '    void Verify()\n    {\n        Check(CA430LegacyCheck.EmptyParty(),"accepted save gains no automatic companions or possessions");')
files={'ZSCRIPT':b'version "4.14"\n#include "campaign.zs"\n#include "legacy_checks.zs"\n',
       'MAPINFO':b'GameInfo { AddEventHandlers="CA429Campaign" }\n',
       'campaign.zs':source.encode(),'legacy_checks.zs':(Path(__file__).parent/'legacy_checks.zs').read_bytes()}
with zipfile.ZipFile(OUT/'legacy-checks.pk3','w') as z:
 for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
old=ROOT.parent/'issue429-work/build/issue429/ca429-legacy-campaign-b.zds'
dest=OUT/'accepted-510-campaign.zds'
if dest.exists():assert dest.read_bytes()==old.read_bytes()
else:shutil.copyfile(old,dest)
print('Preserved accepted save SHA256',hashlib.sha256(dest.read_bytes()).hexdigest())
