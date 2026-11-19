"""Archive reproducible source/text/capture evidence without private binaries."""
from pathlib import Path
import hashlib,json,shutil
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');h=Path(__file__).resolve().parent
out=root/'assets/validation_v5_17_107/evidence';out.mkdir(exist_ok=False)
allowed={'.py','.zs','.json','.txt','.log','.ini','.cfg','.csv','.png','.html','.modeldef'}
hashes={}
def copy(path,destination):
    data=path.read_bytes();destination.parent.mkdir(parents=True,exist_ok=True);destination.write_bytes(data)
    hashes[destination.relative_to(out).as_posix()]=hashlib.sha256(data).hexdigest()
for directory in sorted((root/'build').glob('issue857-*')):
    if not directory.is_dir():continue
    for path in sorted(directory.rglob('*')):
        if path.is_file() and (path.suffix.lower() in allowed or path.name in ('ZSCRIPT','CVARINFO','MODELDEF','MAPINFO')):
            copy(path,out/'runs'/directory.name/path.relative_to(directory))
for path in sorted((root/'build').glob('issue857-*')):
    if path.is_file() and path.suffix.lower() in allowed:copy(path,out/'records'/path.name)
for pattern in ('*wardrobe*857*','*continuity*857*','*frames857*','*performance857*','*public857*'):
    for path in sorted(h.glob(pattern)):
        if path.is_file() and path.suffix in ('.py','.zs'):copy(path,out/'tooling'/path.name)
canonical=json.loads((root/'build/issue857-final01/SUMMARY.json').read_text());assert len(canonical)==11 and all(row['passed'] for row in canonical)
performance=json.loads((root/'build/issue857-presentation-final.json').read_text());assert len(performance)==8
scope=json.loads((root/'build/issue857-scope.json').read_text());assert scope['passed']
summary=dict(issue=857,version='5.17.107',scope=scope,canonical=canonical,canonical_passes=sum(row['pass_lines'] for row in canonical),final_package_passes=sum(row['pass_lines'] for row in canonical if row['runtime']=='final'),performance=performance,qualification='Assertion counts use actual PASS log lines in each process; saved EventHandler totals contain earlier checks and are not added. Host1 is native one-player cooperative mode for dead saves; single-player deliberately refuses saving a dead player. Default presentation, gameplay resources and equipment authority remain unchanged. Candidate binding order is corrected; item-specific grips/coverage and broader attachment work continue in859. No author acceptance.',private_exclusions=['PK3','WAD','IWAD','ZDS','EXE','DLL'],frame_order=json.loads((root/'build/issue857-frame-order.json').read_text()))
(out/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
(out/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
print(json.dumps(dict(files=len(hashes),canonical_passes=summary['canonical_passes'],final_package_passes=summary['final_package_passes'])))
