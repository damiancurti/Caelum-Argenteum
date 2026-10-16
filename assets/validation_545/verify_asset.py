"""Check the generated OBJ's topology, indices and repeatable output bytes."""
from collections import defaultdict
import hashlib
import json
import math
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
paths = [ROOT/"src/models/caelum/weather/rain_cloud.obj",
         ROOT/"src/models/caelum/weather/rain_cloud_palette.png",
         ROOT/"src/shaders/caelum/rain_cloud.fp", ROOT/"assets/rain_cloud/manifest.json"]
before = [p.read_bytes() for p in paths]
subprocess.run([sys.executable, str(ROOT/"assets/generators/generate_rain_cloud.py")],
               check=True, capture_output=True)
assert before == [p.read_bytes() for p in paths], "Generator changed reproducible outputs"
vertices, uvs, normals, faces = [], [], [], []
for line in paths[0].read_text().splitlines():
    fields = line.split()
    if not fields:
        continue
    if fields[0] in ("v", "vt", "vn"):
        target = {"v":vertices,"vt":uvs,"vn":normals}[fields[0]]
        values = tuple(map(float,fields[1:]))
        assert all(math.isfinite(v) for v in values)
        target.append(values)
    if fields[0] == "f":
        assert len(fields) == 4, "Only triangles expected"
        face = []
        for ref in fields[1:]:
            v,uv,n = map(int,ref.split('/'))
            assert 1 <= v <= len(vertices) and 1 <= uv <= len(uvs) and 1 <= n <= len(normals)
            face.append(v-1)
        faces.append(face)
assert all(abs(sum(v*v for v in n)-1)<1e-6 for n in normals)
edges = defaultdict(list)
graph = defaultdict(set)
volume = 0
minimum_area = float('inf')
for face in faces:
    a,b,c = [vertices[i] for i in face]
    u,v = [b[i]-a[i] for i in range(3)],[c[i]-a[i] for i in range(3)]
    normal = (u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0])
    minimum_area = min(minimum_area,math.sqrt(sum(n*n for n in normal))/2)
    volume += sum(a[i]*normal[i] for i in range(3))/6
    for a,b in zip(face,face[1:]+face[:1]):
        edges[tuple(sorted((a,b)))].append((a,b))
        graph[a].add(b);graph[b].add(a)
assert minimum_area>1e-12 and volume>0
assert all(len(e)==2 and e[0]==tuple(reversed(e[1])) for e in edges.values()), "Open or inconsistently wound edge"
seen,queue = set(),[0]
while queue:
    i=queue.pop()
    if i in seen:continue
    seen.add(i);queue.extend(graph[i]-seen)
assert len(seen)==len(vertices), "Disconnected mesh component"
euler = len(vertices)-len(edges)+len(faces)
assert euler==2, "Unexpected handle/cavity"
report = {"version":"5.4.5","issue":251,"vertices":len(vertices),"triangles":len(faces),
          "edges":len(edges),"connected_components":1,"euler_characteristic":euler,
          "signed_volume":volume,"minimum_triangle_area":minimum_area,
          "unit_normals":True,"consistent_winding":True,"repeat_identical":True,
          "hashes":{p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}
(ROOT/"assets/validation_545/static.json").write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(report,indent=2))
