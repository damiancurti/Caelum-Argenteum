"""Drive native buttons/network events and capture actual renderer output."""
from pathlib import Path
import hashlib
import json
import sys

OUT=Path(__file__).resolve().parents[2]/'build/issue133'
LABEL=sys.argv[1] if len(sys.argv)>1 else 'visual-sweep-b'
commands=['wait 90','+use','wait 3','-use','wait 5','screenshot shop-first.png',
    'netevent ca_palomo_merchant_previous','wait 5','screenshot shop-last.png',
    'netevent ca_palomo_merchant_transact','wait 5','screenshot shop-no-money.png',
    'netevent ca_palomo_merchant_mode','wait 5','screenshot shop-sell.png',
    'language enu','netevent ca_palomo_merchant_mode','wait 5','screenshot shop-en.png',
    'netevent ca_palomo_merchant_close','ca133_view 1','wait 5','screenshot home.png',
    'ca133_view 2','wait 5']
for pose in range(6):
    for angle in range(8):
        commands += [f'ca133_pose {pose}',f'ca133_angle {angle}','wait 35',f'screenshot pose-{pose}-{angle}.png']
commands += ['ca133_view 3','wait 10','chase','wait 10','screenshot player-idle.png',
    '+attack','wait 35','screenshot player-fire.png','wait 253','-attack',
    'wait 5','screenshot player-after-fire.png','+crouch','wait 20','screenshot player-crouch.png',
    '-crouch','wait 180','screenshot player-reloaded.png','ca133_view 4','wait 10','screenshot player-sword.png','wait 5','quit']
# Exec reads lines independently; wait only delays the remainder of its own
# command chain. Keep each line below the native parser limit and chain files.
chunks=[];chunk=[]
for command in commands:
    command=command.replace('screenshot ',f'screenshot {LABEL}-')
    if len('; '.join(chunk+[command]))>1800:chunks.append(chunk);chunk=[]
    chunk.append(command)
    # Keep this pose unchanged until the deferred renderer writes the capture.
    if command.startswith('screenshot '):chunk.append('wait 10')
chunks.append(chunk)
manifest={}
for index,chunk in enumerate(chunks):
    if index+1<len(chunks):chunk.append(f'exec {LABEL}-part-{index+1}.cfg')
    content='; '.join(chunk)+'\n';name=f'{LABEL}-part-{index}.cfg'
    (OUT/name).write_text(content,encoding='utf-8')
    manifest[name]={'sha256':hashlib.sha256(content.encode()).hexdigest(),'commands':content}
(OUT/'visual-sweep.cfg').write_text(f'exec {LABEL}-part-0.cfg\n',encoding='utf-8')
(OUT/f'{LABEL}-commands.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
(OUT/'player-shot.cfg').write_text('wait 90; ca133_view 3; wait 20; chase; wait 20; +attack; wait 8; screenshot player-single-shot.png; wait 5; -attack; wait 15; quit\n',encoding='utf-8')
