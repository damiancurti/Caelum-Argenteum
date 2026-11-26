"""Bounded native GC diagnostic; all GC settings disappear with this process."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]/'build/v517/work-713'
stopped='--gc-stop' in sys.argv
if stopped:sys.argv.remove('--gc-stop')
script=ROOT/'assets/validation_v5_16_2/run_barracas_presentation.py'
adapter=script.read_text(encoding='utf-8')
anchor="    sys.path.insert(0, str(previous.parent))"
assert adapter.count(anchor)==1
prefix="stat gc; gc pause; gc stepmul; wait 3200; gc full; gc count; "+('gc stop; ' if stopped else '')+"wait {duration-3200};"
injection=f'''    assert source.count("f'wait {{duration}};")==1
    source=source.replace("f'wait {{duration}};",{("f'"+prefix)!r},1)
    assert source.count('event ca510_frames; screenshot scene.png; wait 3; quit')==1
    source=source.replace('event ca510_frames; screenshot scene.png; wait 3; quit','event ca510_frames; gc count; bench; screenshot scene.png; wait 3; quit',1)
'''
adapter=adapter.replace(anchor,injection+anchor,1)
print('CA838 GC diagnostic mode='+('stop-after-prewindow-full' if stopped else 'normal-after-prewindow-full'),flush=True)
exec(compile(adapter,str(script),'exec'),{'__name__':'__main__','__file__':str(script)})
