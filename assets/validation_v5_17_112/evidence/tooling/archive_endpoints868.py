"""Retain endpoint diagnosis and publish portable reconstruction tools, without binaries."""
from pathlib import Path
import hashlib,json,shutil
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
LOCAL=Path(__file__).parent
public=ROOT/'assets/validation_v5_17_112';public.mkdir(exist_ok=False)
evidence=public/'evidence';evidence.mkdir()
def copy(source,target):
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
def native(source,target):
    for name in ['checks.zs','reference.zs','session.ini','commands.cfg','engine.log','process.log','RESULTS.json']:
        p=source/name
        if p.is_file():copy(p,target/name)
for label in ['baseline02','fresh02','upgrade03','reload02','rollback02']:
    native(ROOT/f'build/issue868-{label}',evidence/'native'/label)
for label in ['checks01','checks02','baseline01','upgrade01','upgrade02','seed01','seed-upgrade01','seed-control01','seed-control02','seed-control03','seed-upgrade02','seed-interpreter01']:
    native(ROOT/f'build/issue868-{label}',evidence/'attempts'/label)
for label in ['exterior01','exterior02']:
    source=ROOT/f'build/issue868-{label}';target=evidence/'prototypes'/label
    for name in ['manifest.json','original-exterior.zs','candidate-exterior.zs']:copy(source/name,target/name)
    copy(source/'source/caelum/survival/CaelumContaminationCombat.zs',target/'source/CaelumContaminationCombat.zs')
profile=ROOT/'build/issue868-deep01';summary=json.loads((ROOT/'build/issue868-deep01-summary.json').read_text())
for name in ['manifest.json']:
    copy(profile/name,evidence/'profile'/name)
for p in (profile/'source').rglob('*'):
    if p.is_file():copy(p,evidence/'profile/source'/p.relative_to(profile/'source'))
for suffix in ['analysis','summary']:
    copy(ROOT/f'build/issue868-deep01-{suffix}.json',evidence/'profile'/f'{suffix}.json')
native_dir=ROOT/summary['directory']
for name in ['results.json','presentation.json','peer0/engine.log','peer0/session.ini','peer0/start.cfg','peer0/presents.csv']:
    copy(native_dir/name,evidence/'profile/native'/name)
copy(ROOT/'build/issue868-suite.json',evidence/'native-suite.json')
for name in ['prepare_endpoints868.py','endpoint_checks868.zs','run_endpoints868.py','run_endpoint_suite868.py','run_contact_profile868.py','archive_endpoints868.py']:
    copy(LOCAL/name,evidence/'tooling'/name)
copy(LOCAL/'endpoint_checks868.zs',public/'checks.zs')
runner=(LOCAL/'run_endpoints868.py').read_text(encoding='utf-8')
runner=runner.replace("ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","ROOT=Path(__file__).resolve().parents[2]")
runner=runner.replace("with_name('endpoint_checks868.zs')","with_name('checks.zs')")
runner=runner.replace("p.add_argument('--runtime',type=Path,default=ROOT/'build/issue866-review01.pk3')","p.add_argument('--runtime',type=Path,required=True)")
runner=runner.replace("p.add_argument('--reference-runtime',type=Path,default=ROOT/'build/issue866-review01.pk3')","p.add_argument('--reference-runtime',type=Path,required=True)")
(public/'run_endpoints.py').write_text(runner,encoding='utf-8',newline='\n')
prepare=(LOCAL/'prepare_endpoints868.py').read_text(encoding='utf-8')
prepare=prepare.replace("ROOT = Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","ROOT = Path(__file__).resolve().parents[2]")
prepare=prepare.replace("p.add_argument('--npc-first', action='store_true')","p.add_argument('--runtime', type=Path, required=True)")
prepare=prepare.replace("runtime = ROOT/'build/issue866-review01.pk3'","runtime = a.runtime.resolve(strict=True)")
start=prepare.index('elif a.npc_first:');end=prepare.index('else:\n    new = old.replace',start)
prepare=prepare[:start]+prepare[end:]
prepare=prepare.replace('npc_first=a.npc_first,','')
(public/'prepare_endpoints.py').write_text(prepare,encoding='utf-8',newline='\n')
scene=(ROOT/'assets/validation_v5_17_110/run_scene.py').read_text(encoding='utf-8').replace('issue864-','issue868-')
guard="assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower(), 'Another native engine is running'\n"
scene=scene.replace('a=p.parse_args();',guard+'a=p.parse_args();',1)
(public/'run_scene.py').write_text(scene,encoding='utf-8',newline='\n')
failure=dict(native_crash_observation=dict(tool='Windows CUA accessibility',title='GZDoom Very Fatal Error',code='C0000005',operation='read',address='0x40000000',instruction_address='0x7ff7e764e555',run='upgrade02',external_report_sent=False),
    chained_assertion='CaelumContaminationContacts.Get(SavedPair.First).Pairs[0]==SavedPair && CaelumContaminationContacts.Get(SavedPair.Second).Pairs[0]==SavedPair',
    interpreter='The old expression also aborts with a null-address VM error under vm_jit=false and vm_jit_aot=false (seed-interpreter01); not demonstrated as JIT-only.',
    correction='Store both method results in local references, validate each non-null record and nonempty list, then compare pair identities. Full and minimal reload/reversal pass. No production method changed; the underlying engine/compiler cause was not isolated beyond the failing diagnostic expression.',
    other_failures=['seed-control02 diagnostic Name/String ternary did not compile; corrected to Name literal.', 'reload01 and rollback01 were refused by the single-engine guard before process launch; their empty local output directories remain.', 'upgrade01 was timed out by the original runner whose JSON error list was empty; passed=false and exit1 remain authoritative. The revised runner records timeout explicitly.'])
(evidence/'failures.json').write_text(json.dumps(failure,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(public=str(public),final_checks=sum(r['checks'] for r in json.loads((evidence/'native-suite.json').read_text())))))
