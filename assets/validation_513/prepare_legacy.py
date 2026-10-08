"""Retain the exact accepted source package; fixtures contain no game/IWAD data."""
from pathlib import Path
import io
import json
import subprocess
import zipfile
from prepare import ROOT, HERE, OUT, package

BASE='b00201098a26582c8820a5424a2a75986b022abf'
if not (OUT/'baseline.pk3').exists():
    raw=subprocess.check_output(['git','archive','--format=zip',BASE,'src'],cwd=ROOT)
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        package('baseline.pk3',{n[4:]:z.read(n) for n in z.namelist() if not n.endswith('/')})
package('legacy.pk3',{'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n',
    'legacy.zs':(HERE/'legacy.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA133Legacy" }\n'})
package('deployment.pk3',{'ZSCRIPT':b'version "4.14"\n#include "routes.zs"\n#include "deployment_persistence.zs"\n',
    'routes.zs':(HERE/'routes.zs').read_bytes(),'deployment_persistence.zs':(HERE/'deployment_persistence.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA133Routes", "CA133DeploymentPersistence" }\n'})
package('manual.pk3',{'ZSCRIPT':b'version "4.14"\n#include "manual.zs"\n',
    'manual.zs':(HERE/'manual.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA133Manual" }\n',
    'CVARINFO':b'server int ca133_visit=0; server bool ca133_attack=false;\n'})
for name,command in {
    'legacy-seed':'wait 110; save ca133-legacy-original; wait 5; quit',
    'legacy-upgrade':'wait 35; save ca133-legacy-upgraded; wait 5; quit',
    'legacy-reload':'wait 35; quit',
    'legacy-hub':'wait 5; changemap MAP03; wait 45; changemap MAP06; wait 45; quit',
    'trade-save':'wait 100; save ca133-city-original; wait 5; quit',
    'trade-reload':'wait 35; save ca133-city-reloaded; wait 5; quit',
    'trade-hub':'wait 5; changemap MAP03; wait 45; changemap MAP06; wait 45; quit',
    'deployment-save':'wait 1000; save ca133-deployment; wait 5; quit',
    'deployment-reload':'wait 35; quit',
    'deployment-hub':'wait 5; changemap MAP03; wait 45; changemap MAP06; wait 45; quit',
}.items():
    (OUT/(name+'.cfg')).write_text(command+'\n',encoding='utf-8')
print(json.dumps({'baseline_commit':BASE,'baseline_retained':str(OUT/'baseline.pk3')}))
