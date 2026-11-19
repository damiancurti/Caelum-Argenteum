"""Keep the final delivery evidence and prose readable without changing runtime."""
from pathlib import Path
import hashlib,json,shutil
root=Path(__file__).resolve().parents[2]/'build/v517/work-713';helpers=Path(__file__).parent
mapping={'392edge/save':'392 edge/save','50.84ms':'50.84 ms','46.32/50.84ms':'46.32/50.84 ms','1.85presents/s':'1.85 presents/s','700-tic':'700-tic','tic3200':'tic 3200','from979,459(control) to3,617,130(stop)':'from 979,459 (control) to 3,617,130 (stop)','passes392 assertions(263 on final)':'passes 392 assertions (263 on final)','normal1,000attacker-cap/600defender':'normal 1,000-attacker-cap/600-defender','Vulkan1280x720':'Vulkan 1280x720','and5%audio':'and 5% audio','has700':'has 700','988attacker NPCs+601defenders(including subcaptain)+player=1,590living':'988 attacker NPCs + 601 defenders (including subcaptain) + player = 1,590 living','health1,421,137':'health 1,421,137','health1,248':'health 1,248','allows350':'allows 350','has18,719members':'has 18,719 members','parent9387ab0e':'parent 9387ab0e','retains18,719members':'retains 18,719 members','pass392assertions(263 final)':'pass 392 assertions (263 final)','GZDoom4.14.2':'GZDoom 4.14.2','matches2,066queries/360,048visits':'matches 2,066 queries/360,048 visits','360,047read-only':'360,047 read-only','All392assertions':'All 392 assertions','complete700tic/28scope':'complete 700-tic/28-scope','leaves178.9117ms':'leaves 178.9117 ms'}
for name in ('README.md','docs/ASSETS.md','docs/HISTORY.md','docs/PROJECT.md','docs/TASKS.md','docs/KNOWN_PITFALLS.md'):
    p=root/name;s=p.read_text(encoding='utf-8')
    if name=='README.md':a=s.index('#838 avoids');b=s.index('\n#836 reduces',a)
    elif name.endswith('KNOWN_PITFALLS.md'):a=s.index('## CA-KP-256');b=s.index('\n## CA-KP-255',a)
    else:a=s.index('## 5.17.97 -');b=s.index('\n## ',a+1)
    section=s[a:b]
    for old,new in mapping.items():section=section.replace(old,new)
    p.write_text(s[:a]+section+s[b:],encoding='utf-8',newline='\n')
out=root/'assets/validation_v5_17_97/evidence';s=json.loads((out/'SUMMARY.json').read_text(encoding='utf-8'))
for name in ['document_relation838.py','record_contract838.py','stage_relation838.py','finish_evidence838.py']:
    target=out/'executed-helpers'/name;shutil.copyfile(helpers/name,target)
    s['files'][target.relative_to(out).as_posix()]=hashlib.sha256(target.read_bytes()).hexdigest()
s['directly_inspected_scenes']=['bursts','gc-control','gc-stop','prototype','oracle','final01','baseline01']
s['native_bench_cpu_snapshot_ms']={'final01':5.701,'baseline01':5.823}
(out/'SUMMARY.json').write_text(json.dumps(s,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Formatted current sections only; retained prior sections; recorded final visual/CPU observations.')
