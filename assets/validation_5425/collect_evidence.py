"""Preserve selected native logs/configuration and hashes; never export IWADs, engines or saves."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('directory',type=Path);p.add_argument('--destination',type=Path,required=True)
    p.add_argument('--labels',nargs='+',required=True)
    a=p.parse_args();a.destination.mkdir(parents=True,exist_ok=True);records=[]
    for label in a.labels:
        for suffix in ('.txt','-run.json','.ini','-bench.txt','-scene.png'):
            source=a.directory/(label+suffix)
            if not source.exists():continue
            raw=source.read_bytes();name=a.directory.name+'-'+source.name
            if suffix.endswith('.txt'):name+='.gz';data=gzip.compress(raw,mtime=0)
            else:data=raw
            target=a.destination/name
            if target.exists() and target.read_bytes()!=data:raise SystemExit('Refusing to replace evidence: '+str(target))
            target.write_bytes(data)
            records.append({'source':source.as_posix(),'artifact':name,'raw_sha256':hashlib.sha256(raw).hexdigest()})
    manifest=a.destination/(a.directory.name+'-evidence.json')
    existing=json.loads(manifest.read_text()) if manifest.exists() else []
    merged={r['artifact']:r for r in existing+records}
    manifest.write_text(json.dumps(list(merged.values()),indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
