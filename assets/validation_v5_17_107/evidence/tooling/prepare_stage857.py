"""Adapt the strict staging audit for the wardrobe patch and additive test queue."""
from pathlib import Path
h=Path(__file__).resolve().parent
s=(h/'stage_navigation855.py').read_text(encoding='utf-8').replace('issue855','issue857').replace('5_17_106','5_17_107').replace('5.17.106','5.17.107')
s=s.replace('9269280c505c06769f24de41f6f0dc6dc936c2d3','887ae8d4ad02bd037acbbf12237108d9f1f941b8').replace('issue857-breath-navigation','issue857-equipment-wardrobe')
s=s.replace("'src/caelum/actors/CaelumDemonBreath.zs','src/caelum/actors/CaelumDemonService.zs'","'pending_test.txt','src/CVARINFO','src/MODELDEF','src/caelum/character/CaelumDomingoPilot.zs','src/caelum/character/CaelumWardrobePilot.zs','src/caelum/equipment/CaelumInventoryService.zs','src/caelum/data/CaelumWornClothingModelData.zs','src/caelum/data/wardrobe_candidate.modeldef'")
s=s.replace("'.csv','.png'","'.csv','.png','.modeldef','.html'").replace("Path(n).name=='MAPINFO'","Path(n).name in ('MAPINFO','MODELDEF','CVARINFO','ZSCRIPT')")
s=s.replace("assert not subprocess.check_output(['git','diff','--name-only','HEAD','--','pending_test.txt'],cwd=root).strip()","previous_queue=subprocess.check_output(['git','show','HEAD:pending_test.txt'],cwd=root).decode('utf-8').replace('\\r\\n','\\n')\ncurrent_queue=(root/'pending_test.txt').read_text(encoding='utf-8');assert current_queue.startswith(previous_queue) and current_queue.count('CA857-EQUIPMENT-01')==1")
s=s.replace("('ASSETS.md','HISTORY.md','PROJECT.md','TASKS.md')","('ASSETS.md','HISTORY.md','PROJECT.md','SYSTEMS.md','TASKS.md')")
s=s.replace('author_queue_unchanged=True','prior_author_queue_preserved=True,new_author_check="CA857-EQUIPMENT-01"')
(h/'stage_wardrobe857.py').write_text(s,encoding='utf-8',newline='\n')
print('Prepared final staging audit; not executed.')
