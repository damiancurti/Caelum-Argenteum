"""Require complete final-source unit, migration, travel and cached-read checks."""
from pathlib import Path
import argparse
import json
import subprocess

ROOT=Path(__file__).resolve().parents[2]

def command(args):
    subprocess.run(args,cwd=ROOT,check=True)

def run(directory,label,script,load=None,runtime='production.pk3',fixture='quick.pk3'):
    args=['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5422/run_native.ps1',
        '-Directory',directory,'-Label',label,'-Script',script,'-Runtime',runtime,'-Fixture',fixture]
    if load:args+=['-LoadGame',load]
    command(args)
    return (ROOT/'build'/directory/(label+'.txt')).read_text(encoding='utf-8-sig')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prefix',default='issue353-final')
    parser.add_argument('--audit-directory',default='issue353-audit01')
    parser.add_argument('--performance-directory',default='issue353-performance03')
    parser.add_argument('--legacy-seed',type=Path,default=Path('build/issue353-save-legacy01/cache-seed.zds'))
    args=parser.parse_args()
    directories={kind:args.prefix+'-'+kind+'01' for kind in ['checks','save','travel']}
    perf=ROOT/'build'/args.performance_directory
    for kind in ['checks','save','travel']:
        command(['python','assets/validation_5443/prepare.py','--directory',directories[kind],'--scenario',kind])
    command(['python','assets/validation_5443/prepare_audit.py','--directory',args.audit_directory,
        '--runtime',str(perf/'current/baseline.pk3'),'--seed',str(perf/'cache-battle.zds')])
    expected=json.loads((perf/'manifest.json').read_text())['runtime_sha256']
    for kind in ['checks','save','travel']:
        assert json.loads((ROOT/'build'/directories[kind]/'manifest.json').read_text())['runtime_sha256']==expected
    text=run(directories['checks'],'checks01','checks.cfg')
    assert 'CA282 DONE passes=3705 failures=0' in text
    folder=ROOT/'build'/directories['save']
    text=run(folder.name,'seed01','save.cfg');assert 'SAVE_CHECK passes=10 failures=0' in text
    text=run(folder.name,'reload01','load.cfg','cache-seed.zds');assert 'SAVE_CHECK passes=10 failures=0' in text
    (folder/'legacy.zds').write_bytes(args.legacy_seed.read_bytes())
    text=run(folder.name,'legacy01','load.cfg','legacy.zds');assert 'SAVE_CHECK passes=10 failures=0' in text
    legacy=args.legacy_seed.resolve().parent
    (legacy/'final-forward.zds').write_bytes((folder/'cache-forward.zds').read_bytes())
    (legacy/'rollback.cfg').write_text('wait 5; netevent ca353_save_verify; wait 3; quit\n')
    text=run(legacy.name,'finalrollback01','rollback.cfg','final-forward.zds')
    assert 'SAVE_CHECK passes=15 failures=0' in text
    text=run(directories['travel'],'travel01','travel.cfg')
    assert 'TRAVEL stage=2 map=MAP98 passes=10 failures=0' in text
    assert 'TRAVEL stage=3 map=MAP99 passes=20 failures=0' in text
    for site in (0,1):
        text=run(args.audit_directory,f'audit-s{site}','measure.cfg','cache-battle.zds','baseline.pk3','front/city.pk3' if site else 'city.pk3')
        import re
        found=re.search(r'CACHE AUDIT health=(\d+) offense=(\d+) weight=(\d+) failures=0',text)
        assert found and min(map(int,found.groups()))>0
        begin=re.search(r'CACHE BEGIN tic=(\d+)',text);end=re.search(r'CACHE END tic=(\d+)',text)
        assert int(end[1])-int(begin[1])==700
    (ROOT/'build'/directories['checks']/'final-gate.json').write_text(json.dumps(dict(passed=True,runtime_sha256=expected),indent=2)+'\n')

if __name__=='__main__':main()
