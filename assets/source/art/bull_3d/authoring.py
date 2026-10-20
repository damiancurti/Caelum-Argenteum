"""Blender 4.5.3 authoring transcript for the editable #369 bull source.

The saved Blender artwork is an input to the deterministic runtime exporter.
This transcript documents the cleanup/rig construction; it is not a promise of
byte-identical Blender serialization. Use a fresh --output authoring directory.
"""
import argparse
import json
import math
import struct
import sys
from pathlib import Path
import bpy
import bmesh
from mathutils import Vector

HERE=Path(__file__).resolve().parent

def activate(obj):
    bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj

def colored_material(name,color):
    mat=bpy.data.materials.new(name);mat.use_nodes=True
    mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=color
    mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.8
    return mat

def ellipsoid(name,position,radii,material):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,location=position)
    obj=bpy.context.object;obj.name=name;obj.scale=radii;bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    obj.data.materials.append(material)
    for face in obj.data.polygons:face.use_smooth=True
    return obj

def horn(data,side):
    path=[Vector((x,y*side+data['center'][1],z)) for x,y,z in data['horn_path']]
    def point(t):
        at=t*(len(path)-1);i=min(len(path)-2,int(at));u=at-i
        p0=path[max(0,i-1)];p1=path[i];p2=path[i+1];p3=path[min(len(path)-1,i+2)]
        return .5*((2*p1)+(-p0+p2)*u+(2*p0-5*p1+4*p2-p3)*u*u+(-p0+3*p1-3*p2+p3)*u*u*u)
    vertices=[];faces=[];rings=data['horn_rings'];sides=data['horn_sides']
    for ring in range(rings):
        t=ring/rings;center=point(t);direction=(point(min(1,t+.001))-point(max(0,t-.001))).normalized()
        normal=direction.cross(Vector((1,0,0))).normalized();other=direction.cross(normal).normalized()
        radius=data['horn_radius']*(1-t)**.85
        for k in range(sides):vertices.append(center+radius*(normal*math.cos(math.tau*k/sides)+other*math.sin(math.tau*k/sides)))
        if ring:
            for k in range(sides):faces.append(((ring-1)*sides+k,(ring-1)*sides+(k+1)%sides,ring*sides+(k+1)%sides,ring*sides+k))
    tip=len(vertices);vertices.append(path[-1]);faces.append(tuple(reversed(range(sides))))
    for k in range(sides):faces.append(((rings-1)*sides+k,(rings-1)*sides+(k+1)%sides,tip))
    mesh=bpy.data.meshes.new('Rebuilt horn mesh');mesh.from_pydata(vertices,[],faces);mesh.update()
    obj=bpy.data.objects.new('Horn_L' if side>0 else 'Horn_R',mesh);bpy.context.scene.collection.objects.link(obj)
    for ring in range(rings):
        t=ring/(rings-1)
        lo=data['horn_base_color'] if t<.55 else data['horn_mid_color'];hi=data['horn_mid_color'] if t<.55 else data['horn_tip_color'];blend=t/.55 if t<.55 else (t-.55)/.45
        mesh.materials.append(colored_material(obj.name+str(ring),tuple(a*(1-blend)+b*blend for a,b in zip(lo,hi))))
    for face in mesh.polygons:face.use_smooth=True;face.material_index=min(rings-1,face.index//sides)
    return obj

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);out=args.output.resolve();out.mkdir(exist_ok=False,parents=True)
    if bpy.app.version!=(4,5,3):raise RuntimeError('Use Blender 4.5.3.')
    config=json.loads((HERE/'DESIGN.json').read_text(encoding='utf-8'));clean=config['cleanup']
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(HERE/'original.glb'))
    original=next(o for o in bpy.context.scene.objects if o.type=='MESH');original.name='Original_reference'
    activate(original);bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    original.rotation_mode='XYZ';original.rotation_euler.z=math.pi;original.location.z=-config['orientation']['source_floor_z']
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    source_material=original.data.materials[0]
    roles=[{'from':l.from_node.name+':'+l.from_socket.name,'to':l.to_node.name+':'+l.to_socket.name} for l in source_material.node_tree.links]
    (out/'material-links.json').write_text(json.dumps(roles,indent=2)+'\n')
    reference=original;reference.hide_render=True;reference.hide_set(True)
    mesh=reference.copy();mesh.data=reference.data.copy();bpy.context.scene.collection.objects.link(mesh);mesh.name='Bull_surface';mesh.hide_render=False;mesh.hide_set(False)
    activate(mesh)
    mesh.data.remesh_voxel_size=clean['voxel_size'];mesh.data.use_remesh_preserve_volume=True
    bpy.ops.object.voxel_remesh()
    smooth=mesh.modifiers.new('Remove thin generated surface folds','SMOOTH');smooth.factor=clean['smooth_factor'];smooth.iterations=clean['smooth_iterations']
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    original=reference.copy();original.data=reference.data.copy();bpy.context.scene.collection.objects.link(original);original.name='Repaired_bake_source';original.hide_render=False;original.hide_set(False)
    repair=config['head_repair']
    for obj in (original,mesh):
        bm=bmesh.new();bm.from_mesh(obj.data)
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=0.000001)
        cut_z=repair['bake_cut_z'] if obj==original else repair['cut_z']
        bmesh.ops.delete(bm,geom=[v for v in bm.verts if v.co.x>repair['cut_x'] and v.co.z>cut_z],context='VERTS')
        if obj==mesh:
            bmesh.ops.holes_fill(bm,edges=[edge for edge in bm.edges if edge.is_boundary],sides=0)
            bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(obj.data);bm.free()
    skull=ellipsoid('Rebuilt_forehead',repair['center'],repair['radii'],colored_material('Forehead_dark_brown',repair['color']))
    target_skull=skull.copy();target_skull.data=skull.data.copy();bpy.context.scene.collection.objects.link(target_skull)
    activate(mesh);target_skull.select_set(True);bpy.ops.object.join()
    activate(original);skull.select_set(True);bpy.ops.object.join()
    details=[]
    for side in (-1,1):
        details.append(horn(repair,side))
        x,y,z=repair['eye_position']
        details.append(ellipsoid('Eye_'+str(side),(x,repair['center'][1]+y*side,z),repair['eye_radii'],colored_material('Eye_dark_brown_'+str(side),repair['eye_color'])))
    detail_triangles=0
    for obj in details:obj.data.calc_loop_triangles();detail_triangles+=len(obj.data.loop_triangles)
    activate(mesh)
    mesh.data.remesh_voxel_size=clean['voxel_size'];mesh.data.use_remesh_preserve_volume=True
    bpy.ops.object.voxel_remesh()
    print('CA369 remesh',len(mesh.data.vertices),len(mesh.data.polygons))
    smooth=mesh.modifiers.new('Blend the repaired forehead','SMOOTH');smooth.factor=clean['smooth_factor'];smooth.iterations=4
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    group=mesh.vertex_groups.new(name='Forehead transition')
    for vertex in mesh.data.vertices:
        weight=min(1,max(0,(vertex.co.x-.18)/.09))*min(1,max(0,(vertex.co.z-.16)/.08))
        if weight:group.add([vertex.index],weight,'REPLACE')
    smooth=mesh.modifiers.new('Soften the rebuilt transition','SMOOTH');smooth.factor=1;smooth.iterations=20;smooth.vertex_group=group.name
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    mesh.data.calc_loop_triangles();before=len(mesh.data.loop_triangles)
    print('CA369 budget',before,detail_triangles)
    reduce=mesh.modifiers.new('Runtime surface budget','DECIMATE');reduce.ratio=min(1,max(1000,clean['target_triangles']-detail_triangles)/before)
    bpy.ops.object.modifier_apply(modifier=reduce.name)
    mesh.data.attributes.new('bake_region','INT','FACE')
    activate(mesh)
    for index,detail in enumerate(details,1):
        copy=detail.copy();copy.data=detail.data.copy();bpy.context.scene.collection.objects.link(copy);copy.select_set(True)
        region=copy.data.attributes.new('bake_region','INT','FACE')
        for item in region.data:item.value=index
    bpy.ops.object.join()
    triangulate=mesh.modifiers.new('Stable export topology','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=triangulate.name)
    for face in mesh.data.polygons:face.use_smooth=True
    # A fresh atlas avoids distorted source seams after topology cleanup.
    bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(angle_limit=math.radians(66),island_margin=0.012);bpy.ops.object.mode_set(mode='OBJECT')
    material=bpy.data.materials.new('Bull_clean_albedo');material.use_nodes=True;mesh.data.materials.clear();mesh.data.materials.append(material)
    skin=bpy.data.images.new('Bull_albedo',width=clean['bake_size'],height=clean['bake_size'],alpha=False)
    skin.colorspace_settings.name='sRGB'
    tex=material.node_tree.nodes.new('ShaderNodeTexImage');tex.image=skin;material.node_tree.nodes.active=tex
    material.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.8
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=clean['bake_samples'];scene.cycles.seed=369
    scene.render.bake.use_selected_to_active=True;scene.render.bake.cage_extrusion=clean['bake_cage'];scene.render.bake.max_ray_distance=.08;scene.render.bake.margin=12
    scene.render.bake.use_pass_direct=False;scene.render.bake.use_pass_indirect=False;scene.render.bake.use_pass_color=True
    # Emission baking transfers the original base color without lighting or
    # metallic/roughness response. The second embedded image is not a normal map.
    source_objects=[original]+details;restore=[]
    for obj in source_objects:
        for index,mat in enumerate(obj.data.materials):
            restore.append((obj,index,mat))
            base=mat.node_tree.nodes['Principled BSDF'].inputs['Base Color']
            bake_material=bpy.data.materials.new(mat.name+'_transfer');bake_material.use_nodes=True;bake_material.node_tree.nodes.clear()
            baked_output=bake_material.node_tree.nodes.new('ShaderNodeOutputMaterial');emission=bake_material.node_tree.nodes.new('ShaderNodeEmission')
            if base.is_linked:
                source_texture=bake_material.node_tree.nodes.new('ShaderNodeTexImage');source_texture.image=base.links[0].from_node.image
                bake_material.node_tree.links.new(source_texture.outputs['Color'],emission.inputs['Color'])
            else:emission.inputs['Color'].default_value=base.default_value
            if obj==original:
                nodes=bake_material.node_tree.nodes;links=bake_material.node_tree.links
                geometry=nodes.new('ShaderNodeNewGeometry');noise=nodes.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=36;noise.inputs['Detail'].default_value=2
                links.new(geometry.outputs['Position'],noise.inputs['Vector'])
                ramp=nodes.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].color=(.003,.002,.001,1);ramp.color_ramp.elements[1].color=(.014,.009,.005,1);links.new(noise.outputs['Fac'],ramp.inputs[0])
                if mat.name.startswith('Forehead_'):links.new(ramp.outputs['Color'],emission.inputs['Color'])
                else:
                    split=nodes.new('ShaderNodeSeparateXYZ');links.new(geometry.outputs['Position'],split.inputs[0])
                    masks=[]
                    for axis,low,high in [('X',.20,.31),('Z',.26,.35)]:
                        remap=nodes.new('ShaderNodeMapRange');remap.clamp=True;remap.interpolation_type='SMOOTHSTEP';remap.inputs['From Min'].default_value=low;remap.inputs['From Max'].default_value=high;links.new(split.outputs[axis],remap.inputs['Value']);masks.append(remap)
                    product=nodes.new('ShaderNodeMath');product.operation='MULTIPLY';links.new(masks[0].outputs[0],product.inputs[0]);links.new(masks[1].outputs[0],product.inputs[1])
                    mix=nodes.new('ShaderNodeMixRGB');links.new(product.outputs[0],mix.inputs[0]);links.new(emission.inputs['Color'].links[0].from_socket,mix.inputs[1]);links.new(ramp.outputs['Color'],mix.inputs[2]);links.new(mix.outputs[0],emission.inputs['Color'])
            bake_material.node_tree.links.new(emission.outputs[0],baked_output.inputs['Surface']);obj.data.materials[index]=bake_material
    # Bake each disconnected component against its matching source so the
    # horns cannot project ivory-colored patches onto the dark forehead.
    mesh.hide_render=True;mesh.hide_set(True)
    for index,source in enumerate(source_objects):
        part=mesh.copy();part.data=mesh.data.copy();bpy.context.scene.collection.objects.link(part);part.name='Bake_part_'+str(index);part.hide_render=False;part.hide_set(False)
        bm=bmesh.new();bm.from_mesh(part.data);layer=bm.faces.layers.int['bake_region']
        bmesh.ops.delete(bm,geom=[face for face in bm.faces if face[layer]!=index],context='FACES')
        bm.to_mesh(part.data);bm.free()
        for obj in source_objects:obj.hide_render=True;obj.hide_set(True)
        source.hide_render=False;source.hide_set(False);activate(part);source.select_set(True)
        scene.render.bake.use_clear=index==0
        bpy.ops.object.bake(type='EMIT')
        part.hide_render=True;part.hide_set(True)
    mesh.hide_render=False;mesh.hide_set(False)
    for obj,index,mat in restore:obj.data.materials[index]=mat
    material.node_tree.links.new(tex.outputs['Color'],material.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
    skin.filepath_raw=str(out/'bull_skin.png');skin.file_format='PNG';skin.save();skin.pack()
    for obj in source_objects:obj.hide_render=True;obj.hide_set(True)
    # The neutral source is recorded before animation for inspection.
    mesh.data.calc_loop_triangles()
    report={'source_vertices':len(reference.data.vertices),'source_triangles':len(reference.data.polygons),
        'clean_vertices':len(mesh.data.vertices),'clean_triangles':len(mesh.data.loop_triangles),
        'cleanup':clean,'bounds':[[min(v.co[i] for v in mesh.data.vertices) for i in range(3)],[max(v.co[i] for v in mesh.data.vertices) for i in range(3)]]}
    (out/'cleanup.json').write_text(json.dumps(report,indent=2)+'\n')
    # Initial cleanup review precedes rigging; later transcript revisions retain
    # this mesh and image as the editable authoring source.
    scene.world=bpy.data.worlds.new('Review world');scene.world.use_nodes=True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.07,.07,.07,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value=.7
    center=Vector((0,0,.31))
    for name,offset,power in [('key',(1,-2,3),900),('fill',(-2,1,2),700)]:
        data=bpy.data.lights.new(name,'AREA');data.energy=power;data.size=2
        lamp=bpy.data.objects.new(name,data);scene.collection.objects.link(lamp);lamp.location=center+Vector(offset);lamp.rotation_euler=(center-lamp.location).to_track_quat('-Z','Y').to_euler()
    camera=bpy.data.objects.new('Review camera',bpy.data.cameras.new('Camera'));scene.collection.objects.link(camera);scene.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=1.3
    scene.render.resolution_x=900;scene.render.resolution_y=700;scene.render.resolution_percentage=100
    for name,offset in [('angle',(2,-3,1.3)),('side',(0,-3,.3)),('front',(3,0,.3))]:
        camera.location=center+Vector(offset);camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(out/(name+'.png'));bpy.ops.render.render(write_still=True)
    activate(mesh);bpy.ops.wm.save_as_mainfile(filepath=str(out/'bull-clean.blend'))
    print('CA369 CLEANUP',json.dumps(report))

if __name__=='__main__':main()
