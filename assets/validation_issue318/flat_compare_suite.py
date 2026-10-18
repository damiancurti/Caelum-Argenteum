"""Finish sustained large battles and repeat the same battery at 1000 versus 600."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
for script,args in [
    ('flat_suite.py',['--directory','issue318-flat-01','--part','sustained']),
    ('flat_suite.py',['--directory','issue318-flat-1600-01','--part','combat']),
    ('flat_suite.py',['--directory','issue318-flat-1600-01','--part','controls']),
    ('flat_inventory_suite.py',['--directory','issue318-flat-1600-01']),
    ('flat_suite.py',['--directory','issue318-flat-1600-01','--part','sustained'])]:
    subprocess.run([sys.executable,str(HERE/script),*args],cwd=ROOT,check=True)
