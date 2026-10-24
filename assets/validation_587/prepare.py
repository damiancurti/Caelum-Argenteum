"""Build deterministic private food-forecast checks; no fixture distribution."""
from pathlib import Path
import importlib.util
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue410-food'


def main():
    WORK.mkdir(parents=True, exist_ok=True)
    spec = importlib.util.spec_from_file_location('room580', ROOT/'assets/validation_580/prepare.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    members = {
        'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs': (HERE/'checks.zs').read_bytes(),
        'MAPINFO': b'GameInfo { AddEventHandlers="CA410JChecks" }\ncluster 8417 { hub }\nmap CFJ410 "Food forecast" { cluster=8417 }\nmap CFJ410B "Food return" { cluster=8417 }\n',
        'maps/CFJ410.wad': module.wad(module.room(), 'CFJ410'),
        'maps/CFJ410B.wad': module.wad(module.room(), 'CFJ410B'),
    }
    with zipfile.ZipFile(WORK/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
        for name, blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), blob)
    scripts = {
        'core': 'wait 35; netevent ca410j_core; wait 5; quit',
        'commit': 'wait 35; netevent ca410j_commit; wait 5; quit',
        'save': 'wait 35; netevent ca410j_seed; save ca410j-original; wait 5; quit',
        'load': 'wait 5; netevent ca410j_loaded; wait 5; quit',
        'hub': 'wait 5; netevent ca410j_loaded; changemap CFJ410B; wait 35; netevent ca410j_loaded; changemap CFJ410; wait 35; netevent ca410j_loaded; wait 5; quit',
    }
    for name, script in scripts.items():
        (WORK/(name+'.cfg')).write_text(script+'\n', encoding='utf-8')
    legacy=(HERE/'legacy.zs').read_text(encoding='utf-8')
    modes={
        'baseline': '''illness.Contamination=12.5;illness.DamageFraction=0.375;
        u.DerivedStats.HealthRegenerationPerSecond=0;
        plan.Available=new('CaelumJourneyModel');plan.Available.Capture(u,false);plan.Open=false;
        skip.Forecast=new('CaelumTimeSkipModel');skip.Forecast.CaptureSkip(u,false);
        ok=skip.Forecast.ProvisionRevision==5;''',
        'bridge': '''ok=illness.Contamination>12.49 && illness.Contamination<=12.5 && illness.DamageFraction==0.375
            && plan.Available!=null && plan.Available.FoodIllness==null
            && skip.Forecast!=null && skip.Forecast.ProvisionRevision==5;
        plan.Available.Capture(u,false);skip.Forecast.CaptureSkip(u,false);
        ok=ok && plan.Available.FoodIllness!=null && plan.Available.FoodIllness!=illness
            && plan.Available.FoodIllness.Contamination==illness.Contamination
            && skip.Forecast.ProvisionRevision==6 && skip.Forecast.FoodIllness!=illness;
        illness.Ensure();ok=ok && illness.DamageFraction==0.375;''',
        'rollback': '''ok=illness.Contamination>12.49 && illness.Contamination<=12.5 && illness.DamageFraction==0.375
            && skip.Forecast!=null && skip.Forecast.ProvisionRevision==5;''',
    }
    for mode, code in modes.items():
        target=WORK/mode
        target.mkdir(parents=True,exist_ok=True)
        bridge=dict(members)
        bridge['checks.zs']=legacy.replace('// MODE',code).encode('utf-8')
        bridge['MAPINFO']=members['MAPINFO'].replace(b'CA410JChecks',b'CA410JLegacy')
        with zipfile.ZipFile(target/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
            for name,blob in sorted(bridge.items()):
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    (WORK/'legacy-seed.cfg').write_text('wait 35; netevent ca410j_legacy; save ca410j-legacy; wait 5; quit\n',encoding='utf-8')
    (WORK/'legacy-load.cfg').write_text('wait 1; netevent ca410j_legacy; wait 5; quit\n',encoding='utf-8')


if __name__ == '__main__':
    main()
