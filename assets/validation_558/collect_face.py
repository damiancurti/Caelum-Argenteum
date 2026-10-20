"""Verify and retain the author-requested #369 face revision evidence.

The initial report.json and its tools/evidence remain the first candidate's
history (commit 885fe498); this script validates the current facial revision.
"""
import json
import math
import re
import shutil
import statistics
from pathlib import Path
from verify import ROOT, HERE, members, sha
from collect import trace

WORK=ROOT/'build/issue369-face-final02'
EXPORT=ROOT/'build/issue369-face-export03'
REPEAT=ROOT/'build/issue369-face-export04'
ART=ROOT/'assets/source/art/bull_3d'
LABELS=['face-front','face-load','face-poses','face-encounter','face-population','face-map01']


def main():
    current=members(WORK/'production.pk3')
    initial=members(ROOT/'build/issue369-final01/production.pk3')
    source={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert current==source==members(ROOT/'build/caelum_argenteum_dev.pk3')
    assert set(current)==set(initial)
    changed=sorted(n for n in current if current[n]!=initial[n])
    assert changed==sorted(['caelum/actors/CaelumBullModel.zs','caelum/actors/CaelumBullModelFrames.zs',
        'licenses/BULL_3D_MODEL.txt','models/caelum/bull/bull.md3','models/caelum/bull/bull_skin.png'])
    def canonical(data):return data.decode('utf-8').replace('\r\n','\n')
    frames='caelum/actors/CaelumBullModelFrames.zs'
    remove_bounds=lambda s:re.sub(r'    const VISUAL_(RADIUS|HEIGHT)=\d+;\n','',canonical(s))
    assert remove_bounds(current[frames])==remove_bounds(initial[frames])
    # Original combat actors and all gameplay data are byte-identical. The sole
    # executable change refreshes saved non-colliding helpers' render bounds.
    model='caelum/actors/CaelumBullModel.zs'
    new=canonical(current[model]);old=canonical(initial[model])
    block=re.search(r'        while\(\(body=CaelumBullModelBody\(it.Next\(\)\)\)!=null\)\n        \{.*?\n        \}',new,re.S)
    assert block and block.group().count('body.A_SetSize(body.VISUAL_RADIUS,body.VISUAL_HEIGHT);')==1
    assert new[:block.start()]+'        while((body=CaelumBullModelBody(it.Next()))!=null)Bodies.Push(body);'+new[block.end():]==old
    repeat_hashes={}
    for p in EXPORT.iterdir():
        if p.is_file():assert p.read_bytes()==(REPEAT/p.name).read_bytes();repeat_hashes[p.name]=sha(p)
    for name,path in {'bull.md3':'models/caelum/bull/bull.md3','bull_skin.png':'models/caelum/bull/bull_skin.png',
        'frames.zs':frames,'TEXTURES':'graphics/caelum/bull_model.textures','bull_invisible.png':'graphics/caelum/bull_invisible.png'}.items():
        assert current[path]==(EXPORT/name).read_bytes()
    exported=json.loads((EXPORT/'manifest.json').read_text(encoding='utf-8'))
    assert exported['source_sha256']==sha(ART/'bull.blend')
    assert (exported['triangles'],exported['vertices'],exported['frames'])==(9108,7381,136)
    assert min(row['min'][2] for row in exported['bounds'] if row['pose'] in ('Death','Corpse','Rest'))>-.001
    assert sha(ART/'original.glb')=='21c6c3413a009d18512a6106ba52e5032c4423c33f8c67bccf3b01a71d9c0c97'
    evidence=HERE/'evidence-face';evidence.mkdir(exist_ok=True)
    def retain(path,name=None):
        dest=evidence/(name or path.name)
        if dest.exists():assert dest.read_bytes()==path.read_bytes(),dest
        else:shutil.copyfile(path,dest)
        return {'file':dest.relative_to(HERE).as_posix(),'sha256':sha(dest)}
    report={'issue':369,'version':'5.5.8','initial_commit':'885fe498','initial_report':'report.json',
        'author_feedback':'More symmetric head, defined eyes instead of black points, bovine muzzle.',
        'author_acceptance':{'id':'CA369-01','accepted':False},'changed_members':changed,
        'original_combat_bytes_unchanged':True,'native_action_timing_unchanged':True,
        'runtime_sha256':sha(WORK/'production.pk3'),'export_repeat_sha256':repeat_hashes,
        'source_sha256':{p.name:sha(p) for p in ART.iterdir() if p.is_file()},'runs':[],'performance':{}}
    prior=HERE/'report-face.json'
    if prior.exists():report['author_acceptance']=json.loads(prior.read_text(encoding='utf-8'))['author_acceptance']
    manifest=json.loads((WORK/'manifest.json').read_text(encoding='utf-8'))
    for label in LABELS:
        log=WORK/(label+'.txt');text=log.read_text(encoding='utf-8-sig');record_path=WORK/(label+'-run.json')
        record=json.loads(record_path.read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0 and not record.get('failure')
        assert record['runtime_sha256'].lower()==manifest['runtime_sha256']
        assert record['fixture_sha256'].lower()==manifest['fixture_sha256']
        assert not re.search(r'CA369 FAIL|Unknown object class|VM execution aborted|Script error',text)
        assert re.search(r'CA369 DONE passes=\d+ failures=0',text)
        report['runs'].append({'label':label,'pass_lines':text.count('CA369 PASS '),'log':retain(log),'record':retain(record_path)})
        values=[float(v) for v in re.findall(r'^CA369 FRAME ([\d.]+)$',text,re.M)]
        if values:
            ticks=[float(v) for v in re.findall(r'^CA369 TICK ([\d.]+)$',text,re.M)];assert len(ticks)==351
            ordered=sorted(values)
            report['performance'][label]={'mean_ms':statistics.mean(values),'p95_ms':ordered[math.ceil(len(values)*.95)-1],
                'p99_ms':ordered[math.ceil(len(values)*.99)-1],'max_ms':max(values),'callback_count':len(values),
                'tics_per_second':350000/(ticks[-1]-ticks[0]),'population':re.findall(r'^CA369 PERF (?:BEGIN|END) .*$',text,re.M)}
            if label=='face-population':assert 'END alive=512' in text and 'census=513 high_density=1' in text
    old_trace=trace(ROOT/'build/issue369-baseline01/baseline-encounter01.txt')
    new_trace=trace(WORK/'face-encounter.txt');assert new_trace==old_trace and len(new_trace)==181
    report['combat_trace_equal_rows']=181
    report['art_report']=retain(ROOT/'build/issue369-face06/face-report.json')
    report['export_manifest']=retain(EXPORT/'manifest.json','export-manifest.json')
    report['build_log']=retain(ROOT/'build/issue369-face-final-build-log.txt')
    static=ROOT/'build/issue369-face-static.json';validation=json.loads(static.read_text(encoding='utf-16'))
    assert validation['version']=='5.5.8' and not validation['errors'];report['static_validation']=retain(static)
    report['captures']=[retain(WORK/name) for name in ['face-front-quick-face-front.png','face-front-quick-face-angle.png',
        'face-poses-quick-walk.png','quick-run.png','quick-gore.png','quick-death.png','quick-corpse.png',
        'face-encounter-quick-map01.png','face-population-quick-perf.png']]
    for name in ['front.png','angle.png','side.png']:report['captures'].append(retain(ROOT/'build/issue369-face06'/name,'authoring-'+name))
    report['presentation']='Unmeasured; same-session ETW access denial retained in initial report. Callback timings are not display FPS.'
    report['passed_checks']=sum(row['pass_lines'] for row in report['runs'])
    report['tooling_sha256']={p.name:sha(p) for p in HERE.iterdir() if p.suffix in ('.py','.ps1','.zs')}
    prior.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['runtime_sha256','passed_checks','combat_trace_equal_rows','performance']},indent=2))


if __name__=='__main__':main()
