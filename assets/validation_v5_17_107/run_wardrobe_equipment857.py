"""Run real equip/unequip/replacement/drop operations in the private native fixture."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];h=Path(__file__).resolve().parent
source=(h/'run_wardrobe857.py').read_text(encoding='utf-8')
source=source.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')","fixture=(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\\n'+(helper/'wardrobe_equipment857.zs').read_text(encoding='utf-8')")
source=source.replace('wait 100; netevent ca857check;','set ca_wardrobe_candidate true; wait 100; netevent ca857check;')
source=source.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Native catalogue equipment controls on an actual opt-in player: creates owned items through existing catalogue data, equips/unequips/replaces/drops through native inventory operations, checks authoritative identity and immediate visual-refresh invariants. Save, rendering and performance acceptance require separate evidence.')
exec(compile(source,str(h/'run_wardrobe857.py'),'exec'),{'__name__':'__main__','__file__':str(h/'run_wardrobe857.py')})
