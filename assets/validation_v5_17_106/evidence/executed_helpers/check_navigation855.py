"""Prove final packaging and bounded source changes against the tested baseline."""
from pathlib import Path
import hashlib,json,subprocess,zipfile
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
base=root/'build/issue851-local03.pk3';final=root/'build/issue855-navigation02.pk3';prototype=root/'build/issue855-navigation01/prototype.pk3'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
gameplay=['caelum/actors/CaelumDemonBreath.zs','caelum/actors/CaelumDemonService.zs']
diagnostics=['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
with zipfile.ZipFile(base) as before,zipfile.ZipFile(final) as after,zipfile.ZipFile(prototype) as candidate:
    names=set(before.namelist());assert names==set(after.namelist())=={p.relative_to(root/'src').as_posix() for p in (root/'src').rglob('*') if p.is_file()}
    changed=[]
    for name in sorted(names):
        old=before.read(name);new=after.read(name)
        assert new==(root/'src'/name).read_bytes(),name
        if old!=new:
            changed.append(name)
            if name in gameplay:assert new==candidate.read(name),name
            else:assert name in diagnostics and old.replace(b'[Caelum 5.17.104]',b'[Caelum 5.17.106]')==new,name
    assert changed==gameplay+diagnostics
result=dict(issue=855,version='5.17.106',members=len(names),baseline_sha256=sha(base),final_sha256=sha(final),final_bytes=final.stat().st_size,changed=changed,final_source_exact=True,prototype_gameplay_exact=True,no_added_removed_members=True,inverse_exact=json.loads((prototype.parent/'manifest.json').read_text())['inverse_exact'],parent_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip())
(root/'build/issue855-source-proof.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result))
