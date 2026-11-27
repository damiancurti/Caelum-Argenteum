"""Read MD3 surfaces and bake player attachments against the owned Domingo animation."""
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
import struct

import numpy as np
from scipy.spatial import cKDTree

ROOT=Path(__file__).resolve().parents[2]
# These samples refer to the retained Domingo motion catalogue. Index order follows
# appearance_catalog.json from idle to punch recovery.
SAMPLES=[0,7,15,19,23,26,150,150,150,36,42,67,74,81,91,100,122,136,48,49,50,55,61,
         48,55,61,150,150,150,29,32,40,45]


@dataclass
class Surface:
    positions: np.ndarray
    faces: np.ndarray
    uv: np.ndarray
    shader: str


def read_model(data):
    if data[:8]!=b'IDP3\x0f\0\0\0':
        raise ValueError("Expected MD3 version 15")
    section=struct.unpack_from('<I',data,100)[0]
    surfaces=[]
    for _ in range(struct.unpack_from('<I',data,84)[0]):
        _,_,_,frames,_,vertices,triangles,tri,shader,st,xyz,end=struct.unpack_from('<4s64s10I',data,section)
        points=np.frombuffer(data,dtype='<i2',offset=section+xyz,count=frames*vertices*4).reshape(frames,vertices,4)
        faces=np.frombuffer(data,dtype='<i4',offset=section+tri,count=triangles*3).reshape(-1,3)
        uv=np.frombuffer(data,dtype='<f4',offset=section+st,count=vertices*2).reshape(-1,2)
        skin=data[section+shader:section+shader+64].split(b'\0')[0].decode('ascii')
        surfaces.append(Surface(points[:,:,:3].astype('f')/64,faces.copy(),uv.copy(),skin))
        section+=end
    return surfaces


def fixed(name,n):
    data=name.encode('ascii')
    if len(data)>=n:
        raise ValueError("MD3 name too long: "+name)
    return data.ljust(n,b'\0')


def encode(name,surfaces):
    chunks=[]
    nframes=len(surfaces[0].positions)
    lows=[]; highs=[]
    for i,s in enumerate(surfaces):
        frames=np.asarray(s.positions,dtype='f')
        verts=frames.shape[1];nf=len(s.faces)
        if verts>4096 or nf>8192 or len(frames)!=nframes:
            raise ValueError("Invalid native surface limits for "+name)
        lows.append(frames.min(axis=1));highs.append(frames.max(axis=1))
        p=frames[:,s.faces[:,0]]
        normals=np.cross(frames[:,s.faces[:,1]]-p,frames[:,s.faces[:,2]]-p)
        vnorm=np.zeros_like(frames)
        for j in range(nframes):
            for col in range(3):
                np.add.at(vnorm[j],s.faces[:,col],normals[j])
        vnorm/=np.maximum(np.linalg.norm(vnorm,axis=2,keepdims=True),1e-8)
        lat=np.rint(np.arctan2(vnorm[:,:,1],vnorm[:,:,0])*128/np.pi).astype('i')&255
        lng=np.rint(np.arccos(np.clip(vnorm[:,:,2],-1,1))*128/np.pi).astype('i')&255
        packed=np.empty((nframes,verts,4),dtype='<i2')
        q=np.rint(frames*64)
        if np.max(np.abs(q))>32767:
            raise ValueError("Position exceeds MD3 precision range")
        packed[:,:,:3]=q
        packed[:,:,3]=((lat<<8)|lng).astype('<u2').view('<i2')
        tridata=s.faces.astype('<i4').tobytes()
        st=s.uv.astype('<f4').tobytes()
        a=108;b=a+len(tridata);c=b+68;d=c+len(st);end=d+packed.nbytes
        header=struct.pack('<4s64s10I',b'IDP3',fixed('surface'+str(i),64),0,nframes,1,verts,nf,a,b,c,d,end)
        chunks.append(header+tridata+struct.pack('<64sI',fixed(s.shader,64),0)+st+packed.tobytes())
    bounds=bytearray()
    for i,(low,high) in enumerate(zip(np.min(lows,axis=0),np.max(highs,axis=0))):
        radius=np.linalg.norm(np.maximum(np.abs(low),np.abs(high)))
        bounds.extend(struct.pack('<10f16s',*low,*high,0,0,0,radius,fixed('pose'+str(i),16)))
    start=108+len(bounds)
    return struct.pack('<4sI64s9I',b'IDP3',15,fixed(name,64),0,nframes,0,len(chunks),0,108,start,start,start+sum(map(len,chunks)))+bounds+b''.join(chunks)


def subset(surface, selected):
    triangles=surface.faces[selected]
    if not len(triangles):
        return None
    ids,local=np.unique(triangles,return_inverse=True)
    return Surface(surface.positions[:,ids],local.reshape(-1,3),surface.uv[ids],surface.shader)


@lru_cache(maxsize=10)
def reference(modules):
    tracks=[]
    directory=ROOT/"src/models/caelum/characters/domingo"
    for module in modules:
        for s in read_model((directory/(module+'.md3')).read_bytes()):
            tracks.append(s.positions[SAMPLES])
    samples=np.concatenate(tracks,axis=1)
    return samples,cKDTree(samples[0])


def animate(vertices, modules=("clothing","underbody","left_hand","right_hand")):
    samples,tree=reference(tuple(modules))
    dist,ids=tree.query(vertices,k=8)
    weights=1/np.maximum(dist,0.15)**2.5
    weights/=weights.sum(axis=1,keepdims=True)
    delta=samples[:,ids,:]-samples[0,ids,:]
    return vertices[None]+np.einsum('fvkc,vk->fvc',delta,weights)


def rigid_track(points,module):
    """Use a least-squares rigid socket so a held item, skull or helmet keeps its shape."""
    samples,_=reference((module,))
    neutral=samples[0]
    center=neutral.mean(axis=0)
    result=[]
    for frame in samples:
        target=frame.mean(axis=0)
        u,_,vt=np.linalg.svd((neutral-center).T@(frame-target))
        if np.linalg.det(u@vt)<0:
            u[:,-1]*=-1
        result.append((points-center)@(u@vt)+target)
    return np.asarray(result,dtype='f')
