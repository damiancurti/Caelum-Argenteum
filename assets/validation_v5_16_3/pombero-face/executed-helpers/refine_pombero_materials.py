from pathlib import Path
import json
import hashlib

root=Path(__file__).resolve().parent/'work-455'
source=root/'assets/source/art/pombero_455'
path=source/'DESIGN.json'
design=json.loads(path.read_text(encoding='utf-8'))
design['atlas']['source_file']='materials-v3.png'
design['additional_sources'].append('PROMPT-v3.json')
for shape in design['shapes']:
    if shape['kind']!='ear':continue
    outline=shape['outline'];curved=[]
    for i in range(len(outline)):
        p0,p1,p2,p3=(outline[j%len(outline)] for j in (i-1,i,i+1,i+2))
        for sample in range(4):
            t=sample/4
            curved.append([round(.5*(2*p1[k]+(-p0[k]+p2[k])*t+(2*p0[k]-5*p1[k]+4*p2[k]-p3[k])*t*t+(-p0[k]+3*p1[k]-3*p2[k]+p3[k])*t*t*t),6) for k in range(3)])
    shape['outline']=curved
    shape['rim_rings']=[[1,0],[.93,.3],[.84,.9],[.73,1],[.55,.25],[.35,-.5],[.1,-.9]]
    shape['concha_depth']=-1.0
path.write_bytes((json.dumps(design,indent=2)+'\n').encode('utf-8'))
path=source/'PROVENANCE.json'
record=json.loads(path.read_text(encoding='utf-8'))
record['material_atlas_previous']=record['material_atlas']
record['material_atlas']={'file':'materials-v3.png','sha256':hashlib.sha256((source/'materials-v3.png').read_bytes()).hexdigest(),'dimensions':[1254,1254],'tool':'Built-in image_gen edit; original output bytes retained. Exact prompt in PROMPT-v3.json.','layout':'Same 2x4 material grid; finer fabric, straw and rope scale with subdued lighting.'}
path.write_bytes((json.dumps(record,indent=2)+'\n').encode('utf-8'))
