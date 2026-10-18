"""Archive selected textual evidence only, with per-member byte hashes."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--directories',nargs='+',required=True)
    p.add_argument('--session',required=True)
    p.add_argument('--collector-directory')
    a=p.parse_args();selected={}
    for directory in a.directories:
        folder=ROOT/'build'/directory
        for path in folder.iterdir():
            if path.is_file() and path.suffix in ('.json','.txt','.cfg','.ini','.csv','.md'):
                selected[directory+'/'+path.name]=path
    for name in ('power-request.json','collector-state.json','collector-stderr.txt','collector-stdout.txt','keep_awake.ps1','collect_presentmon.ps1'):
        selected['session/'+name]=ROOT/'build'/a.session/name
    if a.collector_directory:
        folder=ROOT/'build'/a.collector_directory
        for path in folder.iterdir():
            if path.is_file() and path.suffix in ('.json','.txt','.ps1'):
                selected['collector/'+path.name]=path
    archive=a.output/'evidence.zip';assert not archive.exists(),'Preserve existing evidence archives'
    hashes={}
    with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as output:
        for name,path in sorted(selected.items()):
            raw=path.read_bytes();hashes[name]=hashlib.sha256(raw).hexdigest()
            info=zipfile.ZipInfo(name,(2026,10,18,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o644<<16
            output.writestr(info,raw,compress_type=zipfile.ZIP_DEFLATED,compresslevel=9)
    record=dict(archive=archive.name,archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),member_count=len(hashes),members=hashes,
        exclusions='No engine, IWAD, PK3, private save or unrelated user configuration.')
    (a.output/'evidence.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
    with zipfile.ZipFile(archive) as check:
        assert set(check.namelist())==set(hashes)
        assert all(hashlib.sha256(check.read(n)).hexdigest()==h for n,h in hashes.items())
    print(json.dumps({k:v for k,v in record.items() if k!='members'}))

if __name__=='__main__':main()
