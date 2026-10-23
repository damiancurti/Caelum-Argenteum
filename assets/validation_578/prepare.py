"""Build the deterministic private #479 support-state fixture (no shipped map)."""
from pathlib import Path
import struct
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / 'build/issue479'
OUT.mkdir(parents=True, exist_ok=True)
text = ['namespace="ZDoom";', 'sector { heightfloor=0; heightceiling=128; texturefloor="S479FLAT"; textureceiling="S479FLAT"; lightlevel=192; }']
for x, y in ((-256, -256), (-256, 256), (256, 256), (256, -256)):
    text.append(f'vertex {{ x={x}; y={y}; }}')
for i in range(4):
    text += ['sidedef { sector=0; texturemiddle="S479FLAT"; }',
             f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}']
text.append('thing { x=0; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
body = b''
directory = b''
for name, data in [('CSUP479', b''), ('TEXTMAP', '\n'.join(text).encode()), ('ENDMAP', b'')]:
    directory += struct.pack('<ii8s', 12 + len(body), len(data), name.encode().ljust(8, b'\0'))
    body += data
members = {
    'ZSCRIPT': b'version "4.14"\n' + (HERE / 'fixture.zs').read_bytes()+b'\n'+(HERE / 'gameplay.zs').read_bytes()+b'\n'+(HERE / 'gallery.zs').read_bytes()+b'\n'+(HERE / 'manual_fixture.zs').read_bytes(),
    'MAPINFO': b'GameInfo { AddEventHandlers="CA479Checks", "CA479Gameplay", "CA479Gallery", "CA479Manual" }\nmap CSUP479 "Support-state checks" { }\n',
    'TEXTURES': b'Texture S479FLAT, 64, 64 { Patch "models/caelum/props/stations/ca_station_wood.png", 0, 0 }\n',
    'maps/CSUP479.wad': b'PWAD' + struct.pack('<ii', 3, 12 + len(body)) + body + directory,
}
with zipfile.ZipFile(OUT / 'fixture.pk3', 'w', zipfile.ZIP_STORED) as package:
    for name, data in sorted(members.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
legacy=dict(members)
legacy['ZSCRIPT']=b'version "4.14"\n'+(HERE/'legacy.zs').read_bytes()
legacy['MAPINFO']=b'GameInfo { AddEventHandlers="CA479Legacy" }\nmap CSUP479 "Legacy support migration" { }\n'
with zipfile.ZipFile(OUT/'legacy-fixture.pk3','w',zipfile.ZIP_STORED) as package:
    for name,data in sorted(legacy.items()):package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
scripts = {
    'legacy-save': 'wait 70; netevent ca479_oldseed; wait 5; save ca479-legacy-v2; wait 5; quit',
    'legacy-load': 'wait 70; netevent ca479_migrated; wait 5; quit',
    'legacy-rollback': 'wait 70; netevent ca479_oldrollback; wait 5; quit',
    'live': 'wait 70; netevent ca479_tickseed; wait 40; netevent ca479_tickcheck; wait 1; quit',
    'live-save': 'wait 70; netevent ca479_tickseed; wait 20; save ca479-live; wait 5; quit',
    'live-load': 'wait 20; netevent ca479_tickcheck; wait 1; quit',
    'gameplay': 'wait 70; netevent ca479_gameplay; wait 5; quit',
    'smoke': 'wait 70; netevent ca479_checks; wait 5; quit',
    'save': 'wait 70; netevent ca479_save; wait 5; save ca479-state; wait 5; quit',
    'load': 'wait 70; netevent ca479_load; wait 5; quit',
}
scripts['controls']='wait 70; netevent ca479_manual; wait 45; netevent ca479_slotcheck; '+ 'slot 0; wait 45; netevent ca479_slotcheck; '*4+'netevent ca479_slotsdone; wait 45; netevent ca479_beforecast; +attack; wait 1; -attack; wait 30; +reload; wait 1; -reload; netevent ca479_aftercast; wait 45; netevent ca479_beforealt; +altattack; wait 1; -altattack; wait 30; netevent ca479_afteralt; wait 5; quit'
scripts['interactive']='language es; bind Tab ca_journal_toggle; bind M togglemap; bind F1 "netevent ca479_choose"; bind F2 "netevent ca479_reset"; bind F3 "netevent ca479_attributes"; bind F4 "netevent ca479_seal"; wait 70; netevent ca479_manual'
scripts['gallery-interactive']='language es; ca_journal_page 0; bind Tab ca_journal_toggle; bind M togglemap; bind F1 "netevent ca479_next"; wait 70; netevent ca479_gallery'
scripts['gallery']='wait 70; netevent ca479_gallery; wait 45; '+ '; '.join(f'screenshot art-{i:02}.png; netevent ca479_next; wait 45' for i in range(18))+'; netevent ca479_artcheck; wait 5; quit'
painted_views = [f'screenshot art-world-{i:02}.png; netevent ca479_inventory; ca_journal_open true; wait 25; screenshot art-inventory-{i:02}.png; ca_journal_open false; wait 5; netevent ca479_next; wait 45' for i in range(18)]
# Keep ordered wait continuations below the native command-buffer limit (CA-KP-136).
scripts['painted-gallery']='ca_journal_page 0; wait 70; netevent ca479_gallery; wait 45; '+ '; '.join(painted_views[:9])+'; exec __RUN__-tail.cfg'
scripts['painted-gallery-tail']='; '.join(painted_views[9:])+'; netevent ca479_artcheck; netevent ca479_legacyart; wait 5; quit'
scripts['inventory-preview']='wait 70; netevent ca479_gallery; wait 45; netevent ca479_inventory; ca_journal_page 0; ca_journal_open true; wait 35; screenshot art-inventory-preview.png; netevent ca479_artcheck; wait 5; quit'
scripts['painted-actions']='wait 70; netevent ca479_gallery; wait 45; '+ '; '.join(f'+attack; wait 4; -attack; screenshot art-action-{i:02}.png; wait 40; +user2; wait 6; screenshot art-block-{i:02}.png; -user2; wait 20; screenshot art-return-{i:02}.png; netevent ca479_next; netevent ca479_next; netevent ca479_next; wait 45' for i in range(6))+'; netevent ca479_artcheck; wait 5; quit'
scripts['floating-orb']='wait 70; netevent ca479_orb; wait 45; '+ '; '.join(f'screenshot art-orb-world-{i}.png; netevent ca479_orbcheck; netevent ca479_inventory; ca_journal_open true; ca_journal_page 0; wait 20; screenshot art-orb-inventory-{i}.png; ca_journal_open false; +attack; wait 4; -attack; screenshot art-orb-action-{i}.png; wait 40; screenshot art-orb-return-{i}.png; netevent ca479_next; wait 45' for i in range(3))+'; screenshot art-book-return.png; netevent ca479_legacyart; netevent ca479_orb; netevent ca479_orbfemale; wait 45; screenshot art-orb-female.png; netevent ca479_orbcheck; wait 5; quit'
scripts['orb-interactive']='language es; ca_journal_page 0; bind Tab ca_journal_toggle; bind M togglemap; bind F1 "netevent ca479_next"; wait 70; netevent ca479_orb'
for name, data in scripts.items():
    (OUT / f'{name}.cfg').write_text(data + '\n', encoding='utf-8', newline='\n')
print('Prepared isolated #479 support-state fixture.')
