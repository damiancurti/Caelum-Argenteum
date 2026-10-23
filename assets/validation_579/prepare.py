"""Build the deterministic private #409 water fixture; no fixture is shipped."""
from pathlib import Path
import struct
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / 'build/issue409'
OUT.mkdir(parents=True, exist_ok=True)
text = ['namespace="ZDoom";', 'sector { heightfloor=0; heightceiling=128; texturefloor="W409FLAT"; textureceiling="W409FLAT"; lightlevel=192; }']
for x, y in ((-256,-256),(-256,256),(256,256),(256,-256)):
    text.append(f'vertex {{ x={x}; y={y}; }}')
for i in range(4):
    text += ['sidedef { sector=0; texturemiddle="W409FLAT"; }', f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}']
text.append('thing { x=0; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
text.append('thing { x=-200; y=200; type=30950; arg0=1; arg1=2; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
body = b''
directory = b''
for name, data in [('CWAT409', b''), ('TEXTMAP', '\n'.join(text).encode()), ('ENDMAP', b'')]:
    directory += struct.pack('<ii8s', 12+len(body), len(data), name.encode().ljust(8,b'\0'))
    body += data
members = {
    'ZSCRIPT': b'version "4.14"\n'+(HERE/'fixture.zs').read_bytes(),
    'MAPINFO': b'GameInfo { AddEventHandlers="CA409Checks" }\nmap CWAT409 "Water boiling checks" {}\n',
    'TEXTURES': b'Texture W409FLAT, 64, 64 { Patch "models/caelum/props/stations/ca_station_wood.png", 0, 0 }\n',
    'maps/CWAT409.wad': b'PWAD'+struct.pack('<ii',3,12+len(body))+body+directory,
}
with zipfile.ZipFile(OUT/'fixture.pk3','w',zipfile.ZIP_STORED) as package:
    for name,data in sorted(members.items()):
        package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
scripts = {
    'glass': 'wait 70; netevent ca409_glass; wait 5; quit',
    'glass-live': 'wait 70; netevent ca409_glass_live; wait 140; netevent ca409_glass_tickcheck; wait 5; quit',
    'glass-save': 'wait 70; netevent ca409_glass_save; wait 5; save ca409-hot-glass; wait 5; quit',
    'glass-load': 'wait 70; netevent ca409_glass_load; wait 5; quit',
    'glass-wait': 'wait 70; netevent ca409_glass_wait; wait 140; netevent ca409_glass_waitcheck; wait 5; quit',
    'smoke': 'wait 70; netevent ca409_checks; wait 5; quit',
    'save': 'wait 70; netevent ca409_save; wait 5; save ca409-state; wait 5; quit',
    'load': 'wait 70; netevent ca409_load; wait 5; quit',
    'live': 'wait 70; netevent ca409_live; wait 100; netevent ca409_tickcheck; wait 5; quit',
    'wait': 'wait 70; netevent ca409_wait; wait 140; netevent ca409_waitcheck; wait 5; quit',
    'old-save': 'wait 70; netevent ca409_oldseed; wait 5; save ca409-original-578; wait 5; quit',
    'old-load': 'wait 70; netevent ca409_oldcheck; wait 5; quit',
    'ui': 'language es; wait 70; netevent ca409_manual; netevent ca409_quality; ca_journal_page 0; ca_journal_open true; wait 35; screenshot __RUN__-inventory.png; netevent ca_inventory_boil; wait 15; screenshot __RUN__-task.png; wait 5; quit',
    'interactive': 'language es; ca_journal_page 0; bind Tab ca_journal_toggle; bind F1 "netevent ca409_manual"; bind F2 "netevent ca409_quality"; wait 70; netevent ca409_manual; ca_journal_open true',
}
for name,data in scripts.items():
    (OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8',newline='\n')
print('Prepared private #409 water fixture.')

for current in (False,True):
    legacy=dict(members)
    source=(HERE/'legacy.zs').read_text(encoding='utf-8')
    if current:
        source=source.replace('// CURRENT_CHECK', 'bool migrated=water!=null && water.WaterTemperatureRevision==1; Console.Printf("CA409 %s additive temperature migration",migrated?"PASS":"FAIL"); ok=ok && migrated;')
    legacy['ZSCRIPT']=b'version "4.14"\n'+source.encode()
    legacy['MAPINFO']=b'GameInfo { AddEventHandlers="CA409Legacy" }\nmap CWAT409 "Water legacy checks" {}\n'
    destination=OUT/'legacy-current/legacy.pk3' if current else OUT/'legacy.pk3'
    destination.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(destination,'w',zipfile.ZIP_STORED) as package:
        for name,data in sorted(legacy.items()):package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

# Development-only source overlay; final evidence uses fixture.pk3 with the complete PK3.
with zipfile.ZipFile(OUT/"fixture-dev.pk3","w",zipfile.ZIP_STORED) as package:
    for name,data in sorted(members.items()): package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    for source in sorted((ROOT/"src").rglob("*.zs")):
        package.writestr(zipfile.ZipInfo(source.relative_to(ROOT/"src").as_posix(),(2000,1,1,0,0,0)),source.read_bytes())
    package.writestr(zipfile.ZipInfo("LANGUAGE",(2000,1,1,0,0,0)),(ROOT/"src/LANGUAGE").read_bytes())
