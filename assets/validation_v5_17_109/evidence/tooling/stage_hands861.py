"""Stage only the final #861 patch after required validation."""
from pathlib import Path
import ast,hashlib,json,re,shutil,subprocess,sys
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');dest=root/'assets/validation_v5_17_109';evidence=dest/'evidence'
report=json.loads((root/'build/issue861-validation-final.json').read_text(encoding='utf-8-sig'));assert report['version']=='5.17.109' and not report['errors']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()=='ba5f9e8b249bf36bc685e6ed07bd97a73b01a5bc'
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue861-clothing-hand-selection'
shutil.copyfile(root/'build/issue861-validation-final.json',evidence/'validation-final.json')
shutil.copyfile(Path(__file__),evidence/'tooling/stage_hands861.py')
p=evidence/'SUMMARY.json';summary=json.loads(p.read_text());summary['full_validation_pending']=False;summary['full_validation_passed']=True
summary['validation_note']='The initial full validator found only a strict CONTEXT.md word-limit failure at 2500 words. A just-started retry was stopped while the summary was compressed to 2490 words. The following retry was interrupted before producing its report. Validation resumed on 2026-11-21 with no surviving validator process and the same corrected source; the initial failure report is retained. No runtime or native fixture changed.'
p.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
note='Full project validation passes with no errors; the generated document index is current.\n\n'
for name in ('HISTORY.md','PROJECT.md','TASKS.md'):
 p=root/'docs'/name;s=p.read_text(encoding='utf-8');a=s.index('## 5.17.109 -');b=s.index('\n## ',a+1);section=s[a:b]
 if note not in section:
  i=section.index('\n\n')+2;section=section[:i]+note+section[i:]
 p.write_text(s[:a]+section+s[b:],encoding='utf-8',newline='\n')
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
runtime=['src/caelum/'+n for n in ('character/CaelumAppearanceHands.zs','equipment/CaelumInventoryService.zs','player/CaelumPlayer.zs','world/CaelumPhysicalHazards.zs','world/CaelumSewerMaze.zs')]
public=[p.relative_to(root).as_posix() for p in dest.iterdir() if p.suffix in ('.py','.zs')]
for name in public:
 if name.endswith('.py'):ast.parse((root/name).read_text(encoding='utf-8'))
source_hashes={n:hashlib.sha256((root/n).read_bytes()).hexdigest() for n in sorted(runtime+public)}
(dest/'SOURCE_SHA256.json').write_text(json.dumps(source_hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
hashes={p.relative_to(evidence).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(evidence.rglob('*')) if p.is_file() and p.name!='SHA256.json'}
(evidence/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
hashes={p.relative_to(dest).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(dest.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json' and '__pycache__' not in p.parts}
(dest/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
paths=['.gitattributes','AGENTS.md','README.md','pending_test.txt']+runtime+['docs/'+n for n in ('ASSETS.md','CONTEXT.md','DOCUMENT_INDEX.md','HISTORY.md','KNOWN_PITFALLS.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md')]
subprocess.run(['git','add','--',*paths],cwd=root,check=True)
files=[p.relative_to(root).as_posix() for p in dest.rglob('*') if p.is_file() and '__pycache__' not in p.parts]
allowed={'.py','.zs','.json','.txt','.log','.ini','.cfg','.csv','.png','.modeldef','.html'}
assert all(Path(n).suffix.lower() in allowed or Path(n).name in ('MAPINFO','MODELDEF','CVARINFO','ZSCRIPT') for n in files)
for i in range(0,len(files),60):subprocess.run(['git','add','-f','--',*files[i:i+60]],cwd=root,check=True)
whitespace=subprocess.run(['git','diff','--cached','--check'],cwd=root,capture_output=True)
(root/'build/issue861-stage-whitespace.txt').write_bytes(whitespace.stdout+whitespace.stderr)
assert whitespace.returncode==0,'Read build/issue861-stage-whitespace.txt for full diagnostics.'
staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).splitlines();byte_paths=[n for n in staged if n.startswith(('assets/validation_v5_17_109/','src/'))]
for name in byte_paths:assert subprocess.check_output(['git','cat-file','--filters','--path='+name,':'+name],cwd=root)==(root/name).read_bytes(),name
for name,expected in hashes.items():assert hashlib.sha256((dest/name).read_bytes()).hexdigest()==expected,name
assert not subprocess.check_output(['git','diff','--cached','--name-only','--diff-filter=D'],cwd=root).strip()
previous_queue=subprocess.check_output(['git','show','HEAD:pending_test.txt'],cwd=root).decode('utf-8').replace('\r\n','\n');current_queue=(root/'pending_test.txt').read_text(encoding='utf-8')
assert current_queue.startswith(previous_queue) and current_queue.count('CA861-HANDS-01')==1
for name in ('ASSETS.md','HISTORY.md','PROJECT.md','SYSTEMS.md','TASKS.md','KNOWN_PITFALLS.md'):
 previous=subprocess.check_output(['git','show','HEAD:docs/'+name],cwd=root).decode('utf-8').replace('\r\n','\n');current=(root/'docs'/name).read_text(encoding='utf-8');old_body=previous[previous.index('\n## '):]
 next_section=current.index('\n## ',current.index('\n## ')+1);assert current[next_section:]==old_body,'Historical section changed: '+name
gallery=dest/'review.html';links=re.findall(r'(?:src|href)="([^"]+)"',gallery.read_text(encoding='utf-8'));assert all((gallery.parent/n).is_file() for n in links)
assert len((root/'docs/CONTEXT.md').read_text(encoding='utf-8').split())<2500
audit=dict(staged_files=len(staged),filtered_byte_checks=len(byte_paths),evidence_hash_checks=len(hashes),source_hash_checks=len(source_hashes),gallery_links=len(links),no_removals=True,prior_author_queue_preserved=True,new_author_check='CA861-HANDS-01',prior_thematic_sections_exact=True,new_lesson='CA-KP-265')
(root/'build/issue861-stage-audit.json').write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8');print(json.dumps(audit))
