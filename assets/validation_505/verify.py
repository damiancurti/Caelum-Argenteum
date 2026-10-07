"""Verify the ordinary instrumented build retains every original method body.

This is a token-level transformation check, complemented by native compilation
and matched scene observations. Synthetic interventions are deliberately exempt.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import zipfile
from runtime_identity import tree_hash

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue121'
spec=importlib.util.spec_from_file_location('audit',ROOT/'assets/validation_500/audit_sources.py')
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)

def tokens(text):
    pattern=r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\''
    text=re.sub(pattern,lambda m:'' if m.group().startswith(('//','/*')) else m.group(),text)
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]',text)

def undo_probes(text):
    text=text.replace('CA121NativeTick();','Super.Tick();')
    text=re.sub(r'CA121Profiler\.LOS\((\w+(?:\.\w+)*),(\w+)\)',r'\1.CheckSight(\2)',text)
    text=text.replace('CA121Profiler.Candidate(Defenders.Size());','').replace('CA121Profiler.Candidate();','')
    text=re.sub(r'\{ CA121Profiler cp; if\(level.time%37==0\)\{cp=CA121Profiler.Get\(\);cp.Begin\(25\);\} (body\.A_Chase\([^;]*\);) if\(cp!=null\)cp.End\(25\); \}',r'\1',text)
    return text

def main():
    with zipfile.ZipFile(WORK/'baseline.pk3') as z:base={n:z.read(n) for n in z.namelist()}
    with zipfile.ZipFile(WORK/'instrumented.pk3') as z:instrument={n:z.read(n) for n in z.namelist()}
    selected={(r['class'],r['method']) for r in json.loads((HERE/'categories.json').read_text())['methods']}
    methods=fields=0
    for name,raw in base.items():
        if not name.lower().endswith('.zs'):continue
        original=raw.decode('utf-8-sig');modified=instrument[name].decode('utf-8-sig')
        classes={c['name']:c for c in audit.declarations(modified)}
        for cls in audit.declarations(original):
            other=classes[cls['name']]
            assert [f['declaration'] for f in cls['fields']]==[f['declaration'] for f in other['fields']],(name,cls['name'],'fields')
            fields+=len(cls['fields'])
            by_name={m['name']:m for m in other['methods']}
            for method in cls['methods']:
                key=(cls['name'],method['name'])
                match=by_name[('CA121Body_' if key in selected else '')+method['name']]
                before=original[method['body_start']:method['body_end']+1]
                after=modified[match['body_start']:match['body_end']+1]
                assert tokens(before)==tokens(undo_probes(after)),(name,key,'body')
                methods+=1
    runtime_changes=[];line_endings=[]
    for name,raw in base.items():
        path=ROOT/'src'/name
        current=path.read_bytes()
        if current!=raw:
            if (name.endswith('.zs') or name=='ZSCRIPT') and current.replace(b'\r\n',b'\n')==raw.replace(b'\r\n',b'\n'):
                line_endings.append(name);continue
            # Only the two release-label diagnostics may differ in the delivery.
            assert name in ['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'],name
            assert current.replace(b'[Caelum 5.0.5]',b'[Caelum 5.0.4]').replace(b'\r\n',b'\n')==raw.replace(b'\r\n',b'\n'),name
            runtime_changes.append(name)
    assert {p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}==set(base)
    identity={'source_commit':'bc086979bc2adc2f66e498b66f96a8fe755ed0ea',
              'accepted_archive_sha256':'f8b8d1ba14da0d9db7624eb1ba5e7ebcb6269e1d47e59bb810fecb0c4c6ea695',
              'runtime_tree_sha256':tree_hash(base),'canonical_runtime_tree_sha256':tree_hash(base,canonical=True),'runtime_members':len(base),
              'map06_sha256':hashlib.sha256(base['maps/MAP06.wad']).hexdigest()}
    existing=HERE/'BASELINE_IDENTITY.json'
    if existing.exists():
        expected=json.loads(existing.read_text())
        for key,value in expected.items():
            if key!='runtime_tree_sha256':assert identity[key]==value,key
        identity=expected
    existing.write_text(json.dumps(identity,indent=2)+'\n')
    report={'method_bodies_verified':methods,'field_declarations_verified':fields,
            'instrumented_methods':len(selected),'runtime_changes':runtime_changes,'checkout_line_endings_only':line_endings,
            'production_test_includes':False,'baseline':identity}
    report['tested_baseline_archive_sha256']=hashlib.sha256((WORK/'baseline.pk3').read_bytes()).hexdigest()
    report['tested_baseline_runtime_tree_sha256']=tree_hash(base)
    production=ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(production) as package:
        assert set(package.namelist())==set(base),'Production package member set changed'
        for name in package.namelist():
            assert package.read(name)==(ROOT/'src'/name).read_bytes(),('production member',name)
    report['production']={'archive_sha256':hashlib.sha256(production.read_bytes()).hexdigest(),
                          'members':len(base),'all_members_equal_current_src':True}
    (HERE/'SOURCE_VERIFICATION.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))

if __name__=='__main__':main()
