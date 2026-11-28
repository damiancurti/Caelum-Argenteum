"""Model the brim, skullcap and open helm, and paint their three metal finishes."""
from functools import lru_cache
from io import BytesIO
from math import cos, sin, pi

import numpy as np
from PIL import Image

from sculpted_character_art import MATERIALS, Sculpt, paint
from wearable_helmet_fit import INNER_DEPTH, INNER_WIDTH

ANGLES = np.arange(40) * 2*pi/40
# Styled parts share UVs between tiers. The three trim channels distinguish
# primary inlay, wider secondary fittings, and studs or edging.
SILVER = ((62, 77, 94), (201, 215, 227), (255, 255, 255))
GOLD = ((102, 58, 25), (230, 170, 66), (255, 245, 185))


def strip(model, material, rings):
    """Join the ring surfaces without a disk across the wearer's face."""
    model.rings("head", material, rings)
    model.parts[-1].triangles = model.parts[-1].triangles[:2*len(rings[0])*(len(rings)-1)]


def oval_ring(rx, ry, z, offset=0):
    return [(offset+rx*cos(t), ry*sin(t), z) for t in ANGLES]


def cord(model, material, points, radius):
    model.sweep("head", material, [(*p, radius, radius) for p in points], 8)


def band(model, material, rx, ry, z, width):
    rows = [(rx-.45,ry-.45,z), (rx,ry,z+.25), (rx,ry,z+width-.20),
            (rx-.45,ry-.45,z+width)]
    strip(model,material,[oval_ring(*row) for row in rows])


def rosette(model, x, y, z, size):
    # Hammered diamond and its central cabochon.
    model.patch("head","brass",[(x-.4,y-size,z),(x,y,z-size*1.22),
        (x-.4,y+size,z),(x,y,z+size*1.22)], (x+.7,y,z))
    model.oval("head","iris",(x+.76,y,z),(.5,size*.36,size*.46),12,5)


def felt_hat():
    model = Sculpt()
    def brim(r, lift):
        points = []
        for t in ANGLES:
            ripple=(r-.52)/.48
            points.append((25.3*r*cos(t), 21.8*r*sin(t),
                           161.0 + ripple*(1.35*sin(t)-2.1*cos(t)+1.05*cos(2*t)) + lift))
        return points
    strip(model,"cloth",[brim(.53,.2),brim(.78,-.27),brim(1,-.82),
                         brim(1.012,-.37),brim(1,.12),brim(.78,.63),brim(.53,1)])
    strip(model,"trim",[brim(.965,.16),brim(.994,.24),brim(1.014,-.10),brim(1.012,-.57)])
    # The felt gathers above the leather band, then tips backwards.
    rows=[(160.8,0,0,14.8,12.9),(164,0,0,14.6,12.7),(168,-.3,0,13.2,11.7),
          (173,-.8,.25,11.7,10),(178,-2,.55,9,7.9),(182,-4,1,6.2,5.8),
          (185,-7.5,1.25,4.1,3.7),(186,-10.2,1.4,2.5,2.3),(184.6,-13,1.3,.6,.75)]
    def crease(x,y,z,t):
        fold=max(0,1-abs(z-177)/12)
        return (x+fold*.75*cos(3*t+.5), y*(1+.058*fold*cos(3*t)),z)
    model.loft("head","cloth",rows,32,sculpt=crease)
    cone=model.parts[-1]
    cone.triangles=np.vstack((cone.triangles[:-64],cone.triangles[-32:]))
    band(model,"leather",15.0,13.2,161.6,4.15)
    band(model,"seam",15.15,13.32,162.3,1.50)
    band(model,"trim",14.85,13.12,165.0,.9)
    band(model,"brass",15.16,13.34,163.87,.62)
    # Two embroidered sprays rise out of the hatband. They occupy a broader
    # field in the silver finish, while the felt remains visible between leaves.
    def embroidery(t,z):
        rx=np.interp(z,[165,168,173,178],[14.65,13.4,11.9,9.2])
        ry=np.interp(z,[165,168,173,178],[12.9,11.95,10.25,8.1])
        return np.array([rx*cos(t)-.2,ry*sin(t),z])
    for side in (-1,1):
        stem=[embroidery(side*(.23+.94*u),166+7*u) for u in np.linspace(0,1,9)]
        cord(model,"brass",stem,.29)
        for n in range(4):
            t=side*(.34+.19*n)
            z=166.8+1.37*n
            blade=[embroidery(t,z),embroidery(t-side*.09,z+1.1),
                   embroidery(t+side*.03,z+3.3),embroidery(t+side*.08,z+1.55)]
            crest=embroidery(t,z+1.45)+np.array([.43*cos(t),.43*sin(t),0])
            model.patch("head","sash",blade,crest)
    rosette(model,15.18,0,164.2,2.5)
    return model


def metal_helmet(medium):
    model = Sculpt()
    # The outside of this hollow bowl clears the same compact head envelope
    # as the enclosed helm. Only the medium style descends below the brow.
    rx,ry = INNER_DEPTH+1.65,INNER_WIDTH+1.65
    rim = 159.45
    profile=[(0,1),(2,.995),(5,.955),(8.8,.84),(11.8,.66),(14.2,.42),(15.6,.18),(15.95,.025)]
    shell=[oval_ring(rx*s,ry*s,rim+h) for h,s in profile]
    interior=[oval_ring((rx-1.05)*s,(ry-1.05)*s,rim+h*.94) for h,s in reversed(profile)]
    strip(model,"metal",shell+interior+[shell[0]])
    band(model,"trim",rx+.35,ry+.35,rim,.95)
    band(model,"seam",rx+.38,ry+.38,rim+1.10,2.0)
    band(model,"brass",rx+.42,ry+.42,rim+2.98,.75)
    # Hammered fore-and-aft reinforcement tapers towards the crown. Its
    # folded cross section catches a highlight along the center of the plate.
    for center in (0,pi):
        spine=[]
        for h,scale in profile[1:-1]:
            dx,dy=rx*scale,ry*scale
            half=.25+.08*(1-scale)
            line=[((dx+depth)*cos(center+t),(dy+depth)*sin(center+t),rim+h+lift)
                  for t,depth,lift in ((-half,.12,.03),(0,.48,.21),(half,.12,.03),
                                       (half,-.10,0),(0,.06,.02),(-half,-.10,0))]
            spine.append(line)
        model.rings("head","sash",spine)
    for angle in (pi/2,3*pi/2):
        radius=.55 if medium else .40
        points=[((rx*s+.10)*cos(angle),(ry*s+.10)*sin(angle),rim+h+.08)
                for h,s in profile[1:]]
        cord(model,"trim",points,radius)
    if medium:
        # A single U-shaped shell sweeps from temple to temple around the
        # occiput. The hem rises at the jaw and never crosses the face.
        arc=np.linspace(np.radians(54),np.radians(306),49)
        def wall(t, height, inset=0):
            cheek=abs(sin(t))**4
            hem=143.8-2.8*cheek+2.3*cos(t)
            z=hem+(rim+1-hem)*height
            taper=(1-height)**1.7
            return ((rx-2.2*taper+inset)*cos(t)-.6*taper,
                    (ry-1.6*taper+inset)*sin(t), z)
        # Each horizontal slice encloses only the rear panel; its two ends
        # return across the wall thickness along the front opening.
        rows=[]
        for h in (0,.12,.49,.83,1):
            rows.append([wall(t,h) for t in arc]+[wall(t,h,-.9) for t in arc[::-1]])
        strip(model,"metal",rows)
        for h,material,radius in [(0,"trim",.58),(.13,"seam",.54)]:
            cord(model,material,[wall(t,h,.15) for t in arc],radius)
        for t in (arc[0],arc[-1]):
            cord(model,"trim",[wall(t,h,.10) for h in (0,.3,.65,1)],.6)
        for side in (-1,1):
            temple=pi*.47 if side==1 else 2*pi-pi*.47
            plate=[wall(temple+side*dt,h,.36) for dt,h in
                   ((-.48,.84),(-.08,.97),(.45,.81),(.26,.30),(-.23,.11),(-.43,.31))]
            model.patch("head","sash",plate,wall(temple,.56,1.10))
            cord(model,"brass",[wall(temple+side*dt,h,.56) for dt,h in
                               ((-.42,.31),(-.24,.14),(.22,.31))],.46)
        # The nape is reinforced by overlapping horizontal lames.
        for n in (0,1):
            angles=np.linspace(pi*.66,pi*1.34,25)
            cord(model,"trim",[wall(t,.34+n*.29,.18) for t in angles],.60)
    for t in np.arange(8)*pi/4:
        model.oval("head","brass",((rx+.24)*cos(t),(ry+.24)*sin(t),rim+2.1),
                   (.78,.78,.72),10,5)
    if medium:
        rosette(model,rx+.36,0,rim+3.0,1.5)
    return model


@lru_cache(maxsize=3)
def sculpt(material):
    return felt_hat() if material=="magic" else metal_helmet(material=="medium")


def polished_shade(shade, metal):
    """A cold/warm metal ramp with a narrow reflected highlight."""
    low,body,high=np.asarray(metal)
    light=np.clip(shade,0,1)[...,None]
    value=low+(body-low)*light**.73
    glint=np.clip((light-.57)/.36,0,1)**1.8
    return np.uint8(np.clip(value+(high-body)*glint,0,255))


def finishes(kind, tier, base, heavy_shaders=()):
    """Create the skin and its selective specular map. Heavy retains its original UVs."""
    image=Image.open(BytesIO(base)).convert("RGBA")
    spec=Image.new("L",image.size)
    def decorate(box,metal):
        pixels=np.asarray(image.crop(box))
        luminance=pixels[:,:,:3] @ [.2126,.7152,.0722]
        # Keep hammered marks on the inventory iron and the painted normal
        # gradients on the small modular fittings.
        a,b=np.percentile(luminance,[2,98])
        level=np.clip((luminance-a)/max(6,b-a),0,1)
        if kind=="heavy":
            u=np.linspace(0,1,level.shape[1])[None,:]
            level=.32+.56*level+.12*np.cos(2*pi*(u+level*.18))
        color=np.dstack((polished_shade(level,metal),pixels[:,:,3]))
        image.paste(Image.fromarray(color),box[:2])
        spec.paste(210,box)
    if kind=="heavy":
        tiles=sorted(set(heavy_shaders))
        side=int(np.ceil(np.sqrt(len(tiles))))
        tile=image.width//side
        for index,name in enumerate(tiles):
            x,y=index%side*tile,index//side*tile
            box=(x,y,x+tile,y+tile)
            if name.endswith("/gold.png"):
                decorate(box,SILVER if tier==2 else GOLD)
            elif tier==3 and name.endswith("/metals.png"):
                decorate(box,SILVER)
    else:
        for channel,metal in ([("seam",SILVER)] if tier==2 else
                              [("seam",SILVER),("trim",SILVER),("sash",SILVER),("brass",GOLD)]):
            i=MATERIALS.index(channel)
            tile=image.width//8
            x,y=i%8*tile,i//8*tile
            decorate((x,y,x+tile,y+tile),metal)
    return image,spec


def base_skin(kind):
    return paint({"cloth":(77,53,91), "leather":(74,44,35), "metal":(106,113,122),
                  "seam":(96,78,67), "trim":(78,72,72), "brass":(139,103,56),
                  "sash":(96,74,111) if kind=="magic" else (107,111,119),
                  "iris":(100,133,151) if kind=="magic" else (88,88,80)})
