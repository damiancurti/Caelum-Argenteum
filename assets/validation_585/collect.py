"""Collect final native discovery, migration and exact package evidence."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue415'
EVIDENCE=ROOT/'assets/validation_585'


def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()


def main():
    package=WORK/'current/caelum_argenteum_dev.pk3'
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive:
        names=[n for n in archive.namelist() if not n.endswith('/')]
        if set(names)!=set(expected) or len(names)!=len(expected):raise RuntimeError('Package membership differs')
        for name,path in expected.items():
            if archive.read(name)!=path.read_bytes():raise RuntimeError(f'Package bytes differ: {name}')
    selected=['final-core-01','final-load-01','final-hub-01','final-legacy-load-01','final-migrated-load-01','legacy-save-01','legacy-rollback-01']
    rows=[]
    for label in selected:
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig',errors='replace')
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        if label.startswith('final-') and record['package_sha256'].lower()!=digest(package):raise RuntimeError('Wrong tested package')
        if 'CA415 RESULT' not in log or re.search(r'CA415 FAIL|Script error|VM execution aborted|failed=[1-9]',log):raise RuntimeError('Unsuccessful native check')
        rows.append({'label':label,'passes':len(re.findall(r'^CA415 PASS ',log,re.M)),
                     'package_sha256':record['package_sha256'].lower()})
    native=EVIDENCE/'native';native.mkdir(exist_ok=True)
    for path in WORK.iterdir():
        if path.suffix=='.txt' or path.name.endswith('-run.json'):shutil.copyfile(path,native/path.name)
    shutil.copyfile(WORK/'static-validation.json',EVIDENCE/'static-validation.json')
    core=(WORK/'final-core-01.txt').read_text(encoding='utf-8-sig',errors='replace')
    report={'issue':415,'scope':'Production event discovery; unloaded siege simulation still pending',
        'runs':rows,'native_passes':sum(r['passes'] for r in rows),'source_entries_verified':len(expected),
        'package_sha256':digest(package),'original_save_sha256':digest(WORK/'ca415-original.zds'),
        'maximum_2048_record_sort_ms':float(re.search(r'queue sort ms=([0-9.]+)',core)[1]),
        'performance_limit':'Single native sorting sample; not frame presentation, percentile tails or FPS acceptance.',
        'author_acceptance':json.loads((ROOT/'assets/validation_585/acceptance.json').read_text(encoding='utf-8'))['result']}
    (EVIDENCE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
