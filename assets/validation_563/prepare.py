"""Build deterministic isolated recipe checks; no production balance is added."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue378'
OUT.mkdir(parents=True, exist_ok=True)
members = {
    'ZSCRIPT': b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers = "CA378LegacyChecks", "CA378Checks" }\n',
    'checks.zs': Path(__file__).with_name('checks.zs').read_bytes(),
    'legacy.zs': Path(__file__).with_name('legacy.zs').read_bytes(),
}
legacy = {
    'ZSCRIPT': b'version "4.14"\n#include "legacy.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers = "CA378LegacyChecks" }\n',
    'legacy.zs': members['legacy.zs'],
}
for filename, files in (('checks.pk3', members), ('legacy-checks.pk3', legacy)):
    with zipfile.ZipFile(OUT / filename, 'w', zipfile.ZIP_STORED) as archive:
        for name, content in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
scripts = {
    'suite': 'wait 35; netevent ca378_suite; use CaelumRecipeBook; wait 2; netevent ca378_native_use; wait 5; quit',
    'craft': 'wait 35; netevent ca378_craft; wait 5; quit',
    'time': 'wait 35; netevent ca378_time; wait 5; quit',
    'mansion-time': 'wait 35; netevent ca378_ui; netevent ca_recipe_close; changemap MAP01; '
                    'wait 70; netevent ca378_shelf_view; netevent ca378_time; wait 5; quit',
    'sources': 'wait 35; netevent ca378_ui; netevent ca_recipe_close; changemap MAP01; '
               'wait 70; netevent ca378_sources; wait 5; quit',
    'save': 'wait 35; netevent ca378_save; wait 5; save ca378-reading; wait 5; quit',
    'verify': 'wait 5; netevent ca378_verify; wait 5; quit',
    'travel': 'wait 5; changemap THAZARD; wait 35; netevent ca378_verify; changemap TMAINT; wait 35; netevent ca378_verify; changemap MAP02; wait 35; netevent ca378_verify; wait 5; quit',
    'mansion': 'wait 35; changemap MAP01; wait 70; netevent ca378_mansion; wait 5; quit',
    'legacy-save': 'wait 35; netevent ca378_legacy_save; wait 5; save ca378-legacy; wait 5; quit',
    'legacy-verify': 'wait 5; netevent ca378_legacy_verify; wait 5; quit',
    'upgrade': 'wait 35; netevent ca378_upgrade; wait 5; save ca378-upgraded; wait 5; quit',
    'upgraded-verify': 'wait 35; netevent ca378_upgrade; wait 5; quit',
    'ui': 'wait 35; netevent ca378_ui; wait 10; screenshot recipe-en.png; wait 5; language es; wait 5; '
          'netevent ca_recipe_move 0; wait 10; screenshot recipe-es.png; '
          'netevent ca_recipe_close; changemap MAP01; wait 70; netevent ca378_shelf_view; '
          'wait 10; screenshot shelf.png; wait 5; quit',
    'interactive': 'exec ../../assets/playtest/default_controls.cfg\nlanguage es; wait 35; '
                   'netevent ca378_ui; netevent ca_recipe_close; changemap MAP01; wait 70; '
                   'netevent ca378_author; wait 5; toggleconsole',
}
for name, script in scripts.items():
    (OUT / (name + '.cfg')).write_text(script + '\n', encoding='utf-8')
print('Prepared issue378 checks.')
