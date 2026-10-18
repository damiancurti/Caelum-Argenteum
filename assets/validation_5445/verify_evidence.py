"""Verify archived native evidence hashes without requiring private game assets."""
from pathlib import Path
import hashlib,json,zipfile
HERE=Path(__file__).parent
def main():
    record=json.loads((HERE/'evidence.json').read_text(encoding='utf-8'))
    with zipfile.ZipFile(HERE/'evidence.zip') as archive:
        assert set(archive.namelist())==set(record['sha256'])
        for name,digest in record['sha256'].items():
            assert hashlib.sha256(archive.read(name)).hexdigest()==digest,name
        engines=set()
        for folder,label in [('issue357-checks06','checks06'),('issue357-observe-baseline03','observe03'),('issue357-observe-candidate02','observe02')]:
            run=json.loads(archive.read(f'{folder}/{label}-run.json').decode('utf-8-sig'))
            manifest=json.loads(archive.read(f'{folder}/manifest.json'))
            log=archive.read(f'{folder}/{label}.txt').decode()
            assert run['exit_code']==0
            for kind in ['runtime','fixture']:
                assert run[kind+'_sha256'].lower()==manifest[kind+'_sha256'].lower()
            assert 'GZDoom version g4.14.2' in log
            assert not any(error in log for error in ['CA282 FAIL','VM execution aborted','Script error','JIT error'])
            engines.add(run['engine_sha256'].lower())
        assert len(engines)==1
        checks=archive.read('issue357-checks06/checks06.txt').decode()
        assert 'CA357 CHECKS passes=41 failures=0' in checks
        for folder,label,moved in [('issue357-observe-baseline03','observe03',0),('issue357-observe-candidate02','observe02',20)]:
            text=archive.read(f'{folder}/{label}.txt').decode()
            assert f'CA357 RECOVERY watched=20 moved={moved} released={moved}' in text
            assert 'CA282 DONE passes=1 failures=0' in text
    print(f'Verified {len(record["sha256"])} evidence members and native gates.')
if __name__=='__main__':main()
