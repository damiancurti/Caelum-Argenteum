"""Summarize completed native evidence; assert save preservation and package parity.

Run after prepare.py, the recorded native runs and build_dev.ps1. Re-run after
releasing the keep-awake helper to include its final release record. Local saves,
packages, binaries and IWADs remain in build/ and are never copied for delivery.
"""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue131'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save_objects(phase):
    with zipfile.ZipFile(WORK/f'ca131_verified_{phase}.zds') as archive:
        return json.loads(archive.read('qa131a.map.json'))['objects']


manifest=json.loads((WORK/'MANIFEST.json').read_text())
labels=['final-authority-build','final-checks','viewed-b','final-authority-ui','icon-visual-en',
        'icon-visual-43','icon-visual-wide',
        *['verified-save-'+phase for phase in ['baseline','upgrade','reload','hub','rollback','reupgrade']],
        'performance-baseline','performance-current','final-visual-43']
runs=[]
for label in labels:
    record=json.loads((HERE/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log=(HERE/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert record.get('completed_utc') and re.search(record['expected'],log), label
    assert not re.search(r'CA131 FAIL|Script error,|VM execution aborted|DIED WITH FATAL ERROR',log),label
    result={'label':label,'package_sha256':record['package_sha256'],
            'addon_sha256':record['addon_sha256'],'log_sha256':digest(HERE/f'{label}.txt'),
            'config_sha256':digest(HERE/f'{label}.ini')}
    checks=re.search(r'CA131 COMPLETE checks=(\d+) failures=0',log)
    if checks:result['checks']=int(checks[1])
    runs.append(result)

phases=['baseline','upgraded','reloaded','hub','rollback','reupgraded']
baseline=next(o for o in save_objects('baseline') if o['classtype']=='CaelumPersistentCharacterState')['class:CaelumPersistentCharacterState']
dynamic={'StoredHunger','StoredThirst','StoredSleep','ThermalState'}
save_results=[]
for phase in phases:
    objects=save_objects(phase)
    record=next(o for o in objects if o['classtype']=='CaelumPersistentCharacterState')['class:CaelumPersistentCharacterState']
    thermal={k.lower():v for k,v in next(o for o in objects if o['classtype']=='CaelumThermalState')['class:CaelumThermalState'].items()}
    preserved=[key for key in baseline if key not in dynamic]
    assert all(record.get(key)==baseline[key] for key in preserved),(phase,'persistent record reset')
    for key in dynamic-{'ThermalState'}:
        assert 0<record[key]<=baseline[key],(phase,key)
    assert math.isfinite(thermal['exposure']) and thermal['exposure']>0,phase
    assert 4.49<thermal['acclimation']<=4.5 and thermal['damageremainder']==0.3125,phase
    assert thermal['revision']==(1 if phase=='baseline' else 2),phase
    if phase not in ['baseline','rollback']:
        assert abs(thermal['acclimationmultiplier']-(1+2*10*11/10100))<1e-12,phase
    equipment=next(o['class:CaelumEquipmentItem'] for o in objects if 'class:CaelumEquipmentItem' in o)
    if phase=='baseline':base_equipment=equipment
    assert equipment==base_equipment,(phase,'equipment changed')
    save_results.append({'phase':phase,'save_sha256':digest(WORK/f'ca131_verified_{phase}.zds'),
                         'preserved_record_fields':len(preserved),'equipment_fields_identical':len(equipment),
                         'revision':thermal['revision'],'exposure':thermal['exposure'],
                         'acclimation':thermal['acclimation'],'damage_fraction':thermal['damageremainder'],
                         'derived_multiplier':thermal.get('acclimationmultiplier')})

performance={}
for phase in ['baseline','current']:
    log=(HERE/f'performance-{phase}.txt').read_text(encoding='utf-8-sig')
    rows={int(tic):float(ms) for tic,ms in re.findall(r'PERF tic=(\d+) ms=([\d.]+)',log)}
    assert 'living=6602 attackers=6001 defenders=600 dense=1' in log,phase
    performance[phase]=595000/(rows[700]-rows[105])

standard=ROOT/'build/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(standard) as built,zipfile.ZipFile(WORK/'production.pk3') as tested:
    assert sorted(built.namelist())==sorted(tested.namelist())
    assert all(built.read(name)==tested.read(name) for name in tested.namelist())
    members=len(tested.namelist())
screenshots=[]
for path in sorted(HERE.glob('*.png')):
    if not path.name.startswith(('ca131-','icon-43','final-43')):continue
    width,height=struct.unpack('>II',path.read_bytes()[16:24])
    screenshots.append({'file':path.name,'width':width,'height':height,'sha256':digest(path),
        'status':'superseded before aspect fix' if path.name=='final-43.png' else 'final icon/HUD'})

result={
    'issue':131,'release':'5.1.1','baseline_commit':manifest['baseline_commit'],
    'status':'implemented and agent-verified; author acceptance pending CA131-01/02',
    'engine':'GZDoom 4.14.2, Windows/Vulkan, RNG 116, cap 60, 5% audio, background unpaused',
    'production_sha256':manifest['production'],'standard_build_sha256':digest(standard),
    'standard_build_members_identical':members,'repeat_fixture_hashes_identical':True,'deterministic_fixture_manifest':manifest,
    'post_functional_changes':'Save/viewed/English/aspect evidence predates only the behavior-preserving extraction of existing threshold literals into shared data and helpers. Final-authority-build reruns all 47 assertions on the standard final PK3; final-authority-ui exercises all states and Journal with those helpers.',
    'unique_functional_assertions':47,'viewed_player_native_check':'native second player bot, cinematic fallback, no ownership mutation',
    'runs':runs,'saves':save_results,
    'save_qualifications':'220 of 224 prior record fields remain identical throughout. Three reserve values naturally decrease with simulation and the ThermalState object index changes on hub travel. The entire equipment record remains identical. E/activity/acclimatization/moisture continue simulating; small seeded moisture is already dry by the first saved snapshot. Exact nonzero water preservation across idempotent revision migration is separately asserted in checks.zs. Rolling back restores old gameplay; re-upgrade reconstructs the derived multiplier even with revision 2 retained.',
    'screenshots':screenshots,
    'hud':'Neutral, six harmful states, recovery, Toughness boundaries, extreme overflow, signed localized text, icon, notification, sword and Journal. Native 1024x768, 1280x720 and 1680x720; screenblocks 10/11/12 and hud_scale 0/2/3. Fixed prior fill/frame mismatch with the native coordinate projection. Static Draw path has no thermal mutation, geometry/weather query or serialized duplicate.',
    'journeys':'Actual destination region is passed by the journey planner; both endpoint weather samples advance with civil time. Blend by moving distance, pausing foot/cart progress during sleep and continuing ships. Native region 1 -> 9 forecast changes exposure and adaptation; harmful route rejected, unknown destination rejected, copy remains separate and no real-time damage invented. Shipped destinations currently all share region 1; catalogue and map markers must stay consistent when adding future regions.',
    'performance':{'window_tics':[105,700],'simulation_tics_per_second':performance,'roster':'6001 attackers + 600 defenders + player',
        'qualification':'One short arrival pair, not statistical evidence of improvement or late-battle FPS. Functional source includes HUD projection correction; final later changes add the fixed thermal icon and extract unchanged 10/20/30 boundaries into shared data/helpers used by simulation, HUD bands and Journal. The final standard build reruns all 47 checks and Spanish UI states. No AI/population policy changed; no new per-frame scan.'},
    'corrections':'The copied save fixture omitted WeaponDurabilityRevision, accidentally triggering the old x10 migration before hub restore; the corrected verified-save chain initializes that metadata and compares every equipment field. Early multi-line console scripts quit before their waits; recorded final scripts use one command chain. Initial unsafe walking fixture could heat from exertion; changed to a sheltered cold ship route, preserving production rules. Native multi-value projection helper needed explicit unpack/return. Windows client sizes verified from PNG headers. Before-fix 4:3 capture retained explicitly.',
    'reproduce':'python assets/validation_511/prepare.py; powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_511/run_check.ps1 with the label/package/addon/map/script/language/dimensions recorded in each *-run.json. Use unique labels. For viewed.cfg first run prepare_bots.py and pass the isolated engine path. Standard package: build_dev.ps1. Generate this summary with collect_results.py.',
    'author_pending':['CA131-01','CA131-02'],
}
power=WORK/'power-request.json'
if power.exists():
    result['keep_awake']=json.loads(power.read_text(encoding='utf-8-sig'))
    if result['keep_awake'].get('released_utc'):
        assert result['keep_awake']['release_result'] and result['keep_awake']['active_plan_before']==result['keep_awake']['active_plan_after']
        shutil.copy2(power,HERE/power.name)
(HERE/'RESULTS.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
(HERE/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(f'Verified {len(runs)} native runs, {len(save_results)} saves, {members} matching package members; {len(screenshots)} screenshots.')
