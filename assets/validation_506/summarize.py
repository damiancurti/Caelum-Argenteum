"""Summarize normal-combat #128 comparisons with reproducible raw evidence."""
from pathlib import Path
import importlib.util
import json
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('previous',ROOT/'assets/validation_505/summarize.py')
previous=importlib.util.module_from_spec(spec)
spec.loader.exec_module(previous)
previous.HERE=HERE
previous.WORK=ROOT/'build/issue128'

def main():
    runs={}
    for path in sorted(previous.WORK.glob('*-run.json')):
        label=path.name.removesuffix('-run.json')
        record=json.loads(path.read_text(encoding='utf-8-sig'))
        if not record.get('last_sim_tic'):continue
        data=previous.read(label)
        runs[label]={**{k:v for k,v in data.items() if k not in ['frames','costs','counts','rare']},
                     'raw_log':label+'.txt','package_sha256':record['package_sha256'],
                     'addon_sha256':record['addon_sha256']}
    pairs={}
    for a,b in [('baseline-a','current-a'),('baseline-a','current-b'),
                ('neither-a','no-stagger-a'),('neither-a','no-candidates-a'),
                ('no-stagger-a','current-a'),('no-candidates-a','current-a'),
                ('no-stagger-b','current-b'),('no-candidates-b','current-b'),
                ('no-stagger-a','pruned-cannon-a'),('no-stagger-b','pruned-cannon-b'),
                ('legacy-shared-a','production-c'),('legacy-shared-b','production-d'),
                ('baseline-a','production-c'),('baseline-a','production-d')]:
        if a not in runs or b not in runs:continue
        for window in ['early','congested','later','common']:
            pairs[f'{a}__{b}__{window}']=previous.compare(runs[a],runs[b],window)
    output={'issue':128,'baseline_release':'5.0.5','baseline_commit':'0e2b9eab9e93096993f04beab5d5ef94d69ca0e3',
            'conditions':'Full ordinary MAP06 combat; 6001 attackers and 600 defenders; fixed seed, skill, initial camera and renderer settings; background unpaused; volume 5%.',
            'limitations':['Group targets intentionally change trajectories and subsequent combat workloads.',
                          'Overlay callback rate is not measured GPU/presentation FPS.',
                          'Desktop load is not exclusively controlled; repeated results are observations, not universal guarantees.',
                          'A change in timing alone does not establish an independent causal gain.'],
            'runs':runs,'comparisons':pairs}
    (HERE/'RESULTS.json').write_text(json.dumps(output,indent=2)+'\n',encoding='utf-8')
    for label,data in runs.items():
        print(label,{name:{'tps':round(w['simulation_tics_per_second'],3),'callbacks':round(w['callback_fps'],3),'p95_ms':round(w['frame_callback_interval_ms']['p95'],3)} for name,w in data['windows'].items() if name in ['early','congested','later','common']})

if __name__=='__main__':main()
