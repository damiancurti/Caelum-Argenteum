"""Verify hashes and native gates without private saves or game dependencies."""
from pathlib import Path
import hashlib,json,re,zipfile
HERE=Path(__file__).parent
def main():
    record=json.loads((HERE/'evidence.json').read_text(encoding='utf-8'))
    engines=set();total=0
    with zipfile.ZipFile(HERE/'evidence.zip') as archive:
        assert set(archive.namelist())==set(record['sha256'])
        for name,digest in record['sha256'].items():
            assert hashlib.sha256(archive.read(name)).hexdigest()==digest,name
        for case in record['successful_runs']:
            folder=case['folder'];label=case['label']
            run=json.loads(archive.read(f'{folder}/{label}-run.json').decode('utf-8-sig'))
            manifest=json.loads(archive.read(f'{folder}/manifest.json'))
            log=archive.read(f'{folder}/{label}.txt').decode()
            assert run['exit_code']==0 and 'GZDoom version g4.14.2' in log,folder
            assert not any(x in log for x in ['CA282 FAIL','Script error','VM execution aborted','JIT error']),folder
            for key in ['runtime_sha256','fixture_sha256']:
                assert run[key].lower()==manifest[key].lower(),(folder,key)
            engines.add(run['engine_sha256'].lower())
            markers=re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)',log)
            assert markers and all(f=='0' for _,f in markers)
            if label=='reload':
                assert markers==[('4','0'),('8','0'),('1','0')]
                assertions=9
            else:assertions=sum(int(p) for p,_ in markers)
            assert assertions==case['assertions'];total+=assertions
        for folder in ['issue334-final-roundtrip04','issue334-final-roundtrip-cap05']:
            log=archive.read(folder+'/roundtrip.txt').decode()
            rows=re.findall(r'CA334 PRESENT name=ca_vehicle_wipe_visible arg=(\d+) map=(\w+).*globalwipe=(\d+)',log)
            assert rows==[('1','MAP03','3'),('1','CAH008','3'),('1','MAP03','3')],rows
        assert len(engines)==1 and total==record['native_assertions']
    print(f'Verified {len(record["sha256"])} text members; {len(record["successful_runs"])} runs, {total} assertions.')
if __name__=='__main__':main()
