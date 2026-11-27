"""Check meal topology, unchanged neutral samples and repeat-export bytes."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]

def md3(path):
    blob=path.read_bytes();head=struct.unpack_from('<4sI64s9I',blob);start=head[10]
    surface=struct.unpack_from('<4s64s10I',blob,start)
    return {'vertices':surface[5],'frames':surface[3],
            'triangles':blob[start+surface[7]:start+surface[8]],
            'uv':blob[start+surface[9]:start+surface[10]],
            'poses':blob[start+surface[10]:start+surface[11]]}

def positions(model,frame):
    size=model['vertices']*8;blob=model['poses'][frame*size:(frame+1)*size]
    return [xyz[:3] for xyz in struct.iter_unpack('<3hH',blob)]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repeat',type=Path,required=True)
    parser.add_argument('--report',type=Path,required=True)
    args=parser.parse_args();manifest=json.loads((ROOT/'assets/source/art/rest_motion_460/MODELS.json').read_text())
    result={'issue':460,'models':0,'neutral_vertices':0,'wrist_checks':0,'errors':[]}
    for family in manifest['families']:
        result['wrist_checks']+=family['wrist_checks']
        for relative,expected in family['sha256'].items():
            target=ROOT/'src'/relative;repeat=args.repeat/relative
            if hashlib.sha256(target.read_bytes()).hexdigest()!=expected or repeat.read_bytes()!=target.read_bytes():
                result['errors'].append(relative+': hash/determinism')
            original=ROOT/'src'/relative.replace('rest_motion/'+family['mode']+'/', '')
            new,old=md3(target),md3(original)
            if new['vertices']!=old['vertices'] or new['triangles']!=old['triangles'] or new['uv']!=old['uv']:
                result['errors'].append(relative+': topology/UV')
            for current,legacy in [(0,122),(14,136)]:
                a,b=positions(new,current),positions(old,legacy)
                different=sum(x!=y for x,y in zip(a,b))
                if different:result['errors'].append(relative+f': neutral {current}: {different} changed vertices')
                result['neutral_vertices']+=len(a)
            result['models']+=1
    args.report.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))
    if result['errors']:raise SystemExit(1)

if __name__=='__main__':main()
