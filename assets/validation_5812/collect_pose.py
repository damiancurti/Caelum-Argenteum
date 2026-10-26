"""Retain isolated posture evidence separately from the original toilet checks."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
here=Path(__file__).resolve().parent;root=here.parents[1];work=root/'build/issue502-hygiene'
out=here/'postures';(out/'native').mkdir(parents=True,exist_ok=True);(out/'captures').mkdir(exist_ok=True)
selected=['pose-v3-pose-core','pose-v3-core','pose-v3-forecast','pose-v3-live','pose-v3-pose-save','pose-v3-pose-load','pose-v3-pose-hub','pose-pre-save','pose-v3-pose-legacy','pose-pre-rollback','pose-v3-pose-capture']
records=[]
for label in selected:
    log=(work/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    assert not re.search(r'CA502H FAIL|Script error|VM execution aborted|failures=[1-9]',log),label
    meta=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    records.append({'label':label,'passes':len(re.findall(r'^CA502H PASS',log,re.M)),'package_sha256':meta['package_sha256']})
package=work/'pose-final03/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as archive,zipfile.ZipFile(work/'final01/caelum_argenteum_dev.pk3') as old:
    for name in archive.namelist():assert archive.read(name)==(root/'src'/name).read_bytes(),name
    maps=[n for n in archive.namelist() if n.startswith('maps/')]
    art=[n for n in archive.namelist() if n.startswith(('models/','sprites/','graphics/'))]
    for name in maps+art:assert archive.read(name)==old.read(name),name
    members=len(archive.namelist())
for pattern in ('pose-*.txt','pose-*-run.json'):
    for source in work.glob(pattern):shutil.copyfile(source,out/'native'/source.name)
for name in ('pose-toilet.png','pose-tub.png'):shutil.copyfile(work/name,out/'captures'/name)
report={'issue':502,'version':'5.8.12','passes':sum(r['passes'] for r in records),'selected_runs':records,
 'package_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),'source_members':members,'unchanged_maps':len(maps),'unchanged_art_members':len(art),
 'author_test':'CA502-POSE-01 accepted2026-10-25 without qualifications; CA502-TOILET-01 and CA502-TREATMENT-01 retained',
 'failed_probes':['pose-core-a used a NOBLOCKMAP obstruction; b/c used a solid blockmap chair and still reproduced accepted overlap. Explicit local overlap checks fix the latter in d and final-core.',
 'pose-capture-a: inherited chair offset/facing placed the seated sprite beside the toilet. Centered registration and the fixture-facing direction fix the final capture.'],
 'limitations':'Isolated native functional/visual checks; no multiplayer network or frame-presentation benchmark. Bathtub posture alone does not implement soap bathing. Existing accepted rest furniture is not changed.'}
(out/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ('passes','source_members','unchanged_maps','unchanged_art_members','package_sha256')}))
