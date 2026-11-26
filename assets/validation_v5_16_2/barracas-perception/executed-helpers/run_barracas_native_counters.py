from pathlib import Path
root=Path(__file__).resolve().parents[2]
script=root/'assets/validation_v5_16_2/run_barracas_presentation.py'
source=script.read_text(encoding='utf-8')
old="'event ca510_frames; screenshot scene.png; wait 3; quit'"
new="'event ca510_frames; screenshot scene.png; wait 5; profilethinkers -t; wait 5; bench; wait 245; quit'"
assert source.count(old)==1
source=source.replace(old,new)
exec(compile(source,str(script),'exec'),{'__name__':'__main__','__file__':str(script)})
