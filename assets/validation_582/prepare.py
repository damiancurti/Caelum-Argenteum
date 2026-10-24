"""Build private deterministic #414 runtime checks, reusing the verified room."""
from pathlib import Path
import importlib.util
import json
import re
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / 'build/issue414-runtime'

def main():
    spec = importlib.util.spec_from_file_location('water_fixture_580', ROOT/'assets/validation_580/prepare.py')
    old = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(old)
    text = old.room()
    def block(match):
        kind, body = match.group(1), match.group(2)
        fields = {k: json.loads(v.strip()) for k,v in re.findall(r'(\w+)\s*=\s*([^;]+);', body)}
        for key in ('x','y','z','heightfloor','heightceiling'):
            if key in fields: fields[key] *= 0.5
        if kind == 'sector':
            if fields.get('id') == 101: fields['user_ca_connected_water'] = 1
            if fields.get('heightfloor') == 96: fields['heightfloor'] = 64
            if fields.get('user_ca414_id') in (101,102):
                fields['user_ca_connected_water_id'] = fields['user_ca414_id']-100
            if fields.get('id') == 101:
                fields.update(user_ca_water_switch=1,user_ca_water_switch_x=192,user_ca_water_switch_y=192,
                              user_ca_water_switch_z=64,user_ca_water_switch_angle=270)
        return kind+' { '+' '.join(k+'='+json.dumps(v)+';' for k,v in fields.items())+' }'
    text=re.sub(r'(vertex|sidedef|linedef|sector|thing)\s*\{([^}]*)\}',block,text)
    members = {
        'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs': (HERE/'checks.zs').read_bytes(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA414RuntimeChecks" }\ncluster 8414 { hub }\nmap CAW414 "Water runtime checks" { cluster=8414 }\nmap CAW414B "Water return checkpoint" { cluster=8414 }\n',
        'maps/CAW414.wad': old.wad(text, 'CAW414'),
        'maps/CAW414B.wad': old.wad(text, 'CAW414B'),
    }
    OUT.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(OUT/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
        for name, blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), blob)
    (OUT/'numeric.cfg').write_text('wait 35; netevent ca414r_numeric; wait 5; quit\n', encoding='utf-8')
    scripts={
        'world':'wait 35; netevent ca414r_prepare; netevent ca414r_calendar; wait 5; netevent ca414r_immersion; wait 5; netevent ca414r_dry; wait 5; quit',
        'save':'wait 35; netevent ca414r_prepare; netevent ca414r_seed; wait 5; save ca414r-closed; wait 5; quit',
        'load':'wait 5; netevent ca414r_loaded; wait 5; quit',
        'hub':'wait 5; netevent ca414r_loaded; changemap CAW414B; wait 35; netevent ca414r_prepare; changemap CAW414; wait 35; netevent ca414r_loaded; wait 5; quit',
        'mansion':'r_drawplayersprites false; wait 1; netevent ca414r_quiet; wait 35; netevent ca414r_mansion; wait 10; screenshot "mansion-water-clear.png"; netevent ca414r_pool; wait 5; netevent ca414r_poolcheck; wait 5; quit',
        'flow-save':'wait 35; netevent ca414r_prepare; netevent ca414r_flowseed; wait 10; save ca414r-flow; wait 5; quit',
        'flow-load':'wait 5; netevent ca414r_flowloaded; wait 5; quit',
        'flow-hub':'wait 5; netevent ca414r_flowloaded; changemap CAW414B; wait 35; netevent ca414r_hour; changemap CAW414; wait 35; netevent ca414r_flowloaded; wait 5; quit',
        'legacy-save':'wait 1; netevent ca414r_quiet; wait 35; netevent ca414r_legacy; save ca414r-old-mansion; wait 5; changemap MAP02; wait 35; netevent ca414r_legacy; save ca414r-old-hub; wait 5; quit',
        'legacy-load':'wait 70; netevent ca414r_legacy; wait 5; quit',
        'legacy-hub':'wait 70; netevent ca414r_legacy; changemap MAP01; wait 70; netevent ca414r_legacy; save ca414r-updated-hub; wait 5; quit',
    }
    for name,script in scripts.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
    controls='''exec ../../assets/playtest/default_controls.cfg
language es
bind F1 "netevent ca414r_dock"
bind F2 "netevent ca414r_north"
bind F3 "netevent ca414r_south"
bind F4 "netevent ca414r_minute"
bind F5 "netevent ca414r_report; toggleconsole"
bind F6 "netevent ca414r_overview"
'''
    (OUT/'interactive.cfg').write_text(controls+'wait 35; netevent ca414r_author\n',encoding='utf-8')
    (OUT/'resume.cfg').write_text(controls+'wait 70; netevent ca414r_report\n',encoding='utf-8')
    with zipfile.ZipFile(OUT/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted({'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n','legacy.zs':(HERE/'legacy.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA414LegacyChecks" }\n'}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    with zipfile.ZipFile(OUT/'performance.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted({'ZSCRIPT':b'version "4.14"\n#include "performance.zs"\n','performance.zs':(HERE/'performance.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA414Performance" }\n'}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    print('Prepared #414 runtime fixture.')

if __name__ == '__main__':
    main()
