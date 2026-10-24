"""Retain #410 evidence; packages, saves and engine dependencies stay private."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue410'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    package=WORK/'current/caelum_argenteum_dev.pk3'
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive:
        assert set(archive.namelist())==set(expected),'Package membership differs'
        for name,path in expected.items():
            assert archive.read(name)==path.read_bytes(),f'Package differs: {name}'
    report={'issue':410,'version':'5.8.3','scope':'Character illness foundation; food lots/cooking/furniture not integrated',
            'package':{'sha256':digest(package),'entries':len(expected),'source_bytes_match':True},'runs':{}}
    native=HERE/'native';native.mkdir(exist_ok=True)
    for record_path in sorted(WORK.glob('*-run.json')):
        label=record_path.name.removesuffix('-run.json')
        if label.startswith('author-'):continue
        log_path=WORK/(label+'.txt')
        if not log_path.exists():continue
        log=log_path.read_text(encoding='utf-8',errors='replace')
        report['runs'][label]={'pass_lines':len(re.findall(r'^CA410 PASS ',log,re.M)),
            'fail_lines':len(re.findall(r'^CA410 FAIL ',log,re.M)),
            'runtime_errors':re.findall(r'^.*(?:Script error|VM execution aborted|Fatal:|Not in a saveable game).*$',log,re.M),
            'record':json.loads(record_path.read_text(encoding='utf-8-sig'))}
        for path in WORK.glob(label+'*'):
            if path.suffix in ('.txt','.json','.ini','.cfg'):shutil.copy2(path,native/path.name)
    capture=WORK/'food-contamination-hud.png'
    shutil.copy2(capture,HERE/capture.name)
    report['capture_sha256']=digest(capture)
    report['private_saves']={p.name:digest(p) for p in WORK.glob('ca410-*.zds')}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'package':report['package'],'checks':{k:(v['pass_lines'],v['fail_lines']) for k,v in report['runs'].items()}},indent=2))

if __name__=='__main__':main()
