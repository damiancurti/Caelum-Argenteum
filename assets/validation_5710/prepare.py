"""Build focused cartridge-station fixtures from the accepted #380 checks."""
from pathlib import Path
import struct
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / 'build/issue471-ammo'
OUT.mkdir(parents=True, exist_ok=True)
text = ['namespace="ZDoom";', 'sector { heightfloor=0; heightceiling=160; texturefloor="A471FLAT"; textureceiling="A471FLAT"; lightlevel=192; }']
for x, y in ((-384,-384),(-384,384),(384,384),(384,-384)):
    text.append(f'vertex {{ x={x}; y={y}; }}')
for i in range(4):
    text += ['sidedef { sector=0; texturemiddle="A471FLAT"; }', f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}']
text.append('thing { x=0; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
body = b''
directory = b''
for name, data in [('CAMM471', b''), ('TEXTMAP', '\n'.join(text).encode()), ('ENDMAP', b'')]:
    directory += struct.pack('<ii8s', 12+len(body), len(data), name.encode().ljust(8,b'\0'))
    body += data
base = (ROOT/'assets/validation_569/checks.zs').read_text(encoding='utf-8')
base = base.replace('r.RecipeBookVersion==11 && m.BookRevision==11', 'r.RecipeBookVersion==m.BookRevision')
for current in (False, True):
    source = base
    if current:
        source = source.replace('Actor.Spawn("CaelumRangedWorkshopStation"', 'Actor.Spawn("CaelumAlchemyStation"')
        source = source.replace('CRAFTING_STATION_RANGED_WORKSHOP,"ranged workshop is required"', 'CRAFTING_STATION_ALCHEMY,"alchemy is required"')
        source = source.replace('// Municiones ya aceptadas', 'Actor.Spawn("CaelumRangedWorkshopStation",u.Pos+(-48,0,0),NO_REPLACE);Open(u);\n        // Municiones ya aceptadas')
    addon = (HERE/'checks.zs').read_text(encoding='utf-8')
    addon = addon.replace('// CURRENT_ONLY', (HERE/'current.zs').read_text(encoding='utf-8') if current else '')
    members = {
        'ZSCRIPT': ('version "4.14"\n'+source+'\n'+addon).encode(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA471AmmoChecks" }\nmap CAMM471 "Cartridge station checks" { nointermission }\nmap CAM471B "Cartridge travel checks" { nointermission }\n',
        'TEXTURES': b'Texture A471FLAT, 64, 64 { Patch "models/caelum/props/stations/ca_station_wood.png", 0, 0 }\n',
        'maps/CAMM471.wad': b'PWAD'+struct.pack('<ii',3,12+len(body))+body+directory,
        'maps/CAM471B.wad': b'PWAD'+struct.pack('<ii',3,12+len(body))+body+directory,
    }
    destination = OUT/('fixture.pk3' if current else 'baseline/fixture.pk3')
    destination.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(destination,'w',zipfile.ZIP_STORED) as package:
        for name,data in sorted(members.items()): package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
scripts = {
    'suite': 'wait 70; netevent ca471_suite; wait 5; quit',
    'station': 'wait 70; netevent ca471_station; wait 5; quit',
    'old-save': 'wait 70; netevent ca471_save; wait 5; save ca471-original-579; wait 5; quit',
    'old-verify': 'wait 70; netevent ca471_verify; wait 5; quit',
    'upgrade': 'wait 70; netevent ca471_upgrade; wait 5; save ca471-upgraded; wait 5; quit',
    'resume': 'wait 70; netevent ca471_resume; wait 5; quit',
    'save': 'wait 70; netevent ca471_save; wait 5; save ca471-current; wait 5; quit',
    'load': 'wait 70; netevent ca471_current; wait 5; quit',
    'travel': 'wait 70; netevent ca471_verify; wait 5; netevent ca471_go; wait 105; netevent ca471_travel; wait 5; quit',
    'live': 'wait 70; netevent ca471_live; wait 80; netevent ca471_livecheck; wait 5; quit',
    'ui': 'language es; wait 70; netevent ca471_ui; wait 35; screenshot __RUN__-alchemy.png; netevent ca471_toggle_station; wait 35; screenshot __RUN__-ranged.png; wait 5; quit',
    'interactive': 'language es; bind F2 "netevent ca471_toggle_station"; wait 70; netevent ca471_manual',
}
for name,data in scripts.items(): (OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8',newline='\n')
print('Prepared deterministic #471 cartridge fixtures.')
