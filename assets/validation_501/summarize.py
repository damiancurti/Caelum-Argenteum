"""Validate and archive #117 evidence; local packages/saves stay out of Git."""
from pathlib import Path
import hashlib
import json
import re
import statistics
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue117'
RUNS=['baseline-domains-final','current-domains','old-save-current-final',
      'new-save-reload','upgraded-save-reload','original-save-rollback',
      'baseline-performance','current-performance','current-performance-repeat','baseline-performance-repeat',
      'menu-flow-es-final','menu-flow-enu-final']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def log(label):
    return (WORK/f'{label}.txt').read_text(encoding='utf-8-sig')


def values(label):
    return [line for line in log(label).splitlines() if line.startswith('CA117 VALUE')]


def save_state(filename):
    with zipfile.ZipFile(WORK/filename) as save:
        info=json.loads(save.read('info.json'))
        data=json.loads(save.read(info['Current Map'].lower()+'.map.json'))
    pawn=next(o for o in data['objects'] if o['classtype']=='CaelumPlayer')
    fields=pawn['class:CaelumPlayer']
    return data,pawn,fields


def verify_loaded_save(filename,label):
    data,pawn,fields=save_state(filename)
    line=next(v for v in values(label) if ' save-load ' in v)
    observed=dict(re.findall(r'(\w+)=(-?[\d.]+)',line))
    mapping={'anima':'CurrentAnima','air':'CurrentAir','adrenaline':'CurrentAdrenaline',
        'lucidity':'CurrentLucidity','hunger':'CurrentHunger','thirst':'CurrentThirst',
        'sleep':'CurrentSleep','debt':'UnderwaterAirRecoveryDebt',
        'debtTics':'UnderwaterAirRecoveryTicsRemaining','combat':'CombatTimeRemaining',
        'stun':'LucidityPhysicalStunRemaining','healthState':'HealthState',
        'survival':'SurvivalPerformanceMultiplier','move':'EffectiveMovementPercent'}
    assert int(observed['hp'])==pawn['health']
    for printed,field in mapping.items():
        assert abs(float(observed[printed])-fields[field])<0.000000001,(filename,field)
    return dict(save=filename,sha256=digest(WORK/filename),run=label,
                exact_serialized_resource_values_checked=len(mapping)+1,
                result='PASS')


def performance(label):
    rows=[dict(re.findall(r'(\w+)=(-?[\d.]+)',line)) for line in log(label).splitlines() if line.startswith('CA116 SIM')]
    first,last=rows[0],rows[-1]
    tics=int(last['tic'])-int(first['tic']); seconds=(float(last['ms'])-float(first['ms']))/1000
    intervals=[float(x) for x in re.findall(r'CA116 FRAME .*interval=([\d.]+)',log(label))]
    profiles=[float(x) for x in re.findall(r'^\s*([\d.]+)\s+[\d.]+\s+1\s+CaelumPlayer\s*$',log(label),re.M)]
    return dict(tics=tics,wall_seconds=seconds,tics_per_second=tics/seconds,
        first=first,last=last,overlay_interval_median_ms=statistics.median(intervals),
        overlay_interval_max_ms=max(intervals),overlay_samples=len(intervals),player_single_tic_profile_ms=profiles)


def main():
    logs={}
    for label in RUNS:
        raw=log(label)
        assert not re.search(r'CA117 FAIL|VM execution aborted|Script error|needs these files',raw),label
        counts=re.findall(r'CA117 (?:DONE|PERSIST .*?) checks=(\d+) failures=(\d+)',raw)
        if 'performance' not in label and not label.startswith('menu-'):
            assert counts and all(int(f)==0 for _,f in counts),label
        logs[label]={'checks':int(counts[-1][0]) if counts else None,'result':'MEASURED' if 'performance' in label else 'PASS'}
        for suffix in ['txt','ini','-run.json']:
            name=label+suffix if suffix.startswith('-') else label+'.'+suffix
            source=WORK/name
            text=source.read_text(encoding='utf-8-sig')
            target=HERE/name
            target.write_text('\n'.join(line.rstrip() for line in text.splitlines()).rstrip()+'\n',encoding='utf-8',newline='\n')
            logs[label][suffix]={'source_sha256':digest(source),'archive_sha256':digest(target)}
    assert values('baseline-domains-final')==values('current-domains')
    for name in ['ca117_baseline.zds','ca117_current.zds']:
        data,pawn,fields=save_state(name)
        # Native object table indexes are references, not stable domain identities.
        for field in ['CharacterProfile','CharacterAllocation','attributes','DerivedStats',
                      'AnatomyProfile','ElementalStatus','ArmorModel','ShieldModel','WeaponModel']:
            if fields[field] is not None:
                fields[field]=data['objects'][fields[field]]
        if 'baseline' in name: prior=fields
        else: assert prior==fields,'All serialized pawn fields must agree at the same fresh-save tic'
    saves=[verify_loaded_save('ca117_baseline_hub.zds','old-save-current-final'),
           verify_loaded_save('ca117_current_hub.zds','new-save-reload'),
           verify_loaded_save('ca117_upgraded.zds','upgraded-save-reload'),
           verify_loaded_save('ca117_baseline_hub.zds','original-save-rollback')]
    before,after=performance('baseline-performance'),performance('current-performance')
    repeat_before,repeat_after=performance('baseline-performance-repeat'),performance('current-performance-repeat')
    traces=[[re.sub(r' ms=[\d.]+','',line) for line in log(label).splitlines() if line.startswith('CA116 SIM')]
            for label in RUNS if 'performance' in label]
    assert all(trace==traces[0] for trace in traces)
    menu_results={}
    for language in ['enu','es']:
        label=f'menu-flow-{language}-final'
        assert 'CA117 MENU page=7 layers=0 attributes=0' in log(label)
        assert log(label).count('Inicio por comando directo')==1
        data,pawn,fields=save_state(f'ca117_created_{language}.zds')
        profile=data['objects'][fields['CharacterProfile']]['class:CaelumCharacterProfile']
        allocation=data['objects'][fields['CharacterAllocation']]['class:CaelumCharacterAllocation']
        assert fields['CharacterCreationComplete'] and not fields['CreationWizardOpen']
        assert profile==dict(Race=2,FirstClass=0,SecondClass=3,Sex=0,HeightChoice=1)
        assert allocation['LayerBonus']==[1,1,1,1]
        assert allocation['AttributeBonus']==[3,3,3,3,3,3,2,2,2,2,2,2]
        assert 'x=0.000 y=337.952' in log(label),'Scheduled forward input must move the native pawn'
        shots={}
        for screen in ['journal','creator-summary','created-map01']:
            name=f'{screen}-{language}.png'; shutil.copyfile(WORK/name,HERE/name); shots[name]=digest(HERE/name)
        menu_results[language]=dict(result='PASS',profile=profile,allocation=allocation,captures=shots,
            route='Native menu events confirm draft; console map MAP01 consumes it through PostBeginPlay. Final physical introduction keypress not covered.',
            movement='Scheduled native +forward/+jump/-forward/-jump commands; physical device latency not measured.')
    result=dict(issue=117,release='5.0.1',date='2026-10-06',baseline_commit='6e8f0d66d718740f503a5ccf181241711d20140f',
        static=json.loads((HERE/'EXTRACTION.json').read_text()),runs=logs,
        equivalence=dict(matching_value_rows=len(values('current-domains')),profile_combinations=64,
            identical_serialized_pawn_fields_at_fresh_save=len(prior),result='PASS'),
        saves=saves,native_menu_flow=menu_results,
        visual_inspection='All six archived Journal, creator-summary and created-MAP01 captures inspected in English/Spanish; existing layout/localization retained.',
        performance=dict(before=before,after=after,
            throughput_change_percent=(after['tics_per_second']/before['tics_per_second']-1)*100,
            reversed_order_repeat_before=repeat_before,reversed_order_repeat_after=repeat_after,
            repeat_throughput_change_percent=(repeat_after['tics_per_second']/repeat_before['tics_per_second']-1)*100,
            identical_scene_population_samples_per_run=len(traces[0]),
            player_mean_ms_before=statistics.mean(repeat_before['player_single_tic_profile_ms']),
            player_mean_ms_after=statistics.mean(repeat_after['player_single_tic_profile_ms']),
            result='OBSERVED REGRESSION: 4.88% to 5.99% lower whole-scene throughput. Full-scene cause unresolved; carry evidence into #120. No speedup claim.'),
        packages={name:digest(WORK/name) for name in ['baseline.pk3','current.pk3','checks.pk3','benchmark.pk3','ui.pk3']},
        limits=[
            'Stateless method relocation preserves behavior; this is not full player modularization or a claimed speedup.',
            'Native tests use disposable synthetic states and actual Windows GZDoom 4.14.2; they are distinct from author gameplay acceptance.',
            'Save compatibility demonstrated from 5.0.0 with unchanged current map layouts. Original 5.0.0 save/package rollback is tested; newer-save downgrade is not claimed.',
            'MAP06 comparison uses matching seed 116, scene, population, Vulkan and 5% master audio. Overlay intervals are not GPU frame times or physical input latency; desktop load and instrumentation remain limitations.'
        ],diagnostics=[
            'Initial artificial equipment omitted WeaponDurabilityRevision=1; baseline correctly migrated 7 to 70. Fixture corrected before baseline/final acceptance runs; production logic unchanged.',
            'First cross-version load used different package basenames; GZDoom refused baseline.pk3 as missing. Final load uses current-runtime/baseline.pk3 containing the new package bytes, matching normal stable production naming.',
            'Git checkout normalized only the unchanged presentation helper from LF to CRLF; verifier identifies that byte-only package difference separately.',
            'Initial UI observer used incompatible Name/String conditional types, then an unsupported String() cast. Corrected to a boolean ReadyWeapon indicator; production code never changed.',
            'Desktop input contention prevented a completed physical-key test. Native console inputs and menu events were used; captures come from the engine, not the unrelated desktop.',
            'Initial menu-flow-es correctly aborted when StartGameDirect was called from ConsoleProcess, outside DMenu::InMenu. Final fixtures confirm the menu draft then use closemenu/map MAP01. Ordinary final keypress is left to CA-501-PLAYER-01.'
        ],reproduction=[
            'Build accepted commit 6e8f0d66 in a separate checkout and preserve its PK3 as build/issue117/baseline.pk3; build this revision as current.pk3. Do not overwrite original save copies.',
            'Run python assets/validation_501/prepare_checks.py and verify_extraction.py. run_native.ps1 accepts -Label, -Package, -Addon, -Map, -Script, -LoadGame; labels must be new.',
            'Run checks.pk3 on MAP03 with baseline.cfg/current.cfg. Stage current.pk3 unchanged as current-runtime/baseline.pk3 for the old-save load; keep the original baseline.pk3 for rollback.',
            'Run baseline/current benchmark.cfg sequentially on MAP06, then reverse order with benchmark-profile.cfg. Never overlap engine processes. Run ui-enu.cfg/ui-es.cfg with ui.pk3 for native menu/input captures.',
            'Run summarize.py after completed native runs; logs/settings/manifests are archived, packages/IWAD/executable/save fixtures stay local.'
        ],author_acceptance='Pending for #117. Author acceptance of #116 recorded separately before merge.')
    (HERE/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'native_runs':{k:v['checks'] for k,v in logs.items()},'equivalence':result['equivalence'],'performance':result['performance']},indent=2))


if __name__=='__main__':main()
