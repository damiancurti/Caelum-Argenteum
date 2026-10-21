"""Package isolated #383 fixtures; retain prior merchant regressions unchanged."""
from pathlib import Path
import importlib.util
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue383'
OUT.mkdir(parents=True, exist_ok=True)
spec = importlib.util.spec_from_file_location('clothing_fixture', ROOT/'assets/validation_566/prepare.py')
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
members = {
    'ZSCRIPT': b'version "4.14"\n#include "checks377.zs"\n#include "legacy383.zs"\n#include "checks383.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers = "CA377Checks", "CA383Checks", "CA383Legacy" }\nmap CLTHQA "Shop checks" { nointermission cluster = 434 }\n',
    'checks377.zs': (ROOT/'assets/validation_561/checks.zs').read_bytes(),
    'checks383.zs': (HERE/'checks.zs').read_bytes(),
    'legacy383.zs': (HERE/'legacy.zs').read_bytes(),
    'maps/CLTHQA.wad': prior.room(),
}
with zipfile.ZipFile(OUT/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, content in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), content)
legacy = {name: members[name] for name in ['checks377.zs','legacy383.zs']}
legacy['ZSCRIPT'] = b'version "4.14"\n#include "checks377.zs"\n#include "legacy383.zs"\n'
legacy['MAPINFO'] = b'GameInfo { AddEventHandlers = "CA383Legacy" }\n'
with zipfile.ZipFile(OUT/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,content in sorted(legacy.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),content)
scripts = {
    'suite': 'wait 35; netevent ca383_suite; wait 5; quit',
    'regression': 'wait 35; netevent ca377_suite; wait 5; quit',
    'save': 'wait 35; netevent ca383_save; wait 5; save ca383-current; wait 5; quit',
    'verify': 'wait 5; netevent ca383_verify; wait 5; quit',
    'travel': 'wait 5; netevent ca383_verify; changemap THAZARD; wait 35; netevent ca383_verify; changemap CLTHQA; wait 35; netevent ca383_verify; changemap MAP01; wait 35; netevent ca383_verify; wait 5; quit',
    'city': 'wait 70; netevent ca383_city; wait 5; quit',
    'legacy-save': 'wait 70; netevent ca383_legacy_save; wait 5; save ca383-legacy; wait 5; quit',
    'rollback': 'wait 35; netevent ca383_rollback; wait 5; quit',
    'upgrade': 'wait 35; netevent ca383_upgrade; wait 5; save ca383-upgraded; wait 5; quit',
    'upgrade-verify': 'wait 35; netevent ca383_upgrade; wait 5; quit',
    'interactive': 'exec ../../assets/playtest/default_controls.cfg\nlanguage es; wait 35; netevent ca383_author; give CaelumGoldCoin 1000; wait 5; toggleconsole',
    'ui-es': 'language es; wait 35; netevent ca383_author; wait 35; screenshot library-es.png; wait 5; quit',
    'ui-en': 'language enu; wait 35; netevent ca383_author; wait 35; screenshot library-en.png; wait 5; quit',
    'perf': 'wait 70; netevent ca383_perf; wait 360; quit',
}
for name, commands in scripts.items():
    (OUT/f'{name}.cfg').write_text(commands+'\n', encoding='utf-8', newline='\n')
print('Prepared #383 isolated fixtures.')
