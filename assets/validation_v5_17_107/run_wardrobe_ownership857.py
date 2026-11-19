"""Extend catalogue operations with native Box, chest and stale-owner checks."""
from pathlib import Path
h=Path(__file__).resolve().parent;root=Path(__file__).resolve().parents[2]
fixture=(h/'wardrobe_equipment857.zs').read_text(encoding='utf-8')
fixture=fixture.replace('    override void NetworkProcess',(h/'wardrobe_ownership857.zs').read_text(encoding='utf-8')+'\n    override void NetworkProcess').replace('Catalogue();','Catalogue();Ownership();')
fixture=(root/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+fixture
s=(h/'run_wardrobe857.py').read_text(encoding='utf-8')
s=s.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture))
s=s.replace('wait 100; netevent ca857check;','set ca_wardrobe_candidate true; wait 100; netevent ca857check;')
s=s.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Native catalogue and ownership controls; Box and chest operations use native gameplay. An explicit diagnostic ownership bypass additionally checks rejection of stale cached references without an event. Not author acceptance.')
exec(compile(s,str(h/'run_wardrobe857.py'),'exec'),{'__name__':'__main__','__file__':str(h/'run_wardrobe857.py')})
