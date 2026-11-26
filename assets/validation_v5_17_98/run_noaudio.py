"""Bounded native sound-backend ablation; no setting or source is changed."""
from pathlib import Path
root=Path(__file__).resolve().parents[2]
script=root/'assets/validation_v5_16_2/run_barracas_presentation.py'
source=script.read_text(encoding='utf-8')
anchor="    sys.path.insert(0, str(previous.parent))"
injection='''    needle="command=[str(engine),'-noautoload','-nomouse','-iwad'"
    assert source.count(needle)==1
    source=source.replace(needle,"command=[str(engine),'-noautoload','-nomouse','-nosound','-iwad'",1)
'''
assert source.count(anchor)==1
source=source.replace(anchor,injection+anchor,1)
print('CA840 diagnostic: no native sound backend in this private process only.',flush=True)
exec(compile(source,str(script),'exec'),{'__name__':'__main__','__file__':str(script)})
