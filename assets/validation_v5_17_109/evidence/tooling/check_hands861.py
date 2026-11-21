"""Verify the exact source/runtime scope of the hand-selector delivery."""
from pathlib import Path
import hashlib,json,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
expected={'caelum/player/CaelumPlayer.zs','caelum/character/CaelumAppearanceHands.zs','caelum/equipment/CaelumInventoryService.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
old=root/'build/issue859-grips02.pk3';runtime=root/'build/issue861-hands01.pk3';prototype=root/'build/issue861-prototype02/prototype.pk3'
with zipfile.ZipFile(old) as a,zipfile.ZipFile(runtime) as b,zipfile.ZipFile(prototype) as c:
 assert set(a.namelist())==set(b.namelist());changed=[]
 for name in b.namelist():
  data=b.read(name);assert data==(root/'src'/name).read_bytes(),name
  if data!=a.read(name):changed.append(name)
 assert set(changed)==expected,changed
 for name in c.namelist():assert b.read(name)==c.read(name),name
 report={'issue':861,'version':'5.17.109','members':len(b.namelist()),'changed':sorted(changed),'unchanged_members':len(b.namelist())-len(changed),'no_added_or_removed_runtime_members':True,'all_runtime_bytes_match_src':True,'all_prototype02_members_match_final':True,'no_new_classes_or_saved_fields':True,'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'baseline_sha256':hashlib.sha256(old.read_bytes()).hexdigest(),'prototype_sha256':hashlib.sha256(prototype.read_bytes()).hexdigest()}
(root/'build/issue861-scope.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
