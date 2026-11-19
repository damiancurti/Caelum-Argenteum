"""Bounded historical-heading and runtime preservation audit for #831."""
from pathlib import Path
import hashlib,json,re,subprocess,shutil
R=Path(__file__).resolve().parents[2]
def git(*args):return subprocess.check_output(['git',*args],cwd=R)
prep=json.loads((R/'assets/validation_v5_17_94/evidence/preparation.json').read_text())
base=prep['base_commit'];reference=prep['historical_reference'];rows=[]
for name in ['docs/ASSETS.md','docs/TASKS.md','docs/PROJECT.md','docs/HISTORY.md']:
 before=git('show',reference+':'+name).decode('utf-8');now=(R/name).read_text(encoding='utf-8')
 def headings(text):
  result={}
  for line in text.splitlines():
   match=re.match(r'## (\d+\.\d+\.\d+[a-z]?) - (.*)',line)
   if match:result.setdefault(match[2],[]).append((match[1],line))
  return result
 earlier=headings(before);current=headings(now)
 for title,values in earlier.items():
  assert title in current,(name,title,'Retained heading missing')
  assert values==current[title],(name,title,values,current[title])
  rows.append({'file':name,'headings':len(values),'title':title,'original':values,'restored':current[title]})
expected={'src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs'}
snapshot=R/'assets/validation_v5_17_94/evidence/runtime-before.json';runtime_before=json.loads(snapshot.read_text(encoding='utf-8'))
runtime_after={p.relative_to(R).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((R/'src').rglob('*')) if p.is_file()}
assert set(runtime_before)==set(runtime_after)
assert {n for n in runtime_before if runtime_before[n]!=runtime_after[n]}==expected
changed=set(git('diff','--name-only',base,'--','src').decode().splitlines())
assert changed==expected,changed
runtime=[]
for name in sorted(expected):
 prior=git('show',base+':'+name);now=(R/name).read_bytes()
 assert prior.count(b'5.17.93')==1
 assert prior.replace(b'5.17.93',b'5.17.94').replace(b'\r\n',b'\n')==now.replace(b'\r\n',b'\n')
 runtime.append({'file':name,'before_sha256':hashlib.sha256(prior).hexdigest(),'after_sha256':hashlib.sha256(now).hexdigest(),'only_diagnostic_release_changed':True})
assert not git('diff',base,'--','pending_test.txt','assets/source','src/models').strip()
assert not git('ls-files','--others','--exclude-standard','--','src').strip()
assert not git('diff','--name-only','--diff-filter=D',base).strip()
out=R/'assets/validation_v5_17_94/evidence';out.mkdir(parents=True,exist_ok=True)
report={**prep,'audited_heading_entries':sum(r['headings'] for r in rows),'heading_audit':rows,'runtime_diagnostic_audit':runtime,
 'runtime_files_hashed_before_and_after':len(runtime_before),'runtime_snapshot_sha256':hashlib.sha256(snapshot.read_bytes()).hexdigest(),
 'other_tracked_runtime_bytes_unchanged':True,'author_queue_unchanged':True,'source_art_unchanged':True,'no_removed_files':True,
 'qualification':'Documentation and diagnostic labels only. Earlier engine and author evidence is retained; no new native or manual acceptance claimed.'}
(out/'historical-audit.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'historical_heading_entries':report['audited_heading_entries'],'restored_headings':len(prep['restored_headings']),'runtime_only_diagnostic_labels':True}))
