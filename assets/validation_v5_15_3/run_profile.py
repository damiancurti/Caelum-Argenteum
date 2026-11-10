"""Keep #450 native presentation and census evidence separate."""
from pathlib import Path

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_profile.py'
    source=previous.read_text(encoding='utf-8').replace('issue447','issue450').replace('issue=447','issue=450')
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
