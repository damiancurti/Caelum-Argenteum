"""Verify portable builders reproduce measured bytes and the native fixture."""
from pathlib import Path
import ast,hashlib,json,subprocess,sys
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';dest=root/'assets/validation_v5_17_104'
baseline=root/'build/issue849-carrier02.pk3';candidate=root/'build/issue851-local02/prototype.pk3'
cases=[('regions01','prepare_regions.py',baseline,['--detail'],'maintenance.pk3'),('environment01','prepare_environment.py',baseline,[],'services.pk3'),('hot01','prepare_hot.py',baseline,[],'services.pk3'),('candidates02','prepare_candidates.py',baseline,[],'services.pk3'),('local02','prepare_local_reach.py',baseline,[],'prototype.pk3'),('local-regions02','prepare_candidates.py',candidate,[],'services.pk3'),('local-oracle02','prepare_local_oracle.py',candidate,[],'oracle.pk3')]
reports=[]
for label,script,runtime,flags,name in cases:
    out=root/('build/issue851-repro-'+label);argument='--candidate' if 'oracle' in script else '--runtime'
    with (root/('build/issue851-repro-'+label+'.log')).open('wb') as log:
        subprocess.run([sys.executable,str(dest/script),argument,str(runtime),'--output',str(out),*flags],cwd=root,stdout=log,stderr=log,check=True)
    original=root/('build/issue851-'+label)/name;assert original.read_bytes()==(out/name).read_bytes(),label
    reports.append(dict(label=label,overlay_sha256=hashlib.sha256(original.read_bytes()).hexdigest(),exact=True))
out=root/'build/issue851-repro-edges01'
with (root/'build/issue851-repro-edges01.log').open('wb') as log:
    subprocess.run([sys.executable,str(dest/'run_local_edges.py'),'--baseline',str(baseline),'--runtime',str(root/'build/issue851-local03.pk3'),'--output',str(out)],cwd=root,stdout=log,stderr=log,check=True)
assert (out/'checks.pk3').read_bytes()==(root/'build/issue851-edges-final01/checks.pk3').read_bytes()
native=json.loads((out/'RESULTS.json').read_text());assert native['passed']
reports.append(dict(label='portable_native_fixture',exact=True,checks=sum(' EDGE PASS ' in s for s in native['checks'])))
for p in dest.glob('*.py'):ast.parse(p.read_text(encoding='utf-8'))
(dest/'evidence/TOOL_REPRODUCTION.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(reports))
