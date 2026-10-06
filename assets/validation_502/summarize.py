"""Assert native evidence and archive reproducible logs/settings without game binaries."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import statistics
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue118'
RUNS=['baseline-inventory-2','current-inventory-final','old-save-current',
      'baseline-pickups-final','current-pickups',
      'baseline-transactions-4','current-transactions-final','ownership-current',
      'new-save-reload','upgraded-save-reload','original-save-rollback',
      'baseline-performance-locked','current-performance-locked',
      'current-performance-repeat','baseline-performance-repeat',
      'inventory-ui-final-enu','inventory-ui-final-es']

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def log(label):return (WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
def rows(label,prefix):return [s for s in log(label).splitlines() if s.startswith(prefix)]

def save_state(name):
    with zipfile.ZipFile(WORK/name) as z:
        info=json.loads(z.read('info.json'))
        data=json.loads(z.read(info['Current Map'].lower()+'.map.json'))
    pawn=next(o for o in data['objects'] if o['classtype']=='CaelumPlayer')
    return data,pawn,pawn['class:CaelumPlayer']

def comparable_save(name):
    data,pawn,fields=save_state(name)
    for key in ['CharacterProfile','CharacterAllocation','attributes','DerivedStats','AnatomyProfile',
                'ElementalStatus','ArmorModel','ShieldModel','WeaponModel']:
        if fields[key] is not None:fields[key]=data['objects'][fields[key]]
    index=data['objects'].index(pawn)
    items=[]
    for item in data['objects']:
        native=item.get('class:Inventory')
        if not native or native['Owner']!=index:continue
        # Compare every saved item subclass payload, amount and native owner identity.
        payload={k:v for k,v in item.items() if k.startswith('class:')}
        payload['classtype']=item['classtype'];payload['class:Inventory']['Owner']='same pawn'
        items.append(payload)
    return fields,items

def loaded_save(name,label):
    data,pawn,fields=save_state(name)
    observed=dict(re.findall(r'(\w+)=(-?[\d.]+)',next(s for s in rows(label,'CA118 VALUE') if ' save-load ' in s)))
    record=next(o['class:CaelumPersistentCharacterState'] for o in data['objects'] if o['classtype']=='CaelumPersistentCharacterState')
    assert int(observed['next'])==record['NextEquipmentItemId']
    assert int(observed['target'])==fields['CraftingTaskTargetItemId']
    assert bool(int(observed['task']))==bool(fields['CraftingTaskActive'])
    assert int(observed['reserved'])==sum(fields['CraftingTaskReservedUnits'])
    assert bool(int(observed['box']))==bool(fields['MagicBoxOwned'])
    assert abs(float(observed['weight'])-data['objects'][fields['DerivedStats']]['class:CaelumDerivedStats']['CarriedWeight'])<1e-9
    return dict(save=name,sha256=digest(WORK/name),run=label,result='PASS',serialized_values_checked=6,
                native_assertions='Exact IDs/owners/wear/Box/deck/essences/reservations/materials/reward and retry checked by fixture')

def performance(label):
    samples=[dict(re.findall(r'(\w+)=(-?[\d.]+)',s)) for s in rows(label,'CA116 SIM')]
    first,last=samples[0],samples[-1]
    tics=int(last['tic'])-int(first['tic']); seconds=(float(last['ms'])-float(first['ms']))/1000
    assert tics==1680 and len(samples)==49,label
    intervals=[float(x) for x in re.findall(r'CA116 FRAME .*interval=([\d.]+)',log(label))]
    profiles=[float(x) for x in re.findall(r'^\s*([\d.]+)\s+[\d.]+\s+1\s+CaelumPlayer\s*$',log(label),re.M)]
    return dict(tics=tics,wall_seconds=seconds,tics_per_second=tics/seconds,first=first,last=last,
        overlay_interval_median_ms=statistics.median(intervals),overlay_interval_max_ms=max(intervals),
        overlay_samples=len(intervals),player_single_tic_profile_ms=profiles),[{k:v for k,v in r.items() if k!='ms'} for r in samples]

def archive(name):
    source=WORK/name; target=HERE/name
    raw=source.read_text(encoding='utf-8-sig')
    lines=raw.splitlines()
    omitted=sum(line.startswith('CA116 INPUT') for line in lines)
    # Camera/time evidence suffices; incidental local key scan codes stay local.
    target.write_text('\n'.join(line.rstrip() for line in lines if not line.startswith('CA116 INPUT')).rstrip()+'\n',encoding='utf-8',newline='\n')
    return dict(source_sha256=digest(source),archive_sha256=digest(target),omitted_local_input_rows=omitted)

def main():
    runs={}
    for label in RUNS:
        raw=log(label)
        assert not re.search(r'CA118 FAIL|Script error|VM execution aborted|needs these files',raw),label
        counts=re.findall(r'CA118 (?:DONE|PERSIST .*?|OWNERSHIP|TRANSACTIONS|PICKUPS) checks=(\d+) failures=(\d+)',raw)
        if 'performance' not in label:assert counts and all(int(f)==0 for _,f in counts),label
        runs[label]=dict(result='MEASURED' if 'performance' in label else 'PASS',checks=int(counts[-1][0]) if counts else None)
        for name in [label+'.txt',label+'.ini',label+'-run.json']:runs[label][name]=archive(name)
        assert 'snd_mastervolume=0.05' in (WORK/(label+'.ini')).read_text(encoding='utf-8-sig'),label
    assert rows('baseline-inventory-2','CA118 VALUE')==rows('current-inventory-final','CA118 VALUE')
    assert rows('baseline-transactions-4','CA118 CRAFT')==rows('current-transactions-final','CA118 CRAFT')
    assert rows('baseline-pickups-final','CA118 PICKUP ')==rows('current-pickups','CA118 PICKUP ')
    prior,items=comparable_save('ca118_baseline.zds');current,current_items=comparable_save('ca118_current.zds')
    assert prior==current,'Every serialized pawn field must agree after resolving object references'
    assert items==current_items,'Every owned inventory subclass payload must agree'
    saves=[loaded_save('ca118_baseline_hub.zds','old-save-current'),loaded_save('ca118_current_hub.zds','new-save-reload'),
        loaded_save('ca118_upgraded.zds','upgraded-save-reload'),loaded_save('ca118_baseline_hub.zds','original-save-rollback')]
    before,scene=performance('baseline-performance-locked');after,scene_after=performance('current-performance-locked')
    assert scene==scene_after,'All scene/population/camera observations must match'
    repeat_after,repeat_scene=performance('current-performance-repeat');repeat_before,repeat_base_scene=performance('baseline-performance-repeat')
    assert scene==repeat_scene==repeat_base_scene,'Reversed-order repeat must have the same scene'
    images=[]
    for language in ['enu','es']:
        for name in [f'inventory-{language}.png',f'selection-{language}.png']:
            shutil.copyfile(WORK/name,HERE/name);images.append(dict(file=name,sha256=digest(HERE/name)))
    diagnostics={
        'compile-1':'Initial extraction omitted native AddInventory and pawn constant qualification; corrected in the deterministic extractor before successful native runs.',
        'baseline-inventory-1':'Fixture used nonexistent bow/size names and a UI console callback for play mutations; corrected to canonical names and NetworkProcess.',
        'baseline-transactions-1':'Fixture dynamic-array literal unsupported; changed to Array.Push.',
        'baseline-transactions-2':'Fixture did not scan the station network before opening it; all crafting correctly failed infrastructure validation.',
        'baseline-transactions-3':'Artificial material stock was 100 grams per type, below assembly requirements. Increased fixture stock to 20000; no production values changed.',
        'baseline-pickups':'Fixture ternary branches needed an explicit common Inventory cast; fixed before successful stack-pickup runs. Runner prevented a current run overlapping this failed compile.',
        'baseline-performance':'DISCARDED: later current-performance launch briefly overlapped before this run exited. Not used for timing conclusions.',
        'current-performance':'DISCARDED: stopped after detecting overlap. Runner now refuses any launch while another GZDoom process is alive; suite waits for each recorded PID.',
        'baseline-performance-final':'DISCARDED: camera moved to x=42.548 during the sample. The final observer consumes local input events; no production input path changed.'}
    diagnostic_files={label:dict(reason=reason,log=archive(label+'.txt'),run=archive(label+'-run.json')) for label,reason in diagnostics.items()}
    report=dict(issue=118,version='5.0.2',baseline_commit='da7d33b88b76241331bd8ddc007773b2e2c8b9f8',
        static='EXTRACTION.json: 604 fields/544 signatures/387 other bodies retained; 160 stateless moves and 12 explicit ownership guards. Re-running the extractor reproduces all four changed runtime sources byte-for-byte.',
        native_runs=runs,identical_inventory_value_rows=len(rows('baseline-inventory-2','CA118 VALUE')),
        identical_crafting_category_rows=len(rows('baseline-transactions-4','CA118 CRAFT')),
        identical_serialized_pawn_fields=len(prior),identical_owned_native_item_payloads=len(items),save_checks=saves,
        performance=dict(baseline=before,current=after,percent_tics_per_second_change=(after['tics_per_second']/before['tics_per_second']-1)*100,
            reverse_order_repeat=dict(baseline=repeat_before,current=repeat_after,percent_tics_per_second_change=(repeat_after['tics_per_second']/repeat_before['tics_per_second']-1)*100),
            identical_scene_rows=len(scene),inventory_projection_200_calls_ms={label:[float(v) for v in re.findall(r'CA118 TIMING inventory-200 ms=([\d.]+)',log(label))] for label in RUNS if 'performance' not in label},
            limits='Simulation throughput and overlay intervals are not GPU frame time or device-to-photon latency. Sparse single-tic profiles and sub-millisecond projection loops cannot isolate full-scene causes. Desktop/GPU/driver load is uncontrolled. No optimization or speedup claim; #117 regression remains evidence for #120.'),
        environment='Windows 11 / GZDoom 4.14.2 Vulkan / Ryzen 9 5950X / RTX 3070 Ti; actual renderer 1520x825, seed 116, skill 2, audio enabled at 5% master. Each accepted run is isolated.',
        screenshots=images,diagnostics=diagnostic_files,archive_normalization='UTF-8/LF, trailing whitespace removed; incidental local key-scan rows omitted with counts and original-source hashes. Raw logs remain in build/.',
        reproduction=['Build baseline da7d33b8 separately as build/issue118/baseline.pk3; retain original saves/packages.',
            'Run extract_inventory.py only to reproduce the move; src/ZSCRIPT includes the service and two diagnostic labels track 5.0.2. Build current package as build/issue118/current.pk3.',
            'Run prepare_checks.py; run_native.ps1 -Package baseline.pk3/current.pk3 -Addon checks.pk3 -Map MAP03 -Script baseline.cfg/current.cfg with unique labels.',
            'Use transactions.cfg for all nine recipe kinds and actual merchant buy/sell, ownership.cfg for foreign-reference rejection.',
            'Keep the original package basename when loading an old save: current-runtime/baseline.pk3 contains current bytes. Run reload.cfg, then reload-only.cfg for original/current/upgraded copies.',
            'run_suite.ps1 serializes checks/performance and records per-run arguments/settings/hashes. Use ui-enu.cfg/ui-es.cfg and matching Language for native projection captures.',
            'Preserve original package/save together for rollback; run verify_extraction.py, summarize.py, build_document_index.py and validate_project.py. Engine/IWAD/PK3/saves remain untracked.'],
        limitations=['Fixtures prepare synthetic inventory/reservations; the broader transaction fixture uses actual stations, plans, recipes and commit calls but completes work programmatically. Real physical keypress play remains author acceptance.',
            'UI fixture normalizes its artificial pending-task total and selects through existing inventory events before capture. No UI strings/layout change.',
            'Existing internal commit helpers require their established coordinator preconditions. Tutorial loans/native copy-toss lifecycle and later session/planning extractions are documented boundaries.',
            'No newer-save downgrade or historical map conversion claim. Tests are isolated single-player, not multiplayer acceptance.'],
        author_acceptance='Passed: author confirmed CA-502-INVENTORY-01 and all #118 tests on 2026-10-06; PR #124 merge and issue closure authorized. Measured performance regressions remain unresolved.')
    (HERE/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['identical_inventory_value_rows','identical_crafting_category_rows','identical_serialized_pawn_fields','identical_owned_native_item_payloads']},indent=2))
    print('MAP06 throughput change: %.3f%%'%report['performance']['percent_tics_per_second_change'])

if __name__=='__main__':main()
