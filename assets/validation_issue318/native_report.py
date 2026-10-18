"""Count new native assertions, never cumulative counters restored from saves."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
rows=[]
for directory in ('issue318-native-08','issue318-door-collision-01'):
    for path in sorted((ROOT/'build'/directory/'current').glob('*-run.json')):
        record=json.loads(path.read_text());label=record['options']['label']
        text=path.with_name(label+'.txt').read_text(encoding='utf-8',errors='replace')
        assert record['exit_code']==0 and record['keep_awake_released']
        assert 'CA318 FAIL' not in text and 'CA318 DONE failures=0' in text
        rows.append({'directory':directory,'label':label,'new_pass_lines':sum(line.startswith('CA318 PASS ') for line in text.splitlines()),
                     'runtime_sha256':record['runtime_sha256'],'fixture_sha256':record['fixture_sha256']})
assert len(rows)==9 and sum(row['new_pass_lines'] for row in rows)==230
(HERE/'NATIVE_VERIFICATION.json').write_text(json.dumps({'runs':rows,'new_assertions':230,'all_exit_zero':True,'all_keep_awake_released':True},indent=2)+'\n')
print('Verified 9 native runs and 230 new assertions')
