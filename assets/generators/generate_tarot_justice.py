"""Append the approved Justice arena, retaining exact reversible map baselines.

Existing TEXTMAP bytes and lump order are preserved. The appended sector carries
its own marker property, so legacy maps cannot accidentally acquire an arena.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import re
import struct
import zipfile
try:
    from .tarot_example_geometry import append_examples
except ImportError:
    from tarot_example_geometry import append_examples

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets/tarot_justice'
BLOCK = re.compile(r'\b(vertex|sector|sidedef|linedef|thing)\s*\{(.*?)\}', re.S)
FIELD = re.compile(r'(\w+)\s*=\s*("(?:[^"\\]|\\.)*"|[^;]+);')


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def lumps(blob):
    magic, count, directory = struct.unpack_from('<4sii', blob)
    assert magic in (b'PWAD', b'IWAD')
    result = []
    for i in range(count):
        start, size, name = struct.unpack_from('<ii8s', blob, directory + 16*i)
        result.append((name.rstrip(b'\0').decode('ascii'), blob[start:start+size]))
    return result


def pack(entries):
    payload = bytearray(); directory = bytearray()
    for name, blob in entries:
        directory += struct.pack('<ii8s', 12+len(payload), len(blob), name.encode('ascii'))
        payload += blob
    return struct.pack('<4sii', b'PWAD', len(entries), 12+len(payload)) + payload + directory


def parse(text):
    groups = {key: [] for key in ('vertex', 'sector', 'sidedef', 'linedef', 'thing')}
    for kind, body in BLOCK.findall(text):
        groups[kind].append({key: json.loads(value.strip()) for key, value in FIELD.findall(body)})
    return groups


def validate(root):
    """Read-only package checks; fail if another map generator dropped an arena."""
    directory=root/'assets/tarot_justice'
    manifest=json.loads((directory/'MAPS.json').read_text(encoding='utf-8'))
    problems=[]
    if digest((directory/'ARENA.json').read_bytes())!=manifest['settings_sha256']:
        problems.append('Justice arena settings changed; regenerate the geometry')
    if digest((directory/'legacy_5133.zip').read_bytes())!=manifest['archive_sha256']:
        problems.append('Pre-Justice map archive checksum mismatch')
    if digest((root/'src/caelum/data/CaelumJusticeGeometry.zs').read_bytes())!=manifest['index_sha256']:
        problems.append('Stale Justice geometry index')
    if digest((root/'assets/tarot_examples/ROOM.json').read_bytes())!=manifest.get('examples_settings_sha256'):
        problems.append('Stale Tarot example geometry settings')
    baseline=json.loads((root/'assets/tarot_examples/BASELINE.json').read_text(encoding='utf-8'))
    if digest((root/'assets/tarot_examples'/baseline['baseline_file']).read_bytes())!=baseline['baseline_sha256']:
        problems.append('Pre-example mansion baseline checksum mismatch')
    for row in manifest['maps']:
        if digest((root/'src/maps'/row['file']).read_bytes())!=row['sha256']:
            problems.append(f'Stale Justice arena geometry: {row["file"]}')
    return problems


def append_arena(blob, data):
    entries = lumps(blob)
    text = dict(entries)['TEXTMAP'].decode('utf-8')
    assert 'user_ca_tarot_justice' not in text, 'Input must be the preserved pre-arena map'
    groups = parse(text)
    vertices = groups['vertex']; grid = data['grid_mu']
    width = data['width_m'] * data['units_per_metre']
    x0, x1 = min(v['x'] for v in vertices), max(v['x'] for v in vertices)
    y0, y1 = min(v['y'] for v in vertices), max(v['y'] for v in vertices)
    options = [(math.ceil(x1/grid)*grid+grid, math.ceil(y1/grid)*grid+grid),
               (math.floor(x0/grid)*grid-grid-width, math.floor(y0/grid)*grid-grid-width)]
    origin = next(((x,y) for x,y in options if -32768<x and x+width<32767 and -32768<y and y+width<32767), None)
    if origin is None:
        raise ValueError('No arena fits beyond the map bounds within native coordinates')
    x,y = origin; vi=len(vertices); si=len(groups['sidedef']); sector=len(groups['sector'])
    added=['\n// #440 Justice: appended independent room; original source above is unchanged.']
    added.append('sector{' + f'heightfloor=0;heightceiling={data["headroom_mu"]};lightlevel={data["light"]};'
                 + f'texturefloor="{data["floor"]}";textureceiling="{data["ceiling"]}";user_ca_tarot_justice=true;' + '}')
    for vx,vy in [(x,y),(x+width,y),(x+width,y+width),(x,y+width)]:
        added.append(f'vertex{{x={vx};y={vy};}}')
    for i in range(4):
        added.append(f'sidedef{{sector={sector};texturemiddle="{data["wall"]}";}}')
        added.append(f'linedef{{v1={vi+(i+1)%4};v2={vi+i};sidefront={si+i};blocking=true;}}')
    result=[]
    for name, content in entries:
        # Current maps contain TEXTMAP only. Refuse a silent stale-node rewrite.
        if name not in (entries[0][0], 'TEXTMAP', 'ENDMAP'):
            raise ValueError(f'Unexpected lump requiring explicit preservation: {name}')
        result.append((name, content+('\n'.join(added)+'\n').encode() if name=='TEXTMAP' else content))
    return pack(result), {'sector':sector,'origin':[x,y,0],'center':[x+width/2,y+width/2,0],
                          'width_mu':width,'original_vertices':vi,'original_sectors':sector}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture-baseline', action='store_true')
    parser.add_argument('--check', action='store_true')
    args=parser.parse_args()
    data=json.loads((DATA/'ARENA.json').read_text(encoding='utf-8'))
    archive=DATA/'legacy_5133.zip';manifest_path=DATA/'MAPS.json'
    if args.capture_baseline:
        if archive.exists() or manifest_path.exists():
            raise ValueError('Baseline already exists; it is immutable')
        rows=[]
        with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as output:
            for path in sorted((ROOT/'src/maps').glob('*.wad')):
                blob=path.read_bytes();assert b'user_ca_tarot_justice' not in blob
                info=zipfile.ZipInfo(path.name,(2000,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
                output.writestr(info,blob,compresslevel=9)
                rows.append({'file':path.name,'legacy_sha256':digest(blob)})
        manifest={'issue':440,'revision':data['revision'],'baseline_commit':'3bd162e33',
                  'archive_sha256':digest(archive.read_bytes()),'maps':rows}
    else:
        manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
    assert digest(archive.read_bytes())==manifest['archive_sha256']
    # Refuse to overwrite unrelated geometry edits, before writing any map.
    if not args.check:
        for row in manifest['maps']:
            current=digest((ROOT/'src/maps'/row['file']).read_bytes())
            assert current in (row['legacy_sha256'],row.get('sha256')), \
                f"Unrecognized map edits: {row['file']}; preserve and review the new baseline explicitly"
    changed=0
    with zipfile.ZipFile(archive) as baseline:
        for row in manifest['maps']:
            old=baseline.read(row['file']);assert digest(old)==row['legacy_sha256']
            new,geometry=append_arena(old,data)
            new,examples=append_examples(new)
            if examples is not None:geometry['examples']=examples
            path=ROOT/'src/maps'/row['file']
            if args.check:
                assert path.read_bytes()==new, f'Stale Justice map: {path.name}'
                assert row['sha256']==digest(new) and row['geometry']==geometry
            else:
                if path.read_bytes()!=new:path.write_bytes(new);changed+=1
                row.update(sha256=digest(new),geometry=geometry)
            if examples is not None:
                example_report=(json.dumps(examples,indent=2)+'\n').encode()
                example_path=ROOT/'assets/tarot_examples/GEOMETRY.json'
                if args.check:assert example_path.read_bytes()==example_report,'Stale Tarot example geometry report'
                else:example_path.write_bytes(example_report)
    native=['// #440: generado desde assets/tarot_justice; sin buscar sectores por tic.',
            'class CaelumJusticeGeometry : Object', '{',
            f'    const REVISION={data["revision"]};',
            f'    const WIDTH={data["width_m"]*data["units_per_metre"]};',
            '    static clearscope int SectorIndex(String map) {',
            '        if(map==CaelumHuntData.Map())return CaelumHuntData.JUSTICE_SECTOR;']
    for row in manifest['maps']:
        native.append(f'        if(map=="{Path(row["file"]).stem}")return {row["geometry"]["sector"]};')
    native+=['        return -1; }', '    static clearscope vector3 Center(String map) {',
             '        if(map==CaelumHuntData.Map())return CaelumHuntData.JusticeCenter();']
    for row in manifest['maps']:
        xyz=','.join(f'{v:g}' for v in row['geometry']['center'])
        native.append(f'        if(map=="{Path(row["file"]).stem}")return ({xyz});')
    native+=['        return (0,0,0); }',
             '    static clearscope Sector Get()', '    {',
             '        int index=SectorIndex(level.MapName);',
             '        if(index<0 || index>=level.Sectors.Size())return null;',
             '        let sector=level.Sectors[index];',
             '        return sector.GetUDMFInt("user_ca_tarot_justice")!=0?sector:null;',
             '    }', '}']
    output=('\n'.join(native)+'\n').encode('utf-8')
    target=ROOT/'src/caelum/data/CaelumJusticeGeometry.zs'
    if args.check:assert target.read_bytes()==output, 'Stale Justice geometry index'
    else:target.write_bytes(output)
    if not args.check:
        manifest['settings_sha256']=digest((DATA/'ARENA.json').read_bytes())
        manifest['index_sha256']=digest(output)
        manifest['examples_settings_sha256']=digest((ROOT/'assets/tarot_examples/ROOM.json').read_bytes())
        manifest_path.write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'maps':len(manifest['maps']),'changed':changed,'checked':args.check,'legacy_archive_sha256':manifest['archive_sha256']}))


if __name__=='__main__':
    main()
