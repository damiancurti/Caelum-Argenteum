"""Close the roof-front opening above the retained top-storey door, issue #61."""


def add_roof_closure(obj,spec,report,root,code,modeldefs,editors):
    data=spec['roof_closure']
    door=next(t for t in report['tympana'] if t['group']==data['door_group'])
    assert door['axis']==1, 'The recorded upper door is aligned along map Y.'
    width=door['width'];half=width/2;depth=spec['depth']/2
    base=obj['sector'][data['ceiling_control_sector']]['heightceiling']
    assert obj['sector'][data['ceiling_control_sector']]['heightfloor']==door['top']
    x,y=door['center']
    planes=[obj['sector'][i] for i in data['roof_control_sectors']]
    def roof_height(offset):
        # Both roof planes extend algebraically: their lower envelope is the
        # actual underside of the paired slopes over the central opening.
        return min(-(p['floorplane_a']*x+p['floorplane_b']*(y+offset)+p['floorplane_d'])/p['floorplane_c'] for p in planes)
    contour=[(-half,0),(half,0),(half,roof_height(half)-base),(0,roof_height(0)-base),(-half,roof_height(-half)-base)]
    vertices=[];faces=[]
    def face(points):
        first=len(vertices)+1;vertices.extend(points)
        faces.append(tuple(range(first,first+len(points))))
    for side in (-1,1):
        for i in range(1,len(contour)-1):
            face([(a,b,side*depth) for a,b in (contour[0],contour[i],contour[i+1])])
    for a,b in zip(contour,contour[1:]+contour[:1]):
        face([(a[0],a[1],-depth),(b[0],b[1],-depth),(b[0],b[1],depth),(a[0],a[1],depth)])
    model='ca_mansion_door_gable.obj';name='CaelumMansionDoorGable'
    text=['# Issue #61: original opaque upper-door gable, fitted to native roof planes.']
    text += [f'v {a:.6f} {b:.6f} {c:.6f}' for a,b,c in vertices]
    text += [f'vt {a/data["texture_repeat"]:.6f} {(b+base)/data["texture_repeat"]:.6f}' for a,b,c in vertices]
    text += ['usemtl '+data['material']]
    text += ['f '+' '.join(f'{i}/{i}' for i in face) for face in faces]
    (root/'src/models/caelum/mansion'/model).write_text('\n'.join(text)+'\n',encoding='utf-8')
    obj['thing'].append(dict(x=x,y=y,height=base,angle=90,type=data['editor_number'],skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True,dm=True,comment='Issue #61: closes upper-door roof-front gap'))
    report['roof_closure']=dict(thing=len(obj['thing'])-1,center=[x,y],base=base,width=width,depth=spec['depth'],ridge=roof_height(0),edges=[roof_height(-half),roof_height(half)],model=model)
    code += [f'class {name} : Actor','{','    Default { +NOGRAVITY }','    States { Spawn: CDLS A -1; Stop; }','}']
    modeldefs += [f'Model {name}','{','    Path "models/caelum/mansion"',f'    Model 0 "{model}"',f'    Scale 1 1 {spec["pixel_stretch"]}','    CorrectPixelStretch','    DontCullBackFaces','    FrameIndex CDLS A 0 0','}']
    editors.append(f'    {data["editor_number"]} = {name}')
