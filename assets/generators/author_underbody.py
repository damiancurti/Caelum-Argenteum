"""Build an editable anatomy candidate from retained CC0 topology and rig.

Run in pinned Blender 4.5.3 with -- --output PATH. The accepted .blend and
original atlas are read-only. Numeric art decisions live in DESIGN.json.
Exports are deterministic from the retained resulting source, not a claim
about byte-for-byte reproducibility of Blender's editable container.
"""
from pathlib import Path
import argparse,hashlib,json,sys
import bpy,bmesh
from mathutils import Vector,Matrix

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/underbody_827'

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def load_obj(path):
    vertices=[];faces=[];groups={};group=''
    for line in path.read_text().splitlines():
        if line.startswith('v '):vertices.append(Vector(map(float,line.split()[1:4])))
        elif line.startswith('g '):group=line[2:];groups[group]=[]
        elif line.startswith('f '):
            face=[int(value.split('/')[0])-1 for value in line.split()[1:]]
            groups[group].append(face)
    return vertices,groups

def close_mesh(bm):
    boundary=[e for e in bm.edges if e.is_boundary]
    if boundary:bmesh.ops.holes_fill(bm,edges=boundary,sides=0)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    assert not [e for e in bm.edges if not e.is_manifold],'Unclosed source surface.'

def remove_zero_volume_islands(bm):
    # A capped neck cut can retain a detached, two-sided triangle. Preserve
    # every volumetric component; only discard an exactly planar closed island.
    remaining=set(bm.verts);components=[]
    while remaining:
        pending=[next(iter(remaining))];component=set()
        while pending:
            vertex=pending.pop()
            if vertex in component:continue
            component.add(vertex)
            pending.extend(edge.other_vert(vertex) for edge in vertex.link_edges if edge.other_vert(vertex) not in component)
        remaining-=component;components.append(component)
    largest=max(components,key=len);removed=[]
    for component in components:
        if component is largest:continue
        faces={face for vertex in component for face in vertex.link_faces}
        assert len(component)==3 and len(faces)==2,'Unexpected disconnected anatomy component.'
        assert len({tuple(sorted(v.index for v in f.verts)) for f in faces})==1,'Disconnected component is not a duplicate opposing triangle.'
        removed.append({'vertices':len(component),'triangles':len(faces)})
        bmesh.ops.delete(bm,geom=list(component),context='VERTS')
    return removed

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    cfg=json.loads((ART/'DESIGN.json').read_text());source=ROOT/cfg['source'];accepted=ROOT/cfg['accepted_rig']
    assert digest(source)==cfg['source_sha256'] and digest(accepted)==cfg['accepted_rig_sha256']
    bpy.ops.wm.open_mainfile(filepath=str(accepted));scene=bpy.context.scene
    rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
    vertices,groups=load_obj(source)
    def point(spec):
        if isinstance(spec,list):return Vector(spec)
        indices=sorted(set(i for f in groups[spec] for i in f));return sum((vertices[i] for i in indices),Vector())/len(indices)
    source_faces=groups[cfg['source_group']];used=sorted(set(i for f in source_faces for i in f));indices={v:i for i,v in enumerate(used)}
    mesh=bpy.data.meshes.new('CC0 fitted anatomy');mesh.from_pydata([vertices[i] for i in used],[],[[indices[i] for i in f] for f in source_faces]);mesh.update()
    obj=bpy.data.objects.new('CA827 Construction source',mesh);scene.collection.objects.link(obj)
    bm=bmesh.new();bm.from_mesh(mesh)
    bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,plane_co=(0,cfg['neck_cut_source_y'],0),plane_no=(0,1,0),clear_outer=True,clear_inner=False)
    loose=[v for v in bm.verts if not v.link_faces]
    if loose:bmesh.ops.delete(bm,geom=loose,context='VERTS')
    close_mesh(bm);bm.to_mesh(mesh);bm.free()
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
    dec=obj.modifiers.new('Deterministic topology reduction','DECIMATE');dec.ratio=cfg['decimate_ratio'];dec.use_collapse_triangulate=True
    bpy.ops.object.modifier_apply(modifier=dec.name)
    helper_data=bpy.data.armatures.new('CA827 Source landmark skeleton');helper=bpy.data.objects.new('CA827 Source landmark skeleton',helper_data);scene.collection.objects.link(helper)
    obj.select_set(False);helper.select_set(True);bpy.context.view_layer.objects.active=helper;bpy.ops.object.mode_set(mode='EDIT')
    for name,(start,end,parent) in cfg['source_bones'].items():
        bone=helper_data.edit_bones.new(name);bone.head=point(start);bone.tail=point(end)
        if parent:bone.parent=helper_data.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT');obj.select_set(True)
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')
    weights={v.index:{obj.vertex_groups[g.group].name:g.weight for g in v.groups if g.weight>0} for v in mesh.vertices}
    assert all(weights.values()),'Bone heat left unweighted vertices.'
    scale=cfg['cross_section_scale'];transforms={}
    # Match the anatomical axes before aligning segment directions. Arbitrary
    # armature roll would twist lateral width into front/back depth.
    axes=Matrix(((0,0,1),(1,0,0),(0,1,0)))
    for bone in helper.data.bones:
        target=rig.data.bones[bone.name]
        fit=cfg['segment_fit'].get(bone.name,{})
        scale=fit.get('cross_section_scale',cfg['cross_section_scale'])
        offset=Vector(fit.get('target_offset',[0,0,0]))
        origin=axes@bone.head_local;direction=axes@(bone.tail_local-bone.head_local);unit=direction.normalized()
        stretch=Matrix.Identity(3)*scale
        for i in range(3):
            for j in range(3):stretch[i][j]+=(target.length/bone.length-scale)*unit[i]*unit[j]
        rotation=direction.rotation_difference(target.tail_local-target.head_local).to_matrix()
        transforms[bone.name]=Matrix.Translation(target.head_local+offset)@(rotation@stretch).to_4x4()@Matrix.Translation(-origin)@axes.to_4x4()
    # Cut the same shared mesh once, then duplicate its exact wrist boundary.
    bm=bmesh.new();bm.from_mesh(mesh);bm.verts.ensure_lookup_table();deform=bm.verts.layers.deform.verify()
    planes={}
    for side,sign in [('L',1),('R',-1)]:
        start,end,_=cfg['source_bones']['forearm.'+side];wrist=point(end);normal=(wrist-point(start)).normalized();planes[side]=(wrist,normal)
        selected={v for v in bm.verts if sign*v.co.x>cfg['wrist_halfspace_minimum_lateral'] and v.co.y>cfg['wrist_halfspace_minimum_height']}
        geometry=list(selected)+[e for e in bm.edges if all(v in selected for v in e.verts)]+[f for f in bm.faces if all(v in selected for v in f.verts)]
        bmesh.ops.bisect_plane(bm,geom=geometry,dist=1e-6,plane_co=wrist,plane_no=normal,clear_outer=False,clear_inner=False)
    part=bm.faces.layers.int.new('CA827 module')
    for face in bm.faces:
        center=face.calc_center_median();face[part]=0
        for side,sign,number in [('L',1,1),('R',-1,2)]:
            wrist,normal=planes[side]
            if sign*center.x>cfg['wrist_halfspace_minimum_lateral'] and center.y>cfg['wrist_halfspace_minimum_height'] and (center-wrist).dot(normal)>1e-6:face[part]=number
    for vert in bm.verts:
        ws=vert[deform];total=sum(ws.values());assert total>0
        original=vert.co.copy();vert.co=sum(((transforms[obj.vertex_groups[i].name]@original)*(weight/total) for i,weight in ws.items()),Vector())
        # Normalize the interpolated cut weights before retaining the source.
        for i in list(ws.keys()):ws[i]/=total
    image=bpy.data.images.load(str(ROOT/cfg['skin']),check_existing=True)
    material=bpy.data.materials.new('CA827 retained skin sample');material.use_nodes=True
    nodes=material.node_tree.nodes;tex=nodes.new('ShaderNodeTexImage');tex.image=image
    material.node_tree.links.new(tex.outputs['Color'],nodes.get('Principled BSDF').inputs['Base Color'])
    nodes.get('Principled BSDF').inputs['Roughness'].default_value=1
    sample=cfg['skin_sample_pixels'];uv_point=((sample[0]+.5)/image.size[0],1-(sample[1]+.5)/image.size[1])
    report={'issue':827,'source_sha256':digest(source),'accepted_rig_sha256':digest(accepted),'modules':{},'bone_heat_unweighted_vertices':0}
    for number,(key,name) in enumerate(cfg['modules'].items()):
        clone=bm.copy();tag=clone.faces.layers.int['CA827 module'];remove=[f for f in clone.faces if f[tag]!=number]
        bmesh.ops.delete(clone,geom=remove,context='FACES');loose=[v for v in clone.verts if not v.link_faces]
        if loose:bmesh.ops.delete(clone,geom=loose,context='VERTS')
        boundary=[tuple(v.co) for v in clone.verts if v.is_boundary]
        close_mesh(clone);bmesh.ops.triangulate(clone,faces=list(clone.faces))
        clone.verts.index_update();removed=remove_zero_volume_islands(clone)
        layer=clone.loops.layers.uv.verify()
        for face in clone.faces:
            face.smooth=True
            for loop in face.loops:loop[layer].uv=uv_point
        result_mesh=bpy.data.meshes.new(name);clone.to_mesh(result_mesh);clone.free()
        result=bpy.data.objects.new(name,result_mesh);scene.collection.objects.link(result);result.data.materials.append(material)
        for group in obj.vertex_groups:result.vertex_groups.new(name=group.name)
        modifier=result.modifiers.new('Accepted Domingo animation','ARMATURE');modifier.object=rig
        result['issue']=827;result['source_license']='CC0-1.0';result['module']=key
        report['modules'][key]={'vertices':len(result_mesh.vertices),'triangles':len(result_mesh.polygons),'boundary_before_caps':boundary,'removed_zero_volume_islands':removed}
    bm.free();bpy.data.objects.remove(obj,do_unlink=True);bpy.data.objects.remove(helper,do_unlink=True)
    rig.data.pose_position='POSE';rig.animation_data.action=bpy.data.actions['IdleBreathing'];scene.frame_set(0)
    for o in scene.objects:
        if o.type=='MESH':o.hide_render=not o.name.startswith('CA827 ')
    for n in ['Head','Eye l-eye','Eye r-eye','Pupil -1','Pupil 1','Hair crown','Long hair L','Long hair R']:bpy.data.objects[n].hide_render=False
    bpy.ops.wm.save_as_mainfile(filepath=str(out/'underbody.blend'),compress=True)
    report['editable_sha256']=digest(out/'underbody.blend');(out/'AUTHORING.json').write_text(json.dumps(report,indent=2)+'\n')
    assert digest(accepted)==cfg['accepted_rig_sha256'] and digest(source)==cfg['source_sha256']
    print(json.dumps({k:{n:v for n,v in row.items() if n!='boundary_before_caps'} for k,row in report['modules'].items()}))

if __name__=='__main__':main()
