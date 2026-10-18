"""Preserve #322 native evidence and verify final source/package equivalence."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent

EXPECTED_COUNTS = {
    'kind0':15, 'kind1':15, 'kind2':15, 'kind3':15, 'route':9,
    'corridor':13, 'resume':19, 'edges':7, 'stairs':3, 'platform':4, 'budget':2,
    'combat':3, 'snapshot':1, 'load-current':30, 'hub':59,
    'ongoing':1, 'load-ongoing':30, 'blocked-save':1, 'load-blocked':30,
    'load-legacy':30, 'campaign':42, 'port-reload':9, 'port-roundtrip':22,
}
CAMPAIGN_CHECKS = {
    'production gate opens with retained native key':11,
    'campaign retains original captive at its authored cell':4,
    'native dialogue release action succeeds':4,
    'campaign release progression is following':4,
    'player walked the entire four-cell to extraction itinerary':1,
    'campaign escort used physical movement without overlap or recovery teleport':1,
    'original prisoner reached extraction with native progression':4,
    'correct extracted prisoner is present at native port destination':4,
    'native destination dialogue pays rescue reward':4,
    'repeated dialogue cannot duplicate reward':4,
    'four rescues pay exactly four authored rewards':1,
}

def completed_case(label, log, passed):
    """Reject an early DONE when a later travel/save phase never executed."""
    done=re.findall(r'^CA282 DONE passes=(\d+) failures=(\d+)',log,re.M)
    if not done or done[-1]!=(str(passed),'0'):return False
    if passed!=EXPECTED_COUNTS.get(label):return False
    checks=[line.removeprefix('CA282 PASS ') for line in log.splitlines() if line.startswith('CA282 PASS ')]
    if label=='campaign':
        return all(checks.count(message)==count for message,count in CAMPAIGN_CHECKS.items())
    if label=='port-roundtrip':
        return checks.count('return to sewer does not recreate extracted prisoner')==4 and checks.count('destination save retains exact rescued reward total')==2
    return True

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--final-directory',required=True)
    parser.add_argument('--reuse-case',nargs='*',default=[],help='Earlier immutable directory:label with identical runtime')
    parser.add_argument('--allow-incomplete',action='store_true')
    args=parser.parse_args()
    records=[]
    for source in sorted((ROOT/'build').glob('issue322-*')):
        if not source.is_dir() or not (source/'manifest.json').exists():continue
        target=HERE/'evidence'/source.name;target.mkdir(parents=True,exist_ok=True)
        with zipfile.ZipFile(source/'quick.pk3') as package:
            for name in ('escort.zs','campaign.zs','route.zs'):
                if name in package.namelist():(target/name).write_bytes(package.read(name))
        with zipfile.ZipFile(source/'production.pk3') as package:
            for name in ('CaelumPrisonerEscort','CaelumEscortNavigation','CaelumAnchoredResident','CaelumPrisoners'):
                member=f'caelum/actors/{name}.zs'
                if member in package.namelist():(target/(name+'.zs.gz')).write_bytes(gzip.compress(package.read(member),mtime=0))
        manifest=json.loads((source/'manifest.json').read_text())
        for path in sorted(source.iterdir()):
            if path.name.startswith('author-preview'):continue
            if path.suffix=='.txt':
                raw=path.read_bytes();log=raw.decode('utf-8','replace')
                (target/(path.name+'.gz')).write_bytes(gzip.compress(raw,mtime=0))
                meta=source/(path.stem+'-run.json')
                run=json.loads(meta.read_text(encoding='utf-8-sig')) if meta.exists() else {}
                passed=len(re.findall(r'^CA282 PASS ',log,re.M))
                runtime_hash=run.get('runtime_sha256','').lower()
                fixture_hash=run.get('fixture_sha256','').lower()
                records.append({'directory':source.name,'label':path.stem,'sha256':hashlib.sha256(raw).hexdigest(),
                    'runtime_sha256':runtime_hash,'fixture_sha256':fixture_hash,
                    'manifest_matches_run':runtime_hash==manifest['runtime_sha256'].lower() and fixture_hash==manifest['fixture_sha256'].lower(),
                    'exit_code':run.get('exit_code'),'passed':passed,
                    'failed':len(re.findall(r'^CA282 FAIL ',log,re.M)),
                    'done':bool(re.search(r'CA282 DONE passes=\d+ failures=0',log)),
                    'complete_case':completed_case(path.stem,log,passed),
                    'measurements':re.findall(r'^CA322 (?:SPEED|MOTION|DRIVER|ROUTE kind|CAMPAIGN tic|NAVCOST).*',log,re.M)})
            elif path.suffix in ('.json','.cfg'):(target/path.name).write_bytes(path.read_bytes())
    expected={'kind0','kind1','kind2','kind3','route','corridor','resume','edges','stairs','platform','budget','combat','snapshot',
              'load-current','hub','ongoing','load-ongoing','blocked-save','load-blocked','load-legacy','campaign','port-reload','port-roundtrip'}
    reuse={item.split(':',1)[1]:item.split(':',1)[0] for item in args.reuse_case}
    assert set(reuse)<=expected
    current=[]
    for label in sorted(expected):
        directory=reuse.get(label,args.final_directory)
        matches=[r for r in records if r['directory']==directory and r['label']==label]
        if not args.allow_incomplete:assert len(matches)==1,(directory,label)
        current.extend(matches)
    final=ROOT/'build'/args.final_directory
    manifest=json.loads((final/'manifest.json').read_text())
    valid=len(current)==len(expected) and all(r['exit_code']==0 and r['done'] and r['failed']==0
        and r['complete_case'] and r['manifest_matches_run']
        and r['runtime_sha256']==manifest['runtime_sha256'].lower() for r in current)
    if not args.allow_incomplete:assert valid,'Final native gate failed'
    equivalent=False;member_count=None
    if not args.allow_incomplete:
        for filename,key in (('production.pk3','runtime_sha256'),('quick.pk3','fixture_sha256')):
            assert hashlib.sha256((final/filename).read_bytes()).hexdigest()==manifest[key].lower()
        with zipfile.ZipFile(final/'production.pk3') as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
            files={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
            assert set(tested.namelist())==set(normal.namelist())==set(files)
            assert all(tested.read(name)==normal.read(name)==data for name,data in files.items())
            equivalent=True;member_count=len(files)
    result={'issue':322,'release':'5.4.35','baseline_ref':'b74ca613','final_directory':args.final_directory,
        **manifest,'final_gate_passed':valid,'normal_equals_tested_source':equivalent,'normal_package_members':member_count,
        'final_runs':len(current),'final_assertions':sum(r['passed'] for r in current),
        'selected_runs':[(r['directory'],r['label']) for r in current],'runs':records,'author_acceptance':'CA322-01 accepted 2026-10-18; explicit prisoner approval; known packed-row limit retained'}
    (HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({key:value for key,value in result.items() if key not in ('runs','selected_runs')}))

if __name__=='__main__':main()
