"""Verify the complete move, explicit ownership guards and package boundary."""
import hashlib
import json
import re
import subprocess
import zipfile
from extract_inventory import ROOT, BASE, PLAYER, SERVICE, EXTERNAL, GUARDS, baseline, arguments, declarations, selected

HERE=__import__('pathlib').Path(__file__).resolve().parent

def tokens(text):
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]',
        re.sub(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|//[^\n]*|/\*[\s\S]*?\*/',lambda m:m.group(1) or '',text))

def body(source,method): return source[method['body_start']:method['body_end']+1]

old=baseline(); new=(ROOT/PLAYER).read_text(encoding='utf-8')
before,after=(next(c for c in declarations(s) if c['name']=='CaelumPlayer') for s in (old,new))
assert [f['declaration'] for f in before['fields']]==[f['declaration'] for f in after['fields']]
assert [m['signature'] for m in before['methods']]==[m['signature'] for m in after['methods']]
moved={m['name'] for m in selected(old,before)}
service=(ROOT/SERVICE).read_text(encoding='utf-8'); decl=declarations(service)[0]
assert not decl['fields']
methods={m['name']:m for m in decl['methods']}
assert set(methods)==moved|{entry[3] for entry in EXTERNAL}
for previous,current in zip(before['methods'],after['methods']):
    name=previous['name']; left=body(old,previous); right=body(new,current)
    if name not in moved:
        assert left==right,name
        continue
    params,args=arguments(previous['signature'])
    call='CaelumInventoryService.'+name+'(self'+(', '+', '.join(args) if args else '')+');'
    if not previous['signature'].startswith('void '):call='return '+call
    assert tokens(right)==tokens('{'+call+'}'),name
    restored=body(service,methods[name])
    if name in GUARDS:
        assert restored.count(GUARDS[name])==1,name
        restored=restored.replace(GUARDS[name],'',1)
    restored=re.sub(r'\b(?:user|CaelumPlayer)\.', '',restored)
    restored=restored.replace('Actor.Spawn(','Spawn(')
    restored=re.sub(r'\buser\b','self',restored)
    assert tokens(left)==tokens(restored),name
for path in sorted({entry[0] for entry in EXTERNAL}):
    original=subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT).decode()
    current=(ROOT/path).read_text(encoding='utf-8'); reconstructed=current
    for entry in [e for e in EXTERNAL if e[0]==path]:
        _,cls,name,replacement=entry
        before_cls=next(c for c in declarations(original) if c['name']==cls)
        after_cls=next(c for c in declarations(current) if c['name']==cls)
        m=next(m for m in before_cls['methods'] if m['name']==name)
        n=next(m for m in after_cls['methods'] if m['name']==name)
        assert m['signature']==n['signature']
        _,args=arguments(m['signature'])
        assert tokens(body(current,n))==tokens('{return CaelumInventoryService.'+replacement+'('+', '.join(args)+');}')
        restored=body(service,methods[replacement]).replace('FindOwnedTarotDeck(user)','Owned(user)').replace('CaelumTarotDeckRules.REVISION','REVISION')
        assert tokens(body(original,m))==tokens(restored),replacement
        reconstructed=reconstructed.replace(body(current,n),body(original,m),1)
    assert reconstructed==original,path
with zipfile.ZipFile(ROOT/'build/issue118/baseline.pk3') as base,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as final:
    added=sorted(set(final.namelist())-set(base.namelist()))
    removed=sorted(set(base.namelist())-set(final.namelist()))
    changed=sorted(n for n in base.namelist() if n in final.namelist() and base.read(n)!=final.read(n))
    newline_only=[n for n in changed if base.read(n).replace(b'\r\n',b'\n')==final.read(n).replace(b'\r\n',b'\n')]
    semantic=[n for n in changed if n not in newline_only]
    assert not removed
    assert added==[SERVICE[4:]]
    expected={'ZSCRIPT',PLAYER[4:]}|{e[0][4:] for e in EXTERNAL}|{'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
    assert set(semantic)==expected,semantic
    for n in ['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']:
        assert base.read(n).decode().replace('5.0.1','5.0.2').replace('\r\n','\n')==final.read(n).decode().replace('\r\n','\n')
report=dict(result='PASS',baseline=BASE,unchanged_fields=len(before['fields']),unchanged_signatures=len(before['methods']),
    unchanged_other_bodies=len(before['methods'])-len(moved),moved_methods=sorted(moved),moved_external_methods=EXTERNAL,
    explicit_ownership_guards=GUARDS,stateless_service=True,player_lines_removed=len(old.splitlines())-len(new.splitlines()),
    added=added,removed=removed,semantic_changes=semantic,newline_only=newline_only,
    package_sha256=hashlib.sha256((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()).hexdigest())
(HERE/'EXTRACTION.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f"PASS: {len(moved)} pawn + {len(EXTERNAL)} physical-item operations; declarations and other bodies unchanged")
