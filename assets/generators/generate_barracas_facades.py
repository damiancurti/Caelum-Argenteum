"""Build geometric facade details using existing owned city textures (#454).

Widths, window bands, spacing and doors come from the retained city profiles;
trim depth comes from the native door thickness. No raster artwork is edited.
The caller owns output packaging and static actor/editor bindings.
"""
from pathlib import Path
from generate_environment_models import Mesh

TEXTURES='graphics/caelum/textures/entornos_v1/ciudad/'

def build(path:Path,width,height,profile,detail,depth,door_y):
    mesh=Mesh(path.stem)
    def face(material,points):
        mesh.add_polygon(material,[(x,z,-y) for x,y,z in points],[(0,1),(1,1),(1,0),(0,0)])
    def box(material,x1,y1,z1,x2,y2,z2):
        for points in [
            [(x1,y1,z1),(x2,y1,z1),(x2,y1,z2),(x1,y1,z2)],
            [(x2,y2,z1),(x1,y2,z1),(x1,y2,z2),(x2,y2,z2)],
            [(x1,y2,z1),(x1,y1,z1),(x1,y1,z2),(x1,y2,z2)],
            [(x2,y1,z1),(x2,y2,z1),(x2,y2,z2),(x2,y1,z2)],
            [(x1,y1,z2),(x2,y1,z2),(x2,y2,z2),(x1,y2,z2)],
            [(x1,y2,z1),(x2,y2,z1),(x2,y1,z1),(x1,y1,z1)]]:face(material,points)
    wood=TEXTURES+'CVCI05.png';stone=TEXTURES+'CVCI01.png'
    window=detail['window_width'];step=detail['window_step'];low=profile['window_sill'];high=profile['window_head']
    def panel(axis,cross,along,w,bottom,top,outward):
        outer=cross+outward*depth;surface=cross+outward*depth/2
        if axis=='x':
            face(wood,[(surface,along-w/2,bottom),(surface,along+w/2,bottom),(surface,along+w/2,top),(surface,along-w/2,top)])
            for a,b,c,d in [(along-w/2-depth,bottom-depth,along-w/2,top+depth),(along+w/2,bottom-depth,along+w/2+depth,top+depth),
                            (along-w/2,bottom-depth,along+w/2,bottom),(along-w/2,top,along+w/2,top+depth)]:
                box(stone,min(cross,outer),a,b,max(cross,outer),c,d)
        else:
            face(wood,[(along-w/2,surface,bottom),(along+w/2,surface,bottom),(along+w/2,surface,top),(along-w/2,surface,top)])
            for a,b,c,d in [(along-w/2-depth,bottom-depth,along-w/2,top+depth),(along+w/2,bottom-depth,along+w/2+depth,top+depth),
                            (along-w/2,bottom-depth,along+w/2,bottom),(along-w/2,top,along+w/2,top+depth)]:
                box(stone,a,min(cross,outer),b,c,max(cross,outer),d)
    for y in range(step,height-step//2,step):
        panel('x',-width/2,y-height/2,window,low,high,-1)
        if abs(y-door_y)>profile['door_width']/2+window/2+depth:
            panel('x',width/2,y-height/2,window,low,high,1)
    for x in range(step,width-step//2,step):
        for sign in (-1,1):panel('y',sign*height/2,x-width/2,window,low,high,sign)
    # Retained house portals supply operational doors later; this fixed visual
    # marks only the architectural preview's opaque shell.
    panel('x',width/2,door_y-height/2,profile['door_width'],0,profile.get('door_height',profile['headroom']),1)
    top=profile['height'];trim=detail['foundation_height']
    for a,b,c,d in [(-width/2-depth,-height/2-depth,width/2+depth,-height/2),
                    (-width/2-depth,height/2,width/2+depth,height/2+depth),
                    (-width/2-depth,-height/2,-width/2,height/2),
                    (width/2,-height/2,width/2+depth,height/2)]:
        box(stone,a,b,top-trim,c,d,top)
    path.parent.mkdir(parents=True,exist_ok=True);mesh.write(path)
    return {'vertices':len(mesh.vertices),'faces':len(mesh.faces)}
