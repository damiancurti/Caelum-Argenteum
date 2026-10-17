"""Package optional actor-ablation controls separately from frozen runtimes."""
from pathlib import Path
import hashlib
import json
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
out=ROOT/'build/issue318-audit-02/no-doors.pk3'
assert not out.exists(),out
members={'ZSCRIPT':b'version "4.14"\n#include "no_doors.zs"\n',
         'no_doors.zs':(HERE/'no_doors.zs').read_bytes(),
         'MAPINFO':b'GameInfo { AddEventHandlers="CA318NoDoors" }\n'}
with zipfile.ZipFile(out,'w') as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
out.with_suffix('.json').write_text(json.dumps({'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'scope':'Remove door leaves and blockers after setup; diagnostic only'},indent=2)+'\n')
print(out)
