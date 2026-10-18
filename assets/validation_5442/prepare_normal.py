"""Verify the normal build against src and reuse the accepted loading smoke."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    args=parser.parse_args()
    folder=ROOT/'build'/args.directory
    folder.mkdir(exist_ok=False)
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive:
        assert set(archive.namelist())==set(source)
        for name,path in source.items():
            assert archive.read(name)==path.read_bytes(),name
        assert not any('ca318_stagger' in n.lower() or n in ('ca318_work.zs','ca318_probe.zs') for n in archive.namelist())
        assert b'ca318_stagger' not in archive.read('CVARINFO')
    shutil.copyfile(package,folder/'production.pk3')
    prior=ROOT/'assets/validation_5441/evidence/normal-production'
    with zipfile.ZipFile(folder/'quick.pk3','w',compression=zipfile.ZIP_DEFLATED) as archive:
        for name in ('MAPINFO','ZSCRIPT'):
            raw=(prior/name).read_bytes()
            (folder/name).write_bytes(raw)
            info=zipfile.ZipInfo(name,(2026,10,18,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
            archive.writestr(info,raw)
    shutil.copyfile(prior/'smoke.cfg',folder/'smoke.cfg')
    record=dict(issue=318,release='5.4.42',purpose='Normal package compilation/loading; no scheduling prototype.',
                runtime_sha256=hashlib.sha256(package.read_bytes()).hexdigest(),
                fixture_sha256=hashlib.sha256((folder/'quick.pk3').read_bytes()).hexdigest(),
                exact_source_members=len(source),source_byte_equality=True,stagger_probe_absent=True)
    (folder/'manifest.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(record))


if __name__=='__main__':main()
