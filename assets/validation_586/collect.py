"""Collect native property evidence and verify final package bytes and reuse scope."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue411'
EVIDENCE=ROOT/'assets/validation_586'


def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()


def main():
    package=WORK/'current/caelum_argenteum_dev.pk3'
    previous=WORK/'current/pre-comment-fix.pk3'
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive,zipfile.ZipFile(previous) as before:
        names=archive.namelist()
        if set(names)!=set(expected) or len(names)!=len(expected):raise RuntimeError('Package membership differs')
        changed=[]
        for name,path in expected.items():
            blob=archive.read(name)
            if blob!=path.read_bytes():raise RuntimeError(f'Package bytes differ: {name}')
            if blob!=before.read(name):
                changed.append(name)
                # The final cleanup repairs UTF-8 accents only in comment lines.
                without_comments=lambda b:b'\n'.join(line for line in b.splitlines() if not line.strip().startswith(b'//'))
                if without_comments(blob)!=without_comments(before.read(name)):
                    raise RuntimeError(f'Reused evidence has a non-comment difference: {name}')
        if changed!=['caelum/world/CaelumPortDefender.zs']:raise RuntimeError('Unexpected cleanup scope')
    selected=['final-core-01','final-load-01','final-hub-01','final-house69-01',
        'final-house70-01','final-access-01','final-routes-01','final-legacy-load-01',
        'final-legacy-hub-01','final-legacy-return-01','final-cross-01','final-preview-es-01',
        'legacy-save-04','legacy-rollback-02','final-core-02','final-author-01']
    rows=[]
    for label in selected:
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig',errors='replace')
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        if record.get('exit_code')!=0 or record.get('timed_out'):raise RuntimeError(f'Failed engine: {label}')
        if 'CA411 RESULT' not in log or re.search(r'CA411 FAIL|Script error|VM execution aborted|failures=[1-9]',log):raise RuntimeError(f'Failed assertions: {label}')
        required=package if label in ['final-core-02','final-author-01'] else previous
        if label.startswith('final-') and record['package_sha256'].lower()!=digest(required):raise RuntimeError(f'Wrong runtime: {label}')
        rows.append({'label':label,'passes':len(re.findall(r'^CA411 PASS ',log,re.M)),
                     'package_sha256':record['package_sha256'].lower()})
    native=EVIDENCE/'native';native.mkdir(exist_ok=True)
    for record in WORK.glob('*-run.json'):
        shutil.copyfile(record,native/record.name)
        log=WORK/(record.name.removesuffix('-run.json')+'.txt')
        if log.exists():shutil.copyfile(log,native/log.name)
    shutil.copyfile(WORK/'static-validation.json',EVIDENCE/'static-validation.json')
    shutil.copyfile(WORK/'property-preview.png',EVIDENCE/'property-preview-es.png')
    shutil.copyfile(WORK/'property-author.png',EVIDENCE/'property-author.png')
    timing=(WORK/'final-routes-01.txt').read_text(encoding='utf-8-sig')
    report={'issue':411,'scope':'Central house purchase/rental and relocation; camps/placement remain pending',
        'runs':rows,'native_passes':sum(r['passes'] for r in rows),'source_entries_verified':len(expected),
        'package_sha256':digest(package),'original_save_sha256':digest(WORK/'ca411-original.zds'),
        'evidence_reuse':{'prior_package_sha256':digest(previous),'changed_members':changed,
            'verification':'All non-comment lines identical; final native core and author fixture repeated after UTF-8 comment cleanup'},
        'one_time_256_chest_migration_ms':float(re.search(r'migration ms=([0-9.]+)',timing)[1]),
        'performance_limit':'Single migration sample, not frame presentation, percentile tails or FPS acceptance.',
        'author_acceptance':json.loads((EVIDENCE/'acceptance.json').read_text(encoding='utf-8'))['result']}
    (EVIDENCE/'report.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
