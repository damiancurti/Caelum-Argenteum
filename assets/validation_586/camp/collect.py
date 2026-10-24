"""Verify camp acquisition evidence against final source bytes and retained probes."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile,subprocess
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue411-camp'
def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def main():
    package=WORK/'current/caelum_argenteum_dev.pk3'
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive,zipfile.ZipFile(WORK/'probe02/caelum_argenteum_dev.pk3') as probe:
        assert set(archive.namelist())==set(expected)
        for name,path in expected.items():assert archive.read(name)==path.read_bytes(),name
        assert set(archive.namelist())-set(probe.namelist())=={'licenses/CAMP_EQUIPMENT_411.txt'}
        for name in probe.namelist():assert archive.read(name)==probe.read(name),name
    selected=['physics03','items03','craft05','shop05','save05','load05','hub05',
        'legacy-seed06','legacy-load06','legacy-rollback06','transfer07','preview08']
    rows=[]
    for label in selected:
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig',errors='replace')
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert record.get('exit_code')==0 and not record.get('timed_out'),label
        assert 'CA411 RESULT' in log and not re.search(r'CA411 FAIL|Script error|VM execution aborted|failures=[1-9]',log),label
        rows.append({'label':label,'passes':len(re.findall(r'^CA411 PASS ',log,re.M)),'package_sha256':record['package_sha256'].lower()})
    native=HERE/'native';native.mkdir(exist_ok=True)
    for record in WORK.glob('*-run.json'):
        shutil.copyfile(record,native/record.name)
        log=WORK/(record.name.removesuffix('-run.json')+'.txt')
        if log.exists():shutil.copyfile(log,native/log.name)
    shutil.copyfile(WORK/'camp-inventory.png',HERE/'inventory-es.png')
    static=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,check=True)
    (HERE/'static-validation.json').write_bytes(static.stdout)
    report={'issue':411,'version':'5.8.6','scope':'Camp acquisition/inventory and pot cooling; placement/fire runtime/cooking remain pending',
        'native_passes':sum(row['passes'] for row in rows),'runs':rows,'source_entries_verified':len(expected),
        'package_sha256':digest(package),'original_save_sha256':digest(WORK/'ca411-camp-original.zds'),
        'reuse':'Probe02 matches every final member byte-for-byte; final adds only artwork license notice. Final trade and UI fixture tested again.',
        'limitations':'Physics/fire burn helpers are isolated evidence, not deployed camp acceptance. No frame-presentation/performance claim. Author away; manual checks deferred.'}
    (HERE/'report.json').write_bytes((json.dumps(report,indent=2)+'\n').encode('utf-8'))
    print(json.dumps({'passes':report['native_passes'],'entries':len(expected),'package_sha256':report['package_sha256']}))
if __name__=='__main__':main()
