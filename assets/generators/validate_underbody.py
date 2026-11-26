"""Validate the reusable anatomy sources, native files and complete pose bindings."""
from pathlib import Path
import hashlib,json,re,struct
ROOT=Path(__file__).resolve().parents[2]

def validate_binding(text,frames=375,slots=10):
    errors=[];declared=set();current={};snapshots={};count=0;seen_frame=False
    for line in text.splitlines():
        model=re.fullmatch(r'\s*Model (\d+) "[^"]+"\s*',line)
        if model:
            if seen_frame:errors.append('Model declared after frame snapshots began')
            declared.add(int(model[1]))
        frame=re.fullmatch(r'\s*FrameIndex (\w+) (\w) (\d+) (\d+)\s*',line)
        if frame:
            seen_frame=True;count+=1;current[int(frame[3])]=int(frame[4]);snapshots[(frame[1],frame[2])]=dict(current)
    if declared!=set(range(slots)):errors.append('Incomplete model-slot declarations')
    if count!=frames*slots or len(snapshots)!=frames:errors.append('Incorrect frame/slot registration count')
    mismatches=[]
    for index in range(frames):
        key=(f'D3{index//26:02X}',chr(65+index%26))
        if snapshots.get(key)!={slot:index for slot in range(slots)}:mismatches.append(index)
    if mismatches:errors.append(f'Frame snapshots carry stale other-slot poses: {mismatches[:8]} ({len(mismatches)} total)')
    return errors

def validate(root=ROOT):
    errors=[]
    try:
        art=root/'assets/source/art/underbody_827';cfg=json.loads((art/'DESIGN.json').read_text());report=json.loads((art/'EXPORT.json').read_text())
        pairs=[(root/cfg['source'],cfg['source_sha256']),(root/cfg['accepted_rig'],cfg['accepted_rig_sha256']),
         (root/cfg['skin'],cfg['skin_sha256']),(root/cfg['editable_source'],cfg['editable_sha256']),
         (root/cfg['editable_source'],report['source_sha256']),(art/'DESIGN.json',report['config_sha256']),
         (root/'assets/generators/export_underbody.py',report['generator_sha256']),
         (root/'assets/generators/author_underbody.py',report['authoring_generator_sha256'])]
        for path,expected in pairs:
            if hashlib.sha256(path.read_bytes()).hexdigest()!=expected:errors.append('Underbody stale input '+path.name)
        for name,expected in report['sha256'].items():
            path=art/'underbody_preview.modeldef' if name=='MODELDEF' else root/'src'/name
            if hashlib.sha256(path.read_bytes()).hexdigest()!=expected:errors.append('Underbody stale export '+name)
        for key,counts in report['modules'].items():
            blob=(root/'src'/cfg['module_path']/(key+'.md3')).read_bytes();header=struct.unpack_from('<4sI64s9I',blob)
            surface=struct.unpack_from('<4s64s10I',blob,header[10])
            if header[:2]!=(b'IDP3',15) or header[6]!=1 or header[11]!=len(blob):errors.append('Underbody invalid native container '+key)
            if (surface[3],surface[5],surface[6])!=(375,counts['vertices'],counts['triangles']):errors.append('Underbody native counts differ '+key)
            neighbors={i:set() for i in range(surface[5])};edges={}
            for i in range(surface[6]):
                triangle=struct.unpack_from('<3I',blob,header[10]+surface[7]+i*12)
                for a,b in zip(triangle,(*triangle[1:],triangle[0])):
                    neighbors[a].add(b);neighbors[b].add(a);edges.setdefault(tuple(sorted((a,b))),[]).append((a,b))
            visited=set();pending=[0]
            while pending:
                vertex=pending.pop()
                if vertex in visited:continue
                visited.add(vertex);pending.extend(neighbors[vertex]-visited)
            if len(visited)!=surface[5] or counts.get('connected_components')!=1:errors.append('Underbody disconnected native mesh '+key)
            if any(len(v)!=2 or v[0]!=v[1][::-1] for v in edges.values()):errors.append('Underbody open native mesh '+key)
        if report['actions']!=24 or report['frames']!=375 or report['quantized_wrist_checks']!=375*report['wrist_pairs']:errors.append('Underbody incomplete sampled wrist continuity')
        errors.extend('Underbody '+e for e in validate_binding((art/'underbody_preview.modeldef').read_text()))
        if not (root/'src/licenses/UNDERBODY_827.txt').is_file():errors.append('Missing underbody attribution')
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append('Underbody: '+str(exc))
    return errors

if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
