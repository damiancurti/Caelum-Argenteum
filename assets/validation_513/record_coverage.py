"""Extract the authoritative native recipe coverage into reviewable evidence."""
from pathlib import Path
import hashlib
import json
import re

HERE=Path(__file__).resolve().parent
log=HERE/'delivery-factories.txt'
text=log.read_text(encoding='utf-8')
rows=[]
for match in re.finditer(r'CA133 RECIPE id=(\d+) kind=(\d+) covered=(\d+) station=([-\d.]+),([-\d.]+) capabilities=(\d+) name=(.*)',text):
    rid,kind,covered,x,y,capabilities,name=match.groups()
    rows.append({'id':int(rid),'kind':int(kind),'covered':covered=='1',
        'workbench':[float(x),float(y)],'network_capabilities':int(capabilities),'name':name})
summary=re.search(r'CA133 COMPLETE checks=(\d+) failures=0',text)
assert summary and len(rows)==int(summary[1])-1 and all(r['covered'] for r in rows)
record=json.loads((HERE/'delivery-factories-run.json').read_text(encoding='utf-8-sig'))
assert record.get('completed_utc')
result={'issue':133,'source':'Native authoritative CaelumCraftingRules and actual workbench network scans',
    'tier':1,'log':log.name,'log_sha256':hashlib.sha256(log.read_bytes()).hexdigest(),
    'package_sha256':record['package_sha256'],'recipes':rows}
(HERE/'RECIPE_COVERAGE.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(f'{len(rows)} authoritative native recipe entries recorded.')
