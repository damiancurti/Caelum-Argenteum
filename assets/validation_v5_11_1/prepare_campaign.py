"""Preserve a pre-formation native campaign save and verify additive migration."""
from pathlib import Path
import re
import zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue429'
source=(Path(__file__).parent/'campaign.zs').read_text(encoding='utf-8')
for label in ('legacy','current'):
    script=re.sub(r'        // BEGIN CURRENT.*?        // END CURRENT','',source,flags=re.S) if label=='legacy' else source
    files={'ZSCRIPT':b'version "4.14"\n#include "campaign.zs"\n','campaign.zs':script.encode(),
           'MAPINFO':b'GameInfo { AddEventHandlers="CA429Campaign" }\n'}
    with zipfile.ZipFile(OUT/f'campaign-{label}.pk3','w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared campaign migration and rollback fixtures.')
(OUT/'current').mkdir(exist_ok=True)
(OUT/'current/campaign-legacy.pk3').write_bytes((OUT/'campaign-current.pk3').read_bytes())
