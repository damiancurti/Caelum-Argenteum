"""Verify frozen #314 native runs and archive byte-exact bounded evidence."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import statistics
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
REQUIRED={
    'issue314-baseline01':['save','rollback','neutral-before'],
    'issue314-current06':['smoke','solver','npc','crouch','save','hub','load','old-load','neutral-after','lava-population'],
    'issue314-current07':['visual','mansion-reference','sewer-reference'],
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def stats(xs):
    xs=sorted(xs)
    def q(p):
        at=(len(xs)-1)*p;lo=int(at)
        return xs[lo]+(xs[min(lo+1,len(xs)-1)]-xs[lo])*(at-lo)
    return {'count':len(xs),'mean_ms':statistics.mean(xs),'p95_ms':q(.95),'p99_ms':q(.99),'maximum_ms':max(xs)}

def main():
    evidence=HERE/'evidence';evidence.mkdir(exist_ok=True)
    report={'issue':314,'release':'5.5.6','required':[],'excluded':[],'performance':[]}
    for directory,labels in REQUIRED.items():
        work=ROOT/'build'/directory;manifest=json.loads((work/'manifest.json').read_text())
        assert sha(work/'production.pk3')==manifest['runtime_sha256']
        assert sha(work/'quick.pk3')==manifest['fixture_sha256']
        for name,digest in manifest['script_hashes'].items():assert sha(work/name)==digest
        shutil.copyfile(work/'manifest.json',evidence/(directory+'--manifest.json'))
        with zipfile.ZipFile(work/'quick.pk3') as archive:
            for name in ('probe.zs','perf.zs'):(evidence/(directory+'--'+name)).write_bytes(archive.read(name))
        for label in labels:
            path=work/(label+'.txt');text=path.read_text(encoding='utf-8',errors='replace')
            record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
            assert record['exit_code']==0 and not record.get('failure'),label
            assert not re.search(r'CA314 FAIL|Script error|VM execution aborted|Cannot find savegame|DIED WITH FATAL ERROR',text),label
            assert re.search(r'CA314 DONE passes=\d+ failures=0',text),label
            assert record['runtime_sha256'].lower()==manifest['runtime_sha256'],label
            assert record['fixture_sha256'].lower()==manifest['fixture_sha256'],label
            assert sha(work/(label+'-commands.cfg')) in manifest['script_hashes'].values(),label
            report['required'].append({'directory':directory,'label':label,'checks':len(re.findall(r'^CA314 PASS ',text,re.M)),
                'runtime_sha256':manifest['runtime_sha256'],'fixture_sha256':manifest['fixture_sha256'],
                'log_sha256':sha(path),'engine_sha256':record['engine_sha256'].lower()})
            for suffix in ('.txt','.ini','-run.json','-commands.cfg','-presentation.json','-presentmon.txt'):
                source=work/(label+suffix)
                if source.exists():shutil.copyfile(source,evidence/(directory+'--'+source.name))
            if 'CA314 PERF BEGIN' in text:
                ticks=[float(n) for n in re.findall(r'CA314 TICK ([\d.]+)',text)]
                frames=[float(n) for n in re.findall(r'CA314 FRAME ([\d.]+)',text)]
                assert len(ticks)==351 and frames,label
                population=int(re.search(r'CA314 PERF BEGIN population=(\d+)',text)[1])
                alive=int(re.search(r'CA314 PERF END alive=(\d+)',text)[1]);assert alive==population
                report['performance'].append({'label':label,'fixture_spawned_population':population,'fixture_alive':alive,
                    'simulation_tics_per_second':350000/(ticks[-1]-ticks[0]),
                    'simulation_intervals':stats([b-a for a,b in zip(ticks,ticks[1:])]),
                    'render_callback_intervals':stats(frames),
                    'application_presentation':'Unavailable: ETW access denied; reference runs do not retry.',
                    'mean_exposure':float(re.search(r'mean_exposure=([-\d.]+)',text)[1])})
    for directory,label,reason in [
        ('issue314-current01','smoke','Fixture called unavailable CheckWater; replaced with elapsed native tics.'),
        ('issue314-current03','smoke','Fixture used reserved state identifier; renamed.'),
        ('issue314-current04','npc','Production NPC current-contact projection remained stale after exit; fixed by resampling after closing the previous interval.'),
        ('issue314-current05','hub','Fixture expected player return to the previous coordinates. Native changemap arrives at the map start; corrected expected support, retained NPC persistence assertion.')]:
        source=ROOT/'build'/directory/(label+'.txt')
        shutil.copyfile(source,evidence/(directory+'--'+source.name))
        report['excluded'].append({'directory':directory,'label':label,'reason':reason,'log_sha256':sha(source)})
    for name in ('ice.png','lava.png','lava-es.png'):
        shutil.copyfile(ROOT/'build/issue314-current07'/name,evidence/name)
    report['native_runs']=len(report['required']);report['checks']=sum(r['checks'] for r in report['required'])
    report['author_acceptance']='CA314-01 pending'
    report['limits']=['Private room only; no campaign placement or realism claim.',
        'Old/current/rollback saves restore exposure and live pawns; no persisted fields were added.',
        'Water takes priority over submerged solid contact; no historical geometry reconstruction.',
        'One ten-second observation per performance condition; no statistically established speedup.',
        'Render callbacks are not application presents or monitor refresh. ETW was unavailable; no 60-FPS presentation acceptance.',
        'Mansion/sewer samples are fixed spawn references, not full traversal acceptance; their native populations were not counted by the fixture.']
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'native_runs':report['native_runs'],'checks':report['checks'],'performance':report['performance']},indent=2))

if __name__=='__main__':main()
