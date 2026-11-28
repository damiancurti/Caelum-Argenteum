"""Build modular player bodies from the approved #736 plates and retained identity art."""
import io
import json
import re
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

from character_mesh_frames import ROOT, Surface, animate, encode, read_model, rigid_track, subset
from reconstruct_actor_mesh import shape_and_skin, silhouette
from generate_appearance_details import atlas, skin_mask
from generate_modular_appearance import tone_image

SRC=ROOT/"src"
OUT=SRC/"models/caelum/players"
ART=ROOT/"assets/source/art/modular_proposals_736"
DETAIL=SRC/"graphics/caelum/appearance/details"
CAT=json.loads((ROOT/"assets/generators/appearance_catalog.json").read_text("utf8"))
FAMILIES=["human","caelith","goblin","wolf","bear","puma","jaguar"]
REL="models/caelum/players/"


def write(name,data):
    (OUT/name).write_bytes(data)


def png(image):
    b=io.BytesIO();image.save(b,'PNG');return b.getvalue()


def board_views(family,sex):
    record=json.loads((ART/'REVIEW.json').read_text('utf8'))
    source=np.asarray(Image.open(ART/record['selected'][family]).convert('RGB'))
    h,w,_=source.shape
    views={}
    for angle,(left,right) in zip([0,90,180],[(.165,.355),(.415,.575),(.635,.815)]):
        top,bottom=(.052,.476) if sex==0 else (.502,.944)
        crop=source[round(h*top):round(h*bottom),round(w*left):round(w*right)].copy()
        # Local grey sweep estimated independently on each scanline.
        edges=np.concatenate([crop[:,:5],crop[:,-5:]],axis=1)
        bg=ndimage.median_filter(np.median(edges,axis=1),size=(13,1))
        d=crop.astype('f')-bg[:,None,:]
        chroma=np.ptp(d,axis=2)
        mask=(np.linalg.norm(d,axis=2)>33)&((chroma>8)|(np.min(d,axis=2)<-45))
        lab,n=ndimage.label(ndimage.binary_closing(mask,iterations=2))
        sizes=np.bincount(lab.ravel());sizes[0]=0
        mask=lab==sizes.argmax()
        # Keep enclosed garment highlights; gaps between arms and the waist stay open.
        holes=ndimage.binary_fill_holes(mask)^mask
        ids,_=ndimage.label(holes)
        counts=np.bincount(ids.ravel())
        mask|=holes&(counts[ids]<200)
        im=Image.fromarray(np.dstack([crop,mask.astype('uint8')*255]))
        views[angle]=silhouette(im)
    views[270]=views[90].transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    return views


def rustic(image,colors=36):
    # Large value groups with preserved hue suit the angular low-poly surfaces.
    rgb=image.convert('RGB').filter(ImageFilter.MedianFilter(3))
    size=(max(8,round(rgb.width*.63)),max(8,round(rgb.height*.63)))
    small=rgb.resize(size,Image.Resampling.LANCZOS)
    toned=small.quantize(colors=colors,dither=Image.Dither.NONE).convert('RGB')
    return toned.resize(rgb.size,Image.Resampling.NEAREST)


def views_for(pattern):
    return {i*45:Image.open(str(pattern).format(i)).convert('RGBA') for i in range(8)}


def reshape_body(points,sex,family,height):
    x,y,z=points.T
    s=z/height
    bump=lambda center,width:np.exp(-((s-center)/width)**2)
    core=np.clip((.19*height-np.abs(y))/(.055*height),0,1)
    if sex==0:
        width=1+.15*bump(.78,.10)+.10*bump(.55,.17)
        depth=1+.13*bump(.72,.16)
        if family=='bear':
            width+=.13*bump(.77,.17)
            depth+=.14*bump(.73,.20)
    else:
        width=1+core*(.16*bump(.49,.09)-.12*bump(.62,.07))+.04*bump(.75,.07)
        depth=1+core*(.10*bump(.49,.11)+.08*bump(.74,.06)-.06*bump(.61,.06))
    points[:,0]=x*depth
    points[:,1]=y*width
    # Narrow the extremities around their local centers, retaining wrist and ankle joins.
    foot=bump(.055,.064)
    points[:,0]*=1-.10*foot
    hand=bump(.47,.072)*(1-core)
    points[:,1]-=np.sign(y)*(.018*height)*hand
    return points


def source_texture(data):
    with Image.open(io.BytesIO(data)) as image:
        return image.convert('RGB')


def body(index,family,sex,views,height):
    shader=REL+f'b{index}.png'
    raw,image,_=shape_and_skin(views,height,shader,'approved body '+str(index),max_faces=4800)
    write(f'b{index}.png',png(rustic(source_texture(image),80)))
    pieces={k:[] for k in ('shirt','trousers','belt','boots','gloves')}
    for s in read_model(raw):
        p=reshape_body(s.positions[0].copy(),sex,family,height)
        s.positions=p[None]
        center=p[s.faces].mean(axis=1)/height
        side=np.abs(center[:,1]);z=center[:,2]
        # Separate complete surfaces for the default outfit and hand attachments.
        garment=np.full(len(z),'shirt',dtype='U10')
        garment[z<.561]='trousers'
        garment[(z>=.548)&(z<.575)&(side<.133)]='belt'
        garment[z<.237]='boots'
        garment[(side>.134)&(z>.389)&(z<.599)]='gloves'
        garment[z>(.837 if family in FAMILIES[:3] else .816)]=''
        for name,parts in pieces.items():
            piece=subset(s,garment==name)
            if piece is None:continue
            piece.positions=animate(piece.positions[0])
            parts.append(piece)
    for name,parts in pieces.items():
        if not parts:raise ValueError(f'Missing {family}/{sex}/{name}')
        write(f'b{index}_{name}.md3',encode(name,parts))
    # Supply actual skin/fur hands with separate left and right meshes. Their exported
    # joints and wrist movement come from the accepted rig.
    hands=[]
    for name in ('left_hand','right_hand'):
        for s in read_model((SRC/f'models/caelum/characters/domingo/{name}.md3').read_bytes()):
            p=s.positions[0].copy();center=p.mean(axis=0)
            p=(p-center)*np.array([.92,.94,.96])+center
            p[:,1]*=(1.03 if sex==0 else .96)
            s.positions=rigid_track(p,name);s.shader=REL+'hskin0.png';hands.append(s)
    write(f'b{index}_hands.md3',encode('bare hands',hands))


def head_module(key,views,height,top,shader,rig,faces):
    output,atlas,_=shape_and_skin(views,height,REL+shader,key,max_faces=faces)
    parts=read_model(output)
    for s in parts:
        coords=s.positions[0].copy()
        coords[:,2]+=top-max(part.positions[0,:,2].max() for part in parts)
        if rig=='hair':
            coords[:,0]*=1.23
            coords[:,1]*=1.19
        # Hair hangs around the head instead of filling the face with an opaque cap.
        if rig=='hair':
            s.faces=s.faces[~((coords[s.faces].mean(axis=1)[:,0]>0)&
                        (coords[s.faces].mean(axis=1)[:,2]<top-.29*height)&
                        (abs(coords[s.faces].mean(axis=1)[:,1])<.27*height))]
        s.positions=rigid_track(coords,'face')
    return encode(key,parts),rustic(source_texture(atlas),32)


def make_heads(index,family,sex,views,height):
    if index>=6:
        # Use the actual male and female animal head from the approved turnaround.
        headviews={a:im.crop((0,0,im.width,round(im.height*.21))) for a,im in views.items()}
        name=f'head{index}_0'
        geo,texture=head_module(name,headviews,.215*height,height,name+'_0.png','face',1600)
        write(name+'.md3',geo)
        for tone,mult in enumerate(CAT['fur_multipliers']):
            rgb=np.asarray(texture)*np.array(mult)
            write(f'{name}_{tone}.png',png(Image.fromarray(np.uint8(np.clip(rgb,0,255)))))
        return
    for face in range(4):
        name=f'head{index}_{face}'
        for tone in range(3):
            kind=CAT['heads'][index]['color_kind']
            cells=atlas(CAT['heads'][index]['faces_source'])
            src={v*45:tone_image(cells[face*8+v],skin_mask(cells[face*8+v],kind),kind,tone) for v in range(8)}
            geo,texture=head_module(name,src,.167*height,height-1.9,f'{name}_0.png','face',1280)
            if tone==0:write(name+'.md3',geo)
            write(f'{name}_{tone}.png',png(texture))
    for hair in range(4):
        name=f'hair{index}_{hair}'
        src=views_for(DETAIL/'hair'/f'{index}_{hair}_{{}}_0.png')
        # Use measured hair-to-face height in the shared source registration.
        face=views_for(DETAIL/'face'/f'{index}_0_0_{{}}_0.png')
        ratio=silhouette(src[0]).height/silhouette(face[0]).height
        mesh,texture=head_module(name,src,.167*height*ratio,height,name+'_0.png','hair',1150)
        write(name+'.md3',mesh)
        value=np.asarray(texture.convert('L')).astype('f')/255.
        for i,color in enumerate(CAT['hair_colors']):
            rgb=np.uint8(np.clip((.22+value[:,:,None]*1.00)*np.asarray(color['rgb']),0,255))
            write(f'{name}_{i}.png',png(Image.fromarray(rgb)))


def main():
    OUT.mkdir(exist_ok=True,parents=True)
    registry=(SRC/'caelum/character/CaelumAppearanceRegistry.zs').read_text('utf8')
    heights=[int(v) for v in re.search(r'heights\[\] = \{([^}]+)',registry)[1].split(',')]
    for i,(family,sex) in enumerate((f,s) for f in FAMILIES for s in (0,1)):
        views=board_views(family,sex)
        height=heights[i*2]
        body(i,family,sex,views,height)
        make_heads(i,family,sex,views,height)
        print(i,family,sex,flush=True)
    fur=[np.uint8(np.clip(np.asarray(base)*mult,0,255)).tolist() for base in CAT['world_fur_hand_tones'] for mult in CAT['fur_multipliers']]
    for tone,c in enumerate(CAT['skin_tones']+CAT['caelith_tones']+fur):
        write('hskin'+str(tone)+'.png',png(Image.new('RGB',(8,8),tuple(c))))


    blank=Surface(np.zeros((1,3,3)),np.array([[0,1,2]]),np.zeros((3,2)),REL+'invisible.png')
    write('conceal.md3',encode('head sprite bridge',[blank]))
    write('invisible.png',png(Image.new('RGBA',(2,2))))

if __name__=='__main__':
    main()
