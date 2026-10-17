"""Conservative MAP06 simplification and a separately labelled opaque-space control.

No production source is written. Closed-space mode deliberately changes overhead
space and is not a gameplay-equivalent optimization.
"""
from pathlib import Path
import argparse
import collections
import hashlib
import json
import sys
import zipfile
from geometry_probe import read_wad,pack_wad,parse

ROOT=Path(__file__).resolve().parents[2]

sys.path.insert(0,str(ROOT/'assets/generators'))
from compact_open_geometry import compact_open_geometry as optimize

def close_interiors(groups):
    sys.path.insert(0,str(ROOT/'assets/generators'))
    import generate_city_interiors as interiors
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text())
    tags={b['tag'] for b in interiors.houses(city)}
    data=interiors.DATA;changes=collections.Counter()
    for sector in groups['sector']:
        if sector.get('textureceiling')!='"F_SKY1"':continue
        if int(sector.get('id','0')) in tags:
            sector['heightceiling']=str(data['headroom']);sector['textureceiling']='"'+data['roof']+'"';changes['interior_ceilings']+=1
        elif float(sector['heightfloor'])==data['height']:
            sector['heightceiling']=sector['heightfloor'];sector['textureceiling']=sector['texturefloor'];changes['closed_wall_sectors']+=1
    return dict(changes)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    p.add_argument('--mode',choices=('safe','closed-interiors'),default='safe');a=p.parse_args()
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=True)
    target=out/(a.mode+'.pk3');assert not target.exists(),'Retain earlier evidence'
    source=ROOT/'src/maps/MAP06.wad';lumps=read_wad(source)
    groups=parse(dict(lumps)['TEXTMAP'].decode());before={k:len(v) for k,v in groups.items()}
    changes=optimize(groups) if a.mode=='safe' else close_interiors(groups)
    text='namespace = "ZDoom";\n'+''.join(kind+'\n{\n'+''.join(f'{k} = {v};\n' for k,v in fields.items())+'}\n'
        for kind in ('vertex','sector','sidedef','linedef','thing') for fields in groups[kind])
    wad=pack_wad([(n,text.encode() if n=='TEXTMAP' else v) for n,v in lumps if n not in ('ZNODES','BLOCKMAP','REJECT')])
    with zipfile.ZipFile(target,'w',zipfile.ZIP_STORED) as z:z.writestr(zipfile.ZipInfo('maps/MAP06.wad',(2000,1,1,0,0,0)),wad)
    report={'mode':a.mode,'scope':'Isolated fresh-map candidate; native/visual/save verification pending',
        'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'before':before,
        'after':{k:len(v) for k,v in groups.items()},'changes':changes,'overlay_sha256':hashlib.sha256(target.read_bytes()).hexdigest()}
    target.with_suffix('.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))

if __name__=='__main__':main()
