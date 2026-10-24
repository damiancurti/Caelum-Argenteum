"""Keep the lot model's evidence separate from the accepted core package."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue410'

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    package=WORK/'lots/caelum_argenteum_dev.pk3'
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive:
        assert set(archive.namelist())==set(expected),'Package membership differs'
        for name,path in expected.items():
            assert archive.read(name)==path.read_bytes(),f'Package differs: {name}'
    report={'issue':410,'version':'5.8.3','scope':'Saved lot metadata model, not yet connected to food inventories or environmental clock',
        'package':{'sha256':digest(package),'entries':len(expected),'source_bytes_match':True},'runs':{}}
    native=HERE/'native';native.mkdir(exist_ok=True)
    for record_path in sorted(WORK.glob('lots-*-run.json')):
        label=record_path.name.removesuffix('-run.json')
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
        report['runs'][label]={'pass_lines':len(re.findall(r'^CA410 PASS ',log,re.M)),
            'fail_lines':len(re.findall(r'^CA410 FAIL ',log,re.M)),
            'runtime_errors':re.findall(r'^.*(?:Script error|VM execution aborted|Fatal:|This savegame needs|Not in a saveable game).*$',log,re.M),
            'record':json.loads(record_path.read_text(encoding='utf-8-sig'))}
        for path in WORK.glob(label+'*'):
            if path.suffix in ('.txt','.json','.ini','.cfg'):shutil.copy2(path,native/path.name)
    report['private_save_sha256']=digest(WORK/'ca410-lots.zds')
    (HERE/'lots-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'package':report['package'],'checks':{k:(v['pass_lines'],v['fail_lines']) for k,v in report['runs'].items()}},indent=2))

if __name__=='__main__':main()
