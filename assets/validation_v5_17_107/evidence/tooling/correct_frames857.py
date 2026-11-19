"""Install the corrected contiguous frame bindings, retaining the failed evidence."""
from pathlib import Path
import json,re
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');h=Path(__file__).resolve().parent
old=(root/'src/caelum/data/wardrobe_candidate.modeldef').read_text(encoding='utf-8')
current=[0]*17;states={}
for sprite,letter,slot,frame in re.findall(r'^ FrameIndex (\S+) (\S+) (\d+) (\d+)$',old,re.M):
    current[int(slot)]=int(frame);states[sprite,letter]=tuple(current)
bad=sum(sum(value!=values[15] for value in values) for values in states.values())
assert bad==374*15,bad
new=(root/'build/issue857-prototype06/source/caelum/data/wardrobe_candidate.modeldef').read_bytes()
(root/'src/caelum/data/wardrobe_candidate.modeldef').write_bytes(new)
source=(h/'prepare_wardrobe_data857.py').read_text(encoding='utf-8').replace("Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","Path(__file__).resolve().parents[2]")
(root/'assets/validation_v5_17_107/prepare_wardrobe_data857.py').write_text(source,encoding='utf-8',newline='\n')
report=dict(issue=857,followup=859,baseline_mismatched_frame_slots=bad,affected_sprite_frames=374,total_frames=375,models=17,cause='GZDoom snapshots the complete current model-frame array on every FrameIndex. Appended accessory entries carry body frame374 into earlier sprite/frame states. Generate all17slots contiguously per state.',native_source='GZDoom4.14.2 src/r_data/models.cpp:1000-1067 and692-700,1129-1135',superseded_runtime='build/issue857-wardrobe01.pk3',superseded_visual='build/issue857-motion01',superseded_candidate_performance='build/issue857-bench-*-candidate01',preserved_control_performance='The four control01 runs use the unchanged original seven-module class; no candidate binding is used.')
(root/'build/issue857-frame-order.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
