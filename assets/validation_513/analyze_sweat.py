"""Report native heat/water budgets and phase timings without claiming presented FPS."""
from pathlib import Path
import hashlib
import json
import sys
import zipfile
from analyze_performance import fields, percentile

HERE=Path(__file__).resolve().parent
WORK=HERE.parents[1]/'build/issue133'


def phase(label,prefix,start,end):
    lines=(HERE/(label+'.txt')).read_text(encoding='utf-8-sig').splitlines()
    rows=[fields(line) for line in lines if line.startswith(prefix+' ')]
    rows=[r for r in rows if start<=r['tic']<=end]
    frames=[fields(line) for line in lines if line.startswith('CA132 FRAME ')]
    frames=[r for r in frames if start<=r['tic']<=end]
    assert rows and rows[-1]['tic']>=end,(label,end)
    record=json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    return {'run':label,'package_sha256':record['package_sha256'],'tic_range':[start,end],
        'tics_per_second':(rows[-1]['tic']-rows[0]['tic'])*1000/(rows[-1]['ms']-rows[0]['ms']),
        'render_callbacks_per_second':(len(frames)-1)*1000/(frames[-1]['ms']-frames[0]['ms']) if len(frames)>1 else None,
        'render_interval_p95_ms':percentile([b['ms']-a['ms'] for a,b in zip(frames,frames[1:])],.95) if len(frames)>1 else None,
        'first':rows[0],'last':rows[-1]}


def snapshot(name):
    path=WORK/name
    with zipfile.ZipFile(path) as z:objects=json.loads(z.read('map06.map.json'))['objects']
    rows=[]
    for body in objects:
        if 'class:CaelumPortDefender' not in body:continue
        combat=body['class:CaelumCombatActor']
        state={k.lower():v for k,v in objects[combat['ThermalState']]['class:CaelumThermalState'].items()}
        row={'health':body.get('health',0),'air':combat['CurrentCombatAir']}
        for key in ('exposure','hydration','sweatkg','sweatrunoffkg','evaporatedkg','evaporationjoules','actionjoules','applieddamagehp'):
            row[key]=state.get(key,0)
        rows.append(row)
    assert len(rows)==600
    return {'name':name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'roster':600,
        'alive':sum(r['health']>0 for r in rows),
        'ranges':{key:[min(r[key] for r in rows),max(r[key] for r in rows)] for key in rows[0]}}


def main():
    volley,city=sys.argv[1:3]
    results=[phase(volley,'CA133 VOLLEY',70,490),phase(volley,'CA133 VOLLEY',490,1400),phase(volley,'CA133 VOLLEY',1400,3500)]
    results += [phase(city,'CA133 CITY',a,b) for a,b in ((350,1715),(1750,3500),(3500,7000),(7000,10500))]
    report={'issue':133,'scope':'After authorized sweat/resource extension. Engine callbacks, not Windows presented FPS. Same scenario does not mean equal live population or combat workload.',
        'phases':results,'snapshots':[snapshot('sweat-volley-'+str(t)+'.zds') for t in (500,1450,3500)],
        'pre_extension_report':'PERFORMANCE.json','pre_extension_death_control':'HEAT_LIMIT.json'}
    (HERE/'SWEAT_RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    for r in results:print(r['run'],r['tic_range'],round(r['tics_per_second'],2),round(r['render_callbacks_per_second'],2))
    for s in report['snapshots']:print(s['name'],s['alive'],s['ranges']['exposure'],s['ranges']['hydration'])


if __name__=='__main__':main()
