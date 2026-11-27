"""Prepare every concrete catalog launch without opening any engine window."""
from pathlib import Path
import argparse,json,traceback
from sessions import HERE,ROOT,load_config,prepare,write_json
from author_terminal import catalog

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--only',nargs='*')
    a=p.parse_args();config=load_config(a.config);out=a.output.resolve()
    out.relative_to(ROOT/'build/author-889');out.mkdir(parents=True,exist_ok=False)
    data=catalog(config);rows=[]
    for action in data['actions']:
        if action['kind'] in ('gallery','tool') or a.only and action['id'] not in a.only:continue
        try:
            record=prepare(action,config,out/action['id'])
            row=dict(action=action['id'],passed=True,session=record['cwd'],packages=len(record['packages']))
        except Exception as e:
            row=dict(action=action['id'],passed=False,error=str(e),traceback=traceback.format_exc())
        rows.append(row);print(json.dumps({k:v for k,v in row.items() if k!='traceback'}),flush=True)
        write_json(out/'RESULTS.json',dict(issue=config['issue'],passed=all(r['passed'] for r in rows),rows=rows,
            qualification='Prepared commands and fixtures only; no native execution or author acceptance.'))
    raise SystemExit(any(not r['passed'] for r in rows))

if __name__=='__main__':
    main()
