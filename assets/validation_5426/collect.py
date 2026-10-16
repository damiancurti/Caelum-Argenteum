"""Preserve #305 native evidence through the shared immutable-log collector."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys

HERE=Path(__file__).resolve().parent

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directories',nargs='+',type=Path)
    args=parser.parse_args()
    destination=HERE/'evidence'
    destination.mkdir(exist_ok=True)
    for directory in args.directories:
        labels=[p.name.removesuffix('-run.json') for p in sorted(directory.glob('*-run.json'))]
        if labels:
            subprocess.run([sys.executable,str(HERE.parent/'validation_5425/collect_evidence.py'),
                str(directory),'--destination',str(destination),'--labels',*labels],check=True)
        records=[]
        for pattern in ('*manifest.json','*.cfg'):
            for source in sorted(directory.glob(pattern)):
                raw=source.read_bytes();name=directory.name+'-'+source.name;target=destination/name
                if target.exists() and target.read_bytes()!=raw:
                    raise SystemExit('Refusing to replace evidence: '+str(target))
                target.write_bytes(raw)
                records.append({'source':source.as_posix(),'artifact':name,'raw_sha256':hashlib.sha256(raw).hexdigest()})
        (destination/(directory.name+'-inputs.json')).write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
