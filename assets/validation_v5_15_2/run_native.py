"""Reuse the isolated native harness with independent #449 fixtures and evidence."""
from pathlib import Path

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue449').replace('CA447','CA449').replace('ca447','ca449').replace('issue=447','issue=449')
    source=source.replace('T447','T449').replace('levelnum=448','levelnum=450').replace('levelnum=447','levelnum=449')
    source=source.replace('cluster=447','cluster=449').replace('cluster 447','cluster 449')
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
