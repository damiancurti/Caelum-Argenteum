"""Stage verified #838 files and independently check evidence checkout bytes."""
from pathlib import Path
import hashlib,json,shutil,subprocess
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';evidence=root/'assets/validation_v5_17_97/evidence'
validation=root/'build/issue838-validation-final.json'
report=json.loads(validation.read_text(encoding='utf-8-sig'));assert not report['errors'],report['errors'];assert report['version']=='5.17.97'
shutil.copyfile(validation,evidence/'validation-final.json')
s=json.loads((evidence/'SUMMARY.json').read_text(encoding='utf-8'));s['project_validation_passed']=True
s['files']['validation-final.json']=hashlib.sha256((evidence/'validation-final.json').read_bytes()).hexdigest()
(evidence/'SUMMARY.json').write_text(json.dumps(s,indent=2)+'\n',encoding='utf-8',newline='\n')
paths=['.gitattributes','AGENTS.md','README.md','src/caelum/actors/CaelumVisualPerception.zs','src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']
paths+=['docs/'+n for n in ['ASSETS.md','CONTEXT.md','DOCUMENT_INDEX.md','HISTORY.md','KNOWN_PITFALLS.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md']]
paths+=[p.relative_to(root).as_posix() for p in (root/'assets/validation_v5_17_97').iterdir() if p.is_file() and p.suffix in ('.py','.zs','.json')]
subprocess.run(['git','add','--',*paths],cwd=root,check=True)
files=[p.relative_to(root).as_posix() for p in evidence.rglob('*') if p.is_file()]
assert not any(Path(n).suffix.lower() in ('.pk3','.wad','.exe','.dll','.zds') for n in files)
for i in range(0,len(files),70):subprocess.run(['git','add','-f','--',*files[i:i+70]],cwd=root,check=True)
subprocess.run(['git','diff','--cached','--check'],cwd=root,check=True)
staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).splitlines()
byte_paths=[n for n in staged if n.startswith(('assets/validation_v5_17_97/','src/'))]
for name in byte_paths:assert subprocess.check_output(['git','cat-file','--filters','--path='+name,':'+name],cwd=root)==(root/name).read_bytes(),name
for name,expected in s['files'].items():assert hashlib.sha256((evidence/name).read_bytes()).hexdigest()==expected,name
assert not subprocess.check_output(['git','diff','--cached','--name-only','--diff-filter=D'],cwd=root).strip()
assert not subprocess.check_output(['git','diff','--name-only','HEAD','--','pending_test.txt'],cwd=root).strip()
for name in ('ASSETS.md','HISTORY.md','PROJECT.md','TASKS.md'):
    previous=subprocess.check_output(['git','show','HEAD:docs/'+name],cwd=root).decode('utf-8').replace('\r\n','\n')
    current=(root/'docs'/name).read_text(encoding='utf-8')
    old_body=previous[previous.index('\n## '):]
    next_section=current.index('\n## ',current.index('## 5.17.97 -')+1)
    assert current[next_section:]==old_body,'Historical section content changed: '+name
result={'staged_files':len(staged),'filtered_byte_checks':len(byte_paths),'evidence_hash_checks':len(s['files']),'no_removals':True,'author_queue_unchanged':True,'prior_thematic_sections_exact':True}
(root/'build/issue838-stage-audit.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result))
