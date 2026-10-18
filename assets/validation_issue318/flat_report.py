"""Summarize complete flat-army measurements without conflating FPS and tics."""
from pathlib import Path
import json
import re

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
def fmt(x):return '-' if x is None else f'{x:.2f}'

def main():
    all_rows={}
    lines=['## Flat armies: sprites, Domingo model and inventory ablation','',
      'The author requested 6,000 Mandingas versus 1,000 soldiers, then the same',
      'battery at 1,000 versus 600, and explicitly authorized removing Mandinga',
      'inventory for a diagnostic comparison. These changes are fixtures only.',
      'Normal gameplay army totals, inventory and art are unchanged.','',
      'Both counts use one flat sector/four boundary lines, Vulkan 1280x720,',
      'seed116, skill2, 48-MU spacing, 100 columns, identical overhead camera and',
      '35 warmup tics. All bodies activate together with opposing native hate',
      'groups and valid targets, retain solid collisions, production stats,',
      'thermal simulation, breath, damage and resources. The soldiers use their',
      'native sword/shield AI outside the MAP06 siege controller: there are no',
      'city routes, carbine orders, cannon crews, commander or reinforcements.',
      'This isolates the flat battle; it does not certify the full MAP06 siege.','',
      'The visual addon contains only MODELDEF mappings. Both army classes use',
      'the existing Domingo MD3 (10,689 vertices, 17,447 triangles, 375 frames;',
      'SHA256 bdc078573426bf82d94dc6b1d6a97f7236cdf31cdf271eabd9ef5512e1f81fa5).',
      'Sparse pose samples follow existing actor sprite-state timings, with',
      'native interpolation, existing scale and double-sided drawing. It adds',
      'no body/proxy/animation thinker and changes no combat state. This is an',
      'approved substitute, not a final Mandinga asset or a model LOD study.','',
      'Inventory removal occurs once after deferred PostBeginPlay initializes',
      'the bodies and before the measurement window. It removes all native',
      'inventory objects from each Mandinga, keeps the supply revision and',
      'verifies zero inventory at removal, window start and end. The 6,000-body',
      'case removes18,000 stacked objects/108,000 units; the 1,000-body case',
      'removes3,000 objects/18,000 units. No recurring cleanup scan is installed.',
      'Absence of potions can change longer combat outcomes; that is a gameplay',
      'qualification, not permission to remove them from production.','',
      'Removing inventory also changes carried weight, effective collision mass',
      'and attack air cost. The difference measures the complete inventory',
      'ablation, not exclusively the Tick cost of the removed objects. Matching',
      'short-run casualties/health does not prove identical resource histories.','',
      'Short onset windows cover175 tics (5 simulated seconds); sustained',
      'windows cover1,050 tics (30 simulated seconds). Frozen controls stop all',
      'nonplayer actor thinkers at the window boundary and measure350 tics:',
      'they isolate drawing plus remaining player/events, not playable combat.',
      'DORMANT_STAT also excludes those bodies from ordinary thinker iterators:',
      'event workloads change and the final ordinary census reads zero, although',
      'the bodies remain visible. Do not subtract this result as pure AI cost.',
      'The initial catch-up burst can put frozen-window tic throughput above35;',
      'it is not evidence of faster combat. Profiling is a separate instrumented',
      'run sampled every17 tics; inclusive nested scopes must not be added.','',
      'ETW records application presents, not monitor refresh. Short windows with',
      'fewer than30 intervals do not support meaningful tail claims.',
      'Reported percentiles are empirical values of each capture, not stable',
      'estimates of future tails; a threshold of 30 does not make p99 precise.',
      'Frozen-control FPS must never be reported as active combat. No two engines',
      'run together; background simulation/rendering and5% audio remain enabled.','']
    for directory,title in [('issue318-flat-01','6,000 versus 1,000'),('issue318-flat-1600-01','1,000 versus 600')]:
        rows=json.loads((ROOT/'build'/directory/'analysis.json').read_text())
        assert len(rows)==20,(directory,len(rows))
        assert all(r['completed'] for r in rows),'Incomplete native measurement'
        all_rows[directory]={r['label']:r for r in rows}
        lines+=['### '+title,'','| Run | Tics/s | App FPS | ETW N | Mean frame ms | p95 ms | p99 ms |','| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
        for r in rows:
            p=r.get('presentmon',{});s=p.get('MsBetweenPresents',{});n=p.get('sample_count',0)
            assert n>0,(directory,r['label'],'Missing ETW evidence')
            lines+=['| '+' | '.join([r['label'],fmt(r.get('tics_per_second')),fmt(p.get('application_present_fps')),str(n),fmt(s.get('mean')),fmt(s.get('p95') if n>=30 else None),fmt(s.get('p99') if n>=30 else None)])+' |']
        lines+=['','Native counts, health and startup (raw log fields):',
                'First-tic delay is wall latency until the next WorldTick. It includes',
                'deferred initialization, remaining tic work and initial drawing, not',
                'exclusive PostBeginPlay CPU time. Spawn+activation alone is incomplete.','',
                '| Run | Spawn+activation ms | First-tic delay ms | Final native census | Total living health |','| --- | ---: | ---: | --- | ---: |']
        for r in rows:
            if r['label'].startswith('frozen') or r['variant']=='profile':continue
            text=(ROOT/'build'/directory/r['variant']/(r['label']+'.txt')).read_text(encoding='utf-8',errors='replace')
            spawn=re.search(r'CA318 SPAWN_END .*total_ms=([\d.]+)',text)
            first=re.search(r'CA318 INITIAL_TIC ms_since_activation=([\d.]+)',text)
            end=next(l for l in text.splitlines() if l.startswith('CA318 CENSUS end'))
            health=re.search(r'CA318 COMBAT end .*total_health=(\d+)',text)
            if 'empty' in r['label']:
                assert re.search(r'CA318 INVENTORY end bodies=\d+ items=0 uninitialized_supply=0',text)
            lines+=['| '+' | '.join([r['label'],spawn[1],first[1],end.removeprefix('CA318 CENSUS end '),health[1]])+' |']
        lines+=['']
    lines+=['### Sampled subsystem costs','',
            'Values below are **exclusive ms/sample tic**, not GPU costs. Nested',
            'inclusive costs and call counts are retained in analysis.json.',
            'The CombatActor.Tick remainder includes code and native work outside',
            'the selected probes; this table is not a complete engine profiler.','',
            '| Method | 7000 full | 7000 empty | 1600 full | 1600 empty |',
            '| --- | ---: | ---: | ---: | ---: |']
    profiles=[]
    for directory in all_rows:
        for label in ('combat-profile','inventory-empty-profile'):
            profiles.append({p['name']:p for p in all_rows[directory][label]['profile']})
    names=[p['name'] for p in all_rows['issue318-flat-01']['combat-profile']['profile'][:24]]
    for n in ('CaelumDemonService.UpdatePotions','CaelumWeightPressure.WorldTick','CaelumPopulationState.Refresh'):
        if n not in names:names.append(n)
    for name in names:lines+=['| '+name+' | '+' | '.join(fmt(p.get(name,{}).get('exclusive_ms_per_sample_tic')) for p in profiles)+' |']
    lines+=['','Reproduce with flat_army_fixture.py (default6,000/1,000, or',
      '--mandingas1000 --soldiers600), flat_controls.py, flat_suite.py and',
      'flat_inventory_suite.py. Use fresh directories; preserve old labels.',
      'Stop the authorized ETW collector before analyze.py reads its CSV, then',
      'run flat_report.py. Runtime/member hashes, exact commands, native logs,',
      'CPU samples, raw ETW and selected captures accompany the evidence.','']
    text='\n'.join(lines)
    for a,b in [('seed116','seed 116'),('skill2','skill 2'),('removes18','removes 18'),('removes3','removes 3'),
                ('cover175','cover 175'),('cover1','cover 1'),('measure350','measure 350'),('above35','above 35'),
                ('every17','every 17'),('than30','than 30'),('and5%','and 5%'),('default6','default 6'),
                ('--mandingas1000','--mandingas 1000'),('--soldiers600','--soldiers 600')]:text=text.replace(a,b)
    path=HERE/'RESULTS.md';doc=path.read_text(encoding='utf-8')
    start='<!-- FLAT_START -->';end='<!-- FLAT_END -->'
    if start in doc:doc=re.sub(start+'.*?'+end,start+'\n'+text+end,doc,flags=re.S)
    else:doc+='\n'+start+'\n'+text+end+'\n'
    path.write_text(doc,encoding='utf-8');print('Reported 40 completed flat-army measurements')

if __name__=='__main__':main()
