"""Read-only native evidence gate for the private structural-cache candidate."""
from pathlib import Path
import argparse
import json
import re

ROOT=Path(__file__).resolve().parents[2]

def read(path):return json.loads(path.read_text(encoding='utf-8-sig'))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',default='issue354-research01')
    p.add_argument('--audit-directory',default='issue354-audit02')
    a=p.parse_args();folder=ROOT/'build'/a.directory;audit=ROOT/'build'/a.audit_directory
    manifest=read(folder/'manifest.json');candidate=manifest['hashes']['current/baseline.pk3']
    assert manifest['issue']==354 and len(manifest['changed_members'])==6
    run=read(folder/'checks01-run.json');text=(folder/'checks01.txt').read_text(encoding='utf-8-sig')
    assert run['runtime_sha256'].lower()==candidate and run['fixture_sha256'].lower()==manifest['fixture_sha256'] and run['exit_code']==0
    assert 'CA354 CHECKS passes=3958 failures=0' in text and 'CA282 FAIL' not in text
    am=read(audit/'manifest.json');assert am['issue']==354 and am['audited_input_sha256']==candidate
    rows=[]
    for site in (0,1):
        label=f'audit-s{site}';text=(audit/(label+'.txt')).read_text(encoding='utf-8-sig');run=read(audit/(label+'-run.json'))
        assert run['runtime_sha256'].lower()==am['hashes']['baseline.pk3'] and run['exit_code']==0
        assert 'CA282 FAIL' not in text and 'CACHE FRAMES_END' in text
        match=re.search(r'CACHE AUDIT health=(\d+) offense=(\d+) weight=(\d+) failures=0',text)
        assert match and min(map(int,match.groups()))>0
        begin=re.search(r'CACHE BEGIN tic=(\d+)',text);end=re.search(r'CACHE END tic=(\d+)',text)
        assert int(end[1])-int(begin[1])==700
        rows.append(dict(label=label,retained_body_read_counts=list(map(int,match.groups())),failures=0))
    result=dict(passed=True,candidate_sha256=candidate,assertions=3958,extra_research_assertions=253,audits=rows)
    (folder/'native-gate.json').write_text(json.dumps(result,indent=2)+'\n')
    print('PASS: research unit controls and both cached-read audits')

if __name__=='__main__':main()
