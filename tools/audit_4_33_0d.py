#!/usr/bin/env python3
"""Focused source, native-map and author-art audit for V4.33.0d."""
from __future__ import annotations
import argparse
import collections
import csv
import hashlib
import importlib.util
import math
import re
import struct
import zipfile
import zlib
from pathlib import Path

SOURCE_FILES={'CAPALOMO','MAPINFO','TEXTURES','caelum/core/CaelumConstants.zs',
              'caelum/world/CaelumSecretPassage.zs','maps/MAP01.wad'}
ART_DIR='art_source/tiers_2_3_rehechos_4_33_0d'
PROJECT_FILES={
 'APLICAR_4_33_0d.txt','PRUEBAS_4_33_0d.txt',
 'docs/DIALOGUE.md','docs/IMPLEMENTATION_STATUS.md','docs/QUESTS_REPUTATION_FACTIONS.md',
 'docs/ROADMAP.md','docs/MAP01_SECRET_PASSAGE_4_33_0c.md',
 'docs/MAP01_SECRET_PASSAGE_4_33_0d.md','docs/EQUIPMENT_ICONS_4_33_0d.md',
 'tools/audit_4_33_0d.py','tools/build_source_patch_4_33_0d.py',
 'tools/rebuild_map01_4_33_0d.py',
 *(ART_DIR+'/'+n for n in ('INSTRUCCIONES.md','MANIFEST_TIERS.csv','CHECKSUMS_SHA256.txt','VALIDACION.txt'))}
ZIP_TIME=(2026,9,9,18,0,0)

def require(test,message):
    if not test:raise AssertionError(message)

def digest(data):return hashlib.sha256(data).hexdigest()

def load_builder(project):
    spec=importlib.util.spec_from_file_location('map01_0d_builder',project/'tools/rebuild_map01_4_33_0d.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module

def art_rows(project):
    with (project/ART_DIR/'MANIFEST_TIERS.csv').open(encoding='utf-8-sig',newline='') as f:
        rows=list(csv.DictReader(f))
    require(len(rows)==99,'El manifiesto debe contener los 99 iconos autorales')
    require(collections.Counter(r['tier'] for r in rows)=={'1':1,'2':49,'3':49},'Distribución de tiers inesperada')
    return rows

def runtime_files(project):return SOURCE_FILES|{r['ruta_juego'] for r in art_rows(project)}
def package_files(project):return PROJECT_FILES|{'src/'+n for n in runtime_files(project)}

def check_png(data,name):
    require(data[:8]==b'\x89PNG\r\n\x1a\n','PNG inválido: '+name)
    width,height,depth,color=struct.unpack_from('>IIBB',data,16)
    require((width,height,depth,color)==(128,128,8,6),'PNG fuera del formato RGBA 128: '+name)
    pos=8;ended=False
    while pos<len(data):
        size=struct.unpack_from('>I',data,pos)[0];kind=data[pos+4:pos+8]
        chunk=data[pos+4:pos+8+size]
        crc=struct.unpack_from('>I',data,pos+8+size)[0]
        require(zlib.crc32(chunk)&0xffffffff==crc,'CRC PNG incorrecto: '+name)
        pos+=12+size
        if kind==b'IEND':ended=True;break
    require(ended and pos==len(data),'PNG incompleto: '+name)

def audit_art(project):
    checks={}
    for line in (project/ART_DIR/'CHECKSUMS_SHA256.txt').read_text().splitlines():
        sha,name=line.split(None,1);checks[name.strip()]=sha
    for row in art_rows(project):
        data=(project/'src'/row['ruta_juego']).read_bytes()
        require(digest(data)==checks[row['archivo']],'Icono distinto del adjunto: '+row['archivo'])
        check_png(data,row['archivo'])

def audit_runtime(project,baseline,runtime):
    old={p.relative_to(baseline).as_posix() for p in baseline.rglob('*') if p.is_file()}
    new={p.relative_to(runtime).as_posix() for p in runtime.rglob('*') if p.is_file()}
    require(old==new,'Runtime contiene archivos omitidos o instrumentación extra')
    changes={n for n in old if (baseline/n).read_bytes()!=(runtime/n).read_bytes()}
    expected=runtime_files(project)
    require(changes==expected,'Delta ajeno o faltante: '+str(changes^expected))
    for name in expected:
        require((project/'src'/name).read_bytes()==(runtime/name).read_bytes(),'Runtime difiere de fuente: '+name)
    c=(project/'src/caelum/core/CaelumConstants.zs').read_text()
    for name in ('STORY_NPC_RETURN_DISTANCE','PALOMO_MERCHANT_RETURN_DISTANCE'):
        require(re.search(r'const\s+'+name+r'\s*=\s*100\.0\s*;',c),'Umbral no corregido: '+name)
    dialogue=(project/'src/CAPALOMO').read_text()
    for name in ('unknown_voice_who','unknown_voice_where'):
        page=dialogue.split('pagename = "'+name+'";',1)[1].split('\n    }',1)[0]
        require(page.count('$CA_DLG_M01_CONTINUE')==1 and 'choice' not in page,'Continuar duplicado: '+name)
    require(dialogue.count('$CA_DLG_M01_UNKNOWN_VOICE_SILENCE')==1,'Silencio duplicado')
    secret=(project/'src/caelum/world/CaelumSecretPassage.zs').read_text()
    require('Plat_DownWaitUpStayLip(' in secret and 'SetOrigin' not in secret,'Transporte no nativo')
    require('CaelumM01SwordPickup' in secret and 'WEAPON_TYPE_SWORD' in secret,'Falta espada normal')
    require('CaelumM01Vein' not in secret and 'HATCHET' not in secret,'Queda herramienta o excepción de 0c')

def audit_map(project,baseline):
    m=load_builder(project)
    base=(baseline/'maps/MAP01.wad').read_bytes()
    require(digest(base)==m.BASE_SHA256,'MAP01 base no corresponde a 0c')
    _,old_lumps=m.read_wad(baseline/'maps/MAP01.wad')
    _,new_lumps=m.read_wad(project/'src/maps/MAP01.wad')
    require([k for k,_ in new_lumps]==['MAP01','TEXTMAP','ENDMAP'],'Lumps inesperados')
    expected=m.encode(m.build(dict(old_lumps)['TEXTMAP'].decode())).encode()
    require(dict(new_lumps)['TEXTMAP']==expected,'Reconstrucción de MAP01 no reproducible')
    d=m.parse(expected.decode());v=d['vertex'];s=d['sidedef'];sectors=d['sector']
    require(len(d['thing'])==334,'Things duplicados u omitidos')
    references=[];balance=collections.defaultdict(collections.Counter);edge_keys=set()
    for vertex in v:
        require(-32768<=vertex['x']<=32767 and -32768<=vertex['y']<=32767,'Coordenada fuera de rango')
    for e in d['linedef']:
        require(0<=e['v1']<len(v) and 0<=e['v2']<len(v) and e['v1']!=e['v2'],'Línea inválida')
        key=tuple(sorted((e['v1'],e['v2'])))
        require(key not in edge_keys,'Línea duplicada');edge_keys.add(key)
        front=e.get('sidefront',-1);back=e.get('sideback',-1)
        require(0<=front<len(s),'Falta cara frontal')
        require((back>=0)==bool(e.get('twosided')),'Bandera de doble cara incorrecta')
        require(back<len(s),'Cara posterior inválida')
        for idx,direction in ((front,1),(back,-1)):
            if idx<0:continue
            references.append(idx);sec=s[idx]['sector']
            require(0<=sec<len(sectors),'Sector inválido')
            balance[sec][e['v1']]+=direction;balance[sec][e['v2']]-=direction
    require(sorted(references)==list(range(len(s))),'Caras huérfanas o compartidas')
    require(all(not any(counter.values()) for counter in balance.values()),'Sector abierto')

    lengths=collections.Counter()
    for e in d['linedef']:
        comment=e.get('comment','')
        if comment.startswith('V4.33.0d secret '):
            kind=comment.split()[-1];a,b=v[e['v1']],v[e['v2']]
            lengths[kind]+=math.hypot(a['x']-b['x'],a['y']-b['y'])
            require(bool(e.get('midtex3d'))==(kind=='facade'),'Colisión de pared falsa incorrecta')
            if kind!='inner':require(a['x']==b['x']==1842,'Fachada no paralela al muro oriental')
    require(dict(lengths)=={'entry':96.0,'facade':670.0,'inner':119.0},'Longitudes de fachada incorrectas')
    lift=next(i for i,sec in enumerate(sectors) if sec.get('id')==12000)
    faces=[e for e in d['linedef'] if s[e['sidefront']]['sector']==lift or e.get('sideback',-1)>=0 and s[e['sideback']]['sector']==lift]
    require(len(faces)==4 and all(e.get('special')==206 and e.get('arg0')==12000 for e in faces),'Llamada del ascensor incompleta')
    neighbor_heights=[]
    for e in faces:
        for idx in (e['sidefront'],e['sideback']):
            if s[idx]['sector']!=lift:neighbor_heights.append(sectors[s[idx]['sector']]['heightfloor'])
    require(min(neighbor_heights)==-384 and max(neighbor_heights)==0,'Recorrido vertical nativo inválido')

    # Cada sector excavado conserva tags de pisos previos y una losa con el
    # mismo material en la superficie. Las barandas no deben caer al subsuelo.
    for sec in sectors:
        match=re.fullmatch(r'V4\.33\.0d (cave|lift); original sector (\d+)',sec.get('comment',''))
        if not match:continue
        old=sectors[int(match[2])]
        prior={old.get('id',0)}|{int(x) for x in old.get('moreids','').split()};prior.discard(0)
        require(prior <= {int(x) for x in sec.get('moreids','').split()},'Se perdió un tag de piso previo')
        if match[1]=='cave':
            ctrl=next(e for e in d['linedef'] if e.get('special')==160 and e.get('arg0')==sec['id'])
            roof=sectors[s[ctrl['sidefront']]['sector']]
            require((roof['heightfloor'],roof['heightceiling'],roof['textureceiling'])==(-64,0,old['texturefloor']),'La losa no conserva el terreno anterior')
    for e in d['linedef']:
        if not e.get('comment','').startswith('Caelum railing'):continue
        wanted=float(re.search(r'base z=([\d.]+)',e['comment'])[1])
        base=max(sectors[s[e[k]]['sector']]['heightfloor'] for k in ('sidefront','sideback'))
        for k in ('sidefront','sideback'):
            side=s[e[k]]
            require(abs(base+side.get('offsety_mid',0)/2.583333-wanted)<.001,'Baranda desplazada verticalmente')

    cave_things=[t for t in d['thing'] if m.inside((t.get('x',0),t.get('y',0)),m.UNDERGROUND)]
    require(collections.Counter(t['type'] for t in cave_things)=={18469:1,18470:1,18471:1,18507:1,18510:1,18539:1},'Contenido mineral/herramienta de cueva incorrecto')
    modeldef=(baseline/'MODELDEF').read_text()
    for cls,file in [('CaelumVeinCopper2','ca_vein_copper2.obj'),('CaelumVeinTin2','ca_vein_tin2.obj')]:
        body=re.search(r'Model\s+'+cls+r'\s*\{([^}]+)\}',modeldef)[1]
        require(file in body and (baseline/'models/caelum/world/resources'/file).is_file(),'Veta sin modelo: '+cls)

def audit_package(project,path):
    with zipfile.ZipFile(path) as z:
        require(z.namelist()==sorted(package_files(project)),'Lista de archivos del ZIP incorrecta')
        require(z.testzip() is None,'ZIP dañado')
        for item in z.infolist():
            require(item.date_time==ZIP_TIME,'Fecha ZIP no determinista')
            require(z.read(item.filename)==(project/item.filename).read_bytes(),'ZIP difiere de fuente')
            require(not item.filename.endswith('.pk3'),'No debe incluir PK3')

def main():
    p=argparse.ArgumentParser();p.add_argument('--project-root',type=Path,required=True)
    p.add_argument('--baseline-0c-runtime',type=Path,required=True);p.add_argument('--full-runtime',type=Path,required=True)
    p.add_argument('--package',type=Path);args=p.parse_args()
    project=args.project_root.resolve();baseline=args.baseline_0c_runtime.resolve();runtime=args.full_runtime.resolve()
    for name in PROJECT_FILES:require((project/name).is_file(),'Falta '+name)
    audit_art(project);audit_runtime(project,baseline,runtime);audit_map(project,baseline)
    if args.package:audit_package(project,args.package)
    print('[OK] V4.33.0d: runtime, native map topology, railings, 99 author PNGs and package')

if __name__=='__main__':main()
