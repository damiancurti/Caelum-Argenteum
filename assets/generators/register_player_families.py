"""Register modular player models against the existing software sprite fallback."""
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/'src'
DIR='models/caelum/players'
SLOTS=[('b0_'+part,'b0') for part in ('shirt','trousers','belt','boots','gloves')]+[('head0_0','head0_0_0'),('hair0_0','hair0_0_0')]


SLOTS.extend(("gear/"+part,"gear/"+part) for part in ("w0_1","s0","a0_0","a1_0","a2_0","a3_0"))


def register():
    configs=[]
    # Each prefix has one native body per pose. The game owns identity and color.
    for cls in ('CaelumPlayer','CaelumStandalonePlayer','CaelumDomingoPilotPlayer'):
        lines=[f'Model {cls}', '{',f'    Path "{DIR}"','    CorrectPixelStretch','    DontCullBackFaces']
        for slot,(mesh,skin) in enumerate(SLOTS):
            lines.extend([f'    Model {slot} "{mesh}.md3"',f'    Skin {slot} "{skin}.png"'])
        for group in ('P','Q'):
            for identity in range(14):
                for tone in range(3):
                    for pose in range(33):
                        bank=identity*6+tone*2+pose//26
                        sprite=f'{group}{bank:03}'
                        letter=chr(65+pose%26)
                        for slot in range(len(SLOTS)):
                            lines.append(f'    FrameIndex {sprite} {letter} {slot} {pose}')
        configs.append('\n'.join(lines+['}']))
    # The existing separate head sprite still works in the software renderer.
    # Hardware draws head and hair as body slots; a transparent hardware mesh
    # prevents a duplicate sprite being projected over the 3D head.
    registry=(SRC/'caelum/character/CaelumAppearanceDetailsRegistry.zs').read_text('utf8')
    lines=['Model CaelumAppearanceHead','{',f'    Path "{DIR}"','    Model 0 "conceal.md3"',
           '    Skin 0 "invisible.png"']
    for sprite,letters in re.findall(r'^\s*(V[A-Z0-9]{3})\s+([A-Z]+)\s+1;',registry,re.M):
        lines.extend(f'    FrameIndex {sprite} {letter} 0 0' for letter in letters)
    configs.append('\n'.join(lines+['}']))
    (SRC/'caelum/data/player_families.modeldef').write_bytes(('\n\n'.join(configs)+'\n').encode())


if __name__=='__main__':
    register()
