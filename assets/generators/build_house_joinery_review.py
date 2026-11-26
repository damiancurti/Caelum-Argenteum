"""Prepare an opt-in #878 timber-joinery model using unchanged owned textures."""
from pathlib import Path
import argparse,copy,hashlib,json,struct,zipfile
from generate_environment_models import Mesh
import generate_barracas_facades

ROOT=Path(__file__).resolve().parents[2]
CONFIG=ROOT/'assets/source/art/house_joinery_878/CONFIG.json'
def digest(data):return hashlib.sha256(data).hexdigest()
def read_json(name):return json.loads((ROOT/name).read_text(encoding='utf-8'))

def read_mesh(data):
    mesh=None;material=None
    for line in data.decode('utf-8').splitlines():
        fields=line.split()
        if not fields:continue
        if fields[0]=='o':mesh=Mesh(fields[1])
        elif fields[0]=='v':mesh.vertices.append(tuple(map(float,fields[1:])))
        elif fields[0]=='vt':mesh.uvs.append(tuple(map(float,fields[1:])))
        elif fields[0]=='usemtl':material=fields[1]
        elif fields[0]=='f':
            indices=[]
            for value in fields[1:]:
                parts=value.split('/');assert len(parts)==2 and parts[0]==parts[1]
                indices.append(int(parts[0]))
            mesh.faces.append((material,tuple(indices)))
    assert mesh and len(mesh.vertices)==len(mesh.uvs)
    return mesh

def bounds(mesh):
    return [[min(p[i] for p in mesh.vertices),max(p[i] for p in mesh.vertices)] for i in range(3)]
def inventory(mesh):
    materials=[m for m,_ in mesh.faces]
    return dict(vertices=len(mesh.vertices),faces=len(mesh.faces),triangles=sum(len(f)-2 for _,f in mesh.faces),
        material_count=len(set(materials)),native_material_sections=sum(i==0 or m!=materials[i-1] for i,m in enumerate(materials)),bounds=bounds(mesh))

def transform(mesh,config,trim):
    original=copy.deepcopy(mesh);wood=config['wood'];settings=config['proposal']
    assert settings['leaves']==2
    x0,y0,x1,y1=wood['field_pixels'];width,height=wood['pixels']
    uv=[(x0/width,1-y1/height),(x1/width,1-y1/height),(x1/width,1-y0/height),(x0/width,1-y0/height)]
    windows=[];modified=[]
    for face_number,(material,indices) in enumerate(original.faces):
        if material!=wood['runtime_path']:continue
        points=[original.vertices[i-1] for i in indices]
        # OBJ Y is native height; OBJ Z reflects the second map coordinate.
        if min(p[1] for p in points)==0:continue
        assert len(points)==4
        world=[(x,-z,y) for x,y,z in points]
        axis=0 if len({p[0] for p in world})==1 else 1;cross=1-axis
        assert len({p[axis] for p in world})==1
        surface=world[0][axis];outward=1 if surface>0 else -1
        low,high=min(p[cross] for p in world),max(p[cross] for p in world)
        bottom,top=min(p[2] for p in world),max(p[2] for p in world)
        for index,value in zip(indices,uv):mesh.uvs[index-1]=value
        modified.append(face_number)
        row=dict(axis=axis,surface=surface,outward=outward,low=low,high=high,bottom=bottom,top=top)
        windows.append(row)

        def point(along,z,offset):
            coordinate=surface+outward*offset
            x,y=(coordinate,along) if axis==0 else (along,coordinate)
            return x,z,-y

        def face(material,positions,rotate=False):
            coords=uv if material==wood['runtime_path'] else [(0,0),(1,0),(1,1),(0,1)]
            if rotate:coords=[coords[3],coords[0],coords[1],coords[2]]
            # Orient every new closed rail/plate toward its exterior side.
            # DontCullBackFaces does not repair inward lighting normals.
            if (axis==0 and outward<0) or (axis==1 and outward>0):
                positions=list(reversed(positions));coords=list(reversed(coords))
            mesh.add_polygon(material,[point(*p) for p in positions],coords)

        def rail(a,b,c,d,rotate=False):
            relief=trim*settings['relief_depth_fraction']
            # Open backs sit against the retained opaque timber plane.
            faces=[[(a,b,relief),(c,b,relief),(c,d,relief),(a,d,relief)],
                   [(a,b,0),(a,b,relief),(a,d,relief),(a,d,0)],
                   [(c,b,relief),(c,b,0),(c,d,0),(c,d,relief)],
                   [(a,b,0),(c,b,0),(c,b,relief),(a,b,relief)],
                   [(a,d,relief),(c,d,relief),(c,d,0),(a,d,0)]]
            for positions in faces:face(wood['runtime_path'],positions,rotate)

        middle=(low+high)/2;midheight=bottom+(top-bottom)*settings['middle_rail_height_fraction']
        for a,c in [(low,low+trim),(high-trim,high)]:rail(a,bottom,c,top)
        # Stop the central stile at the rails: avoid overlapping coplanar faces.
        for b,d in [(bottom+trim,midheight-trim/2),(midheight+trim/2,top-trim)]:rail(middle-trim/2,b,middle+trim/2,d)
        for b,d in [(bottom,bottom+trim),(midheight-trim/2,midheight+trim/2),(top-trim,top)]:rail(low+trim,b,high-trim,d,True)
        hinge_width=trim*settings['hinge_width_fraction'];hinge_height=trim*settings['hinge_height_fraction']
        distance=trim*(settings['relief_depth_fraction']+settings['hinge_plate_offset_fraction'])
        for center in [low+trim/2,high-trim/2]:
            for fraction in settings['hinge_height_fractions']:
                z=bottom+(top-bottom)*fraction
                face(config['iron']['runtime_path'],[(center-hinge_width/2,z-hinge_height/2,distance),(center+hinge_width/2,z-hinge_height/2,distance),(center+hinge_width/2,z+hinge_height/2,distance),(center-hinge_width/2,z+hinge_height/2,distance)])
    assert windows
    assert mesh.vertices[:len(original.vertices)]==original.vertices
    for i,(_,indices) in enumerate(original.faces):
        assert mesh.faces[i]==original.faces[i]
        if i not in modified:assert all(mesh.uvs[j-1]==original.uvs[j-1] for j in indices)
    assert bounds(mesh)==bounds(original),'Candidate exceeded the original facade envelope'
    # Native OBJ starts a surface on each usemtl. Group this opaque proposal's
    # faces by material so added details do not multiply per-house draw sections.
    mesh.faces.sort(key=lambda f:f[0])
    return windows,modified

def build(runtime,output):
    output=output.resolve();output.relative_to(ROOT/'build');output.mkdir(parents=True,exist_ok=False)
    config=read_json(CONFIG);name=config['runtime_model'];original=(ROOT/'src'/name).read_bytes()
    assert digest(original)==config['source_model_sha256']
    original_mesh=read_mesh(original)
    with zipfile.ZipFile(runtime) as z:
        assert z.read(name)==original
        material_records={}
        for role in ['wood','iron']:
            item=config[role];data=z.read(item['runtime_path']);assert digest(data)==item['sha256']
            if role=='wood':assert list(struct.unpack('>II',data[16:24]))==item['pixels']
            material_records[role]=dict(path=item['runtime_path'],bytes=len(data),sha256=digest(data))
    city=read_json('assets/map06_port/CITY.json');interior=read_json('assets/map06_port/INTERIORS.json')
    door=read_json('assets/map06_port/NATIVE_DOORS.json');layout=read_json('assets/barracas_redesign/LAYOUT.json')
    heights=[max(original_mesh.vertices[i-1][1] for i in indices) for material,indices in original_mesh.faces
             if material==config['wood']['runtime_path'] and min(original_mesh.vertices[i-1][1] for i in indices)==0]
    assert len(heights)==1
    profile={**city['profiles']['house'],'height':interior['height'],'headroom':interior['headroom'],'door_height':heights[0]}
    baseline=output/'original'/Path(name).name
    generate_barracas_facades.build(baseline,*interior['house_size'],profile,city['detail'],door['half_thickness'],(interior['entrance'][1]+interior['entrance'][3])/2)
    assert baseline.read_bytes()==original,'Retained facade does not recompile byte-identically'
    candidate=copy.deepcopy(original_mesh);windows,modified=transform(candidate,config,door['half_thickness'])
    path=output/Path(name).name;candidate.write(path)
    # Confirm serialization retains all final coordinates/UVs at six decimals.
    exported=read_mesh(path.read_bytes());assert bounds(exported)==bounds(original_mesh)
    overlay=output/'candidate.pk3'
    with zipfile.ZipFile(overlay,'x') as z:z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),path.read_bytes())
    report=dict(issue=878,author_acceptance=False,runtime_sha256=digest(runtime.read_bytes()),config_sha256=digest(CONFIG.read_bytes()),
        builder_sha256=digest(Path(__file__).read_bytes()),source_sha256=digest(original),model_sha256=digest(path.read_bytes()),overlay_sha256=digest(overlay.read_bytes()),
        original=inventory(original_mesh),candidate=inventory(exported),source_recompiled_exact=True,original_vertices_retained=True,
        retained_faces_and_door_uvs=True,original_envelope_equal=True,modified_original_window_uv_faces=modified,
        window_count=len(windows),windows=windows,house_instances=sum(b['kind']=='house' for b in layout['buildings']),
        materials=material_records,added_pixel_bytes=0,model_bytes=len(path.read_bytes()),overlay_bytes=len(overlay.read_bytes()),
        model_only_members=[name],native_map_actor_class_and_door_changes=0,scope=config['proposal']['description'],provenance=config['provenance'])
    (output/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    return report

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    report=build(args.runtime.resolve(strict=True),args.output)
    print(json.dumps({k:report[k] for k in ['overlay_sha256','original','candidate','window_count','house_instances','model_bytes']}))
