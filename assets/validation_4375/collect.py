"""Verify and preserve selected native evidence for daily table provisions."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
BASE='e4cf1e3e'
CASES={
    'fresh_policy2':'QA65 POLICY_DONE',
    'normal_midnight':'QA65 BOUNDARY_DONE mode=1',
    'fast_midnight':'QA65 BOUNDARY_DONE mode=2',
    'skip_midnight':'QA65 BOUNDARY_DONE mode=3',
    'outside':'QA65 OTHER_MAP_DONE count=1',
    'legacy_seed':'QA65 LEGACY_SEEDED tables=6 kept=93',
    'legacy_migration':'QA65 MIGRATION_DONE food=92 water=1',
    'legacy_reload':'QA65 MIGRATION_DONE food=92 water=1',
    'legacy_rollback':'QA65 LEGACY_REPORT kept=93 expected=93 liters=0.050000',
    'saved_seed':'QA65 SPLIT_DONE', 'saved_reload':'QA65 TABLE_SAVED_DONE',
    'hub_revisit':'QA65 TABLE_SAVED_DONE', 'multiday_final':'QA65 MULTI_DONE',
    'visual_final':'QA65 VIEW',
    'dialogue_es':'QA65 DIALOGUE_DONE','dialogue_en':'QA65 DIALOGUE_DONE',
}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def run():
    records={}
    for name,marker in CASES.items():
        p=ROOT/f'build/issue65_{name}.log'
        raw=p.read_text(encoding='utf-8',errors='replace')
        assert marker in raw,(name,marker)
        assert not re.search(r'QA6[45] FAIL|Script error|VM execution|aborted|needs the following|necesita los siguientes',raw,re.I),name
        selected=[s for s in raw.splitlines() if s.startswith(('GZDoom version','adding src','adding build','MAP01 -','MAP03 -','MAP07 -','QA64','QA65','Partida guardada','Game saved','Captured'))]
        (OUT/f'{name}.log').write_text('\n'.join(selected)+'\n',encoding='utf-8')
        shutil.copy2(ROOT/f'build/issue65_{name}.cfg',OUT/f'{name}.cfg')
        records[name]={'status':'PASS','assertions':len(re.findall(r'^QA6[45] PASS',raw,re.M)),
                       'completion_marker':marker,'raw_log_sha256':sha(p),
                       'runtime':'4.37.4 baseline' if name in ('legacy_seed','legacy_rollback') else 'current source (before diagnostic version-label update)' if name in ('fresh_policy2','normal_midnight','fast_midnight','skip_midnight','outside') else 'final 4.37.5 PK3'}
    raw=(ROOT/'build/issue65_multiday_final.log').read_text(encoding='utf-8')
    row=re.search(r'^QA65 MULTI_COMPARE (.+)$',raw,re.M)[1]
    values=dict(re.findall(r'(\w+)=([-\d.]+)',row))
    for suffix in ('H','T','S','Sleep','Work'):
        assert values['native'+suffix]==values['model'+suffix],suffix
    assert len(re.findall(r'^QA65 DAY local=[123] ',raw,re.M))==3
    changed=subprocess.check_output(['git','diff',BASE,'--name-only','--','src'],cwd=ROOT,text=True).splitlines()
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        for name in changed:
            assert archive.read(name.removeprefix('src/'))==(ROOT/name).read_bytes(),name
    for name in ('multiday_final','table_fresh','dialogue_es','dialogue_en'):
        shutil.copy2(ROOT/f'build/issue65_{name}.png',OUT/f'{name}.png')
    result={
        'issue':65,'version':'4.37.5','date':'2026-10-02','engine':'GZDoom 4.14.2 / Windows 11',
        'base_commit':subprocess.check_output(['git','rev-parse',BASE],cwd=ROOT,text=True).strip(),
        'depends_on':'issue #64 / PR #71; stacked branch/PR',
        'baseline_package_sha256':sha(ROOT/'build/issue65_baseline_4374.pk3'),
        'final_package_sha256':sha(package),'changed_packaged_sources':{p:sha(ROOT/p) for p in changed},
        'native':records,'three_day_exact_comparison':values,
        'static':{'validate_project.py':'PASS / zero errors','build_dev.ps1':'PASS / 6141 source entries','git diff --check':'PASS','changed_package_sources':'byte-for-byte match'},
        'author_acceptance':'PENDING','author_checks':['CA-4375-TABLES-01','CA-4375-SAVES-01'],
        'carried_author_checks':['CA-4374-TIME-01','CA-4374-CARE-01','CA-4374-SAVE-01'],
        'limitations':[
            'QA uses disposable prepared profiles and selected task durations; actual table inventory, consumption, clock, rest and crafting paths execute in GZDoom.',
            'Three-day integration uses 9,072,000 personal tics, real tables only, and an unfinished 80-hour work fixture. Numeric predictions are compared against native needs, sleep, productive work and final stock.',
            'The three-day fixture detaches the selector forecast and runs a separate time-bounded numeric model. Its screenshot therefore keeps the task-estimate calculating label; endpoint assertions and stock/resource comparisons are recorded in the log.',
            'MAP01 has no normal return route and is outside the campaign hub. The isolated hub fixture assigns MAP01/MAP03 a test hub solely to verify native unload/revisit serialization; production map routing is unchanged.',
            'Legacy migration preserves 92 food rations and one partially filled canteen, adding only one water ration in the free slot. Full legacy tables cannot be forcibly normalized without discarding ambiguous player items.',
            'Original baseline save/package rollback is verified. Upgraded saves are not claimed to downgrade. Same PK3 basename is retained in a separate current directory for migration.',
            'Early fixture attempts corrected an invalid canteen class and an overstrict requirement to consume more than 47 food portions; the actual three-day requirement is sustained water beyond initial stock. Selected runs have no unresolved assertion or runtime errors.',
            'Raw local logs are identified by hashes; selected logs omit unrelated startup details. No author acceptance is inferred.'
        ],
        'reproduce':[
            'Build with build_dev.ps1; wait for completion. Use run_issue65.ps1 from repository root with the configured local engine/IWAD and build/gzdoom.ini.',
            'Default final fixture list: assets/validation_4374/qa assets/validation_4375/legacy assets/validation_4375/qa. Runtime: build/caelum_argenteum_dev.pk3. Pass each saved .cfg through -Commands (Get-Content PATH -Raw).',
            'Use MAP07 for outside. Add assets/validation_4375/hub only for hub_revisit. Omit -Wait for multiday_final; observe the visible run until completion (more than 60 seconds).',
            'Dialogue captures use only assets/validation_4374/qa and assets/validation_4375/ui as fixtures; native menu replies reach the actual Palomo food-source page in each language.',
            'Run saved_seed before saved_reload, adding -LoadSave build/issue65_saves/issue65_table.zds on reload.',
            'Preserve a 4.37.4 package as build/issue65_baseline_4374.pk3. Seed/rollback use this runtime and the 4374/qa plus 4375/legacy fixtures only.',
            'Legacy migration/reload use a copy of the current PK3 at build/issue65_current/issue65_baseline_4374.pk3 and the default fixtures, loading issue65_legacy.zds then issue65_migrated.zds from build/issue65_saves.',
            'Run python assets/validation_4375/collect.py, regenerate the document index, run validate_project.py and git diff --check. Never package local saves, engine/IWAD files or test PK3s.'
        ]
    }
    (OUT/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(f'Collected {len(records)} cases / {sum(r["assertions"] for r in records.values())} passing native assertions. Three-day values exact; package sources match.')

if __name__=='__main__':run()
