"""Collect reproducible native evidence without copying binary test fixtures."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import statistics

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue116'


def quantile(values,fraction):
    values=sorted(values)
    position=(len(values)-1)*fraction
    lo=int(position)
    return values[lo]+(values[min(lo+1,len(values)-1)]-values[lo])*(position-lo)


def benchmark(label):
    text=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
    sim=[]
    for match in re.finditer(r'CA116 SIM (.*)',text):
        sim.append({k:float(v) for k,v in re.findall(r'(\w+)=([-\d.]+)',match[1])})
    assert len(sim)>1
    first,last=sim[0],sim[-1]
    frames=[{k:float(v) for k,v in re.findall(r'(\w+)=([-\d.]+)',m[1])}
            for m in re.finditer(r'CA116 FRAME (.*)',text)]
    intervals=[f['interval'] for f in frames if first['ms']<=f['ms']<=last['ms']]
    blocks=[]
    for block in text.split('Total, ms   Averg, ms   Calls   Actor class')[1:]:
        rows=[]
        for m in re.finditer(r'^\s*([\d.]+)\s+([\d.]+)\s+(\d+)\s+(\w+)\s*$',block,re.M):
            rows.append({'class':m[4],'total_ms':float(m[1]),'average_ms':float(m[2]),'calls':int(m[3])})
        blocks.append(rows)
    metadata=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    native_resolution=re.search(r'Resolution: (.*)',text)[1].strip()
    result={'label':label,'run':metadata,'reported_resolution':native_resolution,
            'sample_count':len(sim),'first':first,'last':last,
            'observed_wall_seconds':(last['ms']-first['ms'])/1000,
            'simulation_tics_per_wall_second':(last['tic']-first['tic'])*1000/(last['ms']-first['ms']),
            'render_overlay_intervals_ms':{'count':len(intervals),'median':statistics.median(intervals),
                                          'p95':quantile(intervals,.95),'max':max(intervals)},
            'camera_constant':all(all(s[k]==first[k] for k in ('x','y','z','angle')) for s in sim),
            'single_tic_thinker_profiles':blocks,
            'errors':re.findall(r'^.*(?:FATAL ERROR|Script error|VM execution aborted|Unknown command).*$',text,re.M)}
    assert not result['errors']
    return result


def collect():
    primary=benchmark('baseline-quiet')
    profile=benchmark('baseline-controlled')
    assert primary['camera_constant'] and profile['camera_constant']
    assert len(profile['single_tic_thinker_profiles'])==3
    checks={}
    for label in ['checks-baseline','contracts-release','reload-release','visual-enu-release','visual-es-release']:
        text=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
        lines=[line for line in text.splitlines() if line.startswith('CA116 ')]
        assert lines and all('FAIL ' not in line and not re.search(r'failures=[1-9]',line) for line in lines),label
        assert not re.search(r'FATAL ERROR|Script error|VM execution aborted',text),label
        checks[label]=lines
        shutil.copyfile(WORK/f'{label}.txt',HERE/f'{label}.txt')
        for extension in ['ini','json']:
            source=WORK/(f'{label}-run.json' if extension=='json' else f'{label}.ini')
            if source.exists(): shutil.copyfile(source,HERE/source.name)
    for label in ['baseline-quiet','baseline-controlled']:
        for suffix in ['.txt','.ini','-run.json']:
            source=WORK/f'{label}{suffix}'
            if source.exists(): shutil.copyfile(source,HERE/source.name)
    probe_text=(WORK/'input-release.txt').read_text(encoding='utf-8-sig')
    probes={}
    for kind,identifier,ms in re.findall(r'CA116 PROBE_(REQUEST|PLAY|ACK|FRAME) id=(\d+) ms=([\d.]+)',probe_text):
        probes.setdefault(identifier,{})[kind]=float(ms)
    assert len(probes)==3 and all(len(probe)==4 for probe in probes.values()),probes
    for probe in probes.values():
        probe['request_to_play_ms']=probe['PLAY']-probe['REQUEST']
        probe['request_to_overlay_ms']=probe['FRAME']-probe['REQUEST']
    for suffix in ['.txt','.ini','-run.json']:
        shutil.copyfile(WORK/f'input-release{suffix}',HERE/f'input-release{suffix}')
    result={'issue':116,'release':'5.0.0','date':'2026-10-06',
            'baseline_commit':'20143c3154617309912a493fa2a7be3c7c2c9ff4',
            'scope_amendment':'Author explicitly expanded audit-only issue to begin refactoring and waived older-save compatibility on 2026-10-06.',
            'runtime_change':json.loads((HERE/'EXTRACTION.json').read_text()),
            'static_checks':{'project_validator':'PASS; errors=[]','package_build':'PASS; 6182 runtime members',
                             'source_inventory_determinism':'PASS; repeated generation byte-identical',
                             'git_diff_check':'PASS','independent_ai_review':'Not performed; no review approval claimed'},
            'final_addon_sha256':{name:hashlib.sha256((WORK/name).read_bytes()).hexdigest() for name in ['benchmark.pk3','checks.pk3','probe.pk3']},
            'fixture_history':'The original runtime passed the same 35 projection assertions before the additional reload-observer/resume diagnostics were added. Final current-save and bilingual runs use the final checks addon identified here.',
            'native_contract_checks':checks,'current_map06_baseline':primary,
            'native_actor_profiles':profile,
            'native_event_route_probe':{'samples':probes,'method':'Scheduled event ca116_probe -> UI ConsoleProcess -> SendNetworkEvent -> play NetworkProcess -> SendInterfaceEvent -> next RenderOverlay. Diagnostic only; no gameplay mutation and no physical key injection.'},
            'historical_only':['Closed #86','assets/validation_4379/south/COMBAT_RECOVERY.json'],
            'limitations':[
                'Single Windows workstation; desktop activity was not isolated. Direct-map arrival test profile, briefing open, fixed camera at (0,320,0), angle 90; not normal campaign arrival or every combat view.',
                'Simulation throughput uses native level.time versus Object.MSTimeF, excluding startup through the first population sample.',
                'RenderOverlay intervals include simulation stalls and addon/logging overhead; these are not GPU frame times, presentation timestamps, or an end-to-end input latency benchmark.',
                '35-tic population scans add overhead. Native thinker profiling runs separately and reports only three individual tics, not function-level attribution or a whole-run average.',
                'Native event route measurements begin at UI ConsoleProcess, not a physical key. No device-to-photon latency measurement. Bilingual UI captures check event-driven page presentation; static hashes protect unchanged input/selectors. Low render cadence limits visible response frequency.',
                'No speedup claim or controlled before/after causal comparison. Earlier exploratory before/after traces changed camera/settings and are excluded from the primary benchmark.',
                'Old saves are outside author-waived acceptance. Current save/reload is tested with disposable native fixtures, not the author campaign.'
            ],
            'diagnostic_corrections':[
                'Initial INI without LastRun/version was treated as a first-run configuration; actual resolution/settings differed. Final runs use a complete initialized INI and report engine resolution.',
                'First -loadgame argument was absolute and GZDoom prepended -savedir, producing a duplicated path. Launcher now passes a save filename relative to its isolated -savedir.',
                'Saved EventHandler did not provide the expected WorldLoaded check. Final reload verification uses StaticEventHandler.WorldLoaded followed by WorldTick and a resumed saved-handler check.',
                'Python default Windows console encoding could not print a Unicode documentation range; subsequent documentation commands use python -X utf8.'
            ],
            'text_artifact_storage':'Archived logs and INI files use LF and omit trailing whitespace/blank lines; original native files remain in build/issue116. Normalization changes no diagnostic content.',
            'author_acceptance':'2026-10-06: author confirmed all delivery tests passed and authorized PR #122 merge and #116 closure; scoped old-save waiver and measurement limits remain.',
            'reproduce':[
                'Build the accepted 20143c31 runtime into build/issue116/baseline.pk3; keep the original package. prepare_benchmark.py preserves an existing baseline instead of overwriting it.',
                'python assets/validation_500/prepare_benchmark.py',
                'python assets/validation_500/prepare_checks.py',
                'powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_500/run_benchmark.ps1 -Label fresh-baseline -Package baseline.pk3 -Script baseline.cfg',
                'Use -Script profile.cfg in a separate fresh run for three thinker profiles. Engine/IWAD arguments accept local paths; do not distribute those files.',
                'Copy the final development package to build/issue116/after.pk3. Use -Addon checks.pk3 -Map MAP01 -Script checks.cfg for native contracts, then -LoadGame ca116_snapshot.zds -Script reload.cfg to verify reload.',
                'For bilingual UI checks use -Map MAP03 -Addon checks.pk3 -Script visual-enu.cfg or visual-es.cfg and matching -Language.',
                'python assets/validation_500/verify_extraction.py; python assets/validation_500/audit_sources.py; python -X utf8 build_document_index.py; python validate_project.py'
            ]}
    for lang in ['enu','es']:
        for kind in ['journal','tarot']:
            source=WORK/f'{kind}-{lang}.png'
            assert source.exists()
            shutil.copyfile(source,HERE/source.name)
    result['native_text_artifacts']={}
    for target in HERE.iterdir():
        if target.suffix not in {'.txt','.ini'}: continue
        original=WORK/target.name
        content=target.read_text(encoding='utf-8-sig')
        normalized='\n'.join(line.rstrip() for line in content.splitlines()).rstrip()+'\n'
        target.write_text(normalized,encoding='utf-8',newline='\n')
        result['native_text_artifacts'][target.name]={
            'original_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),
            'archived_sha256':hashlib.sha256(target.read_bytes()).hexdigest()}
    (HERE/'RESULTS.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({'baseline_tics_per_second':primary['simulation_tics_per_wall_second'],
                      'wall_seconds':primary['observed_wall_seconds'],
                      'render_intervals_ms':primary['render_overlay_intervals_ms'],
                      'native_checks':checks},indent=2))


if __name__=='__main__': collect()
