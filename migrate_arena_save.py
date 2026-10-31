"""Preserve an original GZDoom save and migrate its approved PvP damage rule.

Only the saved level's scalar teamdamage is changed. The native engine restores
that value instead of the current MAPINFO setting when loading an old level.
No actors, inventory references, geometry checksums or other save fields change.
"""
from pathlib import Path
import argparse, hashlib, io, json, os, zipfile

REVISION=1
MANIFEST='caelum-arena-migration.json'

def migrate(data: bytes) -> bytes:
    with zipfile.ZipFile(io.BytesIO(data)) as source:
        names=source.namelist()
        if len(names)!=len(set(names)) or source.testzip() is not None:
            raise ValueError('Duplicate or corrupt native save members.')
        info=json.loads(source.read('info.json'))
        if info.get('Engine')!='GZDOOM' or info.get('Save Version')!=4560:
            raise ValueError('Only native GZDoom 4.14.2 save revision 4560 is supported.')
        if MANIFEST in names:
            record=json.loads(source.read(MANIFEST))
            if record.get('revision')!=REVISION:raise ValueError('Unsupported arena migration revision.')
        changed={}
        for name in names:
            if not name.endswith('.map.json'):continue
            level=json.loads(source.read(name))
            if level.get('saveversion')!=4560 or not isinstance(level.get('objects'),list):
                raise ValueError('Unsupported saved level: '+name)
            if level.get('teamdamage')!=1:
                level['teamdamage']=1.0
                changed[name]=json.dumps(level,ensure_ascii=False,separators=(',',':')).encode('utf-8')
        if not changed:return data
        if MANIFEST in names:raise ValueError('A migrated save changed its approved damage rule; refusing to guess.')
        target=io.BytesIO()
        with zipfile.ZipFile(target,'w',compression=zipfile.ZIP_DEFLATED) as result:
            for entry in source.infolist():result.writestr(entry,changed.get(entry.filename,source.read(entry.filename)))
            result.writestr(MANIFEST,json.dumps({'issue':438,'revision':REVISION,'original_sha256':hashlib.sha256(data).hexdigest(),'levels':sorted(changed)},sort_keys=True))
        return target.getvalue()

def write_copy(source: Path,target: Path) -> None:
    data=migrate(source.read_bytes())
    with target.open('xb') as stream:
        stream.write(data);stream.flush();os.fsync(stream.fileno())

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path);parser.add_argument('destination',type=Path)
    args=parser.parse_args();write_copy(args.source,args.destination)
    print('Migrated copy written; original save preserved: '+str(args.destination))
