"""Fit retained garment geometry to the first modular character construction rig.

The ordinary Python stage prepares deterministic geometry/UV data. Pinned Blender
4.5.3 retains an editable fitting scene. Native exports are generated separately.
No texture pixels, accepted source files or production equipment owners change.
"""
from pathlib import Path
import argparse
import copy
import hashlib
import json
import math
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/worn_clothing_829'


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def write_json(path,value):path.write_text(json.dumps(value,indent=2)+'\n',encoding='utf-8',newline='\n')


def prepare_geometry(config,out):
    from generate_inventory_clothing_models import geometry as clothing_geometry
    from generate_inventory_consumable_models import geometry as shared_geometry
    result={'issue':829,'garments':{}}
    for category in ['clothing','headwear','footwear']:
        source=ROOT/config['source_catalogues'][category]
        catalogue=json.loads((source/'DESIGN.json').read_text())
        neutral={'tiers':list(catalogue['tier_materials']),'tier_materials':catalogue['tier_materials'],
                 'atlas':{'columns':1,'rows':1,'inset':0,'tiles':{key:[0,0] for key in catalogue['materials']}}}
        for key,variant in catalogue['variants'].items():
            family=copy.deepcopy(catalogue['families'][key]);parts=[]
            if category=='clothing' and key in config['unfolded_ensembles']:
                template=config['unfolded_ensembles'][key]
                family['parts']=[p for p in family['parts'] if not p['part'].startswith('folded_trousers')]
                for part in family['parts']:part['worn_height_offset']=config['body_fit']['folded_display_top_offset']
                for original in catalogue['families'][template]['parts']:
                    if 'trouser' not in original['part']:continue
                    part=copy.deepcopy(original);part['material']=part['material'].replace(template+'_',key+'_')
                    family['parts'].append(part)
            if category=='clothing' and key=='RW':
                expanded=[];fringes=sum(p['part'].startswith('poncho_fringe_') for p in family['parts'])
                for part in family['parts']:
                    if part['part'] in ['poncho','poncho_woven_band']:
                        for label,arc in config['poncho_fit']['panels'].items():
                            panel=copy.deepcopy(part);panel['part']+='_'+label;panel['arc_degrees']=arc
                            rows=[];lifts=[];count=config['poncho_fit']['vertical_subdivisions']
                            for index,(a,b) in enumerate(zip(part['rows'],part['rows'][1:])):
                                for step in range(count):
                                    fraction=step/count;rows.append([u+(v-u)*fraction for u,v in zip(a,b)])
                                    lifts.append(part.get('row_lift',[0]*len(part['rows']))[index]*(1-fraction)+part.get('row_lift',[0]*len(part['rows']))[index+1]*fraction)
                            rows.append(part['rows'][-1]);lifts.append(part.get('row_lift',[0]*len(part['rows']))[-1]);panel['rows']=rows;panel['row_lift']=lifts
                            expanded.append(panel)
                    elif part['part'].startswith('poncho_fringe_'):
                        angle=int(part['part'].rsplit('_',1)[1])*360/fringes
                        if angle>180:angle-=360
                        if any(a<=angle<=b for a,b in config['poncho_fit']['panels'].values()):expanded.append(part)
                    else:expanded.append(part)
                family['parts']=expanded
            for part in family['parts']:
                for name in ['segments','surface_subdivisions','outline_subdivisions']:
                    if name in part:part[name]=min(part[name],config['tessellation']['max_'+name])
            for part in family['parts']:
                if category=='clothing' and 'trouser' in part['part'] and 'patch' not in part['part']:continue
                step=config.get('torso_weight_overrides',{}).get(key,{}).get('max_source_vertical_step')
                if category=='clothing' and part['part']=='outer_coat' and step:
                    part=copy.deepcopy(part);rows=[]
                    for a,b in zip(part['rows'],part['rows'][1:]):
                        count=max(1,math.ceil(abs(b[0]-a[0])/step))
                        rows.extend([[u+(v-u)*i/count for u,v in zip(a,b)] for i in range(count)])
                    rows.append(part['rows'][-1]);part['rows']=rows
                if category=='footwear' and part['kind']=='loft':
                    part=copy.deepcopy(part);rows=[]
                    for a,b in zip(part['rows'],part['rows'][1:]):
                        count=max(1,math.ceil(abs(b[0]-a[0])*config['foot_fit']['height_scale']/config['foot_fit']['max_vertical_step']))
                        rows.extend([[u+(v-u)*step/count for u,v in zip(a,b)] for step in range(count)])
                    rows.append(part['rows'][-1]);part['rows']=rows
                generate=clothing_geometry if category=='clothing' else shared_geometry
                mesh,_=generate(neutral,{'parts':[part],'all_parts':family['parts']},variant['tier'])
                if part.get('normalize_uv',False):
                    lo=[min(uv[i] for uv in mesh.uv) for i in [0,1]];hi=[max(uv[i] for uv in mesh.uv) for i in [0,1]]
                    mesh.uv=[[(uv[i]-lo[i])/max(1e-12,hi[i]-lo[i]) for i in [0,1]] for uv in mesh.uv]
                matrix=part.get('rotation',[[1,0,0],[0,1,0],[0,0,1]]);offset=part.get('offset',[0,0,0]);vertices=[]
                for point in mesh.vertices:
                    transformed=[sum(a*b for a,b in zip(row,point))+offset[i] for i,row in enumerate(matrix)]
                    for wave in part.get('surface_wave',[]):
                        transformed[2]+=wave['amplitude']*math.sin(transformed[wave['axis']]*wave['frequency']+wave.get('phase',0))
                    transformed[2]+=part.get('worn_height_offset',0)
                    vertices.append(transformed)
                settings=catalogue['materials'][part['material']];width,height=settings['image_size'];left,top,right,bottom=settings['rect_pixels']
                uv=[[(left+(right-left)*u)/width,1-(top+(bottom-top)*v)/height] for u,v in mesh.uv]
                parts.append(dict(name=part['part'],material=part['material'],texture=settings['texture'],vertices=vertices,uv=uv,
                                  triangles=[t for _,t in mesh.faces],source_rotation=matrix,source_offset=offset,
                                  attachment_target=part.get('attachment_target'),
                                  rows=[[r[0]+part.get('worn_height_offset',0),*r[1:]] for r in part.get('rows',[])]))
            result['garments'][key]=dict(category=category,item_type=variant['item_type'],parts=parts)
    path=out/'GEOMETRY.json';path.write_text(json.dumps(result,separators=(',',':'))+'\n',encoding='utf-8',newline='\n')


def fit_scene(config,out):
    import bpy
    import bmesh
    from mathutils import Vector,Matrix
    from mathutils.bvhtree import BVHTree
    from mathutils.geometry import barycentric_transform
    assert bpy.app.version==(4,5,3),'Use pinned Blender4.5.3.'
    bpy.ops.wm.open_mainfile(filepath=str(ROOT/config['anatomy_source']))
    scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
    body=bpy.data.objects['CA827 Underbody'];body.data.calc_loop_triangles()
    points=[v.co.copy() for v in body.data.vertices];triangles=[tuple(t.vertices) for t in body.data.loop_triangles]
    tree=BVHTree.FromPolygons(points,triangles,all_triangles=True)
    source_weights=[{body.vertex_groups[g.group].name:g.weight for g in v.groups} for v in body.data.vertices]
    raw=json.loads((out/'GEOMETRY.json').read_text());materials={};objects={}

    def material(texture):
        if texture not in materials:
            result=bpy.data.materials.new('CA829 '+Path(texture).stem);result.use_nodes=True
            node=result.node_tree.nodes.new('ShaderNodeTexImage');node.image=bpy.data.images.load(str(ROOT/'src'/texture),check_existing=True)
            result.node_tree.links.new(node.outputs['Color'],result.node_tree.nodes.get('Principled BSDF').inputs['Base Color'])
            result.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=1
            materials[texture]=result
        return materials[texture]

    def attach(obj,key,texture,weights=None):
        obj['issue']=829;obj['module']=key;obj['texture']=texture
        obj.data.materials.clear();obj.data.materials.append(material(texture))
        if weights is not None:
            groups={name:obj.vertex_groups.new(name=name) for name in rig.data.bones.keys()}
            for i,row in enumerate(weights):
                for name,value in row.items():
                    if value>0:groups[name].add([i],value,'REPLACE')
        modifier=obj.modifiers.new('Retained Domingo actions','ARMATURE');modifier.object=rig
        objects.setdefault(key,[]).append(obj)
        for face in obj.data.polygons:face.use_smooth=True

    def skin_weights(point):
        closest,normal,index,distance=tree.find_nearest(point);assert index is not None
        a,b,c=triangles[index]
        factors=barycentric_transform(closest,points[a],points[b],points[c],Vector((1,0,0)),Vector((0,1,0)),Vector((0,0,1)))
        weights={}
        for vertex,factor in zip([a,b,c],factors):
            for name,value in source_weights[vertex].items():weights[name]=weights.get(name,0)+max(0,factor)*value
        total=sum(weights.values());assert total>0
        return {name:value/total for name,value in weights.items()}

    def interpolate(value,knots):
        if value<=knots[0][0]:a,b=knots[:2]
        elif value>=knots[-1][0]:a,b=knots[-2:]
        else:a,b=next((a,b) for a,b in zip(knots,knots[1:]) if a[0]<=value<=b[0])
        return [u+(value-a[0])*(v-u)/(b[0]-a[0]) for u,v in zip(a[1:],b[1:])]

    catalogue=json.loads((ROOT/config['source_catalogues']['clothing']/'DESIGN.json').read_text())
    footwear=json.loads((ROOT/config['source_catalogues']['footwear']/'DESIGN.json').read_text())
    foot_sections={};foot_envelopes={}

    def fit_foot_envelope(point,key,floor,side):
        """Expand a shared shoe envelope around the retained ankle/calf section."""
        fit=config['foot_fit'];height=point.z
        if height<config['body_fit']['feet_mask_z']-fit['transition_height']:return point
        cache=(key,round(height,6))
        if cache not in foot_envelopes:
            source=next(p for p in footwear['families'][key]['parts'] if p['part']=='left_upper')['rows']
            peak=max(row[0] for row in source);end=next(i for i,row in enumerate(source) if row[0]==peak)
            profile=source[1:end+1];width,length,depth=interpolate(height,fit['horizontal_fit_knots'])
            _,cy,rx,ry=interpolate(height/fit['height_scale']+floor,profile)
            cx=depth-cy*length;radius_x=ry*length;radius_y=rx*width
            section_key=round(height,6)
            if section_key not in foot_sections:
                section=[]
                for triangle in triangles:
                    for first,second in zip(triangle,triangle[1:]+triangle[:1]):
                        a,b=points[first],points[second]
                        if (a.z<=height<b.z) or (b.z<=height<a.z):
                            hit=a+(b-a)*((height-a.z)/(b.z-a.z))
                            if hit.y>0:section.append(hit)
                foot_sections[section_key]=section
            clearance=fit['anatomy_clearance'];factor=1.0
            if radius_x>clearance and radius_y>clearance:
                for hit in foot_sections[section_key]:
                    factor=max(factor,math.hypot((hit.x-cx)/(radius_x-clearance),(hit.y-fit['target_center'])/(radius_y-clearance))/math.cos(math.pi/config['tessellation']['max_segments']))
            blend=max(0,min(1,(height-config['body_fit']['feet_mask_z']+fit['transition_height'])/fit['transition_height']))
            foot_envelopes[cache]=(cx,1+(factor-1)*blend)
        cx,factor=foot_envelopes[cache];cy=side*fit['target_center']
        return Vector((cx+(point.x-cx)*factor,cy+(point.y-cy)*factor,height))

    def trousers(key):
        fit=config['trouser_fit'];bm=bmesh.new();bm.from_mesh(body.data)
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,
                              plane_co=(0,0,fit['waist_z']),plane_no=(0,0,1),clear_outer=True,clear_inner=False)
        bmesh.ops.delete(bm,geom=[v for v in bm.verts if abs(v.co.y)>fit['exclude_arms_y']],context='VERTS')
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,
                              plane_co=(0,0,fit['ankle_source_z']),plane_no=(0,0,1),clear_outer=False,clear_inner=True)
        loose=[v for v in bm.verts if not v.link_faces]
        if loose:bmesh.ops.delete(bm,geom=loose,context='VERTS')
        bmesh.ops.holes_fill(bm,edges=[e for e in bm.edges if e.is_boundary],sides=0)
        bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        deform=bm.verts.layers.deform.active
        if deform:
            for vertex in bm.verts:vertex[deform].clear()
        mesh=bpy.data.meshes.new('CA829 '+key+' tailored trousers');bm.to_mesh(mesh);bm.free()
        weights=[skin_weights(v.co) for v in mesh.vertices]
        knots=fit['country_padding'] if key in fit['country_items'] else fit['straight_padding']
        for vertex in mesh.vertices:
            old=vertex.co.copy();_,normal,_,_=tree.find_nearest(old)
            horizontal=Vector((normal.x,normal.y,0));padding=interpolate(old.z,knots)[0]
            if horizontal.length>1e-6:vertex.co+=horizontal.normalized()*padding
            if old.z<fit['inner_gap_below_z'] and old.y:
                vertex.co.y=math.copysign(max(fit['inner_gap']/2,abs(vertex.co.y)),old.y)
            vertex.co.z=interpolate(old.z,fit['hem_height_knots'])[0]
        mesh.update();settings=catalogue['materials'][key+'_pants'];left,top,right,bottom=settings['rect_pixels'];width,height=settings['image_size']
        uv=mesh.uv_layers.active
        for loop in mesh.loops:
            point=mesh.vertices[loop.vertex_index].co
            u=max(0,min(1,(point.y+fit['uv_half_width'])/(2*fit['uv_half_width'])))
            v=max(0,min(1,(point.z-fit['hem_height_knots'][0][1])/(fit['waist_z']-fit['hem_height_knots'][0][1])))
            uv.data[loop.index].uv=((left+(right-left)*u)/width,1-(top+(bottom-top)*(1-v))/height)
        obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj);attach(obj,key,settings['texture'],weights)
        mesh.calc_loop_triangles();return BVHTree.FromPolygons([v.co for v in mesh.vertices],[t.vertices for t in mesh.loop_triangles],all_triangles=True)

    def torso_weights(point,drape,key):
        fit={**config['torso_weights'],**(config.get('torso_weight_overrides',{}).get(key,{}) if drape else {})};z=point.z
        lower,upper=fit['pelvis_to_spine'];spine=max(0,min(1,(z-lower)/(upper-lower)))
        lower,upper=fit['spine_to_chest'];chest=max(0,min(1,(z-lower)/(upper-lower)))
        weights={'pelvis':1-spine,'spine':spine*(1-chest),'chest':spine*chest}
        low,high=fit['thigh_height'];front=max(0,min(1,(point.x-fit['front_depth'][0])/(fit['front_depth'][1]-fit['front_depth'][0])))
        thigh=fit['thigh_weight']*max(0,min(1,(high-z)/(high-low)))*front if drape else 0
        weights={k:v*(1-thigh) for k,v in weights.items()}
        side=max(0,min(1,(point.y+fit['center_blend_half_width'])/(2*fit['center_blend_half_width'])))
        weights['thigh.L']=thigh*side;weights['thigh.R']=thigh*(1-side)
        return weights

    for key,garment in raw['garments'].items():
        category=garment['category'];floor=min(v[2] for part in garment['parts'] for v in part['vertices'])
        trouser_tree=trousers(key) if category=='clothing' else None
        for part in garment['parts']:
            positions=[]
            for vertex in part['vertices']:
                x,y,z=vertex
                if category=='clothing':
                    fit=config['body_fit']
                    if '_sleeve' in part['name'] or ('_cuff' in part['name'] and 'trouser' not in part['name']):
                        source_x,source_y,*_=interpolate(z,part['rows'])
                        target_z,target_x,target_y=interpolate(z,fit['sleeve_axis'])
                        sign=-1 if part['name'].startswith('left_') else 1
                        point=Vector((target_x-(y-source_y)*fit['sleeve_radius_scale'],sign*target_y+(x-source_x)*fit['sleeve_radius_scale'],target_z))
                    else:
                        width=interpolate(z,fit['poncho_width_knots'])[0] if part['name'].startswith('poncho') else 1
                        point=Vector((-y*fit['depth_scale']+fit['depth_offset'],x*fit['width_scale']*width,interpolate(z,fit['height_knots'])[0]))
                        if not part['name'].startswith('poncho') and 'trouser_patch' not in part['name']:
                            knots=config.get('part_fit_overrides',{}).get(key,{}).get(part['name'],fit['lower_torso_depth_knots'])
                            front,back=interpolate(point.z,knots)
                            point.x=fit['depth_offset']+(point.x-fit['depth_offset'])*(front if point.x>=fit['depth_offset'] else back)
                            width_knots=config.get('part_width_overrides',{}).get(key,{}).get(part['name'])
                            if width_knots:point.y*=interpolate(point.z,width_knots)[0]
                elif category=='headwear':
                    fit={**config['head_fit'],**config.get('head_overrides',{}).get(key,{})}
                    point=Vector((-y*fit['depth_scale']+fit['depth_offset'],x*fit['width_scale'],(z-floor)*fit['height_scale']+fit['base_z']))
                else:
                    fit=config['foot_fit'];side=-1 if part['name'].startswith('left_') else 1
                    local=Matrix(part['source_rotation']).transposed()@(Vector(vertex)-Vector(part['source_offset']))
                    height=(local.z-floor)*fit['height_scale']
                    width,length,depth=interpolate(height,fit['horizontal_fit_knots'])
                    point=Vector((-local.y*length+depth,local.x*width+side*fit['target_center'],height))
                    point=fit_foot_envelope(point,key,floor,side)
                positions.append(point)
            if category=='clothing' and 'trouser_patch' in part['name']:
                depth=min(p.x for p in positions)
                for point in positions:
                    hit,_,_,_=trouser_tree.ray_cast(Vector((100,point.y,point.z)),Vector((-1,0,0)))
                    assert hit is not None,'Trouser patch misses fitted surface.'
                    point.x=hit.x+(point.x-depth)+config['trouser_fit']['patch_clearance']
            mesh=bpy.data.meshes.new('CA829 '+key+' '+part['name']);mesh.from_pydata(positions,[],part['triangles']);mesh.update()
            uv=mesh.uv_layers.new(name='Owned source samples')
            for loop in mesh.loops:uv.data[loop.index].uv=part['uv'][loop.vertex_index]
            bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=config['body_fit']['weld_distance'])
            bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
            obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj)
            arm='_sleeve' in part['name'] or '_cuff' in part['name']
            torso=category=='clothing' and not arm and 'trouser_patch' not in part['name']
            drape=part['name'].startswith('poncho') or part['name']=='outer_coat' or part['attachment_target']=='outer_coat'
            obj['deformation_role']='draped_torso' if torso and drape else 'torso' if torso else 'surface_transfer'
            weights=[{'head':1.0} if category=='headwear' else torso_weights(v.co,drape,key) if torso else skin_weights(v.co) for v in mesh.vertices]
            if torso:assert all(set(row)<=set(config['torso_weights']['allowed_bones']) for row in weights),'Unexpected torso bone.'
            attach(obj,key,part['texture'],weights)
        print('CA829 fitted '+key,flush=True)

    # A selectable boot cannot share opaque calf space with full-length trousers.
    # Keep the same garment identity/material and select only its matching hem.
    for combo in config['combinations']:
        key=combo[0];parts=[obj for obj in objects[key] if 'trouser' in obj.name]
        assert parts,'Missing fitted trousers: '+key
        objects[key]=[obj for obj in objects[key] if obj not in parts]
        bare='pants_'+key+'_bare';objects[bare]=parts
        for obj in parts:obj['module']=bare
        for variant,shoe in config['trouser_hems']['variants'].items():
            if shoe is None:continue
            uppers=[obj for obj in objects[shoe] if obj.name.endswith('_upper')]
            assert uppers,'Missing shoe upper: '+shoe
            cut=max(v.co.z for obj in uppers for v in obj.data.vertices)-config['trouser_hems']['overlap']
            module='pants_'+key+'_'+variant
            for source in parts:
                bm=bmesh.new();bm.from_mesh(source.data)
                bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,
                                      plane_co=(0,0,cut),plane_no=(0,0,1),clear_outer=False,clear_inner=True)
                loose=[v for v in bm.verts if not v.link_faces]
                if loose:bmesh.ops.delete(bm,geom=loose,context='VERTS')
                if not bm.faces:bm.free();continue
                fill=bmesh.ops.holes_fill(bm,edges=[e for e in bm.edges if e.is_boundary],sides=0)
                uv_layer=bm.loops.layers.uv.active;sample=source.data.uv_layers.active.data[0].uv
                for face in fill['faces']:
                    for loop in face.loops:loop[uv_layer].uv=sample
                bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
                mesh=bpy.data.meshes.new(source.name+' '+variant);bm.to_mesh(mesh);bm.free()
                obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj)
                for group in source.vertex_groups:obj.vertex_groups.new(name=group.name)
                obj['deformation_role']='retained_trouser_weights';obj['hem_z']=cut
                attach(obj,module,source['texture'])

    # Cut simple shared planes before classifying regions. Per-face weight
    # thresholds can create branched boundary loops that cannot be capped.
    bm=bmesh.new();bm.from_mesh(body.data);bm.verts.ensure_lookup_table()
    for point,normal in [((0,0,config['body_fit']['neck_mask_z']),(0,0,1)),
                         ((0,0,config['body_fit']['feet_mask_z']),(0,0,1)),
                         ((0,0,config['body_fit']['forearm_mask_z']),(0,0,1)),
                         ((0,config['body_fit']['arm_mask_lateral'],0),(0,1,0)),
                         ((0,-config['body_fit']['arm_mask_lateral'],0),(0,1,0))]:
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,
                              plane_co=point,plane_no=normal,clear_outer=False,clear_inner=False)
    part_layer=bm.faces.layers.int.new('CA829Region')
    for face in bm.faces:
        center=face.calc_center_median()
        face[part_layer]=2 if center.z>=config['body_fit']['neck_mask_z'] else 3 if center.z<config['body_fit']['feet_mask_z'] else (4 if center.z<config['body_fit']['forearm_mask_z'] else 1) if abs(center.y)>config['body_fit']['arm_mask_lateral'] else 0
    for number,key in enumerate(['base_core','base_arms','base_neck','base_feet','base_forearms']):
        clone=bm.copy();tag=clone.faces.layers.int['CA829Region']
        bmesh.ops.delete(clone,geom=[f for f in clone.faces if f[tag]!=number],context='FACES')
        loose=[v for v in clone.verts if not v.link_faces]
        if loose:bmesh.ops.delete(clone,geom=loose,context='VERTS')
        edges=[e for e in clone.edges if e.is_boundary]
        if edges:bmesh.ops.holes_fill(clone,edges=edges,sides=0)
        bmesh.ops.triangulate(clone,faces=list(clone.faces));bmesh.ops.recalc_face_normals(clone,faces=list(clone.faces))
        mesh=bpy.data.meshes.new('CA829 '+key);clone.to_mesh(mesh);clone.free()
        # Barycentric source witnesses let export subdivide the original native
        # surface exactly in each pose, including vertices introduced by cuts.
        for n in ['A','B','C']:mesh.attributes.new('CA829Source'+n,'INT','POINT')
        mesh.attributes.new('CA829SourceBary','FLOAT_VECTOR','POINT')
        indices=[mesh.attributes['CA829Source'+n] for n in ['A','B','C']]
        bary=mesh.attributes['CA829SourceBary']
        for i,v in enumerate(mesh.vertices):
            closest,_,triangle,_=tree.find_nearest(v.co);a,b,c=triangles[triangle]
            factors=barycentric_transform(closest,points[a],points[b],points[c],Vector((1,0,0)),Vector((0,1,0)),Vector((0,0,1)))
            for attribute,index in zip(indices,[a,b,c]):attribute.data[i].value=index
            bary.data[i].vector=factors
        obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj)
        for group in body.vertex_groups:obj.vertex_groups.new(name=group.name)
        sample=body.data.uv_layers.active.data[0].uv
        for loop in mesh.uv_layers.active.data:loop.uv=sample
        attach(obj,key,'models/caelum/characters/domingo/domingo_skin.png')
    bm.free()

    gloves=json.loads((ROOT/config['source_catalogues']['gloves']/'DESIGN.json').read_text())
    for key,options in config['gloves'].items():
        for side in ['Left','Right']:
            source=bpy.data.objects['CA827 '+side+' hand'];mesh=source.data.copy();mesh.name='CA829 '+key+' '+side
            for vertex in mesh.vertices:vertex.co+=vertex.normal*options['offset']
            mesh.update();uv=mesh.uv_layers.active;low=[min(v.co[i] for v in mesh.vertices) for i in range(3)];high=[max(v.co[i] for v in mesh.vertices) for i in range(3)]
            for face in mesh.polygons:
                name=key+'_cloth'
                if key=='GF' and face.center.z>high[2]-2:name='GF_trim'
                if key=='GP' and face.normal.x>0.6 and low[2]+5<face.center.z<high[2]-4:name='GP_patch'
                settings=gloves['materials'][name];left,top,right,bottom=settings['rect_pixels'];width,height=settings['image_size']
                for loop_index in face.loop_indices:
                    point=mesh.vertices[mesh.loops[loop_index].vertex_index].co
                    u=(point.y-low[1])/(high[1]-low[1]);v=(point.z-low[2])/(high[2]-low[2])
                    uv.data[loop_index].uv=((left+(right-left)*u)/width,1-(top+(bottom-top)*(1-v))/height)
            obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj)
            for group in source.vertex_groups:obj.vertex_groups.new(name=group.name)
            attach(obj,key,gloves['materials'][key+'_cloth']['texture'])

    # Caps conceal the crown; retain the original lower hair instead of moving
    # identity or erasing a complete hairstyle whenever headwear is selected.
    for name in ['Long hair L','Long hair R']:
        source=bpy.data.objects[name];mesh=source.data.copy();bm=bmesh.new();bm.from_mesh(mesh)
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=1e-6,
                              plane_co=(0,0,config['head_fit']['base_z']),plane_no=(0,0,1),clear_outer=True,clear_inner=False)
        loose=[v for v in bm.verts if not v.link_faces]
        if loose:bmesh.ops.delete(bm,geom=loose,context='VERTS')
        edges=[e for e in bm.edges if e.is_boundary]
        if edges:bmesh.ops.holes_fill(bm,edges=edges,sides=0)
        bmesh.ops.triangulate(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
        obj=bpy.data.objects.new('CA829 lower '+name,mesh);scene.collection.objects.link(obj)
        for group in source.vertex_groups:obj.vertex_groups.new(name=group.name)
        attach(obj,'hair_lower','models/caelum/characters/domingo/domingo_skin.png')

    report={'issue':829,'config_sha256':digest(out/'DESIGN.json'),'geometry_sha256':digest(out/'GEOMETRY.json'),'authoring_sha256':digest(Path(__file__)),'modules':{}}
    for key,items in objects.items():
        report['modules'][key]=[]
        for obj in items:
            check=bmesh.new();check.from_mesh(obj.data)
            bad=sum(not e.is_manifold for e in check.edges);volume=check.calc_volume(signed=True)
            remaining=set(check.verts);components=[]
            while remaining:
                pending=[remaining.pop()];count=0
                while pending:
                    vertex=pending.pop();count+=1
                    for edge in vertex.link_edges:
                        other=edge.other_vert(vertex)
                        if other in remaining:remaining.remove(other);pending.append(other)
                components.append(count)
            check.free()
            weight_error=max(abs(sum(group.weight for group in v.groups)-1) for v in obj.data.vertices)
            assert weight_error<1e-5,'Unnormalized fitted weights: '+obj.name
            if 'tailored trousers' in obj.name:assert len(components)==1,'Disconnected fitted trousers.'
            report['modules'][key].append(dict(object=obj.name,vertices=len(obj.data.vertices),faces=len(obj.data.polygons),nonmanifold_edges=bad,rest_signed_volume=volume,
                                               connected_components=len(components),component_vertices=sorted(components),max_weight_sum_error=weight_error,
                                               deformation_role=obj.get('deformation_role','retained_anatomy'),
                                               weight_groups=sorted({obj.vertex_groups[g.group].name for v in obj.data.vertices for g in v.groups if g.weight>0}),texture=obj['texture']))
    rig.data.pose_position='POSE';rig.animation_data.action=bpy.data.actions['IdleBreathing'];scene.frame_set(0)
    for obj in scene.objects:
        if obj.type=='MESH':obj.hide_render=obj.get('module') not in ['CS','pants_CS_low','HC','GC','BS','base_forearms','base_neck','hair_lower'] and obj.name not in ['Head','Eye l-eye','Eye r-eye','Pupil -1','Pupil 1']
    # Retain exact owned files inside the editable scene so moving the source
    # from its build folder does not break relative image references.
    known={Path(name).name:ROOT/'src'/name for name in materials}
    known['domingo_skin.png']=ROOT/'assets/source/art/domingo_3d_pilot/domingo_skin.png'
    report['packed_images']={}
    for image in bpy.data.images:
        if image.source!='FILE' or image.users==0:continue
        path=Path(bpy.path.abspath(image.filepath))
        if path.name=='domingo_skin.png':path=known[path.name]
        if not path.is_file():path=known.get(Path(image.filepath).name,path)
        assert path.is_file(),'Missing editable image: '+image.filepath
        image.filepath=str(path);image.reload();image.pack()
        assert hashlib.sha256(image.packed_file.data).hexdigest()==digest(path),'Packing changed image bytes.'
        report['packed_images'][image.name]={'source':path.relative_to(ROOT).as_posix(),'sha256':digest(path)}
    bpy.ops.wm.save_as_mainfile(filepath=str(out/'wardrobe.blend'),compress=True)
    report['editable_sha256']=digest(out/'wardrobe.blend');write_json(out/'AUTHORING.json',report)
    problems=[(k,r['object'],r['nonmanifold_edges']) for k,v in report['modules'].items() for r in v if r['nonmanifold_edges']]
    print(json.dumps({'modules':len(objects),'parts':sum(len(v) for v in objects.values()),'nonmanifold_part_count':len(problems),'first_problems':problems[:5]}),flush=True)


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--blender',type=Path);parser.add_argument('--fit',action='store_true',help=argparse.SUPPRESS)
    argv=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else sys.argv[1:];args=parser.parse_args(argv)
    out=args.output.resolve();out.relative_to(ROOT/'build');config=json.loads(((out if args.fit else ART)/'DESIGN.json').read_text())
    assert digest(ROOT/config['anatomy_source'])==config['anatomy_sha256']
    for name,expected in config['source_sha256'].items():assert digest(ROOT/name)==expected,name
    if args.fit:fit_scene(config,out);return
    if not args.blender:parser.error('--blender must identify pinned Blender4.5.3.')
    out.mkdir(parents=True,exist_ok=False);write_json(out/'DESIGN.json',config);prepare_geometry(config,out)
    subprocess.run([str(args.blender.resolve(strict=True)),'--background','--python-exit-code','1','--python',str(Path(__file__).resolve()),'--','--fit','--output',str(out)],cwd=ROOT,check=True)
    assert (out/'AUTHORING.json').is_file() and (out/'wardrobe.blend').is_file(),'Incomplete Blender authoring output.'


if __name__=='__main__':main()
