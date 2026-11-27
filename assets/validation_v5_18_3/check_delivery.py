"""Verify and extract a complete beta ZIP, then exercise its packaged coordinator."""
from pathlib import Path,PurePosixPath
import argparse,hashlib,json,os,sqlite3,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[2]

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--archive',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--expected-version',default='5.18.3')
    a=p.parse_args();archive=a.archive.resolve(strict=True);out=a.output.resolve();out.relative_to(ROOT/'build')
    out.mkdir(parents=True,exist_ok=False);extracted=out/'extracted';extracted.mkdir()
    expected=archive.with_suffix('.zip.sha256').read_text().split()[0];assert sha(archive)==expected
    with zipfile.ZipFile(archive) as z:
        names=z.namelist();assert len(names)==len(set(names))
        for name in names:
            assert not PurePosixPath(name).is_absolute() and '..' not in PurePosixPath(name).parts and ':' not in name and '\\' not in name
            assert (extracted/name).resolve().is_relative_to(extracted)
        assert z.testzip() is None
        z.extractall(extracted)
    delivery=json.loads((extracted/'DELIVERY.json').read_text());assert delivery['version']==a.expected_version
    assert set(names)=={r['path'] for r in delivery['files']}|{'DELIVERY.json','SHA256SUMS.txt'}
    for row in delivery['files']:
        target=extracted/row['path'];assert target.stat().st_size==row['bytes'] and sha(target)==row['sha256'],row['path']
    for line in (extracted/'SHA256SUMS.txt').read_text().splitlines():
        digest,name=line.split('  ',1);assert sha(extracted/name)==digest,name
    manifest=json.loads((extracted/'MANIFEST.json').read_text());runtime=extracted/manifest['game']
    assert sha(runtime)==manifest['sha256'] and len(manifest['files'])==19055
    with zipfile.ZipFile(runtime) as z:
        assert not set(manifest['excluded_development_maps'])&set(z.namelist())
        assert set(z.namelist())=={r['path'] for r in manifest['files']}
        for row in manifest['files']:assert hashlib.sha256(z.read(row['path'])).hexdigest()==row['sha256']
    assert not any(Path(name).suffix.lower() in ['.exe','.wad','.zds','.pk3'] for name in names)
    environment=os.environ.copy();environment.pop('PYTHONPATH',None);environment['PYTHONDONTWRITEBYTECODE']='1'
    command=['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(extracted/'run_release.ps1'),
        '-Mode','Profiles','-ProfileDirectory',str(out/'profiles'),'-Python',sys.executable,'-Language','en']
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    result=subprocess.run(command,cwd=out,input=b'0\n',stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env=environment,startupinfo=startup,timeout=90)
    (out/'profile-menu.txt').write_bytes(result.stdout)
    assert result.returncode==0 and b'Traceback' not in result.stdout,result.stdout.decode(errors='replace')
    database=out/'profiles/profiles.sqlite3';assert database.exists()
    with sqlite3.connect(database.resolve().as_uri()+'?mode=ro',uri=True) as db:
        assert db.execute('pragma application_id').fetchone()[0]==0x43415052
        assert db.execute('select count(*) from campaigns').fetchone()[0]==0
    for row in delivery['files']:assert sha(extracted/row['path'])==row['sha256']
    report=dict(issue=469,passed=True,version=a.expected_version,archive=str(archive),archive_sha256=expected,
        runtime_sha256=manifest['sha256'],delivered_files=len(names),runtime_members=len(manifest['files']),
        excluded_development_maps=manifest['excluded_development_maps'],extracted=str(extracted),
        profile_menu_command=command,profile_menu_exit=0,packaged_resources_resolved=True,
        delivered_files_unchanged_after_use=True,author_acceptance=False,
        qualification='Fresh extracted folder and disposable coordinator on the recorded Windows machine; no second-machine certification.')
    (out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))

if __name__=='__main__':main()
