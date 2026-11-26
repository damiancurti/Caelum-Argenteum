"""Reload a disposable joinery-candidate checkpoint with the default model restored.

The retained native house-use harness supplies actual portal/render-ACK travel.
Only its reload source and single phase change; no save bytes are rewritten.
"""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
i=sys.argv.index('--saved-session');checkpoint=Path(sys.argv[i+1]).resolve(strict=True)/'fresh/checkpoint.zds'
del sys.argv[i:i+2]
assert checkpoint.is_file()
previous=ROOT/'assets/validation_v5_16_2/run_barracas_house_use.py'
source=previous.read_text(encoding='utf-8')
changes=[("for phase in ('fresh', 'reload'):","for phase in ('removal',):"),
         ("if phase == 'reload':","if phase == 'removal':"),
         ("out / 'fresh/checkpoint.zds'",repr(str(checkpoint)))]
for old,new in changes:
    assert source.count(old)==1,old
    source=source.replace(old,new)
sys.path.insert(0,str(previous.parent))
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__'})
