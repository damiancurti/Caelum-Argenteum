"""Native walkable mound, short underground tunnel and resource-free gem art."""
from copy import deepcopy
import math


def add_cave(obj,spec,report,root):
    vertices,lines,sides,sectors=(obj[k] for k in ('vertex','linedef','sidedef','sector'))
    before={k:len(v) for k,v in obj.items()}
    ox,oy=spec['origin'];angle=math.radians(spec['angle']);co,si=math.cos(angle),math.sin(angle)
    def world(u,v):return round(ox+co*u-si*v,6),round(oy+si*u+co*v,6)
    def contains(rect,u,v):
        a,b,c,d=rect
        return a<=u<c and b<=v<d
    outer=next(c['sector'] for c in report['exterior_partition']['cells'] if contains(c['bounds'],ox,oy))
    outer_bounds=next(c['bounds'] for c in report['exterior_partition']['cells'] if c['sector']==outer)
    base=deepcopy(sectors[outer]);step=spec['grid'];u0,v0,u1,v1=spec['bounds']
    def surface(u,v):
        a,b,c,d=spec['mound_core']
        dist=math.hypot(max(a-u,0,u-c),max(b-v,0,v-d))
        t=max(0,1-dist/spec['mound_blend']);fade=t*t*(3-2*t)
        return round(fade*(spec['mound_height']+spec['mound_variation']*math.sin(u/step)*math.cos(v/step)),6)
    def floor(u):return -spec['depth']*min(1,max(0,u/spec['descent_length']))
    def plane(points):
        p,q,r=points;det=(q[0]-p[0])*(r[1]-p[1])-(r[0]-p[0])*(q[1]-p[1])
        gx=((q[2]-p[2])*(r[1]-p[1])-(r[2]-p[2])*(q[1]-p[1]))/det
        gy=((q[0]-p[0])*(r[2]-p[2])-(r[0]-p[0])*(q[2]-p[2]))/det
        length=math.sqrt(gx*gx+gy*gy+1)
        return [value/length for value in (-gx,-gy,1,gx*p[0]+gy*p[1]-p[2])]
    ids={};edges={};triangles=[];controls=[]
    for u in range(u0,u1+step,step):
        for v in range(v0,v1+step,step):
            x,y=world(u,v)
            assert contains(outer_bounds,x,y), 'Cave layout must remain inside its exterior cell'
            ids[u,v]=len(vertices);vertices.append(dict(x=x,y=y))
    for u in range(u0,u1,step):
        for v in range(v0,v1,step):
            cave=any(contains(r,u+step/2,v+step/2) for r in spec['tunnel_rectangles'])
            approach=contains(spec['approach'],u+step/2,v+step/2)
            a,b,c,d=(u,v),(u,v+step),(u+step,v+step),(u+step,v)
            for tri in ((a,b,c),(a,c,d)):
                sid=len(sectors);sector=deepcopy(base)
                sector.update(lightlevel=spec['outside_light'],comment='Issue #61: decorative cave '+('tunnel' if cave else 'approach' if approach else 'mound'))
                bottom=[floor(p[0]) if cave else 0 if approach else surface(*p) for p in tri]
                fp=plane([(*world(*p),h) for p,h in zip(tri,bottom)])
                sector.update({f'floorplane_{k}':val for k,val in zip('abcd',fp)})
                sector['texturefloor']=spec['rock_texture'] if cave or approach else spec['grass_texture']
                if cave:
                    tag=spec['first_roof_tag']+len(controls)
                    assert not any(s.get('id')==tag or str(tag) in s.get('moreids','').split() for s in sectors)
                    sector['id']=tag
                    top=plane([(*world(*p),surface(*p)) for p in tri])
                    controls.append(dict(target=sid,tag=tag,top=top))
                sectors.append(sector)
                triangles.append(dict(sector=sid,kind='tunnel' if cave else 'approach' if approach else 'mound',vertices=[ids[p] for p in tri],local=[list(p) for p in tri],floor=bottom))
                for p,q in zip(tri,tri[1:]+tri[:1]):
                    va,vb=ids[p],ids[q];sd=len(sides)
                    sides.append(dict(sector=sid,texturebottom=spec['rock_texture'],texturetop=spec['rock_texture']))
                    if (vb,va) in edges:lines[edges[vb,va]].update(sideback=sd,twosided=True)
                    else:
                        edges[va,vb]=len(lines);lines.append(dict(v1=va,v2=vb,sidefront=sd))
    for li in edges.values():
        if 'sideback' not in lines[li]:
            lines[li].update(sideback=len(sides),twosided=True);sides.append(dict(sector=outer))
    # Control polygons are disconnected, outside the playable horizon. Their
    # native 3D floors provide both the underground roof and walkable grass above.
    for i,control in enumerate(controls):
        cs=len(sectors);sector=dict(heightfloor=spec['roof_underside'],heightceiling=spec['mound_height'],texturefloor=spec['rock_texture'],textureceiling=spec['grass_texture'],lightlevel=spec['inside_light'],comment='Issue #61: solid cave roof control')
        sector.update({f'ceilingplane_{k}':-val for k,val in zip('abcd',control['top'])})
        sectors.append(sector)
        x=spec['control_origin'][0]+i*spec['control_spacing'];y=spec['control_origin'][1];s=spec['control_size']
        vi=len(vertices);vertices.extend(dict(x=a,y=b) for a,b in ((x,y),(x,y+s),(x+s,y+s),(x+s,y)))
        for j in range(4):
            sd=len(sides);sides.append(dict(sector=cs,texturemiddle=spec['rock_texture']))
            line=dict(v1=vi+j,v2=vi+(j+1)%4,sidefront=sd,blocking=True)
            if j==0:line.update(special=160,arg0=control['tag'],arg1=1,arg3=255)
            lines.append(line)
        control['sector']=cs
    code=['// Gemas decorativas: Actor puro, sin recursos, inventario ni extracción.']
    modeldefs=[];editors=[];gems=[]
    for i,g in enumerate(spec['gems']):
        name='CaelumCaveScenery'+g['kind'];frame=g['frame'];ed=spec['first_editor_number']+i
        code += [f'class {name} : Actor','{','    Default { +NOGRAVITY }',f'    States {{ Spawn: CAVE {frame} -1; Stop; }}','}']
        modeldefs += [f'Model {name}','{','    Path "models/caelum/world/resources"',f'    Model 0 "ca_vein_{g["model"]}.obj"',f'    Scale {spec["gem_scale"]} {spec["gem_scale"]} {spec["gem_scale"]}','    CorrectPixelStretch','    DontCullBackFaces',f'    FrameIndex CAVE {frame} 0 0','}']
        editors.append(f'    {ed} = {name}')
        x,y=world(*g['position']);index=len(obj['thing'])
        obj['thing'].append(dict(x=x,y=y,height=0,type=ed,angle=g['angle'],skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True,dm=True,comment='Issue #61: decorative gem; no resources'))
        gems.append(dict(thing=index,classname=name,position=[x,y,floor(g['position'][0])]))
    (root/'src/caelum/world/CaelumDecorativeCave.zs').write_text('\n'.join(code)+'\n',encoding='utf-8')
    for filename,content in [('MODELDEF',modeldefs),('MAPINFO',editors)]:
        path=root/'src'/filename;text=path.read_text(encoding='utf-8')
        start='// BEGIN GENERATED DECORATIVE CAVE';end='// END GENERATED DECORATIVE CAVE';block=start+'\n'+'\n'.join(content)+'\n'+end
        if start in text:
            first=text.index(start);last=text.index(end,first)+len(end);text=text[:first]+block+text[last:]
        elif filename=='MAPINFO':
            at=text.rfind('}');text=text[:at]+block+'\n'+text[at:]
        else:text+='\n'+block+'\n'
        path.write_text(text,encoding='utf-8')
    report['cave']=dict(before=before,outer_sector=outer,triangles=triangles,controls=controls,gems=gems,walk_route=[[*world(u,v),floor(u)] for u,v in spec['walk_route']],views=[dict(view,world=[*world(*view['position'][:2]),view['position'][2]],yaw=spec['angle']+view['angle']) for view in spec['views']])
