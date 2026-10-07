"""Check integrated native evidence and archive text only; no engine or saves."""
from pathlib import Path
import hashlib,importlib.util,json,re,statistics,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue120'
def load_module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);m.WORK=WORK;return m
inventory=load_module('inventory_evidence',ROOT/'assets/validation_502/summarize.py')
tarot=load_module('tarot_evidence',ROOT/'assets/validation_503/summarize.py')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def log(label):return (WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
def rows(label,prefix):return [s for s in log(label).splitlines() if s.startswith(prefix)]
def archive(name):
    p=WORK/name;q=HERE/name;raw=p.read_text(encoding='utf-8-sig');unwrapped=False
    if name.endswith('-run.json'):
        metadata=json.loads(raw)
        script=metadata.get('command_script')
        if isinstance(script,dict):
            # Get-Content adds PowerShell provider metadata; archive only its text.
            assert isinstance(script.get('value'),str),name
            metadata['command_script']=script['value'];unwrapped=True
        raw=json.dumps(metadata,indent=2)+'\n'
    lines=raw.splitlines()
    q.write_text('\n'.join(s.rstrip() for s in lines if not s.startswith('CA116 INPUT')).rstrip()+'\n',encoding='utf-8',newline='\n')
    return dict(source_sha256=digest(p),archive_sha256=digest(q),omitted_local_input_rows=sum(s.startswith('CA116 INPUT') for s in lines),unwrapped_powershell_script_metadata=unwrapped)
def comparable_save(name):
    fields,items=inventory.comparable_save(name)
    objects=tarot.save(name)
    for item in items:
        if item['classtype']!='CaelumWeatherState':continue
        weather=item['class:CaelumWeatherState']
        # Native object-table indices may swap; retain values and alias identity.
        weather['comparison_samples_alias']=weather['current']==weather['outside']
        for field in ['current','outside']:weather[field]=objects[weather[field]] if weather[field] is not None else None
    return fields,items
def performance(label):
    text=log(label);events={}
    samples=[dict(re.findall(r'(\w+)=(-?[\d.]+)',line)) for line in rows(label,'CA116 SIM')]
    samples=[s for s in samples if 35<=int(s['tic'])<=1715]
    assert len(samples)==49 and int(samples[-1]['tic'])-int(samples[0]['tic'])==1680,label
    seconds=(float(samples[-1]['ms'])-float(samples[0]['ms']))/1000
    scene=[{k:v for k,v in s.items() if k!='ms'} for s in samples]
    p=dict(tics=1680,wall_seconds=seconds,tics_per_second=1680/seconds,first=samples[0],last=samples[-1],
        player_single_tic_profile_ms=[float(x) for x in re.findall(r'^\s*([\d.]+)\s+[\d.]+\s+1\s+CaelumPlayer\s*$',text,re.M)])
    first=float(p['first']['ms']);last=float(p['last']['ms'])
    intervals=[float(dt) for ms,dt in re.findall(r'CA116 FRAME n=\d+ ms=([\d.]+) interval=([\d.]+)',text)
               if float(ms)-float(dt)>=first and float(ms)<=last]
    p['overlay_interval_median_ms']=statistics.median(intervals)
    p['overlay_interval_max_ms']=max(intervals)
    p['overlay_samples']=len(intervals)
    p['overlay_window']='Only intervals wholly inside the same 1680-tic simulation observation window.'
    for kind,num,ms in re.findall(r'CA116 PROBE_(REQUEST|PLAY|ACK|FRAME) id=(\d+) ms=([\d.]+)',text):events.setdefault(num,{})[kind]=float(ms)
    assert len(events)==3 and all(set(e)=={'REQUEST','PLAY','ACK','FRAME'} for e in events.values()),label
    p['synthetic_input_event_route_ms']=[dict(id=n,request_to_play=e['PLAY']-e['REQUEST'],request_to_ack=e['ACK']-e['REQUEST'],request_to_overlay=e['FRAME']-e['REQUEST']) for n,e in events.items()]
    p['thinker_profiles']=[dict(total_ms=float(a),each_ms=float(b),instances=int(c),cls=d) for a,b,c,d in re.findall(r'^\s*([\d.]+)\s+([\d.]+)\s+(\d+)\s+(Caelum\w+)\s*$',text,re.M)]
    return p,scene
def main():
    original=json.loads((ROOT/'assets/validation_500/BASELINE_IDENTITY.json').read_text(encoding='utf-8'))
    assert digest(WORK/'architecture1.pk3')==original['package_sha256']
    runs=[]
    for d in ['player','inventory','tarot']:
        runs.extend(f'{d}-{s}-final' for s in ['baseline','current','old-save','new-save','upgraded-save','original-rollback'])
    runs.extend(f'transactions-{p}-final' for p in ['baseline','current'])
    runs.extend(f'pickups-{p}-final2' for p in ['baseline','current'])
    runs.extend(['architecture1-old-save-final','architecture1-upgraded-save-final','architecture1-original-rollback-final','bot-authority-configured'])
    runs.extend(['creation-enu-final','creation-es-final','live-journal-final','live-trucazo-final','live-truco-final'])
    perf=['architecture1-performance-final','current-performance-final','current-performance-repeat-final','architecture1-performance-repeat-complete']
    runs.extend(perf)
    report={}
    for label in runs:
        raw=log(label);assert not re.search(r'CA(?:116|117|118|119|120) FAIL|Script error|VM execution aborted|FATAL ERROR|needs these files',raw),label
        counts=re.findall(r'checks=(\d+) failures=(\d+)',raw)
        if label.startswith('creation-'):
            assert 'CA117 MENU allocated layers=0 attributes=0' in raw and 'CA117 INTRO advanced' in raw,label
        elif label not in perf:assert counts and all(int(f)==0 for _,f in counts),label
        report[label]=dict(result='MEASURED' if label in perf else 'PASS',checks=int(counts[-1][0]) if counts else None)
        for name in [label+'.txt',label+'.ini',label+'-run.json']:report[label][name]=archive(name)
        assert 'snd_mastervolume=0.05' in (WORK/(label+'.ini')).read_text(encoding='utf-8-sig'),label
        meta=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        if 'baseline' not in label and 'rollback' not in label and label not in [perf[0],perf[3]]:
            assert meta['package_sha256'].lower()==digest(WORK/'current.pk3'),label
    comparisons={}
    for d,prefix in [('player','CA117 VALUE'),('inventory','CA118 VALUE'),('tarot','CA119 VALUE'),('tarot','CA119 TABLE'),('transactions','CA118 CRAFT'),('pickups','CA118 PICKUP ')]:
        suffix='final2' if d=='pickups' else 'final'
        a=rows(d+'-baseline-'+suffix,prefix);b=rows(d+'-current-'+suffix,prefix)
        assert a and a==b,(d,prefix)
        comparisons[d+' '+prefix]=len(a)
    save_comparisons={}
    for domain in ['player','inventory']:
        a,items=comparable_save(f'ca120_{domain}_baseline.zds');b,items2=comparable_save(f'ca120_{domain}_current.zds')
        assert a==b,(domain,'pawn');assert items==items2,(domain,'inventory')
        save_comparisons[domain]=dict(identical_pawn_fields=len(a),identical_inventory_payloads=len(items))
    a=tarot.save('ca120_tarot_baseline.zds');b=tarot.save('ca120_tarot_current.zds')
    assert tarot.payload(a,'CaelumPersistentCharacterState')==tarot.payload(b,'CaelumPersistentCharacterState')
    for cls in ['CaelumTrucazoMatch','CaelumTrucoMatch']:assert tarot.match(a,cls)==tarot.match(b,cls),cls
    save_comparisons['tarot']=dict(identical_record_fields=len(tarot.payload(a,'CaelumPersistentCharacterState')),identical_matches=2)
    for language in ['enu','es']:
        _,_,fields=inventory.save_state(f'ca120_created_{language}.zds')
        assert fields['CharacterCreationComplete'] and not fields['CreationWizardOpen'],language
        raw=log(f'creation-{language}-final')
        assert 'CA117 MENU page=7 layers=0 attributes=0' in raw,language
    journal=log('live-journal-final')
    assert 'CA120 UI owner=0 canonical=1 selected36=0' in journal
    assert digest(HERE/'journal-before.png')!=digest(HERE/'journal-after.png')
    for mode in ['trucazo','truco']:
        assert 'CA120 UI owner=0 canonical=1' in log('live-'+mode+'-final'),mode
        assert digest(HERE/(mode+'-before.png'))!=digest(HERE/(mode+'-after.png')),mode
    observations={};scene=None
    for label in perf:
        p,s=performance(label);observations[label]=p
        if scene is None:scene=s
        else:assert scene==s,label
    changes=[(observations[c]['tics_per_second']/observations[b]['tics_per_second']-1)*100 for b,c in [(perf[0],perf[1]),(perf[3],perf[2])]]
    saves={p.name:dict(sha256=digest(p),distributed=False) for p in sorted(WORK.glob('ca120_*.zds'))}
    for name in ['ca116_snapshot.zds','ca119_baseline_tc.zds','ca119_baseline_tr.zds']:
        saves[name]=dict(sha256=digest(WORK/name),distributed=False)
    diagnostics={
        'bot-authority-first':'Fixture used the wrong selection field name; corrected to EquipmentSelectionItemId. Not passing evidence.',
        'bot-authority-second':'Installed engine had no zcajun/bots.cfg, so addbot created no participant. Final run uses an identical local engine copy with a test-only bot definition; installed files untouched.',
        'pickups-baseline-final':'Generic stack-pickup fixture was mistakenly run in MAP01, whose accepted Limbo raw-material quota rejects those pickups. The #118 source schedule uses MAP03; restored that fixture map. Production quota/ownership rules are unchanged.',
        'pickups-baseline-timing':'Repeating with the original 35-tic wait also fails on MAP01; timing is not the cause. MAP03 is the correct generic-pickup fixture context.',
        'architecture1-performance-repeat-final':'Process exited after only 45 scene samples (35..1575), short of the required 1680-tic window. No native error was logged; exit cause was not isolated. Discarded as a complete comparison and repeated with a longer final wait. All accepted performance runs use only samples 35..1715.'}
    result=dict(issue=120,version='5.0.4',baseline_commit='c4b717c7e8ab49e0cbe1a6f67e7f15f18c850b52',architecture1_baseline_commit='20143c3154617309912a493fa2a7be3c7c2c9ff4',
        source_proof='AUTHORITY.json: 203 exact guards; unchanged fields/signatures/remaining bodies; focused package boundary; one stateless authority helper.',
        package_sha256={n:digest(WORK/n) for n in ['architecture1.pk3','baseline.pk3','current.pk3']},
        native_runs=report,identical_output_rows=comparisons,serialized_comparisons=save_comparisons,
        authority='36 assertions with two actual native player pawns/records (local player plus native GZDoom bot). Explicit routing, owner isolation, prediction rejection, null/orphan safety, foreign record/preview rejection and legitimate drop/pickup ID collision handling pass. This is not a two-client network test.',
        persistence='Three domains: original 5.0.3 saves loaded under 5.0.4, current saves, upgraded re-saves and original-pair rollback. A 5.0.0 Architecture 1 save also loads/re-saves/reloads under 5.0.4; original 5.0.0 pair replays. No schema change, no downgrade of upgraded saves claimed.',
        performance=dict(runs=observations,identical_scene_rows=49,percent_tics_per_second_changes=changes,
            limits='Original Architecture 1 pre-extraction 4.37.24 versus final 5.0.4, then reversed order. Fixed seed/camera/populations, 1680 tics each. Overlay callback intervals are not GPU frame times; UI/play/UI diagnostic events are not physical device-to-photon latency. Desktop/GPU load and window focus are uncontrolled; every launch uses the same hidden/windowed configuration. Earlier #117/#118 regressions remain recorded; no causal attribution or speedup claim.'),
        saves=saves,diagnostics={k:dict(reason=v,log=archive(k+'.txt')) for k,v in diagnostics.items()},
        ui=dict(creation='Native menu callbacks allocate the accepted 4+30-point draft in English/Spanish; MAP01 PostBeginPlay consumes it into a completed character. Console map startup is used; this does not claim a physical final introduction keypress.',
            live='Agent visual inspection of actual target-window captures after native Enter/Right keys: the Spanish Journal changes Ace of Cups from unselected (2/3) to selected (3/3); Trucazo shows the played 7 of Coins winning a trick; Truco shows the played King of Swords and Argento bidding Truco. Observer logs confirm the canonical player record at load. The WorldTick observer does not advance during paused UI, so after-action evidence is the inspected native menu, not a claimed log/serial assertion. Image hashes only identify those inspected artifacts.',
            screenshots={n:digest(HERE/n) for n in ['journal-before.png','journal-after.png','trucazo-before.png','trucazo-after.png','truco-before.png','truco-after.png']}),
        environment='GZDoom 4.14.2 / Windows 11 / Vulkan / Ryzen 9 5950X / RTX 3070 Ti; seed116/skill2; audio enabled at 5%; serial launches.',
        author_acceptance='Pending CA-503-TAROT-01 and CA-504-AUTHORITY-01. Agent fixtures do not establish author acceptance.',
        reproduction=['Build baseline/current separately; prepare_checks.py creates deterministic test addons outside src. Stage current package under baseline.pk3/after-final.pk3 for native historical save basenames; preserve originals.',
            'run_suite.ps1 -Group fresh, reload, transactions, projection, performance, repeat launches serialized runs; each run records exact args, package/addon/engine/IWAD hashes and initial settings.',
            'The complete replacement performance run uses run_native.ps1 -Label architecture1-performance-repeat-complete -Package architecture1.pk3 -Script benchmark-long.cfg. Compare only tic35..1715; extra final-wait tics are excluded.',
            'run_suite.ps1 -Group creation exercises both languages. For live UI, load the current Tarot save or original #119 ca119_baseline_tc/tr saves with ui/checks.pk3; ui-journal.cfg opens the Ace page. Observe the actual target window, then press Enter or Right/Enter and capture the changed selection/played card.',
            'prepare_bot_engine.ps1 copies the installed engine locally and adds one bot definition. run_native.ps1 with that engine, authority/checks.pk3, MAP03 and bots.cfg runs the two-pawn test.',
            'verify_authority.py verifies source contracts; summarize.py compares values/save payloads and archives UTF-8 text. Never distribute engine, IWAD, PK3, saves or local fixtures in src.'],
        limitations=['No coop/PvP, networked Trucazo, join/leave/reconnect/respawn/session ownership transfer or shared campaign-clock contract is implemented.',
            'The existing campaign clock deliberately stops with multiple participants. Map-local siege controllers/actors remain shared map state, not per-player copies.',
            'No gameplay, balance, map, art, controls or actor count changed. Thermal exposure, native UI redesign, campaign expansion and measured mass-AI optimization remain separate work.',
            'Archive normalization removes trailing whitespace and incidental local key-scan rows. PowerShell Get-Content script values are unwrapped from redundant provider metadata; actual script text, args, hashes and hardware remain. Original logs/metadata and their hashes remain local.'])
    (HERE/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(result='PASS',rows=comparisons,saves=save_comparisons,performance_percent=changes)))
if __name__=='__main__':main()
