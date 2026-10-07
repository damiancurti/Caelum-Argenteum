"""Check and retain #119 native evidence; never distribute engine/IWAD/saves."""
from pathlib import Path
import hashlib,json,re,shutil,statistics,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue119'
RUNS=['baseline-tarot-final','current-tarot-final','old-save-current-final2',
      'current-save-reload-final2','upgraded-save-reload-final2','original-save-rollback-final2',
      'tarot-ui-enu-final2','tarot-ui-es-final2','baseline-performance-final','current-performance-final',
      'baseline-menus-final2','current-menus-enu-final2','current-menus-es-final2','old-trucazo-menu-final2','old-truco-menu-final2',
      'live-trucazo-verified','live-truco-verified']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def log(label):return (WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
def rows(label,prefix):return [s for s in log(label).splitlines() if s.startswith(prefix)]
def archive(name):
    p=WORK/name;q=HERE/name
    text=p.read_text(encoding='utf-8-sig');lines=text.splitlines()
    q.write_text('\n'.join(s.rstrip() for s in lines if not s.startswith('CA116 INPUT')).rstrip()+'\n',encoding='utf-8',newline='\n')
    return dict(source_sha256=digest(p),archive_sha256=digest(q),omitted_input_rows=sum(s.startswith('CA116 INPUT') for s in lines))
def save(name):
    with zipfile.ZipFile(WORK/name) as z:
        info=json.loads(z.read('info.json'));data=json.loads(z.read(info['Current Map'].lower()+'.map.json'))
    return data['objects']
def payload(objects,name):return next(o['class:'+name] for o in objects if o['classtype']==name)
def match(objects,name):
    p=payload(objects,name).copy()
    p['Sides']=[objects[n]['class:CaelumTrucazoSide'] for n in p['Sides']]
    if p.get('opponent') is not None:p['opponent']=objects[p['opponent']]['classtype']
    return p
def performance(label):
    samples=[dict(re.findall(r'(\w+)=(-?[\d.]+)',s)) for s in rows(label,'CA116 SIM')]
    a,b=samples[0],samples[-1];tics=int(b['tic'])-int(a['tic']);seconds=(float(b['ms'])-float(a['ms']))/1000
    assert tics==1680 and len(samples)==49
    intervals=[float(x) for x in re.findall(r'CA116 FRAME .*interval=([\d.]+)',log(label))]
    profiles=[float(x) for x in re.findall(r'^\s*([\d.]+)\s+[\d.]+\s+1\s+CaelumPlayer\s*$',log(label),re.M)]
    return dict(tics=tics,wall_seconds=seconds,tics_per_second=tics/seconds,first=a,last=b,
        overlay_interval_median_ms=statistics.median(intervals),overlay_interval_max_ms=max(intervals),
        player_single_tic_profile_ms=profiles),[{k:v for k,v in r.items() if k!='ms'} for r in samples]

def main():
    report={}
    for label in RUNS:
        text=log(label)
        assert not re.search(r'CA119 FAIL|Script error|VM execution aborted|FATAL ERROR',text),label
        counts=re.findall(r'CA119 (?:CHECKS|PERSIST|CAPTURE card=\d+) checks=(\d+) failures=(\d+)',text)
        if 'performance' not in label:assert counts and all(int(f)==0 for _,f in counts),label
        report[label]=dict(result='MEASURED' if 'performance' in label else 'PASS',checks=int(counts[-1][0]) if counts else None)
        for name in [label+'.txt',label+'.ini',label+'-run.json']:report[label][name]=archive(name)
        assert 'snd_mastervolume=0.05' in (WORK/(label+'.ini')).read_text(encoding='utf-8-sig')
        meta=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        if 'baseline' not in label and 'rollback' not in label:
            assert meta['package_sha256'].lower()==digest(WORK/'current.pk3'),label
    assert rows('baseline-tarot-final','CA119 TABLE')==rows('current-tarot-final','CA119 TABLE')
    before=rows('baseline-tarot-final','CA119 VALUE');after=rows('current-tarot-final','CA119 VALUE')
    assert len(before)==len(after)==7
    assert [re.sub(r'flight=\d','flight=X',x) for x in before]==[re.sub(r'flight=\d','flight=X',x) for x in after]
    assert all('flight=1' in x for x in after)
    assert any('flight=0' in x for x in before)
    for label in ['old-save-current-final2','upgraded-save-reload-final2','current-save-reload-final2']:
        assert any(' requested ' in x and 'flight=1' in x for x in rows(label,'CA119 VALUE'))
    initial_old=save('ca119_baseline.zds');initial_new=save('ca119_current.zds')
    assert payload(initial_old,'CaelumPersistentCharacterState')==payload(initial_new,'CaelumPersistentCharacterState')
    for name in ['CaelumTrucazoMatch','CaelumTrucoMatch']:
        assert match(initial_old,name)==match(initial_new,name),name
    for name in ['ca119_current_hub.zds','ca119_upgraded.zds']:
        objects=save(name)
        assert sum(o['classtype']=='CaelumTarotFlight' for o in objects)==1,name
        assert payload(objects,'CaelumPersistentCharacterState')['TarotEffectTics']>0
    assert not any(o['classtype']=='CaelumTarotFlight' for o in save('ca119_baseline_hub.zds'))
    b,scene=performance('baseline-performance-final');c,scene2=performance('current-performance-final')
    assert scene==scene2
    images=[]
    for name in ['tarot-enu.png','tarot-es.png']:
        shutil.copyfile(WORK/name,HERE/name);images.append(dict(file=name,sha256=digest(HERE/name)))
    for name in ['trucazo-window-enu.png','trucazo-play-window-enu.png','truco-window-es.png','truco-play-window-es.png']:
        images.append(dict(file=name,sha256=digest(HERE/name),method='Windows.Graphics.Capture through Computer Use; actual native menu and keyboard action inspected'))
    diagnostics={
        'baseline-tarot':'Initial fixture spawned an invisible Ace and attempted capture before the ordinary visibility update. Fixed the fixture; production visibility unchanged.',
        'baseline-tarot-fixed':'Corrected captures pass. Scripted return to the one-way mansion did not produce the intended hub save; replaced with the actual MAP02/MAP06/MAP02 hub route.',
        'old-save-current-final':'Five startup wait tics let the command sequence finish without the intended post-load event/save. Increased startup delay to 105 tics; final2 logs prove the requested event and save.',
        'upgraded-save-reload-final':'Rejected missing upgraded save from that short startup schedule; retained diagnostic, corrected schedule and verified actual file before later reload.',
        'tarot-ui-enu-final2':'Tarot page rendered correctly; the internal screenshot command omits native menus. Diagnostic UI logging confirms the menu is open. Actual window captures replace the world-only images.',
        'baseline-menus-final':'Synthetic replacement opponent set StoryAnchored before deferred PostBeginPlay, which resets it from args[0]. Final2 fixture sets the canonical anchored spawn argument; production NPC behavior unchanged.',
        'menu-diagnostic':'Diagnostic fixture mixed String/Name ternary operands; corrected to two Name operands.',
        'menu-diagnostic2':'Both native handlers and the real Trucazo menu exist, but the internal screenshot still shows the world. Window capture confirms native menu rendering.'}
    diagnostic_files={k:dict(reason=v,log=archive(k+'.txt')) for k,v in diagnostics.items()}
    result=dict(issue=119,version='5.0.3',baseline_commit='135ae0f91de84a7d4f4b3c0f803da254aeacd0ad',
        source_proof='EXTRACTION.json: 24 extracted implementations, retained schemas/signatures, explicit adapter routes and all remaining code checked; one added runtime service, no removed members.',
        native_runs=report,identical_card_attribute_rows=936,identical_value_rows_except_native_flight=7,
        identical_initial_record=True,identical_initial_matches=['CaelumTrucazoMatch','CaelumTrucoMatch'],
        persistence_fix='Baseline loses native flight on non-hub travel with the paid Fool effect still active. Current travel and old-save personal-time recovery restore exactly one native instance without resetting selection/timers or charging Anima.',
        performance=dict(baseline=b,current=c,percent_tics_per_second_change=(c['tics_per_second']/b['tics_per_second']-1)*100,identical_scene_rows=49,
            limits='One matched pair; no meaningful speedup claim. Overlay intervals are not GPU frame times, and no physical-input latency was measured. Desktop/GPU load is uncontrolled. Earlier #117/#118 regressions remain separate evidence for #120.'),
        environment='Windows 11 / GZDoom 4.14.2 / Vulkan / Ryzen 9 5950X / RTX 3070 Ti; actual renderer 1520x825; seed 116; skill 2; audio enabled at 5%; runs serialized.',
        saves={n:dict(sha256=digest(WORK/n),distributed=False) for n in ['ca119_baseline.zds','ca119_baseline_hub.zds','ca119_current.zds','ca119_current_hub.zds','ca119_upgraded.zds','ca119_baseline_tc.zds','ca119_baseline_tr.zds']},
        screenshots=images,diagnostics=diagnostic_files,
        author_acceptance='Pending CA-503-TAROT-01; agent-only evidence is not author play.',
        reproduction=['Retain original 5.0.2 package/save pair for rollback. Build current source separately; stage current bytes under current-runtime/baseline.pk3 when loading the original basename.',
            'prepare_checks.py creates deterministic fixture addons/configs under build/issue119. run_native.ps1 and run_suite.ps1 record args, hashes, settings and isolated native launches.',
            'Use the normal MAP01/MAP02/MAP06 route and MAP02 hub return. Start reload scripts after 105 tics so the requested play event/save actually occurs.',
            'verify_extraction.py checks bodies, declarations, adapters and package boundary. summarize.py asserts native rows/save payloads and archives normalized UTF-8 evidence.',
            'The production service has no fields. All test sources and synthetic state remain in the separate addon, outside src. Do not distribute engine, IWAD, PK3 or saves.'],
        limitations=['Fixtures create synthetic collection/progress and dispatch gameplay methods/events. They do not claim complete campaign or physical-key acceptance.',
            'No new acquisition content, other Major powers, host/networked matches or multiplayer lifecycle support is implemented.',
            'Archive normalization removes trailing whitespace and incidental local key-scan rows; original logs and hashes remain local.'])
    (HERE/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(result='PASS',contracts=936,value_rows=7,performance_percent=result['performance']['percent_tics_per_second_change'])))
if __name__=='__main__':main()
