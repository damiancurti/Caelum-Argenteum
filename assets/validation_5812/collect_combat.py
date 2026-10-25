"""Retain selected final native evidence; do not distribute packages or saves."""
from pathlib import Path
import hashlib,json,re,shutil,subprocess,zipfile
root=Path(__file__).resolve().parents[2];work=root/'build/issue502-hygiene';out=root/'assets/validation_5812/combat';native=out/'native';native.mkdir(parents=True,exist_ok=True)
labels=['combat-final-core02','combat-final-live02','combat-final-trace01','combat-final-save01','combat-final-load01','combat-final-hub01','combat-old-save02','combat-final-legacy01','combat-rollback02','combat-final-calendar01','combat-final-clean01']
rows=[]
for label in labels:
 log=(work/(label+'.txt')).read_text(encoding='utf-8')
 assert not re.search(r'CA502[HM] FAIL|Script error|VM execution aborted|Failed to load|failures=[1-9]',log),label
 rec=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'));assert rec['exit_code']==0,label
 count=len(re.findall(r'^CA502[HM] PASS ',log,re.M));assert count>0,label
 rows.append({'label':label,'executed_pass':count,'runtime_sha256':rec['package_sha256'].lower(),'addon_sha256':rec['addon_sha256'].lower()})
 for suffix in ['.txt','-run.json']:shutil.copyfile(work/(label+suffix),native/(label+suffix))
perf=[]
for label in ['combat-perf-baseline03','combat-perf-final01']:
 r=json.loads((work/(label+'.json')).read_text());perf.append({k:r[k] for k in ['label','runtime_sha256','frames','mean_callback_ms','p95_callback_ms','p99_callback_ms','worst_callback_ms','phase_elapsed_ms','presentmon_available']})
 for suffix in ['.json','.txt','-presentmon.txt']:shutil.copyfile(work/(label+suffix),native/(label+suffix))
package=work/'combat-final01/caelum_argenteum_dev.pk3';baseline=work/'calendar-final01/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as z,zipfile.ZipFile(baseline) as old:
 names=z.namelist()
 for n in names:assert z.read(n)==(root/'src'/n).read_bytes(),n
 maps=[n for n in names if n.startswith('maps/')]
 art=[n for n in names if n.startswith(('sprites/','models/','textures/','graphics/'))]
 for n in maps+art:assert z.read(n)==old.read(n),n
 report={'issue':502,'version':'5.8.12','production_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),'source_identical_members':len(names),'unchanged_maps':len(maps),'unchanged_art_members':len(art),'native_pass':sum(r['executed_pass'] for r in rows),'native_fail':0,'runs':rows,'performance':perf,'author_acceptance':'CA502-COMBAT-01 pending; CA502-CALENDAR-01 accepted2026-10-25','limitations':['Render callbacks are a cadence proxy; PresentMon permission denied. No campaign-wide FPS acceptance.','Ambient and continuous actor contact plus NPC housekeeping remain pending.','Native None damage retains existing defense routing.']}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ['native_pass','native_fail','source_identical_members','unchanged_maps','unchanged_art_members']}))
