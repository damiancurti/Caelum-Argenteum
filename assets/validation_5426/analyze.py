"""Summarize #305 controls using the same simulation windows as #304."""
from pathlib import Path
import argparse
import importlib.util
import json

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('previous_analysis',HERE.parent/'validation_5425/analyze.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    manifest=json.loads((args.directory/'manifest.json').read_text())
    folders=[args.directory]+sorted(args.directory.parent.glob(args.directory.name+'-late-*'))
    result={'manifest':manifest,'runs':{}}
    observations={};texts={}
    for folder in folders:
        for record in sorted(folder.glob('*-run.json')):
            label=record.name.removesuffix('-run.json')
            log=folder/(label+'.txt')
            key=folder.name+'/'+label
            texts[key]=log.read_text(encoding='utf-8-sig')
            summary=previous.summary(log,manifest)
            run=summary.get('run',{})
            summary['valid']=bool(summary['valid'] and run.get('exit_code')==0
                and not run.get('native_crash') and not run.get('engine_error'))
            result['runs'][key]=summary
            if summary.get('valid'):
                first,last=summary['observation_tic_bounds']
                fields=('tic','alive','total','remaining','defenders','corpses','archived','projectiles')
                observations[key]=[tuple(row[field] for field in fields)
                    for row in previous.rows(texts[key],'CA304 SIM')
                    if first<=row['tic']<=last]
            print(key,summary['valid'],round(summary.get('simulation_tics_per_wall_second',0),3),
                  summary.get('population',{}))
    result['matched_population_projectile_observations']={}
    for group in ('early','late','late-profile'):
        entries=[(key,rows) for key,rows in observations.items()
                 if key.split('/')[-1].startswith(group+'-')
                 and (group!='late' or not key.split('/')[-1].startswith('late-profile-'))]
        if entries:
            first=max(result['runs'][key]['observation_tic_bounds'][0] for key,rows in entries)
            last=min(result['runs'][key]['observation_tic_bounds'][1] for key,rows in entries)
            common=[(key,[row for row in rows if first<=row[0]<=last]) for key,rows in entries]
            timing={}
            for key,rows in common:
                sim=[row for row in previous.rows(texts[key],'CA304 SIM') if first<=row['tic']<=last]
                if len(sim)>1:
                    timing[key]={'tics_per_wall_second':(sim[-1]['tic']-sim[0]['tic'])*1000/(sim[-1]['ms']-sim[0]['ms']),
                        'sampled_bounds':[sim[0]['tic'],sim[-1]['tic']]}
            result['matched_population_projectile_observations'][group]={
                'runs':[key for key,rows in entries],
                'individual_samples_per_run':[len(rows) for key,rows in entries],
                'common_observation_bounds':[first,last],
                'common_samples_per_run':[len(rows) for key,rows in common],
                'all_common_samples_equal':all(rows==common[0][1] for key,rows in common),
                'common_timing':timing}
    old_profile=HERE.parent/'validation_5425/late-on.json'
    if old_profile.exists():
        baseline=json.loads(old_profile.read_text())['runs']['probe-03']
        expected=manifest['variants']['profile-base']['sha256']
        if baseline['run']['runtime_sha256'].lower()!=expected:
            raise SystemExit('The previous profile is not the identical instrumented baseline.')
        result['reused_profile_baseline']={'source':'../validation_5425/late-on.json:probe-03',
            'identical_runtime_sha256':expected,'result':baseline}
    args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
