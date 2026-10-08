"""Bind the sweat extension to source, preserving the previous city evidence manifest."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue133'


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    names={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    package=WORK/'production.pk3'
    for target in (package,ROOT/'build/caelum_argenteum_dev.pk3',WORK/'upgrade/baseline.pk3'):
        with zipfile.ZipFile(target) as z:
            assert set(z.namelist())==set(names)
            for name,path in names.items():
                source=ROOT/'assets/map06_port/legacy_512/MAP06.wad' if target==WORK/'upgrade/baseline.pk3' and name=='maps/MAP06.wad' else path
                assert z.read(name)==source.read_bytes(),(target,name)
    commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    changed=subprocess.check_output(['git','diff','--name-only','b00201098a26582c8820a5424a2a75986b022abf','--','src'],cwd=ROOT,text=True).splitlines()
    sources={}
    for name in changed:
        current=(ROOT/name).read_bytes();blob=subprocess.check_output(['git','show',commit+':'+name],cwd=ROOT)
        assert current==blob or (b'\0' not in blob and current.replace(b'\r\n',b'\n')==blob.replace(b'\r\n',b'\n')),name
        sources[name]={'runtime_sha256':hashlib.sha256(current).hexdigest(),'git_blob_sha256':hashlib.sha256(blob).hexdigest()}
    records={};production_sha=sha(package)
    for path in sorted(HERE.glob('*-run.json')):
        r=json.loads(path.read_text(encoding='utf-8-sig'))
        if not r.get('completed_utc'):continue
        records[path.name]={'sha256':sha(path),'package_sha256':r['package_sha256'],'addon_sha256':r['addon_sha256'],
            'matches_current_package':r['package_sha256'].lower()==production_sha,'expected':r['expected']}
    report={'issue':133,'version':'5.1.3','implementation_commit':commit,
        'production_package_sha256':production_sha,'default_package_sha256':sha(ROOT/'build/caelum_argenteum_dev.pk3'),
        'compatible_package_sha256':sha(WORK/'upgrade/baseline.pk3'),
        'source_binding':sources,'completed_records':records,
        'pre_extension_manifest':{'name':'MANIFEST_CITY.json','sha256':sha(HERE/'MANIFEST_CITY.json')},
        'qualification':'Native evidence remains bound to each actual package. Earlier city/art/navigation evidence is not relabelled as a final-source run; RESULTS.md describes affected retests and scoped reuse.'}
    (HERE/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('Bound',len(sources),'runtime changes and',len(records),'native records to',commit)


if __name__=='__main__':main()
