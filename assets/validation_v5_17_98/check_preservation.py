"""Independent pixel/metadata, deterministic regeneration and package preservation audit."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,zipfile
from PIL import Image
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True)
p.add_argument('--regenerate',action='store_true',help='Explicitly regenerate maintained assets and require byte-identical output')
p.add_argument('--output',type=Path,required=True);a=p.parse_args()
sha=lambda b:hashlib.sha256(b).hexdigest()
generator=root/'assets/generators/register_elemental_vfx.py'
paths=[root/'src/graphics/caelum/vfx/elemental.textures',root/'src/graphics/caelum/vfx/projectiles.png',root/'src/graphics/caelum/vfx/statuses.png',root/'src/caelum/actors/CaelumElementalVFXData.zs',root/'assets/source/art/elemental_518/REGISTRATION.json']+sorted((root/'src/graphics/caelum/vfx/projectile_frames').glob('*.png'))
before={str(p.relative_to(root)):sha(p.read_bytes()) for p in paths}
if a.regenerate:subprocess.run([sys.executable,str(generator)],cwd=root,check=True)
after={str(p.relative_to(root)):sha(p.read_bytes()) for p in paths};assert before==after
with zipfile.ZipFile(a.baseline) as old,zipfile.ZipFile(a.runtime) as new:
    original=old.read('graphics/caelum/vfx/elemental.textures').decode('utf-8');current=new.read('graphics/caelum/vfx/elemental.textures').decode('utf-8')
    atlas=Image.open(root/'assets/source/art/elemental_518/projectiles.png').convert('RGBA')
    assert old.read('graphics/caelum/vfx/projectiles.png')==new.read('graphics/caelum/vfx/projectiles.png')==(root/'assets/source/art/elemental_518/projectiles.png').read_bytes()
    count=0;frames=[]
    for line in original.splitlines():
        m=re.match(r'Sprite "(\w+)", (\d+), (\d+) .*Patch "graphics/caelum/vfx/projectiles.png", (-?\d+), (-?\d+) \}',line)
        if not m:continue
        name=m[1];w,h=int(m[2]),int(m[3]);x,y=-int(m[4]),-int(m[5]);path=f'graphics/caelum/vfx/projectile_frames/{name}.png'
        candidate=Image.open(root/'src'/path);expected=atlas.crop((x,y,x+w,y+h));assert candidate.mode=='RGBA' and candidate.size==expected.size and candidate.tobytes()==expected.tobytes()
        replacement=line.replace(f'Patch "graphics/caelum/vfx/projectiles.png", {m[4]}, {m[5]}',f'Patch "{path}", 0, 0')
        assert current.count(replacement)==1
        current=current.replace(replacement,line,1);count+=1
        assert new.read(path)==(root/'src'/path).read_bytes()
        frames.append(dict(name=name,rect=[x,y,x+w,y+h],rgba_sha256=sha(expected.tobytes()),png_sha256=sha(new.read(path))))
    assert count==36 and current==original
    oldnames=set(old.namelist());newnames=set(new.namelist());assert not oldnames-newnames
    assert newnames=={p.relative_to(root/'src').as_posix() for p in (root/'src').rglob('*') if p.is_file()}
    added=sorted(newnames-oldnames);assert added==sorted('graphics/caelum/vfx/projectile_frames/'+f['name']+'.png' for f in frames)
    changed=[]
    for name in sorted(oldnames):
        assert new.read(name)==(root/'src'/name).read_bytes(),name
        if old.read(name)!=new.read(name):changed.append(name)
    assert changed==sorted(['graphics/caelum/vfx/elemental.textures','licenses/ELEMENTAL_VFX_518.txt','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']),changed
    for name in ('caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'):
        assert old.read(name).replace(b'[Caelum 5.17.97]',b'[Caelum 5.17.98]')==new.read(name)
    runtime_members=len(newnames)
assert subprocess.check_output(['git','diff','--','pending_test.txt'],cwd=root)==b''
report=dict(issue=840,passed=True,baseline_sha256=sha(a.baseline.read_bytes()),runtime_sha256=sha(a.runtime.read_bytes()),runtime_members=runtime_members,added=added,changed=changed,frames=frames,regeneration_identical=before==after,regenerated_outputs=after,original_atlas_retained=True,all_bindings_restored_exactly=True,author_queue_unchanged=True,qualification='Independent Pillow decode compares every derived RGBA byte with original authored atlas rectangles. Inverse binding replacement restores the complete original file. Every unchanged package member is compared byte-for-byte; only expected resources, provenance and two diagnostic version strings differ. Not native performance or author acceptance.')
report.update(regeneration_identical=True if a.regenerate else None,source_package_exact=True,generator_sha256=sha(generator.read_bytes()),runtime_bytes=a.runtime.stat().st_size,derived_png_bytes=sum((root/'src'/name).stat().st_size for name in added))
a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({k:v for k,v in report.items() if k not in ('frames','added','regenerated_outputs')},indent=2))
