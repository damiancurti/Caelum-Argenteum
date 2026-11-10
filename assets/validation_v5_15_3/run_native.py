"""Reuse the native two-peer/save harness with separate #450 evidence."""
from pathlib import Path

if __name__ == '__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue450').replace('CA447','CA450').replace('ca447','ca450').replace('issue=447','issue=450')
    source=source.replace('T447','T450').replace('levelnum=448','levelnum=451').replace('levelnum=447','levelnum=450')
    source=source.replace('cluster=447','cluster=450').replace('cluster 447','cluster 450')
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
