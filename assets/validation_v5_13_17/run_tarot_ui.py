"""Capture the production Tarot panel for two acquired Major cards."""
from pathlib import Path
import argparse,importlib.util,datetime,json
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('tarot_ui_author',ROOT/'assets/validation_v5_13_9/run_author_suite.py')
suite=importlib.util.module_from_spec(spec);spec.loader.exec_module(suite);original=suite.prepare
def prepare(selection,peer,*args):
    result=original(selection,peer,*args)
    with (peer/'controls.cfg').open('a',encoding='utf-8') as f:
        if selection['role']==0:
            f.write(f'wait 180; ca_journal_page 6; ca_journal_tarot_selected 19; ca_journal_open true; wait 20; screenshot "{(peer/"sun-panel.png").as_posix()}"; wait 5; ca_journal_tarot_selected 9; ca_journal_open true; wait 20; screenshot "{(peer/"hermit-panel.png").as_posix()}"; wait 5; ca_journal_open false; wait 130; quit\n')
        else:f.write('wait 355; quit\n')
    return result
suite.prepare=prepare
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True);p.add_argument('--iwad',type=Path,required=True)
args=p.parse_args();args.smoke=False;args.port=32646
for field in ('runtime','engine','iwad'):setattr(args,field,getattr(args,field).resolve(strict=True))
home=ROOT/'build/issue440'/datetime.datetime.now().strftime('ui-review-%Y%m%d-%H%M%S');home.mkdir(parents=True)
result=suite.launch(args,home,0)
Path(__file__).with_name('ui_results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(directory=result['directory'],passed=result['passed'])));raise SystemExit(not result['passed'])
