"""Read-only final native gates; requires every stage, not the first DONE marker."""
from pathlib import Path
import argparse
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[2]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--audit-directory',default='issue353-audit02')
    a=p.parse_args();rows=[]
    expected=json.loads((ROOT/'build/issue353-performance03/manifest.json').read_text())['runtime_sha256']
    cases=[('issue353-final-checks01','checks01',['CA282 DONE passes=3705 failures=0']),
        *[('issue353-final-save01',label,['CA353 SAVE_CHECK passes=10 failures=0']) for label in ('seed01','reload01','legacy01')],
        ('issue353-final-travel01','travel01',['TRAVEL stage=2 map=MAP98 passes=10 failures=0','TRAVEL stage=3 map=MAP99 passes=20 failures=0'])]
    for directory,label,markers in cases:
        folder=ROOT/'build'/directory;text=(folder/(label+'.txt')).read_text(encoding='utf-8-sig')
        run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert run['runtime_sha256'].lower()==expected and run['exit_code']==0
        assert all(marker in text for marker in markers) and 'CA282 FAIL' not in text
        rows.append(dict(directory=directory,label=label,markers=markers,runtime_sha256=expected))
    legacy=ROOT/'build/issue353-save-legacy01';label='finalrollback01'
    text=(legacy/(label+'.txt')).read_text(encoding='utf-8-sig')
    run=json.loads((legacy/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and 'CA353 SAVE_CHECK passes=15 failures=0' in text and 'CA282 FAIL' not in text
    assert run['runtime_sha256'].lower()=='a54546d67f01d733b910e93b58c62cd67d7b72c062a0c3f26410cbd180a3e1a1'
    forward=(ROOT/'build/issue353-final-save01/cache-forward.zds').read_bytes()
    assert (legacy/'final-forward.zds').read_bytes()==forward
    rows.append(dict(directory=legacy.name,label=label,new_assertions=5,final_runtime_forward_save_sha256=hashlib.sha256(forward).hexdigest(),legacy_runtime_sha256=run['runtime_sha256']))
    audit=ROOT/'build'/a.audit_directory;manifest=json.loads((audit/'manifest.json').read_text())
    assert manifest['audited_input_sha256']==expected
    for site in (0,1):
        label=f'audit-s{site}';text=(audit/(label+'.txt')).read_text(encoding='utf-8-sig')
        run=json.loads((audit/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert run['runtime_sha256'].lower()==manifest['hashes']['baseline.pk3'] and run['exit_code']==0
        assert 'CA282 FAIL' not in text and 'CACHE FRAMES_END' in text
        match=re.search(r'CACHE AUDIT health=(\d+) offense=(\d+) weight=(\d+) failures=0',text)
        assert match and min(map(int,match.groups()))>0
        begin=re.search(r'CACHE BEGIN tic=(\d+)',text);end=re.search(r'CACHE END tic=(\d+)',text)
        assert int(end[1])-int(begin[1])==700
        rows.append(dict(directory=a.audit_directory,label=label,retained_body_read_counts=list(map(int,match.groups())),failures=0))
    result=dict(passed=True,normal_runtime_sha256=expected,checks=rows)
    (ROOT/'build/issue353-final-checks01/final-gate.json').write_text(json.dumps(result,indent=2)+'\n')
    print('PASS: final native units, save/reload/forward migration, both hub legs, two cached-read audits')

if __name__=='__main__':main()
