"""Prepare isolated #408 water rooms and deterministic native fixtures."""
from pathlib import Path
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue408'
OUT.mkdir(parents=True, exist_ok=True)

def wad(text):
    lumps = [('CAWATER', b''), ('TEXTMAP', text.encode()), ('ENDMAP', b'')]
    body = b''
    directory = b''
    for name, data in lumps:
        directory += struct.pack('<ii8s', 12 + len(body), len(data), name.encode().ljust(8, b'\0'))
        body += data
    return b'PWAD' + struct.pack('<ii', len(lumps), 12 + len(body)) + body + directory

def rooms():
    text = ['namespace="ZDoom";']
    # Separated rooms keep each test source unambiguous; these are not campaign coordinates.
    for room in range(11):
        x = room * 768
        quality = room - 1
        marker = ('user_ca_potable_water=1;' if quality == 0 else
                  f'user_ca_water_quality={quality};' if 1 <= quality <= 7 else
                  'user_ca_water_quality=32;user_ca_potable_water=1;' if quality == 9 else '')
        water = 'waterzone=true;' if room > 0 else ''
        text.append(f'sector {{ heightfloor=0; heightceiling=256; texturefloor="FLOOR4_8"; textureceiling="CEIL1_1"; lightlevel=224; {water}{marker} }}')
        for vx, vy in [(x, 0), (x, 512), (x + 512, 512), (x + 512, 0)]:
            text.append(f'vertex {{ x={vx}; y={vy}; }}')
        for edge in range(4):
            index = room * 4 + edge
            text.append(f'sidedef {{ sector={room}; texturemiddle="STARTAN3"; }}')
            text.append(f'linedef {{ v1={index}; v2={room*4+(edge+1)%4}; sidefront={index}; blocking=true; }}')
    text.append('thing { x=256; y=256; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
    return '\n'.join(text)

members = {
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n#include "legacy.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers="CA408Checks", "CA408Legacy" }\ncluster 8408 { hub }\nmap CAWATER "Water quality checks" { cluster=8408 }\nmap CAWATR2 "Water travel checks" { cluster=8408 }\n',
    'checks.zs': (HERE / 'checks.zs').read_bytes(),
    'legacy.zs': (HERE / 'legacy.zs').read_bytes(),
    'maps/CAWATER.wad': wad(rooms()),
    'maps/CAWATR2.wad': wad(rooms()),
}
with zipfile.ZipFile(OUT / 'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, data in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
(OUT / 'upgrade').mkdir(exist_ok=True)
(OUT / 'upgrade/legacy-checks.pk3').write_bytes((OUT / 'checks.pk3').read_bytes())
legacy = {key: value for key, value in members.items() if key != 'checks.zs'}
legacy['ZSCRIPT'] = b'version "4.14"\n#include "legacy.zs"\n'
legacy['MAPINFO'] = legacy['MAPINFO'].replace(b'"CA408Checks", ', b'')
with zipfile.ZipFile(OUT / 'legacy-checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, data in sorted(legacy.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
scripts = {
    'suite': 'wait 35; netevent ca408_suite; wait 5; quit',
    'save': 'wait 35; netevent ca408_save; wait 5; save ca408-current; wait 5; quit',
    'verify': 'wait 5; netevent ca408_verify; wait 5; quit',
    'legacy-save': 'wait 35; netevent ca408_legacy_save; wait 5; save ca408-legacy; wait 5; quit',
    'rollback': 'wait 5; netevent ca408_legacy_verify; wait 5; quit',
    'upgrade': 'wait 5; netevent ca408_upgrade; wait 5; save ca408-upgraded; wait 5; quit',
    'upgraded-verify': 'wait 5; netevent ca408_upgrade; wait 5; quit',
    'travel': 'wait 5; netevent ca408_verify; changemap CAWATR2; wait 35; netevent ca408_verify; changemap CAWATER; wait 35; netevent ca408_verify; wait 5; quit',
    'sources': 'wait 35; netevent ca408_setup; ' + '; '.join(f'netevent ca408_source {q}; wait 3; netevent ca408_sourcecheck {q}; wait 3' for q in range(10)) + '; quit',
    'dispatch': 'wait 35; netevent ca408_author; netevent ca408_source 1; wait 3; netevent ca_inventory_water 1; wait 3; netevent ca408_dispatchcheck 0; netevent ca_inventory_water 0; wait 3; netevent ca408_dispatchcheck 1; wait 3; quit',
    'hud': 'language es; wait 35; netevent ca408_author; wait 15; screenshot "hud-es.png"; wait 5; quit',
    'interactive': 'exec ../../assets/playtest/default_controls.cfg\nlanguage es\nbind F1 "netevent ca408_source 0"\nbind F2 "netevent ca408_source 1"\nbind F3 "netevent ca408_source 2"\nbind F4 "netevent ca408_source 4"\nbind F5 "netevent ca408_source 7"\nwait 35; netevent ca408_author; wait 5; toggleconsole',
    'ui-es': 'language es; wait 35; netevent ca408_author; wait 10; ca_journal_toggle; wait 15; screenshot "ui-es.png"; wait 5; quit',
    'ui-en': 'language enu; wait 35; netevent ca408_author; wait 10; ca_journal_toggle; wait 15; screenshot "ui-en.png"; wait 5; quit',
}
for name, data in scripts.items():
    (OUT / f'{name}.cfg').write_text(data + '\n', encoding='utf-8', newline='\n')
print('Prepared isolated #408 fixtures and author controls.')
