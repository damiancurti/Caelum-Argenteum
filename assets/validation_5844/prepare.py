"""Prepare private native decoration fixtures without modifying production maps."""
from pathlib import Path
import argparse
import subprocess
import zipfile
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue410-decor'
BASE=R.parent/'issue502-housekeeping-work/build/issue502-housekeeping/final43b/caelum_argenteum_dev.pk3'
def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','47acf3e3','--name-only','--','src'],cwd=R,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))
prior=(R/'assets/validation_5836/checks.zs').read_text(encoding='utf-8').replace('CA410RF','CA410O').replace('RecipeBookVersion==22','RecipeBookVersion==24')
# Reuse production trade/crafting/Box checks only for the two affected variants.
for method,next_method in [('Craft','Items'),('Items','Trade'),('Trade','FaceClear')]:
    begin=prior.index('    void '+method+'(')
    end=prior.index('    '+('bool' if next_method=='FaceClear' else 'void')+' '+next_method+'(',begin)
    section=prior[begin:end].replace('int v=0;v<CaelumRestFurnitureData.COUNT','int v=CaelumRestFurnitureData.FIRST_DECOR_VARIANT;v<CaelumRestFurnitureData.COUNT').replace('int k=0;k<CaelumRestFurnitureData.COUNT','int k=CaelumRestFurnitureData.FIRST_DECOR_VARIANT;k<CaelumRestFurnitureData.COUNT')
    prior=prior[:begin]+section+prior[end:]
prior=prior.replace('u.CraftingSelectionRecipe=CaelumRestFurnitureData.FIRST_RECIPE+2;','u.CraftingSelectionRecipe=CaelumRestFurnitureData.FIRST_RECIPE+CaelumRestFurnitureData.FIRST_DECOR_VARIANT+1;')
prior=prior.replace('u.CraftingSelectionRecipe++;u.RefreshCraftingPreview();','u.CraftingSelectionRecipe--;u.RefreshCraftingPreview();')
prior=prior.replace('wooden chair needs no textile or sewing machine','wooden statue needs no textile or sewing machine').replace('cot textile still requires sewing machine','painting textile requires sewing machine')
pack(W/'checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "prior.zs"\n#include "checks.zs"\n','prior.zs':prior.encode(),'checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA410DecorChecks"}\nmap CBTH410 "Away" {cluster=434}\n','maps/CBTH410.wad':(R/'assets/validation_5826/away.wad').read_bytes()})
for case in ['catalogue','craft','trade','items','reject','resume']:
    (W/(case+'.cfg')).write_text(f'wait 210; netevent ca410o_{case}; wait 10; quit\n')
(W/'seed.cfg').write_text('wait 210; netevent ca410o_seed; wait 10; save decor-current; wait 10; quit\n')
(W/'hub.cfg').write_text('wait 210; netevent ca410o_seed; wait 10; netevent ca410o_away; wait 70; netevent ca410o_home; wait 210; netevent ca410o_resume; wait 10; quit\n')
(W/'input.cfg').write_text('wait 210; netevent ca410o_input 0; wait 10; +crouch; wait 10; +use; wait 10; -use; wait 10; netevent ca410o_input 1; -crouch; wait 10; quit\n')
for case in ['view','icon']:
    for k in range(2):(W/(case+str(k)+'.cfg')).write_text(f'wait 210; netevent ca410o_{case} {k}; wait 35; screenshot decor-{case}{k}.png; wait 10; quit\n')
legacy=(R/'assets/validation_5840/legacy.zs').read_text(encoding='utf-8').replace('CA410DS','CA410O').replace('k<8','k<12').replace('k=8;','k=12;').replace('RecipeBookVersion==22','RecipeBookVersion==23').replace('RestFurnitureRevision==4','RestFurnitureRevision==5').replace('Products.Size()==8','Products.Size()==12')
pack(W/'legacy-checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n','legacy.zs':legacy.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA410DiningLegacyChecks"}\n'})
(W/'priorseed.cfg').write_text('wait 210; netevent ca410ds_priorseed; wait 10; save decor-prior43; wait 10; quit\n')
(W/'priorload.cfg').write_text('wait 210; netevent ca410ds_priorload; wait 10; quit\n')
print('Decoration fixtures ready')
