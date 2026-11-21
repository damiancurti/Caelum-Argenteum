from pathlib import Path
import subprocess,sys,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue861-ordinary01'
with (root/'build/issue861-ordinary01.log').open('wb') as log:
 r=subprocess.run([sys.executable,'-X','utf8','assets/validation_v5_17_109/run_hand_ownership861.py','--ordinary-player','--runtime','build/issue861-hands01.pk3','--output',str(out)],cwd=root,stdout=log,stderr=log)
d=json.loads((out/'RESULTS.json').read_text()) if (out/'RESULTS.json').exists() else {}
print(json.dumps({'ordinary_player_passed':r.returncode==0 and d.get('passed',False),'pass_lines':sum('EDGE PASS' in x for x in d.get('checks',[])),'errors':d.get('errors',[])}),flush=True)
if r.returncode or not d.get('passed'):raise SystemExit(1)
r=subprocess.run([sys.executable,'-X','utf8',str(Path(__file__).with_name('run_hand_performance861.py'))],cwd=root);raise SystemExit(r.returncode)
