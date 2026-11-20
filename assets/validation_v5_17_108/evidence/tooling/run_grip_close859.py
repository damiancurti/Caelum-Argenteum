"""Inspect both native grips and every supported glove shell at close range."""
from pathlib import Path
import json,subprocess,sys
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');rows=[]
for glove,focus in [('bare','Left'),('GF','Right'),('GC','Right'),('GW','Right'),('GP','Right')]:
    out=root/f'build/issue859-close-{glove.lower()}-{focus.lower()}01'
    command=[sys.executable,'-X','utf8','assets/validation_v5_17_108/run_grip_motion859.py','--glove',glove,'--focus',focus,'--runtime','build/issue859-grips02.pk3','--output',str(out)]
    with out.with_suffix('.log').open('wb') as log:process=subprocess.run(command,cwd=root,stdout=log,stderr=log)
    d=json.loads((out/'RESULTS.json').read_text()) if (out/'RESULTS.json').exists() else {}
    row={'glove':glove,'focus':focus,'directory':out.relative_to(root).as_posix(),'passed':process.returncode==0 and d.get('passed',False),'pass_lines':sum('EDGE PASS' in x for x in d.get('checks',[])),'capture_pose_checks':d.get('capture_pose_checks')};rows.append(row)
    (root/'build/issue859-close-summary.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
    if not row['passed']:sys.exit(1)
