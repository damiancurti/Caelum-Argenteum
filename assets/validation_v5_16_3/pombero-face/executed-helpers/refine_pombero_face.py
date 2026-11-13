from pathlib import Path
import json
import hashlib

root=Path(__file__).resolve().parent/'work-455'
source=root/'assets/source/art/pombero_455'
path=source/'DESIGN.json'
design=json.loads(path.read_text(encoding='utf-8'))
face_path='models/caelum/folklore/pombero/face.png'
design['materials']['face']={'path':face_path,'native_batch':'face','source_file':'face-v1.png'}
design['materials']['skin']={'path':face_path,'native_batch':'face','uv_rect':[.12,.48,.25,.63]}
design['materials']['hair']={'path':face_path,'native_batch':'face','uv_rect':[.0,.02,.13,.35]}
design['additional_sources']=['FACE-PROMPT.json']
retired_prefixes=('eye socket ','eye ','iris ','pupil ','bushy brow ','nostril ','upper eyelid ','lower eyelid ','forehead fringe ')
retired_names={'closed smiling mouth','lower lip','jaw stubble'}
design['shapes']=[shape for shape in design['shapes'] if shape['name'] not in retired_names and not shape['name'].startswith(retired_prefixes)]
head=next(shape for shape in design['shapes'] if shape['name']=='continuous face and cranium')
head['front_projection']={'material':'face','minimum_x':.1,'y_bounds':[-9.5,9.5],'z_bounds':[63.1,84.5]}
for bump in head['front_deformation']:
    if bump['y']==0 and bump['z']==73.8:
        bump.update(z=71.9,width_y=2.55,width_z=2.0,depth=4.1)
head['front_deformation'] += [
    {'y':0,'z':69.5,'width_y':3.1,'width_z':.55,'depth':.65},
    {'y':0,'z':68.6,'width_y':3.0,'width_z':.6,'depth':.5},
    {'y':0,'z':67.0,'width_y':3.3,'width_z':1.1,'depth':1.0},
]
for shape in design['shapes']:
    if shape['name'].startswith('side hair '):
        for row in shape['rows']:
            row[3]*=.55;row[4]*=.55
design['reference_role']+=' Facial follow-up uses an original reference-led diffuse plate registered to a sculpted continuous head, with the rear cranium retaining a separate material; no billboard or camera alignment.'
path.write_bytes((json.dumps(design,indent=2)+'\n').encode('utf-8'))
provenance_path=source/'PROVENANCE.json'
provenance=json.loads(provenance_path.read_text(encoding='utf-8'))
provenance['facial_material']={'file':'face-v1.png','sha256':hashlib.sha256((source/'face-v1.png').read_bytes()).hexdigest(),'dimensions':[1254,1254],'tool':'Built-in image_gen; original output bytes retained. Exact prompt in FACE-PROMPT.json.','mapping':'Frontal UV projection onto the continuous 3D head; skin/hair patches reuse bounded UV regions. No raster pixels were edited.'}
provenance_path.write_bytes((json.dumps(provenance,indent=2)+'\n').encode('utf-8'))
