"""Build a reversible 5.0.6 runtime bridge preserving the 5.1 thermal schema.

Reads the pinned accepted baseline from Git and adds serialization declarations
only. Gameplay remains 5.0.6: thermal simulation is inactive, saved thermal state
is retained for returning to 5.1. Never rewrites or deletes a save. Output is an
ignored, regenerable PK3; distribute neither engine nor IWAD/test saves.
"""
from pathlib import Path
import hashlib
import io
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue130'
BASE = '45f16371d49c38894e6d256d32d8101d4b06cd4c'


def main():
    active = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/NH'], text=True)
    if 'gzdoom.exe' in active.lower():
        raise SystemExit('Close native runs before replacing packages.')
    archive = subprocess.check_output(['git', 'archive', '--format=zip', BASE, 'src'], cwd=ROOT)
    with zipfile.ZipFile(io.BytesIO(archive)) as source:
        members = {n.removeprefix('src/'): source.read(n) for n in source.namelist() if not n.endswith('/')}
    # Preserve the new references in their original owners without moving data.
    declarations = {
        'caelum/equipment/CaelumPersistentCharacterState.zs': 'CaelumThermalState ThermalState;',
        'caelum/actors/CaelumCombatActor.zs': 'CaelumThermalState ThermalState; bool ThermalBluntDelivery;',
        'caelum/player/CaelumPlayer.zs': 'bool ThermalBluntDelivery;',
        'caelum/equipment/CaelumEquipmentPickups.zs': 'double ThermalWaterKg;',
        'caelum/actors/CaelumActorProjectile.zs': 'Array<Actor> ThermalRecipients;',
        'caelum/world/CaelumJourneyPlan.zs': 'CaelumThermalJourney ThermalForecast;',
    }
    classes = {
        'caelum/equipment/CaelumEquipmentPickups.zs': 'class CaelumEquipmentItem ',
        'caelum/actors/CaelumActorProjectile.zs': 'class CaelumActorProjectile ',
        'caelum/world/CaelumJourneyPlan.zs': 'class CaelumJourneyPlan ',
    }
    for name, declaration in declarations.items():
        text = members[name].decode('utf-8-sig')
        start = text.index(classes.get(name, 'class '))
        opening = text.index('{', start)+1
        members[name] = (text[:opening]+'\n    '+declaration+'\n'+text[opening:]).encode('utf-8')
    state = (ROOT/'src/caelum/survival/CaelumThermalState.zs').read_text(encoding='utf-8')
    state = state[:state.index('    CaelumThermalState CopyForForecast()')]+'}\n'
    journey = '''class CaelumThermalJourney : Object play
{
    CaelumThermalState Result;
    String Failure;
    double WorstExposure;
}
'''
    members['caelum/thermal_rollback_schema.zs'] = (state+journey).encode('utf-8')
    # Old gameplay cannot accrue thermal time. Preserve personal values but
    # invalidate cached timestamps before another 5.1 load resumes simulation.
    members['caelum/thermal_rollback_reset.zs'] = b'''class CaelumThermalRollbackReset : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        let actors=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor body;
        while((body=CaelumCombatActor(actors.Next()))!=null)
            if(body.ThermalState!=null){body.ThermalState.RuntimeReady=false;body.ThermalState.SourceMap="";body.ThermalState.PendingActivityJoules=0;body.ThermalState.PropelledVelocity=(0,0);}
        for(int i=0;i<MAXPLAYERS;i++)
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            let record=user.GetPersistentCharacterState(false);
            if(record!=null && record.ThermalState!=null)
            {record.ThermalState.SourceMap="";record.ThermalState.PendingActivityJoules=0;record.ThermalState.PropelledVelocity=(0,0);}
        }
    }
}
'''
    members['MAPINFO'] += b'\nGameInfo { AddEventHandlers="CaelumThermalRollbackReset" }\n'
    members['ZSCRIPT'] += b'\n#include "caelum/thermal_rollback_reset.zs"\n'
    for name in ['CaelumThermalData.zs', 'CaelumThermalFire.zs']:
        text = (ROOT/'src/caelum/survival'/name).read_text(encoding='utf-8')
        if name == 'CaelumThermalFire.zs':
            text = text[:text.index('class CaelumThermalFire :')]
        members['caelum/'+name] = text.encode('utf-8')
    members['ZSCRIPT'] += b'\n#include "caelum/thermal_rollback_schema.zs"\n#include "caelum/CaelumThermalData.zs"\n#include "caelum/CaelumThermalFire.zs"\n'
    OUT.mkdir(exist_ok=True)
    output = OUT/'rollback-506.pk3'
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_STORED) as package:
        for name, content in sorted(members.items()):
            package.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), content)
    result = dict(baseline=BASE, package_sha256=hashlib.sha256(output.read_bytes()).hexdigest(),
                  mode='5.0.6 gameplay with retained inert thermal serialization schema', saves_modified=False)
    (OUT/'ROLLBACK_MANIFEST.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
