"""Validate the public launch boundary, including legacy menu requests."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_standalone import request, MARKER

def line(count,role=0,mode=3,palomo=None):
    result=MARKER+f'{role}|{mode}|0|{count}|32700|0|127.0.0.1|session.json'
    return result if palomo is None else result+'|'+str(palomo)

assert request(line(2))['palomo']==0
assert request(line(3,palomo=0))['palomo']==0
for count in range(4,9):
    for slot in range(count+1):assert request(line(count,palomo=slot))['palomo']==slot
for value in (line(2,palomo=1),line(3,palomo=3),line(4,palomo=5),line(4,palomo=-1),line(4,mode=0,palomo=1)):
    try:request(value)
    except ValueError:pass
    else:raise AssertionError(value)
print('PASS: legacy NPC requests, approved 4-8-player roles, invalid population/mode/slot rejection')
