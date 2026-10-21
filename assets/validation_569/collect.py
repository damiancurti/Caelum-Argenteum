"""Collect final #380 native evidence, keeping diagnostic failures separate."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue380'

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def redact(value):
    if isinstance(value,list):return [redact(v) for v in value]
    if isinstance(value,dict):return {k:redact(v) for k,v in value.items()}
    if not isinstance(value,str):return value
    value=value.replace(str(ROOT),'<repo>').replace(ROOT.as_posix(),'<repo>')
    value=value.replace(r'C:\Program Files (x86)\GZDoom\gzdoom.exe','<engine>')
    value=re.sub(r'C:\\Program Files \(x86\)\\Steam[^"\r\n]*DOOM2\.WAD','<iwad>',value,flags=re.I)
    return re.sub(r'C:\\Users\\[^\\\s]+','<user>',value,flags=re.I)

def clean(text):return '\n'.join(line.rstrip() for line in redact(text).splitlines()).rstrip()+'\n'

def main():
    (HERE/'native').mkdir(exist_ok=True)
    labels=['suite-final-01','save-final-01','reload-final-01','travel-final-01',
        'baseline-upgrade-final-01','upgraded-reload-final-01','clothing-upgrade-final-01',
        'baseline-arrow-save-01','baseline-rollback-final-01','resume-final-01',
        'completed-reload-final-01','legacy-resume-final-01','fire-final-02','ranged-final-01','world-final-02']
    runs=[]
    for label in labels:
        path=WORK/(label+'.txt');log=path.read_text(encoding='utf-8',errors='replace')
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0 and not record.get('timed_out'),label
        assert not re.search(r'CA(?:380|386|376|194|192|313) FAIL|Script error|VM execution aborted|failures=[1-9]',log),label
        runtime=WORK/record['runtime']/'caelum_argenteum_dev.pk3'
        assert sha(runtime)==record['package_sha256'].lower(),label
        addon='legacy-checks.pk3' if record['runtime']=='baseline' else 'checks.pk3'
        if label in ['resume-final-01','completed-reload-final-01','legacy-resume-final-01']:addon='resume-checks.pk3'
        if label=='fire-final-02':addon='ballistics-qa.pk3'
        if label=='ranged-final-01':addon='ballistics-ranged.pk3'
        assert sha(WORK/addon)==record['addon_sha256'].lower(),label
        (HERE/'native'/(label+'.txt')).write_text(clean(log),encoding='utf-8',newline='\n')
        runs.append({'label':label,'record':redact(record),'passes':len(re.findall(r'CA(?:380|386|376|194|192|313) PASS ',log)),
            'raw_log_sha256':sha(path),'fixture':addon})
    package=WORK/'current/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as archive:
        names=archive.namelist()
        for name in names:
            assert archive.read(name).replace(b'\r\n',b'\n')==(ROOT/'src'/name).read_bytes().replace(b'\r\n',b'\n'),name
        assert set(names)=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    export=ROOT/'assets/art_source/cartridge_kits/exports.json'
    before=sha(export);data=json.loads(export.read_text(encoding='utf-8'))
    outputs={row['output']:sha(ROOT/row['output']) for row in data['exports']}
    subprocess.run([str(ROOT/'build/issue387-tools/Scripts/python.exe'),str(ROOT/'assets/generators/generate_cartridge_kit_sprites.py')],check=True)
    assert before==sha(export) and outputs=={p:sha(ROOT/p) for p in outputs}
    for row in data['exports']:assert sha(ROOT/row['source'])==row['source_sha256'] and sha(ROOT/row['output'])==row['output_sha256']
    validation=json.loads(subprocess.check_output(['python','validate_project.py'],cwd=ROOT,text=True,encoding='utf-8'))
    assert not validation['errors']
    (HERE/'project-validation.json').write_text(json.dumps(validation,indent=2)+'\n',encoding='utf-8')
    shutil.copy2(WORK/'kits-world.png',HERE/'kits-world.png')
    diagnostics=[]
    for label in ['smoke-01','smoke-02','suite-01','fire-final-01']:
        path=WORK/(label+'.txt');record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        (HERE/'native'/('diagnostic-'+label+'.txt')).write_text(clean(path.read_text(encoding='utf-8',errors='replace')),encoding='utf-8')
        diagnostics.append({'label':label,'record':redact(record),'raw_log_sha256':sha(path),'counts_as_passing':False})
    report={'issue':380,'version':'5.6.9','base_commit':'5fbeaac7','package_sha256':sha(package),'source_member_count':len(names),
        'runs':runs,'native_runs':len(runs),'passes':sum(r['passes'] for r in runs),'failures':0,'diagnostics':diagnostics,
        'art_exports':data,'screenshot_sha256':sha(HERE/'kits-world.png'),
        'saves':{p.name:sha(p) for p in WORK.glob('ca380-*.zds')},
        'author_acceptance':'CA380-01 passed on 2026-10-21: live cartridge assembly and kit sprites',
        'limitations':['Shop availability and stock renewal are #383/#385.','Not a frame-presentation or large-map performance benchmark.']}
    (HERE/'report.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['native_runs','passes','failures','package_sha256']}))

if __name__=='__main__':main()
