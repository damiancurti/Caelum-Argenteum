"""Check the documentation contract affected by #831 without rerunning art tests."""
from pathlib import Path
import argparse,hashlib,json,re,sys

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=Path.cwd())
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();root=args.root.resolve();sys.path.insert(0,str(root))
    import validate_project as contract
    errors=[];inputs={}
    def check(ok,message):
        if not ok:errors.append(message)
    def read(name):
        path=root/name;blob=path.read_bytes();inputs[name]=hashlib.sha256(blob).hexdigest()
        return blob.decode('utf-8-sig')
    def version(text,label,name):
        markers=re.findall(r'^'+re.escape(label)+r'\s*(\S+)',text[:1000].replace('**',''),re.M)
        check(len(markers)==1,name+': require exactly one opening version marker')
        value=markers[0].rstrip('.') if markers else ''
        check(bool(contract.NUMERIC_VERSION_RE.fullmatch(value)),name+': invalid numeric release')
        return value
    def links(text,name):
        targets=re.findall(r'\]\(([^)]+)\)',text)
        for target in targets:
            if not re.match(r'^[a-z]+:',target) and not target.startswith('#'):
                check(((root/name).parent/target.split('#')[0]).exists(),name+': missing link '+target)
        return targets
    readme=read('README.md');release=version(readme,'Current release:','README.md')
    check(release=='5.17.94','The focused #831 release must be 5.17.94')
    actual={p.relative_to(root/'docs').as_posix() for p in (root/'docs').rglob('*') if p.is_file()}
    check(actual==contract.ALLOWED_DOCS,'Unexpected maintained document set')
    for heading in ['## Implemented','## Planned','## Pending validation']:
        check(heading in readme,'README missing '+heading)
    for name in ['AGENTS.md']+['docs/'+n for n in sorted(contract.DOCUMENTS)]:
        text=read(name);check(version(text,'Documentation version:',name)==release,name+': release mismatch')
        check('VALIDATION_RESULT_PLACEHOLDER' not in text,name+': unfinished validation placeholder')
        if name!='docs/HISTORY.md':links(text,name)
    for name in sorted(contract.ANCILLARY|{contract.DOC_INDEX_NAME}):links(read('docs/'+name),'docs/'+name)
    errors.extend(contract.index_problems(root))
    for name in contract.DIAGNOSTICS:
        values=re.findall(r'\[Caelum ([^\]]+)\]',read(name))
        check(bool(values) and all(v==release for v in values),name+': diagnostic release mismatch')
    targets=links(readme,'README.md')
    for name in ['pending_test.txt','docs/HISTORY.md']:
        check(name in targets,'README missing required link '+name)
    read('pending_test.txt');words=len(read('docs/CONTEXT.md').split())
    check(words<2500,'CONTEXT exceeds the word limit')
    for name in ['build_document_index.py','.github/ISSUE_TEMPLATE/tarea.md']:
        check((root/name).is_file(),'Missing '+name)
    result={'issue':831,'version':release,'context_words':words,'documents':len(actual),'errors':errors,'inputs':inputs,
            'qualification':'Scoped current-header, diagnostic-label, maintained-document, link and index checks. Runtime preservation and historical-heading audit are separate evidence; unchanged art/gameplay tests are not rerun.'}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:result[k] for k in ['issue','version','context_words','documents','errors']}))
    raise SystemExit(bool(errors))

if __name__=='__main__':main()
