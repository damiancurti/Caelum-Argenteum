"""Read native snapshots to distinguish thermal attrition from cheap live AI."""
from pathlib import Path
import hashlib
import json
import zipfile

HERE=Path(__file__).resolve().parent
WORK=HERE.parents[1]/'build/issue133'
snapshots=[]
for name in ('volley-500.zds','volley-1450.zds'):
    path=WORK/name
    with zipfile.ZipFile(path) as archive:objects=json.loads(archive.read('map06.map.json'))['objects']
    rows=[]
    for body in objects:
        if 'class:CaelumPortDefender' not in body:continue
        combat=body['class:CaelumCombatActor']
        thermal={k.lower():v for k,v in objects[combat['ThermalState']]['class:CaelumThermalState'].items()}
        rows.append({'health':body.get('health',0),'maximum_health':combat['CombatMaximumHealth'],
            'air':combat['CurrentCombatAir'],'exposure':thermal['exposure'],
            'thermal_damage_hp':thermal['applieddamagehp'],'action_heat_joules':thermal['actionjoules'],
            'reference_jump_joules':thermal['referencejumpheat'],'inertia_joules_per_degree':thermal['inertia']})
    snapshots.append({'save':name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'roster':len(rows),
        'alive':sum(r['health']>0 for r in rows),'ranges':{key:[min(r[key] for r in rows),max(r[key] for r in rows)] for key in rows[0]}})
assert snapshots[0]['alive']==600 and snapshots[1]['alive']==0
assert snapshots[1]['ranges']['thermal_damage_hp'][0]>=snapshots[1]['ranges']['maximum_health'][1]
report={'issue':133,'evidence':'Native snapshot confirmation after the unchanged full-roster firearm control',
    'diagnostic_run':'volley-cause','scope':'Stationary targets never attack. Normal Air, native collision, friendly bodies, physiology and thermal damage remain enabled.',
    'finding':'All 600 fire 14 rounds and complete one reload. Action heat is 14 x 4 x the existing jump heat reference; the current #130 Air-to-heat profile is retained without a second heat-cost multiplier. All 600 die from accumulated thermal damage by tic 1400 in the measured control.',
    'snapshots':snapshots,'policy':'This is a balance limitation, not a sustained-fire performance success. Changing the approved thermal profile requires an explicit design decision; #133 does not silently exempt soldiers or refill their resources.'}
(HERE/'HEAT_LIMIT.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(snapshots,indent=2))
