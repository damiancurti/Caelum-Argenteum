"""Keep exact standalone audit evidence separate from later dependency fixes."""
from pathlib import Path
import hashlib,json,shutil,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
EVIDENCE=HERE/'evidence'


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    validation=json.loads((ROOT/'build/issue466-validation.json').read_text(encoding='utf8'))
    assert not validation['errors'] and validation['version']=='5.18.0'
    EVIDENCE.mkdir(parents=True,exist_ok=True)
    subprocess.run([sys.executable,'-X','utf8',str(ROOT/'assets/generators/audit_distribution.py'),'--check'],check=True,cwd=ROOT)
    inventory_path=ROOT/'assets/distribution/INVENTORY.json'
    inventory=json.loads(inventory_path.read_text(encoding='utf8'))
    assert len(inventory['files'])==19053 and len(inventory['excluded_development_maps'])==5
    assert len({r['path'] for r in inventory['files']})==len(inventory['files'])
    assert not inventory['errors']
    package=ROOT/'build/issue466-review01.pk3'
    source=ROOT/'build/issue466-final02'
    native=json.loads((source/'SUMMARY.json').read_text())
    assert native['completed'] and native['exit']==0 and not native['commercial_iwad_loaded']
    assert len(native['texture_results'])==58 and len(native['missing_textures'])==12
    assert native['runtime_sha256']==sha(package)
    with zipfile.ZipFile(package) as z:
        assert len(z.namelist())==19053 and z.testzip() is None
        assert set(z.namelist())=={r['path'] for r in inventory['files']}
        for row in inventory['files']:
            assert hashlib.sha256(z.read(row['path'])).hexdigest()==row['sha256'],row['path']
    for name in ['native.log','stdout.txt','command.json','commands.cfg','session.ini','SUMMARY.json']:
        target=EVIDENCE/'native'/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source/name,target)
    attempts={
        'issue466-bootstrap01':'Initial no-palette bootstrap; runner timeout, client diagnostic not captured.',
        'issue466-bootstrap02':'Observed native fatal PLAYPAL not found; closed owned window after inspection.',
        'issue466-bootstrap03':'Diagnostic grayscale palette exposed missing episode definition; observed fatal, closed owned window.',
        'issue466-bootstrap04':'Palette plus episode reached initialization; no retained exit code, not completion evidence.',
        'issue466-native01':'Runner mistook nonfatal missing native menu textures for fatal script parsing; rejected.',
        'issue466-native02':'Successful 58-texture/blood-default baseline probe on #465 package.',
        'issue466-final01':'Launched before build completion; owned process stopped and attempt rejected. Final02 waited for builder exit 0. Runner now checks package existence/CRC/hash before launch.'}
    for name in attempts:
        source=ROOT/'build'/name;target=EVIDENCE/'attempts'/name;target.mkdir(parents=True,exist_ok=True)
        for filename in ['stdout.txt','command.json','SUMMARY.json','observation.json','ATTEMPT.json']:
            if (source/filename).exists():shutil.copyfile(source/filename,target/filename)
    shutil.copyfile(ROOT/'build/issue466-validation.json',EVIDENCE/'project-validation.json')
    shutil.copyfile(ROOT/'build/issue466-build.txt',EVIDENCE/'build.txt')
    report={'issue':466,'version':'5.18.0','native':native,'attempts':attempts,
        'inventory_sha256':sha(inventory_path),'runtime_files':19053,'distribution_candidate_files':19048,
        'exact_metadata_files':inventory['exact_metadata_files'],'excluded_development_maps':inventory['excluded_development_maps'],
        'package_sha256':sha(package),'package_matches_inventory':True,'inventory_regeneration_matches':True,
        'project_validation':'project-validation.json','author_acceptance':'Pending CA466-RIGHTS-01 and all prior author checks',
        'limits':['Diagnostic bootstrap is not distributable or approved production art.',
            'Audit findings remain unresolved until #467; test WADs remain present in this development package.',
            'Source-specific rights and author statements are not a blanket legal clearance.',
            'Native resource/default checks do not establish visual acceptance or full campaign readiness.']}
    (EVIDENCE/'SUMMARY.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(json.dumps({'runtime_files':19053,'excluded_test_maps':5,'native_texture_lookups':58,'missing_textures':12,'package_matches_inventory':True}))


if __name__=='__main__':main()
