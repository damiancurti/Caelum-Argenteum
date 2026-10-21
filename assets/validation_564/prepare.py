"""Prepare deterministic isolated loot fixtures, never production distributions."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue384'
OUT.mkdir(parents=True, exist_ok=True)
members = {
    'ZSCRIPT': b'version "4.14"\n#include "probe.zs"\n#include "saves.zs"\n#include "ice.zs"\n#include "tables.zs"\n#include "current.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers = "CA384Probe", "CA384SaveChecks", "CA384IceChecks", "CA384Tables", "CA384CurrentChecks" }\n',
    'probe.zs': (HERE / 'probe.zs').read_bytes(),
    'saves.zs': (HERE / 'saves.zs').read_bytes(),
    'current.zs': (HERE / 'current.zs').read_bytes(),
    'ice.zs': (HERE / 'ice.zs').read_bytes(),
    'tables.zs': (HERE / 'tables.zs').read_bytes(),
}
legacy = {k:v for k,v in members.items() if k!='current.zs'}
legacy['ZSCRIPT'] = b'version "4.14"\n#include "probe.zs"\n#include "saves.zs"\n#include "ice.zs"\n#include "tables.zs"\n'
legacy['MAPINFO'] = b'GameInfo { AddEventHandlers = "CA384Probe", "CA384SaveChecks", "CA384IceChecks", "CA384Tables" }\n'
for filename, files in (('checks.pk3',members),('legacy-checks.pk3',legacy)):
    with zipfile.ZipFile(OUT / filename, 'w', zipfile.ZIP_STORED) as archive:
        for name, content in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
scripts = {
    'probe':'wait 35; netevent ca384_probe_start; wait 5; netevent ca384_probe_kill; wait 15; netevent ca384_probe_verify; wait 5; quit',
    'save':'wait 35; netevent ca384_save_spawn; wait 5; netevent ca384_save_kill; wait 15; netevent ca384_save_snapshot; save ca384-original; wait 5; quit',
    'original-verify':'wait 5; netevent ca384_original_verify; wait 5; quit',
    'upgrade':'wait 5; netevent ca384_upgrade; save ca384-upgraded; wait 5; quit',
    'verify':'wait 5; netevent ca384_verify; wait 5; quit',
    'travel':'wait 5; netevent ca384_verify; changemap THAZARD; wait 35; changemap TMAINT; wait 35; netevent ca384_verify; wait 5; quit',
    'ice-save':'wait 35; netevent ca384_ice_spawn; wait 5; netevent ca384_ice_normal; wait 15; netevent ca384_ice_freeze; save ca384-ice; wait 5; quit',
    'ice-finish':'wait 5; netevent ca384_ice_force; wait 5; netevent ca384_ice_verify; wait 5; quit',
    'ice-upgrade':'wait 5; netevent ca384_ice_upgrade; netevent ca384_ice_force; wait 5; netevent ca384_ice_verify; wait 5; quit',
    'tables':'wait 35; changemap MAP02; wait 70; netevent ca384_tables; save ca384-tables; wait 5; quit',
    'tables-legacy':'wait 35; changemap MAP02; wait 70; netevent ca384_tables; save ca384-tables-legacy; wait 5; quit',
    'tables-reload':'wait 70; netevent ca384_tables_reload; wait 35; quit',
    'ice-save-current':'wait 35; netevent ca384_ice_spawn; wait 5; netevent ca384_ice_normal; wait 15; netevent ca384_ice_freeze; save ca384-current-ice; wait 5; quit',
    'interactive':'exec ../../assets/playtest/default_controls.cfg; language es; wait 70; god; toggleconsole',
}
for name, script in scripts.items():
    (OUT / (name + '.cfg')).write_text(script+'\n', encoding='utf-8')
print('Prepared issue384 checks.')
