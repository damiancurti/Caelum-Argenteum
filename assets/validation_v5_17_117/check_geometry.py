"""Audit original preservation and every new rail/plate exterior normal."""
from pathlib import Path
import argparse,hashlib,json,sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from build_house_joinery_review import read_mesh,bounds
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();cfg=json.loads((ROOT/'assets/source/art/house_joinery_878/CONFIG.json').read_text())
original=read_mesh((ROOT/'src'/cfg['runtime_model']).read_bytes())
with zipfile.ZipFile(a.candidate) as z:
    assert z.namelist()==[cfg['runtime_model']]
    mesh=read_mesh(z.read(cfg['runtime_model']))
assert mesh.vertices[:len(original.vertices)]==original.vertices
assert bounds(mesh)==bounds(original)
retained={(m,f) for m,f in mesh.faces if max(f)<=len(original.vertices)}
assert retained==set(original.faces)
added=[(m,f) for m,f in mesh.faces if min(f)>len(original.vertices)]
rails=plates=0
for material,face in added:
    points=[mesh.vertices[i-1] for i in face]
    p0,p1,p2=points[:3];u=[p1[i]-p0[i] for i in range(3)];v=[p2[i]-p0[i] for i in range(3)]
    normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
    assert sum(x*x for x in normal)>0
    offset=min(face)-1-len(original.vertices);window,local=divmod(offset,156)
    assert 0<=window<17
    center=[sum(p[i] for p in points)/len(points) for i in range(3)]
    if local<140:
        start=len(original.vertices)+window*156+(local//20)*20
        vertices=mesh.vertices[start:start+20]
        inside=[(min(p[i] for p in vertices)+max(p[i] for p in vertices))/2 for i in range(3)]
        assert sum(normal[i]*(center[i]-inside[i]) for i in range(3))>0
        rails+=1
    else:
        assert material==cfg['iron']['runtime_path']
        outward=[center[0],0,center[2]]
        assert sum(normal[i]*outward[i] for i in range(3))>0
        plates+=1
assert rails==595 and plates==68
result=dict(issue=878,passed=True,original_faces=len(retained),original_vertices=len(original.vertices),new_rail_faces_outward=rails,new_hinge_faces_outward=plates,original_bounds_equal=True,overlay_sha256=hashlib.sha256(a.candidate.read_bytes()).hexdigest(),qualification='Static original-face/bounds and nondegenerate outward-normal audit; native view review and author acceptance remain separate.')
a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(result))
