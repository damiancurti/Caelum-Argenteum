"""Prepare/run matched house-hub versus full-height opaque house walls (#318)."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile

from geometry_probe import read_wad, pack_wad, parse

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('ca318_prepare',HERE/'prepare.py')
prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)
sys.path.insert(0,str(ROOT/'assets/generators'))
import generate_house_hubs as hubs


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def opaque_wad():
    lumps=read_wad(ROOT/'src/maps/MAP06.wad')
    text=dict(lumps)['TEXTMAP'].decode()
    data=parse(text);homes=hubs.interiors.houses(hubs.CITY)
    candidates={i for i,s in enumerate(data['sector']) if int(s['heightfloor'])==hubs.interiors.DATA['height']}
    assert candidates
    # Compaction shares a sector with unrelated 184-MU structures. Split only
    # the house faces, preserving every vertex, line, texture and map thing.
    selected=set()
    for line in data['linedef']:
        points=[tuple(int(data['vertex'][int(line[key])][axis]) for axis in ('x','y'))
                for key in ('v1','v2')]
        if not any(all(x<=a<=x2 and y<=b<=y2 for a,b in points)
                   for x,y,x2,y2 in (home['bounds'] for home in homes)):
            continue
        for key in ('sidefront','sideback'):
            if key in line and int(data['sidedef'][int(line[key])]['sector']) in candidates:
                selected.add(int(line[key]))
    assert selected
    after=parse(text);copies={};heights=[]
    for side in sorted(selected):
        source=int(data['sidedef'][side]['sector'])
        if source not in copies:
            sector=dict(data['sector'][source]);sector['heightfloor']=sector['heightceiling']
            # hw_CheckClip deliberately keeps a closed boundary open when both
            # ceiling textures are sky. The closed house sector needs its owned
            # opaque roof material even though its floor and ceiling coincide.
            assert sector['texturefloor'] != '"F_SKY1"'
            sector['textureceiling']=sector['texturefloor']
            heights.append(int(sector['heightceiling']));copies[source]=len(after['sector'])
            after['sector'].append(sector)
        after['sidedef'][side]['sector']=str(copies[source])
    for kind in ('vertex','linedef','thing'):assert data[kind]==after[kind]
    assert after['sector'][:len(data['sector'])]==data['sector']
    changed='namespace = "ZDoom";\n'+''.join(kind+'\n{\n'+''.join(f'{k} = {v};\n' for k,v in record.items())+'}\n'
        for kind in ('vertex','sector','sidedef','linedef','thing') for record in after[kind])
    output=pack_wad([(n,changed.encode() if n=='TEXTMAP' else v) for n,v in lumps
                     if n not in ('ZNODES','BLOCKMAP','REJECT')])
    return output,{'added_house_sectors':len(copies),'reassigned_house_sides':len(selected),'original_roof':hubs.interiors.DATA['height'],
                   'occluder_tops':sorted(set(heights)),
                   'closed_sector_ceiling_material':'Existing opaque house roof, not F_SKY1; avoids the native both-sky clipping exception.',
                   'unchanged_vertices_lines_things_and_original_sectors':True,
                   'textmap_md5':hashlib.md5(changed.encode()).hexdigest(),
                   'wad_sha256':hashlib.sha256(output).hexdigest(),
                   'scope':'Author-approved diagnostic only: same private interiors and XY footprints; roof/flight/visibility/thermal geometry changes.'}


def build(directory,source):
    out=ROOT/'build'/directory;out.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(ROOT/'build'/source/'current/runtime.pk3') as z:
        original={n:z.read(n) for n in z.namelist()}
    assert original['maps/MAP06.wad']==(ROOT/'src/maps/MAP06.wad').read_bytes()
    opaque,geometry=opaque_wad()
    prepare.METHODS['CaelumHouseResidents']='Tick CreateResident PrepareCity PrepareHouse PrepareOtherMap BeginDeployment PreTravelled Travelled'
    prepare.METHODS['CaelumHouseResident']='Suspend Resume ParkBinding'
    prepare.ALWAYS.update(('BeginDeployment','PrepareCity','PrepareHouse','PreTravelled','Travelled'))
    for shape in ('houses','opaque'):
        for population,profiled in ((6000,False),(1000,False),(1000,True),(6000,True)):
            name=f'{shape}-{population}'+('-profile' if profiled else '')
            work=out/name;work.mkdir(exist_ok=False)
            members=original.copy();meta={'source':source,'shape':shape,'mandingas':population,
                                         'defender_identities':600,'geometry':geometry if shape=='opaque' else 'Original 184-MU house shells'}
            if shape=='opaque':
                members['maps/MAP06.wad']=opaque
                catalogue='caelum/data/CaelumCartographyCatalogueData.zs'
                members[catalogue]=re.sub(rb'(MAP06_CHECKSUM = ")[^"]+',lambda m:m[1]+geometry['textmap_md5'].encode(),members[catalogue])
            if population==1000:
                prepare.replace(members,'/CaelumPortData.zs','return IsSouth()?6000:MANDINGAS;','return MANDINGAS;')
                meta['population_scope']='Author-requested diagnostic; no production budget change'
            if profiled:
                meta['methods']=prepare.profile(members)
                members['ZSCRIPT']+=b'\n#include "ca318_profiler.zs"\n'
                members['ca318_profiler.zs']=(HERE/'profiler.zs').read_bytes()
                members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA318Profiler" }\n'
            meta['runtime_sha256']=prepare.package(work/'runtime.pk3',members)
            with zipfile.ZipFile(ROOT/'build'/source/'current/observer.pk3') as z:
                fixture={n:z.read(n) for n in z.namelist()}
            fixture['observer.zs']=(HERE/'observer.zs').read_bytes()
            prepare.package(work/'observer.pk3',fixture)
            meta['fixture_sha256']=digest(work/'observer.pk3')
            (work/'manifest.json').write_text(json.dumps(meta,indent=2)+'\n',encoding='utf-8')
            print('PREPARED',name,flush=True)
    (out/'GEOMETRY.json').write_text(json.dumps(geometry,indent=2)+'\n',encoding='utf-8')


def run(directory,part):
    plans=[]
    if part=='peace':
        for pitch in (0,75):
            for repeat,shape in enumerate(('houses','opaque','opaque','houses'),1):
                plans.append((f'{shape}-6000',f'peace-{pitch}-{repeat}',0,0,pitch,140,350,240))
    elif part=='siege1000':
        for site in (0,4):
            for repeat,shape in enumerate(('houses','opaque','opaque','houses'),1):
                plans.append((f'{shape}-1000',f'siege1000-{site}-{repeat}',1,site,0,700,1050,600))
    elif part=='siege6000':
        for repeat,shape in enumerate(('houses','opaque','opaque','houses'),1):
            plans.append((f'{shape}-6000',f'siege6000-{repeat}',1,0,0,700,1050,600))
    elif part=='profiles':
        for shape in ('houses','opaque'):
            plans.append((f'{shape}-1000-profile','profile-siege1000',1,0,0,700,350,600))
    elif part=='profiles6000':
        for shape in ('houses','opaque'):
            plans.append((f'{shape}-6000-profile','profile-siege6000',1,0,0,700,350,600))
    elif part=='interior':
        for repeat,shape in enumerate(('houses','opaque','opaque','houses'),1):
            plans.append((f'{shape}-6000',f'house-interior-{repeat}',0,-1,0,140,350,240))
    elif part=='render':
        for pitch in (0,75):
            for shape in ('houses','opaque'):
                plans.append((f'{shape}-6000',f'render-{pitch}',0,0,pitch,140,350,240))
    outcomes=[]
    for variant,label,phase,site,pitch,warmup,window,timeout in plans:
        stop=ROOT/'build'/directory/'stop-after-current.signal'
        if stop.exists() and stop.read_text().strip()=='stop':break
        cmd=[sys.executable,str(HERE/'run.py'),'--directory',directory,'--variant',variant,'--label',label,
             '--phase',str(phase),'--site',str(site),'--pitch',str(pitch),'--warmup',str(warmup),
             '--window',str(window),'--timeout',str(timeout),'--global-presentmon','--postwait','210']
        if part=='interior':cmd+=['--commands','wait 70; changemap CAH158']
        result=subprocess.run(cmd,cwd=ROOT)
        outcomes.append({'variant':variant,'label':label,'returncode':result.returncode})
        (ROOT/'build'/directory/f'{part}-outcomes.json').write_text(json.dumps(outcomes,indent=2)+'\n',encoding='utf-8')
        # A bounded watchdog is itself a result. Preserve it, then test the paired
        # shape, rather than silently dropping the expensive half of the comparison.
        if result.returncode and not (ROOT/'build'/directory/variant/f'{label}-run.json').exists():
            raise RuntimeError('Setup failed before an isolated engine run')


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode',choices=('prepare','prepare-full-profiles','peace','siege1000','siege6000','profiles','profiles6000','interior','render'))
    p.add_argument('--directory',required=True,help='Fresh evidence directory; existing labels are never overwritten')
    p.add_argument('--source',default='issue318-houses-09')
    p.add_argument('--reuse',help='Reuse immutable runtime packages; refresh observer only')
    args=p.parse_args()
    if args.mode=='prepare-full-profiles':
        out=ROOT/'build'/args.directory
        for shape in ('houses','opaque'):
            original=out/f'{shape}-1000-profile';work=out/f'{shape}-6000-profile'
            work.mkdir(exist_ok=False)
            with zipfile.ZipFile(original/'runtime.pk3') as z:
                members={name:z.read(name) for name in z.namelist()}
            prepare.replace(members,'/CaelumPortData.zs','return MANDINGAS;','return IsSouth()?6000:MANDINGAS;')
            meta=json.loads((original/'manifest.json').read_text())
            meta['mandingas']=6000
            meta['population_scope']='Normal authored 6,000 attackers and 600 defender identities; separate instrumented run'
            meta['runtime_sha256']=prepare.package(work/'runtime.pk3',members)
            os.link(original/'observer.pk3',work/'observer.pk3')
            (work/'manifest.json').write_text(json.dumps(meta,indent=2)+'\n',encoding='utf-8')
            print('PREPARED',work.name,flush=True)
    elif args.mode=='prepare' and args.reuse:
        out=ROOT/'build'/args.directory;out.mkdir(exist_ok=True)
        source=ROOT/'build'/args.reuse
        for original in sorted(source.iterdir()):
            if not (original/'runtime.pk3').is_file():continue
            work=out/original.name;work.mkdir(exist_ok=False)
            os.link(original/'runtime.pk3',work/'runtime.pk3')
            with zipfile.ZipFile(original/'observer.pk3') as z:fixture={n:z.read(n) for n in z.namelist()}
            fixture['observer.zs']=(HERE/'observer.zs').read_bytes()
            meta=json.loads((original/'manifest.json').read_text())
            meta['fixture_sha256']=prepare.package(work/'observer.pk3',fixture)
            meta['runtime_reused_from']=args.reuse+'/'+original.name
            (work/'manifest.json').write_text(json.dumps(meta,indent=2)+'\n',encoding='utf-8')
        shutil.copyfile(source/'GEOMETRY.json',out/'GEOMETRY.json')
        print('Reused immutable runtimes with collision-checked observer',flush=True)
    elif args.mode=='prepare':build(args.directory,args.source)
    else:run(args.directory,args.mode)


if __name__=='__main__':main()
