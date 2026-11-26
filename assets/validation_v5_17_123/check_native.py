"""Sequential native launch/menu/save checks for selected final terminal actions."""
from pathlib import Path
import argparse,json
from author_terminal import catalog
from sessions import ROOT,load_config,prepare,run,write_json

REPRESENTATIVES=[
    'v5_16_3-run_nahuelito_preview','v5_17_0-run_modular_preview',
    'v5_17_1-run_coin_drops-coins','v5_17_1-run_coin_drops-food',
    'v5_17_70-run_torso_armor_drops','v5_17_5-run_pombero',
    'v5_17_18-run_beast_men-lobizon','v5_17_83-run_native_gallery',
    'v5_17_91-run_gallery','v5_17_92-run_underbody','wardrobe-art',
    'v5_17_95-run_iqm_viewer','equipment']

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--only',nargs='*')
    a=p.parse_args();config=load_config(a.config);data=catalog()
    actions={r['id']:r for r in data['actions']}
    chosen=a.only or REPRESENTATIVES+[r['id'] for r in data['actions'] if r.get('group')=='environment']
    assert all(key in actions for key in chosen)
    out=a.output.resolve();out.relative_to(ROOT/'build/author-889');out.mkdir(parents=True,exist_ok=False)
    rows=[]
    for key in chosen:
        record=prepare(actions[key],config,out/key,smoke=True)
        result=run(record,hidden=True);result['session']=record['cwd'];rows.append(result)
        write_json(out/'RESULTS.json',dict(issue=889,rows=rows,passed=all(r['passed'] for r in rows),
            qualification='Hidden native launch/save-menu/checkpoint smoke. No visual, campaign, performance or author acceptance.'))
        print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)

if __name__=='__main__':
    main()
