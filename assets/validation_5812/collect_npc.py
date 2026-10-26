"""Collect final NPC exposure evidence without counting serialized totals twice."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
root=Path(__file__).resolve().parents[2];work=root/'build/issue502-hygiene'
out=root/'assets/validation_5812/npc';native=out/'native';native.mkdir(parents=True,exist_ok=True)
labels=['npc2-core01','npc2-save01','npc2-load01','npc2-hub01','npc2-legacy01',
        'npc2-legacy-hub01','npc-old-save01','npc-old-rollback01','npc2-clock01',
        'npc2-combat01','npc2-calendar01']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
runs=[]
for label in labels:
    log=work/(label+'.txt');data=log.read_text(encoding='utf-8-sig')
    failures=re.findall(r'^CA502[HMN] FAIL.*',data,re.M)
    assert not failures,(label,failures)
    record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record.get('exit_code')==0 and not record.get('timed_out'),label
    for suffix in ['.txt','-run.json']:shutil.copy2(work/(label+suffix),native/(label+suffix))
    runs.append({'label':label,'passed':len(re.findall(r'^CA502[HMN] PASS ',data,re.M)),
                 'failed':0,'runtime_sha256':record['package_sha256'].lower(),
                 'fixture_sha256':record['addon_sha256'].lower(),'log_sha256':digest(log)})
runtime=work/'npc-final02/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(runtime) as z,zipfile.ZipFile(work/'combat-final01/caelum_argenteum_dev.pk3') as old:
    for name in z.namelist():assert z.read(name)==(root/'src'/name).read_bytes(),name
    maps=[n for n in old.namelist() if n.startswith('maps/')]
    art=[n for n in old.namelist() if n.startswith(('sprites/','models/','graphics/','textures/','patches/'))]
    for name in maps+art:assert z.read(name)==old.read(name),name
    members=len(z.namelist())
perf=[]
for label in ['npc-perf-baseline01','npc-perf-final01']:
    record=json.loads((work/(label+'.json')).read_text());perf.append(record)
    for suffix in ['.json','.txt','-presentmon.txt']:shutil.copy2(work/(label+suffix),native/(label+suffix))
report={'runtime':'npc-final02','runtime_sha256':digest(runtime),'source_identical_members':members,
        'unchanged_maps':len(maps),'unchanged_art_members':len(art),'runs':runs,
        'executed_passes':sum(r['passed'] for r in runs),'failures':0,'performance':perf,
        'author_crash_sha256':'a03655c12364daecdc38de7b32b72a066a647cec74f845ce6e7c44f0ef5598d6',
        'author_acceptance':'CA502-NPC-01 accepted 2026-10-25; combat and calendar acceptance preserved.'}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['executed_passes','failures','runtime_sha256','source_identical_members','unchanged_maps','unchanged_art_members']}))
