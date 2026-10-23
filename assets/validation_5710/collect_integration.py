"""Record focused checks after merging the completed #409 dependency."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
OUT=HERE/'integration'
OUT.mkdir(parents=True,exist_ok=True)
package=ROOT/'build/issue409/current/caelum_argenteum_dev.pk3'
with package.open('rb') as stream:sha=hashlib.file_digest(stream,'sha256').hexdigest()
sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(sources)
    for name,path in sources.items():assert archive.read(name)==path.read_bytes(),name
runs=[]
for directory,label,prefix in [('issue409','integrated-glass01','CA409'),('issue471-ammo','integrated-station01','CA380')]:
    source=ROOT/'build'/directory
    metadata=json.loads((source/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log=(source/f'{label}.txt').read_text(encoding='utf-8',errors='replace')
    assert metadata['exit_code']==0 and metadata['package_sha256'].lower()==sha
    assert prefix+' FAIL' not in log and prefix+' RESULT' in log
    for suffix in ('.txt','-run.json'):shutil.copyfile(source/(label+suffix),OUT/(label+suffix))
    runs.append({'issue':409 if prefix=='CA409' else 471,'label':label,
                 'passed':len(re.findall('^'+prefix+' PASS ',log,re.M))})
report={'version':'5.7.10','scope':'#471 dependency integration of completed #409 base',
        'package_sha256':sha,'source_entries':len(sources),'source_bytes_match':True,
        'runs':runs,'native_assertions_passed':sum(r['passed'] for r in runs),
        'author_471_acceptance':'2026-10-23; CA471-AMMO-01, without qualifications',
        'author_409_acceptance':False}
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f"Integrated package: {report['native_assertions_passed']} assertions, source bytes match.")
