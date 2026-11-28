"""Sculpt the four carried shield faces, returns and fittings in left-palm space."""
from math import cos, pi, sin
import numpy as np

from sculpted_character_art import Sculpt, paint

# Half-width and half-height of the approved worn pieces in player model units.
SIZES = [(22.5,22.5), (28.5,45), (35,56), (27.5,32.5)]
PALM = np.array([5.25, 28.1, 83.8])
ANGLE = np.radians(40)
NORMAL = np.array([np.cos(ANGLE), np.sin(ANGLE), 0])
ACROSS = np.array([-np.sin(ANGLE), np.cos(ANGLE), 0])
UP = np.array([0, 0, 1])


def sculpt(index):
    model = Sculpt()
    w, h = SIZES[index]
    angles = np.arange(64)*2*pi/64
    if index in (0, 3):
        outline = np.array([(w*cos(t), h*sin(t)) for t in angles])
    elif index == 1:
        # Keep the long lower point and the crowned shoulders of the kite.
        outline = np.array([(0,-1),(.45,-.56),(.83,-.13),(.98,.27),(.96,.58),
                            (.82,.78),(.50,.91),(0,1),(-.50,.91),(-.82,.78),
                            (-.96,.58),(-.98,.27),(-.83,-.13),(-.45,-.56)]) * [w,h]
    else:
        outline = np.array([(-.88,-1),(.88,-1),(1,-.91),(1,.88),(.92,.965),
                            (.64,1),(-.64,1),(-.92,.965),(-1,.88),(-1,-.91)]) * [w,h]
    camber = [4.0, 6.0, 7.5, 5.0][index]
    thickness = [2.8, 3.6, 4.8, 3.4][index]
    metal = "metal" if index in (0,2) else "brass"

    def face(u,v):
        return 10 + camber * (1 - .84*(u/w)**2 - .16*(v/h)**2)

    def point(u,v,depth):
        return PALM + ACROSS*u + UP*v + NORMAL*depth

    def skin(u,v,relief=0):
        return point(u,v,face(u,v)+relief)

    def loop(scale, depth):
        return [skin(u*scale,v*scale,depth) for u,v in outline]

    def sweep(material, centers, widths):
        model.sweep("shield",material,[(*pos,a,b) for pos,(a,b) in zip(centers,widths)],10)

    def relief(u,v,rx,rz,rise,material,sides=20):
        rings = []
        for scale,d in ((1,0),(.95,rise*.24),(.70,rise*.68),(.35,rise*.94),(.07,rise)):
            rings.append([skin(u+scale*rx*cos(t),v+scale*rz*sin(t),d)
                          for t in np.arange(sides)*2*pi/sides])
        model.rings("shield",material,rings)

    # Build a continuous convex back, solid cut edge and crowned face.
    rings = [loop(r,-thickness) for r in (.05,.4,.75,1)] + [loop(r,0) for r in (1,.75,.4,.05)]
    model.rings("shield", "leather" if index<3 else "dark", rings)
    # Each wooden stave spans the board front-to-back. Trace the silhouette
    # at each station so joints and paint follow the curved face.
    xs = np.unique(np.r_[outline[:,0], np.linspace(-w,w,9)])
    def limits(u):
        hits = []
        for a,b in zip(outline,np.roll(outline,-1,axis=0)):
            if min(a[0],b[0]) <= u <= max(a[0],b[0]) and abs(b[0]-a[0])>1e-6:
                hits.append(a[1]+(u-a[0])*(b[1]-a[1])/(b[0]-a[0]))
        return min(hits),max(hits)

    for j,(a,b) in enumerate(zip(np.linspace(outline[:,0].min(), outline[:,0].max(), 9),
                                 np.linspace(outline[:,0].min(), outline[:,0].max(), 9)[1:])):
        left,right=a+.12,b-.12
        edges=[left,*[x for x in xs if left+.03<x<right-.03],right]
        for back in (True,False):
            rings=[]
            for u in edges:
                lo,hi=limits(u)
                v=np.linspace(lo*.985,hi*.985,7)
                base=-thickness if back else 0
                depth=base+(-.48 if back else .55)
                rings.append([skin(u,t,depth) for t in v] + [skin(u,t,base) for t in v[::-1]])
            mat=("leather" if j%3 else "sole") if back else (
                "cloth" if index==3 or index==2 and j in (2,3,4,5) or index==1 and j>=3 else
                "trim" if index==1 and j==2 else "leather" if j%3 else "sole")
            model.rings("shield",mat,rings)

    # Close the rim as a hollow binding: a capped disk would cover the face.
    rim = [loop(r,d) for r,d in ((.92,-thickness-.7),(1,-thickness-1),(1.018,-thickness/2),
                                  (1,.9),(.965,1.8),(.922,1.35),(.92,-thickness-.7))]
    model.rings("shield",metal,rim)
    model.parts[-1].triangles=model.parts[-1].triangles[:2*len(outline)*(len(rim)-1)]
    # Rivets on every corner of polygonal boards or evenly around a round rim.
    samples=outline[::8] if len(outline)==64 else outline[::2]
    for u,v in samples*.96:
        relief(u,v,1.20,1.20,2.5,"brass" if metal=="metal" else "metal",10)

    if index==0:
        relief(0,0,10,10,3.1,"brass")
        relief(0,0,8.6,8.6,10.0,"metal")
    elif index==1:
        # Crescent with tapering tips, following the kite's blue field.
        pts=[]; widths=[]
        for t in np.linspace(.25*pi,1.75*pi,23):
            phase=(t-.25*pi)/(1.50*pi)
            pts.append(skin(3+w*.39*cos(t),h*.27+h*.24*sin(t),1.9))
            widths.append((.32+2.6*sin(pi*phase),.28+1.7*sin(pi*phase)))
        sweep("brass",pts,widths)
    elif index==2:
        for t in np.arange(12)*2*pi/12:
            pts=[skin(r*cos(t+d),5+r*sin(t+d),1) for r,d in ((7,-.19),(21,0),(7,.19))]
            model.patch("shield","brass",pts,skin(11*cos(t),5+11*sin(t),4))
        relief(0,5,9.5,9.5,7.2,"brass")
    else:
        for t in np.arange(8)*pi/4:
            u,v=w*.75*cos(t),h*.75*sin(t)
            relief(u,v,1.5,2,2.8,"glint",8)
        gem=[(0,-17),(8,-1),(0,17),(-8,1)]
        model.patch("shield","brass",[skin(u*1.24,v*1.10,1) for u,v in gem],skin(0,0,9))
        model.patch("shield","iris",[skin(u,v,4.8) for u,v in gem],skin(-1,2,13))

    # Rear cross braces and grip. The middle of the grip passes through the
    # curled fingers at the origin; mounting lugs rise from the inner board.
    for v in (-h*.36,h*.36):
        span=w*(.62 if index==1 and v<0 else .74)
        us=np.linspace(-span,span,9)
        sweep("sole",[skin(u,v,-thickness-1) for u in us],[(1.6,1.7)]*len(us))
    grip=[skin(0,-8,-thickness),point(0,-7,3),point(0,-4,0),point(0,4,0),
          point(0,7,3),skin(0,8,-thickness)]
    sweep("leather",grip,[(2.2,1.8),(1.7,1.6),(1.5,1.5),(1.5,1.5),(1.7,1.6),(2.2,1.8)])
    palette={"cloth":(43,67,116),"leather":(135,90,54),"sole":(93,66,46),
             "metal":(170,174,177),"brass":(214,155,62),"trim":(215,197,162),
             "iris":(48,146,236),"glint":(147,207,246)}
    return model, paint(palette)
