"""Prepare deterministic private contamination checks, reusing accepted rooms."""
from pathlib import Path
import importlib.util
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue502'


def main():
    WORK.mkdir(parents=True, exist_ok=True)
    spec = importlib.util.spec_from_file_location('room580', ROOT/'assets/validation_580/prepare.py')
    room = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(room)
    members = {
        'ZSCRIPT': b'version "4.14"\n#include "forecast.zs"\n#include "checks.zs"\n',
        'forecast.zs': (ROOT/'assets/validation_587/checks.zs').read_bytes(),
        'checks.zs': (HERE/'checks.zs').read_bytes(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA502Checks" }\ncluster 8502 { hub }\nmap CTX502 "Contamination" { cluster=8502 }\nmap CTX502B "Contamination return" { cluster=8502 }\n',
        'maps/CTX502.wad': room.wad(room.room(), 'CTX502'),
        'maps/CTX502B.wad': room.wad(room.room(), 'CTX502B'),
    }
    with zipfile.ZipFile(WORK/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
        for name, blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), blob)
    scripts = {
        'rules': 'wait 35; netevent ca502_rules; wait 5; quit',
        'runtime': 'wait 35; netevent ca502_runtime; wait 5; quit',
        'save': 'wait 35; netevent ca502_seed; save ca502-original; wait 5; quit',
        'load': 'wait 5; netevent ca502_loaded; wait 5; quit',
        'hub': 'wait 5; netevent ca502_loaded; changemap CTX502B; wait 35; netevent ca502_loaded; changemap CTX502; wait 35; netevent ca502_loaded; wait 5; quit',
        'manual': 'bind F1 "netevent ca502_manual89"; bind F2 "netevent ca502_manual90"; bind F3 "netevent ca502_manual100"; bind F4 "netevent ca502_immune"; bind F5 "netevent ca502_clean"; wait 35; netevent ca502_clean',
    }
    for name, script in scripts.items():
        (WORK/(name+'.cfg')).write_text(script+'\n', encoding='utf-8')
    legacy=(HERE/'legacy.zs').read_text(encoding='utf-8')
    modes={
        'baseline': '''illness.Contamination=12.5;illness.DamageFraction=0.375;
        u.DerivedStats.HealthRegenerationPerSecond=0;
        skip.Forecast=new('CaelumTimeSkipModel');skip.Forecast.CaptureSkip(u,false);
        ok=skip.Forecast.ProvisionRevision==6;''',
        'bridge': '''ok=illness.Contamination>12.49 && illness.Contamination<=12.5 && illness.DamageFraction==0.375
            && skip.Forecast!=null && skip.Forecast.ProvisionRevision==6;
        skip.Forecast.CaptureSkip(u,false);
        ok=ok && skip.Forecast.ProvisionRevision==7 && skip.Forecast.FoodIllness!=illness;
        illness.Ensure();ok=ok && illness.DamageFraction==0.375;''',
        'rollback': '''ok=illness.Contamination>12.49 && illness.Contamination<=12.5 && illness.DamageFraction==0.375
            && skip.Forecast!=null && skip.Forecast.ProvisionRevision==6;''',
    }
    for mode,code in modes.items():
        target=WORK/mode;target.mkdir(parents=True,exist_ok=True)
        bridge=dict(members)
        bridge['ZSCRIPT']=b'version "4.14"\n#include "checks.zs"\n'
        bridge['checks.zs']=legacy.replace('// MODE',code).encode('utf-8')
        bridge['MAPINFO']=members['MAPINFO'].replace(b'CA502Checks',b'CA502Legacy')
        with zipfile.ZipFile(target/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
            for name,blob in sorted(bridge.items()):
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    (WORK/'legacy-seed.cfg').write_text('wait 35; netevent ca502_legacy; save ca502-legacy; wait 5; quit\n',encoding='utf-8')
    (WORK/'legacy-load.cfg').write_text('wait 1; netevent ca502_legacy; wait 5; quit\n',encoding='utf-8')


if __name__ == '__main__':
    main()
