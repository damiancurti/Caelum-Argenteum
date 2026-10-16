"""Create a new named observer artifact; retain every prior fixture unchanged."""
import argparse
import json
import zipfile
from pathlib import Path
from prepare import HERE, package

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);p.add_argument('name');a=p.parse_args()
    assert a.name.endswith('.pk3') and '/' not in a.name and '\\' not in a.name
    dest=a.directory/a.name;assert not dest.exists()
    with zipfile.ZipFile(a.directory/'observer.pk3') as z:members={n:z.read(n) for n in z.namelist()}
    members['observer.zs']=(HERE/'observer.zs').read_bytes()
    digest=package(dest,members)
    dest.with_suffix('.json').write_text(json.dumps({'sha256':digest},indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
