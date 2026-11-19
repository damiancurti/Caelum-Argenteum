"""Bounded native resource-precache diagnostic; private settings only."""
from pathlib import Path
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
script=root/'assets/validation_v5_16_2/run_barracas_presentation.py'
source=script.read_text(encoding='utf-8')
anchor="    sys.path.insert(0, str(previous.parent))"
injection='''    needle="vid_preferbackend=1\\\\nvid_vsync=false"
    assert source.count(needle)==1
    source=source.replace(needle,"gl_precache=true\\\\n"+needle,1)
'''
assert source.count(anchor)==1
source=source.replace(anchor,injection+anchor,1)
print('CA840 diagnostic: native resource precache enabled in this private process only.',flush=True)
exec(compile(source,str(script),'exec'),{'__name__':'__main__','__file__':str(script)})
