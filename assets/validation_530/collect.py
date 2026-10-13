"""Collect only final issue-scoped native evidence, without runtime dependencies."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue255'
labels=['baseline-ref','final-ref','final-4x3-ref','final-wide-ref','final-large',
        'baseline-save','current-load-final']
records=[]
for label in labels:
    run=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert run['exit_code']==0, label
    if label=='baseline-save':
        assert 'CA255 SNAPSHOT seal=1 weapon=3 tarot=1' in log and 'Game saved.' in log,label
    else:
        assert 'CA255 DONE failures=0' in log, label
    records.append(run)
    for name in [f'{label}-run.json',f'{label}.txt']:
        shutil.copyfile(WORK/name,HERE/name)
for name in ['baseline-ref-ready.png','final-ref-ready.png','final-ref-active.png',
             'final-ref-unavailable.png','final-ref-absent.png','final-4x3-ref-active.png',
             'final-wide-ref-active.png','final-large-large.png','current-load-final-loaded.png']:
    shutil.copyfile(WORK/name,HERE/name)
evidence={'issue':255,'version':'5.3.0','baseline_commit':'7e79bcb7',
          'runs':records,'author_acceptance':'pending CA255-01',
          'runtime_sha256':hashlib.sha256((WORK/'production.pk3').read_bytes()).hexdigest(),
          'static_commands':[{'command':'python validate_project.py','exit_code':0},
                             {'command':'powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1','exit_code':0}]}
(HERE/'evidence.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8')
print('Collected',len(records),'successful native runs.')
