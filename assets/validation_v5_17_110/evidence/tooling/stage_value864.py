"""Finalize and stage only the validated #864 patch, preserving history."""
from pathlib import Path
import ast, hashlib, json, re, shutil, subprocess, sys

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');dest=root/'assets/validation_v5_17_110';evidence=dest/'evidence'
report=json.loads((root/'build/issue864-validation-final.json').read_text(encoding='utf-8-sig'))
assert report['version']=='5.17.110' and not report['errors']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()=='e9bd0915dde87dd9d451371dfbfa7aa119f63de1'
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue864-contact-settlement'
shutil.copyfile(root/'build/issue864-validation-final.json',evidence/'validation-final.json')
shutil.copyfile(Path(__file__),evidence/'tooling/stage_value864.py')
p=evidence/'SUMMARY.json';summary=json.loads(p.read_text());assert not summary['direct_visual_review_pending']
summary['full_validation_pending']=False;summary['full_validation_passed']=True
p.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
note='Full project validation passes with no errors; the generated document index is current.\n\n'
for name in ('HISTORY.md','PROJECT.md','TASKS.md'):
    p=root/'docs'/name;s=p.read_text(encoding='utf-8');a=s.index('## 5.17.110 -');b=s.index('\n## ',a+1);section=s[a:b]
    section=section.replace('each is1280x720','each is 1280x720')
    if note not in section:
        i=section.index('\n\n')+2;section=section[:i]+note+section[i:]
    p.write_text(s[:a]+section+s[b:],encoding='utf-8',newline='\n')
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
runtime=['src/caelum/survival/CaelumContaminationState.zs','src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']
public=[p.relative_to(root).as_posix() for p in dest.glob('*.py')]
for name in public:ast.parse((root/name).read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
source_hashes={n:sha(root/n) for n in sorted(runtime+public)}
(dest/'SOURCE_SHA256.json').write_text(json.dumps(source_hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
evidence_hashes={p.relative_to(evidence).as_posix():sha(p) for p in sorted(evidence.rglob('*')) if p.is_file() and p.name!='SHA256.json'}
(evidence/'SHA256.json').write_text(json.dumps(evidence_hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
hashes={p.relative_to(dest).as_posix():sha(p) for p in sorted(dest.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json' and '__pycache__' not in p.parts}
(dest/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
paths=['.gitattributes','AGENTS.md','README.md']+runtime+['docs/'+n for n in ('ASSETS.md','CONTEXT.md','DOCUMENT_INDEX.md','HISTORY.md','KNOWN_PITFALLS.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md')]
subprocess.run(['git','add','--',*paths],cwd=root,check=True)
files=[p.relative_to(root).as_posix() for p in dest.rglob('*') if p.is_file() and '__pycache__' not in p.parts]
assert not any(Path(n).suffix.lower() in {'.pk3','.wad','.zds','.exe','.dll','.pyc'} for n in files)
for i in range(0,len(files),60):subprocess.run(['git','add','-f','--',*files[i:i+60]],cwd=root,check=True)
check=subprocess.run(['git','diff','--cached','--check'],cwd=root,capture_output=True)
(root/'build/issue864-stage-whitespace.txt').write_bytes(check.stdout+check.stderr)
assert check.returncode==0,'Read build/issue864-stage-whitespace.txt'
staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).splitlines()
byte_paths=[n for n in staged if n.startswith(('assets/validation_v5_17_110/','src/'))]
for name in byte_paths:assert subprocess.check_output(['git','cat-file','--filters','--path='+name,':'+name],cwd=root)==(root/name).read_bytes(),name
for name,expected in hashes.items():assert sha(dest/name)==expected,name
assert not subprocess.check_output(['git','diff','--cached','--name-only','--diff-filter=D'],cwd=root).strip()
old_queue=subprocess.check_output(['git','show','HEAD:pending_test.txt'],cwd=root).decode('utf-8').replace('\r\n','\n')
assert (root/'pending_test.txt').read_text(encoding='utf-8')==old_queue
for name in ('ASSETS.md','HISTORY.md','PROJECT.md','SYSTEMS.md','TASKS.md','KNOWN_PITFALLS.md'):
    previous=subprocess.check_output(['git','show','HEAD:docs/'+name],cwd=root).decode('utf-8').replace('\r\n','\n');current=(root/'docs'/name).read_text(encoding='utf-8')
    old_body=previous[previous.index('\n## '):];next_section=current.index('\n## ',current.index('\n## ')+1)
    assert current[next_section:]==old_body,'Historical section changed: '+name
gallery=dest/'review.html';links=re.findall(r'(?:src|href)="([^"]+)"',gallery.read_text(encoding='utf-8'))
assert all((gallery.parent/n).is_file() for n in links)
words=len((root/'docs/CONTEXT.md').read_text(encoding='utf-8').split());assert words<2500
audit=dict(staged_files=len(staged),filtered_byte_checks=len(byte_paths),artifact_hash_checks=len(hashes),source_hash_checks=len(source_hashes),gallery_links=len(links),context_words=words,no_removals=True,author_queue_exact=True,prior_thematic_sections_exact=True,new_lesson='CA-KP-266')
(root/'build/issue864-stage-audit.json').write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8')
print(json.dumps(audit))
