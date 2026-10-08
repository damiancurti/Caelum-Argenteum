"""Summarize simulation and renderer callbacks, never Windows presented FPS."""
from pathlib import Path
import json
import re
import statistics

HERE=Path(__file__).resolve().parent
WORK=HERE.parents[1]/'build/issue133'
JOBS=[('perf-legacy-full','CA132 SIM',[(350,3500,'full army, old geometry')]),
      ('perf-legacy-staged','CA132 SIM',[(350,3500,'staged army, old geometry')]),
      ('perf-city-staged','CA133 CITY',[(350,1715,'occupied peaceful city'),(1750,3500,'scheduled exit'),
          (3500,7000,'deployment and buildup'),(7000,10500,'later combined workload')]),
      ('perf-volleys','CA133 VOLLEY',[(70,490,'600 living firearm component: fire and reload'),
          (490,1400,'thermal attrition after firing stops'),(1400,3500,'post-attrition corpses; not sustained fire')])]


def fields(line):
    return {key:float(value) for key,value in re.findall(r'(\w+)=(-?\d+(?:\.\d+)?)',line)}


def percentile(values,fraction):
    ordered=sorted(values);index=(len(ordered)-1)*fraction;lo=int(index);hi=min(len(ordered)-1,lo+1)
    return ordered[lo]+(ordered[hi]-ordered[lo])*(index-lo)


def main():
    results=[]
    for label,marker,phases in JOBS:
        path=WORK/(label+'.txt')
        if not path.exists():raise SystemExit(f'Missing completed run: {label}')
        lines=path.read_text(encoding='utf-8').splitlines()
        sim=[fields(line) for line in lines if line.startswith(marker+' ')]
        frames=[fields(line) for line in lines if line.startswith('CA132 FRAME ')]
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert record.get('completed_utc'),label
        for start,end,phase in phases:
            rows=[r for r in sim if start<=r['tic']<=end];render=[r for r in frames if start<=r['tic']<=end]
            assert len(rows)>1 and rows[-1]['tic']==end,(label,phase)
            intervals=[r['ms']-l['ms'] for l,r in zip(render,render[1:])]
            item={'run':label,'phase':phase,'tic_range':[start,end],'package_sha256':record['package_sha256'],
                  'tics_per_second':(rows[-1]['tic']-rows[0]['tic'])*1000/(rows[-1]['ms']-rows[0]['ms']),
                  'render_callbacks_per_second':(len(render)-1)*1000/(render[-1]['ms']-render[0]['ms']) if len(render)>1 else None,
                  'render_interval_median_ms':statistics.median(intervals) if intervals else None,
                  'render_interval_p95_ms':percentile(intervals,.95) if intervals else None,
                  'render_samples':len(render),'ranges':{key:[min(r[key] for r in rows),max(r[key] for r in rows)] for key in rows[0] if key not in ('tic','ms')},
                  'first':rows[0],'last':rows[-1]}
            results.append(item)
    report={'evidence':'Engine simulation and RenderOverlay callbacks in background; not presented/displayed FPS. Actor/projectile counts are sampled every 35 tics, not instantaneous peaks. Different new-city calendar, geometry and carbine behavior are a combined workload, not an isolated geometry delta.',
            'phases':results}
    (HERE/'PERFORMANCE.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    lines=['# #133 native performance controls','',report['evidence'],'',
           '| Scenario | Tics | Tics/s | Render callbacks/s | Render median/p95 ms |',
           '| --- | --- | ---: | ---: | ---: |']
    for row in results:
        rate=row['render_callbacks_per_second'];median=row['render_interval_median_ms'];p95=row['render_interval_p95_ms']
        lines.append(f"| {row['phase']} | {row['tic_range'][0]}–{row['tic_range'][1]} | {row['tics_per_second']:.2f} | {rate:.2f} | {median:.2f} / {p95:.2f} |")
    lines+=['','Population, shots, reloads, projectile ranges, exact phase endpoints and package hashes are in PERFORMANCE.json.',
            'The firearm component uses all 600 original housed actors and stationary diagnostic targets, with staggered four-tic attack requests and native recovery. It does not measure natural target selection or deployment.',
            'All 600 shoot 14 rounds, finish one reload and then stop firing. Thermal damage kills all of them by tic 1400; HEAT_LIMIT.json confirms the cause in native saved state. Later cheap rendering is not evidence of sustained live firearm performance. No thermal balance or resources were overridden.']
    (HERE/'PERFORMANCE.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('\n'.join(lines))


if __name__=='__main__':main()
