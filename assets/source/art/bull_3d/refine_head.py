"""Author-requested facial refinement of the frozen #369 rigged source.

Input: bull.blend from commit recorded in DESIGN.json / face_refinement.
Uses a fresh output directory, retaining all reference objects and the body rig.
The resulting editable .blend is the deterministic runtime export input.
"""
import argparse
import hashlib
import json
import math
import sys
from pathlib import Path
import bpy
import bmesh
from mathutils import Vector
from mathutils.bvhtree import BVHTree

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
from authoring import activate, colored_material, horn


def new_mesh(name,vertices,faces,materials,indices=None):
    data=bpy.data.meshes.new(name);data.from_pydata(vertices,[],faces);data.update()
    obj=bpy.data.objects.new(name,data);bpy.context.scene.collection.objects.link(obj)
    for mat in materials:data.materials.append(mat)
    for face in data.polygons:
        face.use_smooth=True
        if indices is not None:face.material_index=indices[face.index]
    return obj


def sphere(name,center,radii,mat,segments=24,rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,location=center)
    obj=bpy.context.object;obj.name=name;obj.scale=radii
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    obj.data.materials.append(mat)
    for face in obj.data.polygons:face.use_smooth=True
    return obj


def fur_material(config):
    mat=colored_material('Symmetric_head_brown',config['fur_color'])
    nodes=mat.node_tree.nodes;links=mat.node_tree.links
    noise=nodes.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=48;noise.inputs['Detail'].default_value=2
    geo=nodes.new('ShaderNodeNewGeometry');links.new(geo.outputs['Position'],noise.inputs['Vector'])
    ramp=nodes.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].color=config['fur_color'];ramp.color_ramp.elements[1].color=config['fur_variation']
    links.new(noise.outputs['Fac'],ramp.inputs[0]);links.new(ramp.outputs[0],nodes['Principled BSDF'].inputs['Base Color'])
    return mat


def head(config,mat):
    sections=config['head_sections'];count=config['head_rings'];vertices=[];faces=[]
    for x,z,w,h in sections:
        for j in range(count):
            a=math.tau*j/count;c=math.cos(a);s=math.sin(a)
            vertices.append((x,w*math.copysign(abs(c)**config['head_power'],c),z+h*s))
    for i in range(len(sections)-1):
        for j in range(count):faces.append((i*count+j,i*count+(j+1)%count,(i+1)*count+(j+1)%count,(i+1)*count+j))
    faces+=[tuple(reversed(range(count))),tuple((len(sections)-1)*count+j for j in range(count))]
    obj=new_mesh('Symmetric_forehead_cheeks_bridge',vertices,faces,[mat])
    activate(obj);sub=obj.modifiers.new('Smooth symmetric facial contour','SUBSURF');sub.levels=1
    bpy.ops.object.modifier_apply(modifier=sub.name)
    # The cross-section mesh is deliberately smooth and bilateral; reduction
    # is handled symmetrically later rather than decimating one side differently.
    return obj


def eye(config,side,head_surface,fur):
    center=Vector(config['eye_center']);center.y*=side
    normal=Vector(config['eye_normal']);normal.y*=side;normal.normalize()
    horizontal=Vector((normal.y*side,-normal.x*side,0)).normalized()
    vertical=normal.cross(horizontal)*(-side)
    if vertical.z<0:vertical=-vertical
    vertices=[];faces=[];indices=[];count=20
    mats=[colored_material('Eye_layer_%d_%d'%(side,i),c) for i,c in enumerate(config['eye_colors'])]
    mats[-1]=fur
    surface=BVHTree.FromObject(head_surface,bpy.context.evaluated_depsgraph_get())
    def conform(point,depth):
        hit,n,_,_=surface.ray_cast(Vector((point.x,side*.6,point.z)),Vector((0,-side,0)))
        if hit is None:raise RuntimeError('Eye contour must lie on the head')
        return hit+n*depth
    for ring,(width,height,depth) in enumerate(config['eye_layers']):
        for j in range(count):
            a=math.tau*j/count
            # Almond corners and a narrow horizontal pupil, not a black sphere.
            sine=math.sin(a)
            vertical_shape=sine if ring<3 else math.copysign(abs(sine)**1.4,sine)
            v=conform(center+horizontal*(width*math.cos(a))+vertical*(height*vertical_shape),depth)
            vertices.append(v)
    faces.append(tuple(reversed(range(count))));indices.append(0)
    for i in range(len(config['eye_layers'])-1):
        for j in range(count):
            faces.append((i*count+j,i*count+(j+1)%count,(i+1)*count+(j+1)%count,(i+1)*count+j));indices.append(i+1)
    obj=new_mesh('Lidded_eye_'+str(side),vertices,faces,mats,indices)
    gleam=sphere('Corneal_highlight_'+str(side),conform(center+horizontal*.004+vertical*.004,.005),(.001,.001,.001),colored_material('Muted_eye_reflection_'+str(side),(.26,.22,.16,1)),8,4)
    return [obj,gleam]


def ear(config,side,fur):
    center=Vector(config['ear_center']);center.y*=side
    dx,dy,dz=config['ear_extent'];vertices=[];faces=[];indices=[];count=12
    for k in range(5):
        t=k/4;width=math.sin(math.pi*t)**.7
        for j in range(count):
            a=math.tau*j/count
            vertices.append(center+Vector((dx*width*math.cos(a),side*dy*(t-.45),dz*width*math.sin(a))))
    for i in range(4):
        for j in range(count):
            faces.append((i*count+j,i*count+(j+1)%count,(i+1)*count+(j+1)%count,(i+1)*count+j))
            indices.append(1 if math.cos(math.tau*(j+.5)/count)>.4 and i in (1,2) else 0)
    return new_mesh('Symmetric_ear_'+str(side),vertices,faces,[fur,colored_material('Ear_inner_'+str(side),config['ear_inside'])],indices)


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source',required=True,type=Path);parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);out=args.output.resolve();out.mkdir(exist_ok=False,parents=True)
    design=json.loads((HERE/'DESIGN.json').read_text(encoding='utf-8'));cfg=design['face_refinement']
    assert bpy.app.version==(4,5,3)
    assert hashlib.sha256(args.source.read_bytes()).hexdigest()==cfg['input_blend_sha256']
    bpy.ops.wm.open_mainfile(filepath=str(args.source.resolve()))
    scene=bpy.context.scene;rig=bpy.data.objects['Bull_Rig'];mesh=bpy.data.objects['Bull_surface']
    rig.data.pose_position='REST';scene.frame_set(0)
    before_bones=len(rig.data.bones);before_actions={name:len(bpy.data.actions[name].fcurves) for name in design['export_actions']}
    # Preserve the accepted body vertices, UV coordinates, weights and actions.
    # Only the old head/details are removed from the editable runtime mesh.
    fur=fur_material(cfg);mesh.data.materials.append(fur);fur_index=len(mesh.data.materials)-1
    activate(mesh);bm=bmesh.new();bm.from_mesh(mesh.data);region=bm.faces.layers.int['bake_region']
    detail_vertices={v for face in bm.faces if face[region]>0 for v in face.verts}
    cut=list(detail_vertices)
    bmesh.ops.delete(bm,geom=cut,context='VERTS')
    # Keep the original closed neck surface: a cut-and-cap creates a large
    # concave polygon with visible shading wedges. Nest the old facial volume
    # inside the replacement, blending only its existing head boundary.
    unchanged_positions=[];refined_neck_vertices=0
    for vertex in bm.verts:
        x,y,z=vertex.co
        weight=min(1,max(0,(x-.15)/.10))*min(1,max(0,(z-.18)/.07))
        weight=weight*weight*(3-2*weight)
        if weight:
            refined_neck_vertices+=1
            target=Vector((.17+.15*(x-.17),y*.3,.36+.45*(z-.36)))
            vertex.co=vertex.co.lerp(target,weight)
        else:unchanged_positions.append(tuple(vertex.co))
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh.data);bm.free()
    kept_vertices=len(mesh.data.vertices)
    activate(mesh);blend=mesh.vertex_groups.new(name='Refined neck transition')
    for vertex in mesh.data.vertices:
        x,y,z=vertex.co
        weight=min(1,max(0,(x-.12)/.08))*min(1,max(0,(z-.18)/.08))
        if weight:blend.add([vertex.index],weight,'REPLACE')
    smooth=mesh.modifiers.new('Soften preserved neck transition','SMOOTH');smooth.factor=.5;smooth.iterations=8;smooth.vertex_group=blend.name
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    body_positions=[list(v.co) for v in mesh.data.vertices]
    details=[head(cfg,fur)]
    for side in (-1,1):
        horn_config=dict(design['head_repair']);horn_config['center']=[.3,0,.39]
        details.append(horn(horn_config,side));details.extend(eye(cfg,side,details[0],fur));details.append(ear(cfg,side,fur))
    nose=sphere('Broad_bovine_muzzle',cfg['muzzle_center'],cfg['muzzle_radii'],colored_material('Muzzle_leather',cfg['muzzle_color']))
    nose.data.materials.append(colored_material('Nostril_cavity',cfg['cavity_color']))
    for side in (-1,1):
        position=Vector(cfg['nostril_center']);position.y*=side
        cutter=sphere('Nostril_cut_reference_'+str(side),position,cfg['nostril_radii'],nose.data.materials[1])
        # Rotate the oval around its own center: bovine lateral nostrils.
        from mathutils import Matrix
        turn=Matrix.Rotation(side*.45,3,'X')
        for vertex in cutter.data.vertices:vertex.co=position+turn@(vertex.co-position)
        activate(nose);boolean=nose.modifiers.new('Recessed nostril '+str(side),'BOOLEAN');boolean.operation='DIFFERENCE';boolean.solver='EXACT';boolean.object=cutter
        bpy.ops.object.modifier_apply(modifier=boolean.name);cutter.hide_render=True;cutter.hide_set(True)
    details.append(nose)
    activate(nose);bevel=nose.modifiers.new('Soft nostril rims','BEVEL');bevel.width=.0018;bevel.segments=2;bevel.limit_method='ANGLE';bevel.angle_limit=.5
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    # Broad lower lip and a recessed horizontal mouth line.
    mouth=Vector(cfg['mouth_center'])
    details.append(sphere('Lower_lip',mouth+Vector((-.006,0,-.005)),(.026,.082,.012),colored_material('Lower_lip_brown',cfg['muzzle_color']),20,8))
    details.append(sphere('Mouth_line',mouth,(.027,.081,.0025),colored_material('Mouth_shadow',cfg['lip_color']),20,6))
    for obj in details:
        # Symmetric topology reduction for the loft only, keeping the center seam.
        if obj.name.startswith('Symmetric_forehead'):
            activate(obj);dec=obj.modifiers.new('Facial symmetric triangle budget','DECIMATE');dec.ratio=.44;dec.use_symmetry=True;dec.symmetry_axis='Y';bpy.ops.object.modifier_apply(modifier=dec.name)
        obj.vertex_groups.new(name='Head').add(list(range(len(obj.data.vertices))),1,'REPLACE')
        obj.data.uv_layers.new(name='UVMap')
        activate(mesh);obj.select_set(True);bpy.ops.object.join()
    assert len(rig.data.bones)==before_bones
    assert {name:len(bpy.data.actions[name].fcurves) for name in design['export_actions']}==before_actions
    assert [list(v.co) for v in mesh.data.vertices[:kept_vertices]]==body_positions
    # Normalize the orientation of all newly constructed surfaces before export.
    activate(mesh);bm=bmesh.new();bm.from_mesh(mesh.data);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh.data);bm.free()
    tri=mesh.modifiers.new('Final facial triangulation','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=tri.name)
    # Bake a new atlas using preserved UVMap for the old body material.
    for mat in mesh.data.materials:
        if mat is None:continue
        for node in mat.node_tree.nodes:
            if node.type=='TEX_IMAGE':
                uv=mat.node_tree.nodes.new('ShaderNodeUVMap');uv.uv_map='UVMap';mat.node_tree.links.new(uv.outputs[0],node.inputs['Vector'])
    mesh.data.uv_layers.new(name='RefinedAtlas');mesh.data.uv_layers.active=mesh.data.uv_layers['RefinedAtlas']
    mesh.data.uv_layers['RefinedAtlas'].active_render=True
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(angle_limit=math.radians(66),island_margin=.008);bpy.ops.object.mode_set(mode='OBJECT')
    skin=bpy.data.images.new('Bull_refined_albedo',width=cfg['atlas_size'],height=cfg['atlas_size'],alpha=False);skin.colorspace_settings.name='sRGB'
    for mat in mesh.data.materials:
        if mat is None:continue
        nodes=mat.node_tree.nodes;links=mat.node_tree.links;principled=nodes.get('Principled BSDF');base=principled.inputs['Base Color']
        emission=nodes.new('ShaderNodeEmission')
        if base.is_linked:links.new(base.links[0].from_socket,emission.inputs[0])
        else:emission.inputs[0].default_value=base.default_value
        if mat.name!='Bull_clean_albedo':
            # MD3 receives sector lighting, so the facial atlas includes soft,
            # bilateral shape shading and cavity occlusion for readable volume.
            geometry=nodes.new('ShaderNodeNewGeometry')
            dot=nodes.new('ShaderNodeVectorMath');dot.operation='DOT_PRODUCT';dot.inputs[1].default_value=(.35,0,.93675);links.new(geometry.outputs['Normal'],dot.inputs[0])
            ramp=nodes.new('ShaderNodeMapRange');ramp.clamp=True;ramp.inputs['From Min'].default_value=0;ramp.inputs['From Max'].default_value=1;ramp.inputs['To Min'].default_value=.6875;ramp.inputs['To Max'].default_value=1.25;links.new(dot.outputs['Value'],ramp.inputs['Value'])
            ao=nodes.new('ShaderNodeAmbientOcclusion');ao.samples=8;ao.inputs['Distance'].default_value=.06
            ao_range=nodes.new('ShaderNodeMapRange');ao_range.inputs['To Min'].default_value=.6;ao_range.inputs['To Max'].default_value=1;links.new(ao.outputs['AO'],ao_range.inputs['Value'])
            factor=nodes.new('ShaderNodeMath');factor.operation='MULTIPLY';links.new(ramp.outputs[0],factor.inputs[0]);links.new(ao_range.outputs[0],factor.inputs[1])
            color=nodes.new('ShaderNodeMixRGB');color.blend_type='MULTIPLY';color.inputs[0].default_value=1
            if base.is_linked:links.new(base.links[0].from_socket,color.inputs[1])
            else:color.inputs[1].default_value=base.default_value
            links.new(factor.outputs[0],color.inputs[2]);links.new(color.outputs[0],emission.inputs[0])
        links.new(emission.outputs[0],nodes.get('Material Output').inputs['Surface'])
        target=nodes.new('ShaderNodeTexImage');target.image=skin;nodes.active=target
    scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.seed=369;scene.render.bake.use_selected_to_active=False;scene.render.bake.margin=8
    bpy.ops.object.bake(type='EMIT')
    mat=colored_material('Bull_refined_atlas',(1,1,1,1));tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=skin
    uv=mat.node_tree.nodes.new('ShaderNodeUVMap');uv.uv_map='RefinedAtlas';mat.node_tree.links.new(uv.outputs[0],tex.inputs['Vector']);mat.node_tree.links.new(tex.outputs['Color'],mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
    mesh.data.materials.clear();mesh.data.materials.append(mat)
    for face in mesh.data.polygons:face.material_index=0
    skin.filepath_raw=str(out/'bull_skin.png');skin.file_format='PNG';skin.save();skin.pack()
    # Exporter reads the active atlas; keep all previous UV/provenance data.
    mesh.data.uv_layers.active=mesh.data.uv_layers['RefinedAtlas']
    rig.data.pose_position='POSE';rig.animation_data.action=bpy.data.actions['Idle'];scene.frame_set(0)
    assert len(mesh.data.polygons)<=cfg['target_triangles']
    # Measure mirrored new facial surfaces, excluding the retained asymmetric
    # body and the old facial volume nested inside the replacement.
    verts=[v.co.copy() for v in mesh.data.vertices[kept_vertices:]]
    faces=[tuple(i-kept_vertices for i in face.vertices) for face in mesh.data.polygons if all(i>=kept_vertices for i in face.vertices)]
    surface=BVHTree.FromPolygons(verts,faces)
    symmetry=max(surface.find_nearest(Vector((v.x,-v.y,v.z)))[3] for v in verts)
    report={'retained_source_body_vertices':kept_vertices,'refined_old_head_neck_vertices':refined_neck_vertices,'vertices':len(mesh.data.vertices),'triangles':len(mesh.data.polygons),'bones':before_bones,'actions_unchanged':True,'facial_mirrored_surface_max_distance':symmetry}
    (out/'face-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    bpy.ops.wm.save_as_mainfile(filepath=str(out/'bull.blend'))
    camera=scene.camera;camera.data.type='ORTHO';center=Vector((.30,0,.39));camera.data.ortho_scale=.58
    scene.render.resolution_x=1000;scene.render.resolution_y=900;scene.render.resolution_percentage=100
    for name,offset in [('front',(3,0,.08)),('angle',(3,-3,.5)),('side',(0,-3,.12))]:
        camera.location=center+Vector(offset);camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(out/(name+'.png'));bpy.ops.render.render(write_still=True)
    print('CA369 FACE',json.dumps(report))


if __name__=='__main__':main()
