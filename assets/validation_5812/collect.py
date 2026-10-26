"""Collect focused native evidence without modifying runtime or prior runs."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
here=Path(__file__).resolve().parent;root=here.parents[1];work=root/'build/issue502-hygiene'
selected=['final-core-b','final-forecast','final-capture-b','save-a','final-load','final-hub','old-save-a','final-legacy','old-load-a']
records=[]
for label in selected:
 text=(work/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 assert not re.search(r'CA502H FAIL|Script error|VM execution aborted|failures=[1-9]',text),label
 record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 records.append({'label':label,'passes':len(re.findall(r'^CA502H PASS',text,re.M)),'package_sha256':record['package_sha256']})
package=work/'final01/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as archive,zipfile.ZipFile(work/'baseline/caelum_argenteum_dev.pk3') as old:
 for name in archive.namelist():assert archive.read(name)==(root/'src'/name).read_bytes(),name
 maps=[n for n in archive.namelist() if n.startswith('maps/')]
 for name in maps:assert archive.read(name)==old.read(name),name
 members=len(archive.namelist())
(here/'native').mkdir(exist_ok=True)
for pattern in ('*.txt','*-run.json'):
 for source in work.glob(pattern):shutil.copyfile(source,here/'native'/source.name)
(here/'captures').mkdir(exist_ok=True)
for name in ('toilet-hint-b.png','toilet-progress-b.png'):shutil.copyfile(work/name,here/'captures'/name)
report={'issue':502,'version':'5.8.12','passes':sum(r['passes'] for r in records),'selected_runs':records,'package_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),'source_members':members,'unchanged_maps':len(maps),'author_test':'CA502-TOILET-01 pending','failed_probes':['core-a/b: binary residue after105 world tics deferred completion; hygiene-only epsilon clamp fixes it.','forecast-a/b/c: fixture retained thermal exposure; existing unsupported-effect guard correctly rejected exact prediction. Adapter tests isolate thermal exposure without changing production guards.','final-capture first attempt: screenshot before camera/target interpolation settled; retained raw evidence, subsequent15-tic view captured actual progress.'],'reused_evidence':'save-a prepares a partial session with probe02; final01 loads and completes that saved session and verifies hub cancellation. Original final07 bathroom runtime creates/rolls back its own pre-feature save.','limitations':'Native isolated functional checks; no campaign-wide or frame-presentation performance claim. No new global actor scan. Soap bathing/gear cleaning/NPC routines are not implemented by this patch.'}
(here/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ('passes','source_members','unchanged_maps','package_sha256')},indent=2))
