"""Finalize successful validation evidence and stage the focused issue857 patch."""
from pathlib import Path
import ast,hashlib,json,shutil,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';dest=root/'assets/validation_v5_17_107';evidence=dest/'evidence'
report=json.loads((root/'build/issue857-validation-final.json').read_text(encoding='utf-8-sig'));assert report['version']=='5.17.107' and not report['errors']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()=='887ae8d4ad02bd037acbbf12237108d9f1f941b8'
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue857-equipment-wardrobe'
shutil.copyfile(root/'build/issue857-validation-final.json',evidence/'validation-final.json')
summary=json.loads((evidence/'SUMMARY.json').read_text());summary['full_validation_pending']=False;summary['full_validation_passed']=True
(evidence/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
note='Full project validation passes with no errors; the generated document index is current.\n\n'
for name in ('HISTORY.md','PROJECT.md','TASKS.md'):
    path=root/'docs'/name;source=path.read_text(encoding='utf-8');start=source.index('## 5.17.107 -');end=source.index('\n## ',start+1)
    section=source[start:end]
    if note not in section:
        at=section.index('\n\n')+2;section=section[:at]+note+section[at:];path.write_text(source[:start]+section+source[end:],encoding='utf-8',newline='\n')
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
for path in dest.glob('*.py'):ast.parse(path.read_text(encoding='utf-8'))
hashes={p.relative_to(dest).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(dest.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(dest/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
paths=['.gitattributes','AGENTS.md','README.md','pending_test.txt','src/CVARINFO','src/MODELDEF','src/caelum/character/CaelumDomingoPilot.zs','src/caelum/character/CaelumWardrobePilot.zs','src/caelum/equipment/CaelumInventoryService.zs','src/caelum/data/CaelumWornClothingModelData.zs','src/caelum/data/wardrobe_candidate.modeldef','src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']
paths+=['docs/'+n for n in ('ASSETS.md','CONTEXT.md','DOCUMENT_INDEX.md','HISTORY.md','KNOWN_PITFALLS.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md')]
subprocess.run(['git','add','--',*paths],cwd=root,check=True)
files=[p.relative_to(root).as_posix() for p in dest.rglob('*') if p.is_file()]
allowed={'.py','.zs','.json','.txt','.log','.ini','.cfg','.csv','.png','.modeldef','.html'}
assert all(Path(n).suffix.lower() in allowed or Path(n).name in ('MAPINFO','MODELDEF','CVARINFO','ZSCRIPT') for n in files)
for i in range(0,len(files),60):subprocess.run(['git','add','-f','--',*files[i:i+60]],cwd=root,check=True)
subprocess.run(['git','diff','--cached','--check'],cwd=root,check=True)
staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).splitlines();byte_paths=[n for n in staged if n.startswith(('assets/validation_v5_17_107/','src/'))]
for name in byte_paths:assert subprocess.check_output(['git','cat-file','--filters','--path='+name,':'+name],cwd=root)==(root/name).read_bytes(),name
for name,expected in hashes.items():assert hashlib.sha256((dest/name).read_bytes()).hexdigest()==expected,name
assert not subprocess.check_output(['git','diff','--cached','--name-only','--diff-filter=D'],cwd=root).strip()
previous_queue=subprocess.check_output(['git','show','HEAD:pending_test.txt'],cwd=root).decode('utf-8').replace('\r\n','\n')
current_queue=(root/'pending_test.txt').read_text(encoding='utf-8');assert current_queue.startswith(previous_queue) and current_queue.count('CA857-EQUIPMENT-01')==1
for name in ('ASSETS.md','HISTORY.md','PROJECT.md','SYSTEMS.md','TASKS.md'):
    previous=subprocess.check_output(['git','show','HEAD:docs/'+name],cwd=root).decode('utf-8').replace('\r\n','\n');current=(root/'docs'/name).read_text(encoding='utf-8');old_body=previous[previous.index('\n## '):]
    next_section=current.index('\n## ',current.index('## 5.17.107 -')+1);assert current[next_section:]==old_body,'Historical section changed: '+name
audit=dict(staged_files=len(staged),filtered_byte_checks=len(byte_paths),evidence_hash_checks=len(hashes),no_removals=True,prior_author_queue_preserved=True,new_author_check="CA857-EQUIPMENT-01",prior_thematic_sections_exact=True)
(root/'build/issue857-stage-audit.json').write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8');print(json.dumps(audit))
