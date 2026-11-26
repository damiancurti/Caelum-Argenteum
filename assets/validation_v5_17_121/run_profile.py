"""Reuse native municipal and approved normal-siege observers for #886."""
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[2]
index=sys.argv.index('--scene');scene=sys.argv[index+1];del sys.argv[index:index+2]
assert scene in ['civic','siege']
if scene=='civic':
    previous=ROOT/'assets/validation_v5_17_120/run_profile.py'
    source=previous.read_text(encoding='utf-8');old='issue=883,';new='issue=886,'
    sys.argv+=['--scene','civic']
else:
    previous=ROOT/'assets/validation_v5_16_2/run_barracas_presentation.py'
    source=previous.read_text(encoding='utf-8');old='issue=454,';new='issue=886,'
    sys.argv+=['--siege']
assert source.count(old)==1;source=source.replace(old,new)
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__'})
