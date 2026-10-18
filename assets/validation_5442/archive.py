"""Archive only textual test evidence; never package private game dependencies."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--session', required=True)
    parser.add_argument('--normal', help='Normal package loading-smoke directory')
    args = parser.parse_args()
    folder = ROOT / 'build' / args.directory
    session = ROOT / 'build' / args.session
    selected = {}
    for path in folder.iterdir():
        if not path.is_file():
            continue
        if path.name.startswith(('matrix-', 'audit-', 'checks0', 'seed01')) and path.suffix in ('.json','.txt','.cfg','.ini','.csv'):
            selected['native/' + path.name] = path
        elif path.name in ('manifest.json','analysis.json','seed.cfg','checks.cfg'):
            selected['native/' + path.name] = path
    for name in ('power-request.json','collector-state.json','collector-stderr.txt','collector-stdout.txt','keep_awake.ps1','collect_presentmon.ps1','determinism.json'):
        selected['session/' + name] = session / name
    if args.normal:
        for path in (ROOT/'build'/args.normal).iterdir():
            if path.is_file() and (path.suffix in ('.json','.txt','.cfg','.ini') or path.name in ('MAPINFO','ZSCRIPT')):
                selected['normal/' + path.name] = path
    archive = HERE / 'evidence.zip'
    assert not archive.exists(), 'Do not overwrite an evidence archive.'
    hashes = {}
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for name,path in sorted(selected.items()):
            raw = path.read_bytes()
            hashes[name] = hashlib.sha256(raw).hexdigest()
            info = zipfile.ZipInfo(name, (2026,10,18,0,0,0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            output.writestr(info, raw, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    record = dict(archive=archive.name, archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),
                  member_count=len(hashes), members=hashes,
                  exclusions='No engine, IWAD, PK3, private save, or unrelated user configuration.')
    (HERE / 'evidence.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:v for k,v in record.items() if k!='members'}))


if __name__ == '__main__':
    main()
