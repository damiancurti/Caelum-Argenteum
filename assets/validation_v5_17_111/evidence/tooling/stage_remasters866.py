"""Stage only the validated #866 candidate with exact-source/evidence audits."""
from pathlib import Path
import ast
import hashlib
from html.parser import HTMLParser
import json
import re
import shutil
import subprocess
import sys

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
dest=root/'assets/validation_v5_17_111';source=root/'assets/source/art/environment_remasters_866';ev=dest/'evidence'
report=json.loads((root/'build/issue866-validation-final.json').read_text(encoding='utf-8-sig'))
assert report['version']=='5.17.111' and not report['errors']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()=='75321a2ba64bc56ed032ef73d81fcda43ff1387f'
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue866-environment-remasters'
shutil.copyfile(root/'build/issue866-validation-final.json',ev/'validation-final.json')
shutil.copyfile(Path(__file__),ev/'tooling/stage_remasters866.py')
p=ev/'SUMMARY.json';summary=json.loads(p.read_text());summary['full_validation_pending']=False;summary['full_validation_passed']=True
p.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
note='Full project validation passes with no errors; the generated document index is current.\n\n'
for name in ('HISTORY.md','PROJECT.md','TASKS.md'):
    p=root/'docs'/name;s=p.read_text(encoding='utf-8');a=s.index('## 5.17.111 -');b=s.index('\n## ',a+1);section=s[a:b]
    section=section.replace('\n All 42','\nAll 42')
    if note not in section:
        i=section.index('\n\n')+2;section=section[:i]+note+section[i:]
    p.write_text(s[:a]+section+s[b:],encoding='utf-8',newline='\n')
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
runtime=['src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']
public=[p.relative_to(root).as_posix() for p in dest.glob('*.py')]+['assets/generators/build_environment_remaster_review.py']
for name in public:ast.parse((root/name).read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for row in json.loads((source/'PROVENANCE.json').read_text())['files']:
    assert sha(source/row['file'])==row['sha256'],row['file']
(dest/'SOURCE_SHA256.json').write_text(json.dumps({n:sha(root/n) for n in sorted(runtime+public)},indent=2)+'\n',encoding='utf-8',newline='\n')
evidence_hashes={p.relative_to(ev).as_posix():sha(p) for p in sorted(ev.rglob('*')) if p.is_file() and p.name!='SHA256.json'}
(ev/'SHA256.json').write_text(json.dumps(evidence_hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
hashes={p.relative_to(dest).as_posix():sha(p) for p in sorted(dest.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json' and '__pycache__' not in p.parts}
(dest/'SHA256SUMS.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
class Links(HTMLParser):
    def __init__(self):super().__init__();self.links=[]
    def handle_starttag(self,tag,attrs):
        self.links.extend(v for k,v in attrs if k in ('src','href') and v and not v.startswith('#'))
gallery=source/'review.html';parser=Links();parser.feed(gallery.read_text(encoding='utf-8'))
assert all((gallery.parent/link).is_file() for link in parser.links)
paths=['.gitattributes','AGENTS.md','README.md','pending_test.txt']+runtime+['docs/'+n for n in ('ASSETS.md','CONTEXT.md','DOCUMENT_INDEX.md','HISTORY.md','KNOWN_PITFALLS.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md')]
subprocess.run(['git','add','--',*paths],cwd=root,check=True)
files=[p.relative_to(root).as_posix() for base in (dest,source) for p in base.rglob('*') if p.is_file() and '__pycache__' not in p.parts]+['assets/generators/build_environment_remaster_review.py']
assert not any(Path(n).suffix.lower() in {'.pk3','.wad','.zds','.exe','.dll','.pyc','.zip'} for n in files)
for i in range(0,len(files),60):subprocess.run(['git','add','-f','--',*files[i:i+60]],cwd=root,check=True)
check=subprocess.run(['git','diff','--cached','--check'],cwd=root,capture_output=True)
(root/'build/issue866-stage-whitespace.txt').write_bytes(check.stdout+check.stderr)
assert check.returncode==0,'Read build/issue866-stage-whitespace.txt'
staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).splitlines()
assert set(staged)<=set(paths+files)
assert not subprocess.check_output(['git','diff','--cached','--name-only','--diff-filter=D'],cwd=root).strip()
byte_paths=[n for n in staged if n.startswith(('assets/validation_v5_17_111/','assets/source/art/environment_remasters_866/','src/'))]
for name in byte_paths:assert subprocess.check_output(['git','cat-file','--filters','--path='+name,':'+name],cwd=root)==(root/name).read_bytes(),name
for name,expected in hashes.items():assert sha(dest/name)==expected,name
old_queue=subprocess.check_output(['git','show','HEAD:pending_test.txt'],cwd=root).decode('utf-8').replace('\r\n','\n')
new_queue=(root/'pending_test.txt').read_text(encoding='utf-8');assert new_queue.startswith(old_queue)
extra=new_queue[len(old_queue):];assert extra.count('CA866-MATERIAL-01')==1 and len(extra.splitlines())==5
for name in ('ASSETS.md','HISTORY.md','PROJECT.md','SYSTEMS.md','TASKS.md','KNOWN_PITFALLS.md'):
    old=subprocess.check_output(['git','show','HEAD:docs/'+name],cwd=root).decode('utf-8').replace('\r\n','\n');now=(root/'docs'/name).read_text(encoding='utf-8')
    assert now[now.index('\n## ',now.index('\n## ')+1):]==old[old.index('\n## '):],name
words=len((root/'docs/CONTEXT.md').read_text(encoding='utf-8').split());assert words<2500
audit=dict(staged_files=len(staged),filtered_byte_checks=len(byte_paths),artifact_hash_checks=len(hashes),source_provenance_checks=27,gallery_links=len(parser.links),context_words=words,no_removals=True,prior_author_queue_preserved=True,one_new_author_test='CA866-MATERIAL-01',prior_thematic_sections_exact=True,new_lesson='CA-KP-267')
(root/'build/issue866-stage-audit.json').write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(audit))
