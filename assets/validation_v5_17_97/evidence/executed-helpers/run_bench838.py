"""Run the approved presentation window, then allow native bench to finish."""
from pathlib import Path
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
script=root/'assets/validation_v5_16_2/run_barracas_presentation.py'
source=script.read_text(encoding='utf-8')
old="'event ca510_frames; screenshot scene.png; wait 3; quit'"
new="'event ca510_frames; screenshot scene.png; bench; wait 350; quit'"
assert source.count(old)==1
source=source.replace(old,new,1)
exec(compile(source,str(script),'exec'),{'__name__':'__main__','__file__':str(script)})
