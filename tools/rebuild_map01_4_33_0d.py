#!/usr/bin/env python3
"""Carve the contiguous MAP01 lift/cave; Python standard library only."""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import re
import struct
from pathlib import Path

BASE_SHA256 = '715e5e59f65e2ba203872203aea2bf2b091dd1ee31708843a88c5322a0111f86'
LIFT_TAG, ROOF_TAG = 12000, 12001
FLOOR_Z = -384
SHAFT = [(1875,272),(1875,360),(1959,360),(1959,272)]
UNDERGROUND = [(1875,360),(1875,480),(1015,480),(975,520),
               (975,1240),(1015,1280),(1959,1280),(1999,1240),
               (1999,520),(1959,480),(1959,360)]
KINDS = ('vertex','linedef','sidedef','sector','thing')
EPS = 1e-7

def read_wad(path):
    data = Path(path).read_bytes()
    magic, count, offset = struct.unpack_from('<4sii', data)
    assert magic in (b'PWAD',b'IWAD')
    result=[]
    for i in range(count):
        start,size,name=struct.unpack_from('<ii8s',data,offset+i*16)
        result.append((name.rstrip(b'\0').decode(),data[start:start+size]))
    return magic,result

def write_wad(path,magic,lumps):
    data=bytearray(b'\0'*12); entries=[]
    for name,content in lumps:
        entries.append((len(data),len(content),name.encode().ljust(8,b'\0')))
        data.extend(content)
    offset=len(data)
    for entry in entries: data.extend(struct.pack('<ii8s',*entry))
    struct.pack_into('<4sii',data,0,magic,len(lumps),offset)
    Path(path).parent.mkdir(parents=True,exist_ok=True)
    Path(path).write_bytes(data)

def parse(text):
    result={k:[] for k in KINDS}
    for kind,body in re.findall(r'(?ms)^\s*(vertex|linedef|sidedef|sector|thing)\s*(?://[^\n]*)?\s*\{(.*?)^\s*\}',text):
        fields={}
        for key,value in re.findall(r'(?m)^\s*(\w+)\s*=\s*("(?:\\.|[^"\\])*"|true|false|[-+\d.eE]+)\s*;',body):
            fields[key]=json.loads(value)
        result[kind].append(fields)
    return result

def encode(data):
    parts=['namespace = "ZDoom";','// MAP01 V4.33.0d: native lift and contiguous underground cave.']
    for kind in KINDS:
        for index,obj in enumerate(data[kind]):
            body='\n'.join('    '+key+' = '+json.dumps(value,ensure_ascii=False)+';' for key,value in obj.items())
            parts.append(f'// {kind} {index}\n{kind}\n{{\n{body}\n}}')
    return '\n\n'.join(parts)+'\n'

def sub(a,b): return (a[0]-b[0],a[1]-b[1])
def cross(a,b): return a[0]*b[1]-a[1]*b[0]
def point(a,b,t): return (round(a[0]+(b[0]-a[0])*t,7),round(a[1]+(b[1]-a[1])*t,7))
def edges(poly): return list(zip(poly,poly[1:]+poly[:1]))

def inside(p,poly):
    hits=0
    for a,b in edges(poly):
        if (a[1]>p[1]) != (b[1]>p[1]):
            x=a[0]+(p[1]-a[1])*(b[0]-a[0])/(b[1]-a[1])
            hits += x > p[0]
    return bool(hits%2)

def split_parameters(a,b,c,d):
    r,s=sub(b,a),sub(d,c); den=cross(r,s); q=sub(c,a)
    if abs(den)>EPS:
        t,u=cross(q,s)/den,cross(q,r)/den
        return [max(0,min(1,t))] if -EPS<=t<=1+EPS and -EPS<=u<=1+EPS else []
    if abs(cross(q,r))>EPS: return []
    rr=r[0]*r[0]+r[1]*r[1]
    result=[]
    for p in (c,d):
        t=((p[0]-a[0])*r[0]+(p[1]-a[1])*r[1])/rr
        if -EPS<=t<=1+EPS: result.append(max(0,min(1,t)))
    return result

def segments(a,b,cutters):
    ts={0.0,1.0}
    for c,d in cutters: ts.update(round(t,10) for t in split_parameters(a,b,c,d))
    ordered=sorted(ts)
    return [(point(a,b,lo),point(a,b,hi),lo) for lo,hi in zip(ordered,ordered[1:]) if hi-lo>EPS]

def build(text):
    # Quita la geometría y Things de 0c como un bloque; no deja la cueva remota.
    text=re.sub(r'(?ms)^\s*// CAELUM_MAP01_4_33_0C_BEGIN.*?^\s*// CAELUM_MAP01_4_33_0C_END\s*','\n',text)
    src=parse(text); out=copy.deepcopy(src)
    verts=src['vertex']; sides=src['sidedef']; lines=src['linedef']
    xy=lambda index:(verts[index]['x'],verts[index]['y'])
    old_edges=[(xy(e['v1']),xy(e['v2'])) for e in lines]
    boundaries={k:[] for k in range(len(src['sector']))}
    for e,(a,b) in zip(lines,old_edges):
        front=sides[e['sidefront']]['sector']
        back=sides[e['sideback']]['sector'] if e.get('sideback',-1)>=0 else -1
        if front==back: continue
        for sec in (front,back):
            if sec in boundaries: boundaries[sec].append((a,b))

    def original_sector(p):
        for sec in [*range(1,len(src['sector'])),0]:
            hit=0
            for a,b in boundaries[sec]:
                if (a[1]>p[1])!=(b[1]>p[1]):
                    hit += a[0]+(p[1]-a[1])*(b[0]-a[0])/(b[1]-a[1]) > p[0]
            if hit%2: return sec
        raise AssertionError(f'Point outside intended original sectors: {p}')

    # Conserva cada tag previo de pisos 3D; sólo agrega un suelo subterráneo
    # y una losa que mantiene intacta la superficie anterior a Z=0.
    mapping={};roof_tags={}
    def mapped_sector(old,region):
        if (old,region) in mapping:return mapping[(old,region)]
        sector=copy.deepcopy(src['sector'][old])
        assert sector['heightfloor']==0 and sector['heightceiling']==30000,(old,sector)
        prior=[sector.pop('id',0)]+[int(v) for v in sector.pop('moreids','').split()]
        texture=sector['texturefloor']
        if region=='cave' and texture not in roof_tags:roof_tags[texture]=ROOF_TAG+len(roof_tags)
        tag=roof_tags[texture] if region=='cave' else LIFT_TAG
        sector['id']=tag
        if any(prior):sector['moreids']=' '.join(str(t) for t in prior if t)
        sector['heightfloor']=FLOOR_Z if region=='cave' else 0
        sector['texturefloor']='CACVROCK' if region=='cave' else 'CMWD03'
        sector['comment']=f'V4.33.0d {region}; original sector {old}'
        mapping[(old,region)]=len(out['sector']);out['sector'].append(sector)
        return mapping[(old,region)]

    def resolve(old,p):
        if inside(p,SHAFT):
            assert old==92,(old,p)
            return mapped_sector(92,'lift')
        if inside(p,UNDERGROUND):
            assert old in boundaries,(old,p)
            return mapped_sector(old,'cave')
        return old

    # Las fachadas son midtextures nativas, con el mismo alto y repetición
    # del muro original. La abertura sur y el tabique interior no bloquean.
    panels=[((1842,-383),(1842,-287),'entry'),
            ((1842,-287),(1842,383),'facade'),
            ((1842,-87),(1961,-87),'inner')]
    new_edges=edges(SHAFT)+edges(UNDERGROUND)+[(a,b) for a,b,_ in panels]
    out['linedef']=[];out['sidedef']=[]
    vertex_ids={(v['x'],v['y']):i for i,v in enumerate(out['vertex'])}
    def vid(p):
        if p not in vertex_ids:
            vertex_ids[p]=len(out['vertex']);out['vertex'].append({'x':p[0],'y':p[1]})
        return vertex_ids[p]
    def side_index(obj):
        idx=len(out['sidedef']);out['sidedef'].append(obj);return idx
    def samples(a,b):
        mid=point(a,b,.5);dx,dy=b[0]-a[0],b[1]-a[1];n=math.hypot(dx,dy)
        return (mid[0]+dy/n*.01,mid[1]-dx/n*.01),(mid[0]-dy/n*.01,mid[1]+dx/n*.01)
    seen=set()
    for old,(a,b) in zip(lines,old_edges):
        for p,q,start in segments(a,b,new_edges):
            front_point,back_point=samples(p,q)
            obj=copy.deepcopy(old);obj['v1']=vid(p);obj['v2']=vid(q)
            for slot,pos in [('sidefront',front_point),('sideback',back_point)]:
                if old.get(slot,-1)<0:continue
                side=copy.deepcopy(sides[old[slot]])
                side['sector']=resolve(side['sector'],pos)
                if out['sector'][side['sector']]['heightfloor']==FLOOR_Z:
                    side['texturebottom']='CACVROCK'
                if start:side['offsetx']=int(round(side.get('offsetx',0)+start*math.dist(a,b)))
                obj[slot]=side_index(side)
            if old.get('dontpegbottom') and old.get('sideback',-1)>=0:
                old_base=max(src['sector'][sides[old[k]]['sector']]['heightfloor'] for k in ('sidefront','sideback'))
                new_base=max(out['sector'][out['sidedef'][obj[k]]['sector']]['heightfloor'] for k in ('sidefront','sideback'))
                for k in ('sidefront','sideback'):
                    side=out['sidedef'][obj[k]]
                    if new_base!=old_base and side.get('texturemiddle','-')!='-':
                        assert side['texturemiddle']=='CMRLBAL','Revisar escala de midtexture'
                        side['offsety_mid']=side.get('offsety_mid',0)+(old_base-new_base)*2.583333
            out['linedef'].append(obj);seen.add(tuple(sorted((p,q))))

    for a,b in new_edges:
        for p,q,_ in segments(a,b,old_edges+new_edges):
            key=tuple(sorted((p,q)))
            if key in seen:continue
            seen.add(key);fp,bp=samples(p,q)
            f=resolve(original_sector(fp),fp);back=resolve(original_sector(bp),bp)
            fs={'sector':f,'texturetop':'CMIN01','texturebottom':'CACVROCK','texturemiddle':'-'}
            bs=dict(fs,sector=back)
            obj={'v1':vid(p),'v2':vid(q),'sidefront':side_index(fs),
                 'sideback':side_index(bs),'twosided':True,'dontpegbottom':True}
            mid=point(p,q,.5)
            for pa,pb,kind in panels:
                if abs(cross(sub(mid,pa),sub(pb,pa)))<EPS and min(pa[0],pb[0])-EPS<=mid[0]<=max(pa[0],pb[0])+EPS and min(pa[1],pb[1])-EPS<=mid[1]<=max(pa[1],pb[1])+EPS:
                    fs['texturemiddle']=bs['texturemiddle']='CMIN01'
                    # La coordenada del motivo se conserva a lo largo de toda la cara.
                    fs['offsetx']=bs['offsetx']=int(round(math.dist(p,(1842,-383)) if kind!='inner' else p[0]-1842))
                    obj['comment']='V4.33.0d secret '+kind
                    if kind=='facade':obj['midtex3d']=True
                    break
            out['linedef'].append(obj)

    # Cualquier cara de la cabina permite llamarla con Usar. El actor inicia
    # el descenso automático únicamente cuando todo el cuerpo cabe encima.
    lift=mapping[(92,'lift')]
    for obj in out['linedef']:
        fs=out['sidedef'][obj['sidefront']]['sector']
        bs=out['sidedef'][obj['sideback']]['sector'] if obj.get('sideback',-1)>=0 else -1
        if lift in (fs,bs):
            obj.update(special=206,arg0=LIFT_TAG,arg1=16,arg2=175,arg3=0,
                       playeruse=True,playeruseback=True,repeatspecial=True)
            obj['comment']='V4.33.0d native lift call'

    # Control nativo de la losa: techo de cueva a -64; terreno/mansión a 0.
    for n,(texture,tag) in enumerate(roof_tags.items()):
        control=len(out['sector'])
        out['sector'].append({'heightfloor':-64,'heightceiling':0,
            'texturefloor':'CACVROCK','textureceiling':texture,'lightlevel':128,
            'comment':'V4.33.0d underground roof; preserves ground at Z=0'})
        x=-20000+n*96
        for i,(a,b) in enumerate(edges([(x,32000),(x,32064),(x+64,32064),(x+64,32000)])):
            obj={'v1':vid(a),'v2':vid(b),'sidefront':side_index({'sector':control,
                 'texturetop':'-','texturebottom':'-','texturemiddle':'CMIN01'}),'blocking':True}
            if i==0:obj.update(special=160,arg0=tag,arg1=1,arg2=0,arg3=255)
            out['linedef'].append(obj)

    def add_thing(type_id,x,y,height=0,angle=0,args=None):
        t={'x':float(x),'y':float(y),'height':float(height),'angle':angle,'type':type_id}
        if args:t.update({f'arg{i}':v for i,v in enumerate(args) if v})
        t.update({f'skill{i}':True for i in range(1,6)});t.update(single=True,coop=True,dm=True)
        out['thing'].append(t)
    add_thing(18036,-1440,0,angle=180,args=[1])
    for type_id,x,y,angle in [(18021,1040,-378,90),(18022,-290,-378,90),
                              (18020,-290,378,270),(18023,1036,378,270)]:
        add_thing(type_id,x,y,136,angle,[1])
    add_thing(18538,1917,316,angle=90)
    add_thing(18539,1860,575)
    add_thing(18469,1170,680,angle=35)
    add_thing(18470,1500,845,angle=170)
    add_thing(18471,1740,1040,angle=290)
    add_thing(18507,1860,1150,angle=180)
    add_thing(18510,1100,1100,angle=0)
    return out

def main():
    p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args()
    assert hashlib.sha256(args.input.read_bytes()).hexdigest()==BASE_SHA256,'Se requiere MAP01 V4.33.0c original'
    magic,lumps=read_wad(args.input)
    result=[]
    for name,data in lumps:
        if name=='TEXTMAP':
            rebuilt=build(data.decode());data=encode(rebuilt).encode()
            print({kind:len(items) for kind,items in rebuilt.items()})
        result.append((name,data))
    write_wad(args.output,magic,result)
    print('MAP01 V4.33.0d:',args.output)

if __name__=='__main__':main()
