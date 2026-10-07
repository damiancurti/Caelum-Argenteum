"""Rebuild every diagnostic package twice from pinned Git content and compare bytes."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import zipfile
from runtime_identity import tree_hash

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
OUT=ROOT/'build/issue121/reproduction'
fingerprints=[]
for iteration in range(2):
    subprocess.run([sys.executable,str(HERE/'prepare.py'),'--from-git','--output',str(OUT)],cwd=ROOT,check=True)
    fingerprints.append({p.name:hashlib.file_digest(p.open('rb'),'sha256').hexdigest() for p in sorted(OUT.glob('*.pk3'))})
    print(f'Reconstruction {iteration+1}: {len(fingerprints[-1])} package hashes',flush=True)
assert fingerprints[0]==fingerprints[1],'Repeated package generation changed bytes'
with zipfile.ZipFile(OUT/'baseline.pk3') as package:
    content={n:package.read(n) for n in package.namelist()}
identity=json.loads((HERE/'BASELINE_IDENTITY.json').read_text())
assert tree_hash(content,canonical=True)==identity['canonical_runtime_tree_sha256']
result={'source_commit':identity['source_commit'],'iterations':2,'identical_package_bytes':True,
        'canonical_runtime_tree_sha256':tree_hash(content,canonical=True),'package_sha256':fingerprints[0],
        'qualification':'Git reconstruction can differ from the original accepted ZIP in metadata and text line endings; canonical runtime content must match.'}
(HERE/'REPRODUCTION.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS: reproducible diagnostic packages from the pinned accepted source.')
