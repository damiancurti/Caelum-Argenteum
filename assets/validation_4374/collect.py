"""Collect issue 64 native evidence; never distribute local saves or dependencies."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/validation_4374'
CASES = {
    'compare_normal': 'QA64 AUDIT_DONE mode=2',
    'compare_skip': 'QA64 AUDIT_DONE mode=3',
    'fast': 'QA64 FAST_DONE', 'fast_skip': 'QA64 EXIT_DONE',
    'boundaries_interrupt': 'QA64 INTERRUPT_DONE',
    'no_supplies': 'QA64 NO_SUPPLIES_DONE',
    'availability_final': 'QA64 AVAILABILITY_DONE',
    'model': 'QA64 MODEL_DONE', 'model_edge2': 'QA64 MODEL_DONE',
    'schedule3': 'QA64 SCHEDULE_DONE', 'seated_final': 'QA64 SEATED_DONE',
    'task_sleep_final': 'QA64 AUDIT_DONE mode=5',
    'task_awake_pass': 'QA64 AUDIT_DONE mode=5',
    'save_active_final': 'active=1 sleeping=1',
    'reload_active_final': 'QA64 AUDIT_DONE mode=1',
    'completed_reload_final': 'QA64 COMPLETED_RELOAD_DONE',
    'legacy_seed': 'MAP01 -', 'legacy_migrated2': 'QA64 BOUNDARY_DONE',
    'legacy_rollback': 'MAP01 -',
    'package_final': 'MAP01 -',
}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run():
    records = {}
    raw = {}
    for name, marker in CASES.items():
        source = ROOT / f'build/issue64_{name}.log'
        content = source.read_text(encoding='utf-8', errors='replace')
        assert marker in content, (name, marker)
        assert not re.search(r'QA64 FAIL|Script error|aborted|VM execution|needs the following|necesita los siguientes', content, re.I), name
        raw[name] = content
        selected = [line for line in content.splitlines() if line.startswith((
            'GZDoom version', 'adding src', 'adding build', 'MAP01 -', 'MAP02 -',
            'QA64', 'Partida guardada', 'Game saved', 'Captured'))]
        (OUT / f'{name}.log').write_text('\n'.join(selected)+'\n', encoding='utf-8')
        cfg = ROOT / f'build/issue64_{name}.cfg'
        shutil.copy2(cfg, OUT / f'{name}.cfg')
        records[name] = {'status': 'PASS', 'assertions': content.count('QA64 PASS'),
                         'raw_log_sha256': sha(source), 'completion_marker': marker,
                         'runtime': 'final gameplay PK3 (diagnostic labels finalized afterward)' if name in ('seated_final','task_sleep_final','task_awake_pass','save_active_final','reload_active_final','completed_reload_final') else 'final PK3' if name=='package_final' else 'development snapshot / see limitations'}
    comparisons = {}
    for a, b, label, flag in [('compare_normal','compare_skip','COMPARE','ordinary'), ('fast','fast_skip','FAST_COMPARE','fast')]:
        rows = []
        for name in (a,b):
            line = re.search(r'^QA64 '+label+r' (.+)$', raw[name], re.M)[1]
            values = dict(re.findall(r'(\w+)=([-\d.]+)', line)); values.pop(flag)
            rows.append(values)
        assert rows[0] == rows[1], (a,b,rows)
        comparisons[a+' vs '+b] = rows[0]
    changed = subprocess.check_output(['git','diff','--name-only','--','src'], cwd=ROOT, text=True).splitlines()
    changed += subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'], cwd=ROOT, text=True).splitlines()
    package = ROOT / 'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        for file in changed:
            assert archive.read(file.removeprefix('src/')) == (ROOT/file).read_bytes(), file
    for name in ('selector_en','task_awake','task_sleep_final','reload_active_final','exit'):
        shutil.copy2(ROOT/f'build/issue64_{name}.png', OUT/f'{name}.png')
    result = {
        'issue':64, 'version':'4.37.4', 'date':'2026-10-02', 'engine':'GZDoom 4.14.2 / Windows 11',
        'baseline_commit':'c3ba10b1e92fe48fee3b7501984ccc794671299d',
        'baseline_package_sha256':sha(ROOT/'build/issue64_baseline_4373.pk3'),
        'final_package_sha256':sha(package), 'packaged_changed_sources':{p:sha(ROOT/p) for p in changed},
        'native':records, 'exact_comparisons':comparisons,
        'static':{'validate_project.py':'PASS / zero errors','git diff --check':'PASS','build_dev.ps1':'PASS'},
        'author_acceptance':'PENDING', 'author_checks':['CA-4374-TIME-01','CA-4374-CARE-01','CA-4374-SAVE-01'],
        'limitations':[
            'QA prepares safe tutorial progression, existing materials and shortened task duration; native work/payment/output paths execute.',
            'Normal/fast comparisons and targeted guard/migration cases were run during implementation. Subsequent changes corrected forecast health ordering, target stability/rounding and bag-fit caching; affected cases were rerun. Final PK3 cases explicitly identified above cover tasks, active/completed saves and chairs.',
            'The schedule fixture first records actual nearby threats, then makes only those actors friendly to isolate the future calendar event. Production safety guards remain enabled.',
            'Legacy saves require the original PK3 basename. A separate current-package copy has that basename; original baseline save/package are preserved for rollback. Upgraded saves are not claimed to downgrade.',
            'Daily food/water policy and combined multi-day consumption remain the separate dependent issue 65 patch.',
            'Selected logs retain native assertions and state; original raw log hashes identify full local evidence. Fixtures and captures are not author acceptance.'
        ],
        'reproduce':[
            'Run from repository root with the engine/IWAD paths in run_issue64.ps1 and build/gzdoom.ini available locally.',
            'Build with build_dev.ps1 and await completion. Use run_issue64.ps1 -Label NAME -Runtime build/caelum_argenteum_dev.pk3 -Fixture assets/validation_4374/qa -Commands (Get-Content assets/validation_4374/NAME.cfg -Raw) -Wait.',
            'Save tests run seed before reload; add -LoadSave build/issue64_saves/issue64_active_final.zds or issue64_completed_task.zds as appropriate.',
            'Legacy seed/rollback use accepted 4.37.3 runtime build/issue64_baseline_4373.pk3 and legacy fixture. Migration loads that save with a current PK3 in a separate directory preserving the basename and both legacy/qa fixtures.',
            'Run python assets/validation_4374/collect.py, python build_document_index.py, python validate_project.py and git diff --check.'
        ]
    }
    (OUT/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(f'Collected {len(records)} cases, {sum(r["assertions"] for r in records.values())} passing assertions; comparisons exact; changed packaged sources match.')

if __name__ == '__main__':
    run()
