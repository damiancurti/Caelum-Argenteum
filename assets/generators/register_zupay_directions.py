"""Correct the reversed source rotation order for Zupay action poses.

Keep source PNGs intact. Assign canonical native names to the matching view;
derive the mapping from the sprite name, so regeneration is idempotent.
"""
from pathlib import Path
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[2]
FRAMES='DEFMNOPQR'
ROTATIONS={1:1,2:8,3:7,4:6,5:5,6:4,7:3,8:2}

def main():
    path=ROOT/'src/TEXTURES'
    text=path.read_text(encoding='utf-8')
    records=[]
    def replace(match):
        frame,rotation=match.group(1),int(match.group(2))
        source=f'sprites/caelum/actors/zupay_colossus/ZUPY{frame}{ROTATIONS[rotation]}.png'
        records.append({'native':f'ZUPY{frame}{rotation}','source':source,
            'source_sha256':hashlib.sha256((ROOT/'src'/source).read_bytes()).hexdigest()})
        return f'Sprite "ZUPY{frame}{rotation}", 416, 416 {{ Offset 208, 400 Patch "{source}", 0, 0 }}'
    text,count=re.subn(r'Sprite "ZUPY(['+FRAMES+r'])([1-8])", 416, 416 \{[^\n]+\}',replace,text)
    assert count==len(FRAMES)*8,count
    path.write_text(text,encoding='utf-8')
    report={'issue':135,'author_report':'Ground slam appears reversed; focused inspection also finds the same action-source order in pain and rock casting.',
        'mapping':ROTATIONS,'frames':FRAMES,'unchanged':'Idle, walking, running, non-directional death and source PNG pixels.', 'records':records}
    (ROOT/'assets/art_source/demon_breath_515/ZUPAY_DIRECTIONS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'Registered {count} Zupay action rotations; source artwork unchanged.')

if __name__=='__main__':main()
