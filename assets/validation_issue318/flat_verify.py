"""Check population, visual equivalence, inventory absence and process cleanup."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
reports=[]
for directory,demons,soldiers in [('issue318-flat-01',6000,1000),('issue318-flat-1600-01',1000,600)]:
    folder=ROOT/'build'/directory;rows=json.loads((folder/'analysis.json').read_text())
    assert len(rows)==20 and all(r['completed'] and r.get('presentmon') for r in rows)
    hashes=set();end_states={};inventory=[]
    for row in rows:
        path=folder/row['variant']/row['label'];rec=json.loads(path.with_name(path.name+'-run.json').read_text())
        assert rec['exit_code']==0 and rec['keep_awake_released']
        assert not rec.get('engine_error') and not rec.get('watchdog_timeout')
        text=path.with_suffix('.txt').read_text(encoding='utf-8',errors='replace')
        assert 'CA318 FAIL' not in text
        census={label:dict((k,int(v)) for k,v in re.findall(r'(\w+)=(\d+)',values))
                for label,values in re.findall(r'CA318 CENSUS (\w+) ([^\r\n]+)',text)}
        for label in ('activated','window'):
            assert census[label]['mandingas']==demons and census[label]['soldiers']==soldiers,(directory,row['label'],label)
            assert census[label]['valid_targets']==demons+soldiers
        if not row['label'].startswith('frozen'):
            end=census['end'];assert end['mandingas']+end['soldiers']+end['dead']==demons+soldiers
            health=int(re.search(r'CA318 COMBAT end .*total_health=(\d+)',text)[1])
            # Actor totals differ under inventory removal, so only compare
            # visual variants with the same inventory condition below.
            end_states[row['label']]={'census':end,'living_health':health}
        else:assert 'nonplayer_actors_frozen=1 player_and_events_active=1' in text
        if 'empty' in row['label']:
            removed=re.search(r'CA318 INVENTORY_REMOVED .*bodies=(\d+) objects=(\d+) units=(\d+)',text)
            assert tuple(map(int,removed.groups()))==(demons,demons*3,demons*18)
            for label in ('after_removal','window','end'):
                assert f'CA318 INVENTORY {label} bodies={demons} items=0 uninitialized_supply=0' in text
            inventory.append(row['label'])
        if row['variant']=='current':hashes.add(rec['runtime_sha256'])
    assert len(hashes)==1
    for a,b in [('sprites-01','models-02'),('sprites-01','models-03'),('sprites-01','sprites-04'),
                ('inventory-empty-02','inventory-empty-models-01'),('inventory-empty-03','inventory-empty-models-02'),
                ('sustained-sprites','sustained-models'),('sustained-empty-sprites','sustained-empty-models')]:
        assert end_states[a]==end_states[b],(directory,a,b,'Visual variant changed end state')
    with zipfile.ZipFile(folder/'current/domingo.pk3') as z:assert z.namelist()==['MODELDEF']
    reports.append({'directory':directory,'runs':len(rows),'initial_combatants':demons+soldiers,
                    'runtime_sha256':next(iter(hashes)),'visual_end_states_match':True,
                    'inventory_absence_verified_runs':inventory,'end_states':end_states,
                    'all_keep_awake_released':True})
assert reports[0]['runtime_sha256']==reports[1]['runtime_sha256']
path=ROOT/'assets/validation_issue318/FLAT_VERIFICATION.json'
path.write_text(json.dumps(reports,indent=2)+'\n');print('Verified 40 runs, populations, visual outcomes and cleanup')
