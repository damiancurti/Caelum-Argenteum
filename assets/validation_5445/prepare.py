"""Build private native navigation/breath checks without distributing game dependencies."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('previous_preparation',ROOT/'assets/validation_5443/prepare.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--seed',type=Path)
    p.add_argument('--require-fixed',action='store_true')
    p.add_argument('--scenario',choices=['observe','checks'],default='observe')
    a=p.parse_args();out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    (out/'baseline.pk3').write_bytes(a.runtime.read_bytes())
    fixture={'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
        'probe.zs':(HERE/(a.scenario+'.zs')).read_bytes(),
        'MAPINFO':('GameInfo { AddEventHandlers="'+('CA353Performance' if a.scenario=='observe' else 'CA357Probe')+'" }\n').encode()}
    if a.require_fixed:fixture['probe.zs']=fixture['probe.zs'].replace(b'REQUIRE_FIXED=0',b'REQUIRE_FIXED=1')
    if a.scenario=='checks':
        # Keep native fixed-point sight traversal within a bounded test room.
        fixture['maps/map99.wad']=base.flat_map().replace(b'32768',b'16384')
    fixturehash=base.prior.base.package(out/'city.pk3',fixture)
    manifest=dict(issue=357,release='5.4.45',runtime_sha256=hashlib.sha256(a.runtime.read_bytes()).hexdigest(),fixture_sha256=fixturehash,scenario=a.scenario,require_fixed=a.require_fixed)
    if a.seed:
        (out/'author.zds').write_bytes(a.seed.read_bytes());manifest['seed_sha256']=hashlib.sha256(a.seed.read_bytes()).hexdigest()
        with zipfile.ZipFile(a.seed) as archive:manifest['seed_info']=json.loads(archive.read('info.json'))
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (out/'probe.cfg').write_text('wait 210; quit\n')
    print(json.dumps(manifest))
if __name__=='__main__':main()
