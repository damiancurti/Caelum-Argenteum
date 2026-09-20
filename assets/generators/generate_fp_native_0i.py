#!/usr/bin/env python3
"""Composición nativa: mangual separado y arcos con sección doble.
Pillow sólo analiza alfa; nunca modifica ni escribe un bitmap.
"""
from pathlib import Path
from PIL import Image
import re,json
ROOT=Path(__file__).resolve().parents[2]
p=ROOT/'src/TEXTURES';s=p.read_text();marker='// BEGIN NATIVE FP 4.36.0i'
if marker in s:s=s.split(marker)[0].rstrip()+'\n'
blocks=[marker]
def groups(values):
 start=0
 for y in range(1,len(values)+1):
  if y==len(values) or values[y]!=values[start]:
   yield start,y-start,values[start];start=y
for t in range(1,4):
 raw=f'sprites/caelum/first_person/v1/flail/F07{t}A0.png'
 cuts=[214 if y<=64 else 211 if y<85 else round(207-(y-85)*0.30) if y<117 else 204 if y<153 else 0 for y in range(200)]
 for part in ('HANDLE','CHAIN'):
  assembled=[]
  for y,h,cut in groups(cuts):
   x,w=(cut,320-cut) if part=='HANDLE' else (0,cut)
   if w<=0:continue
   n=f'CA_FL_{part}_{t}_{y}'
   blocks.append(f'Graphic "{n}", {w}, {h}\n{{ Patch "{raw}", {-x}, {-y} }}')
   assembled.append(f'    Graphic "{n}", {x}, {y}')
  name=('GFS' if part=='HANDLE' else 'GFC')+str(t)+'A0';off='235, 158' if part=='HANDLE' else '213, 61'
  blocks.append(f'Sprite "{name}", 320, 200\n{{\n    NoTrim\n    Offset {off}\n'+ '\n'.join(assembled)+'\n}')
for family,label,scale,offsets in [('standard_bow','SB',6,[304,213,162]),('longbow','LB',4.9,[278,216,185])]:
 im=Image.open(ROOT/f'src/graphics/caelum/first_person/v3/{family}.png').getchannel('A')
 for tier,pivot in enumerate(offsets,1):
  base=f'CA_{label}_COL_{tier}'
  blocks.append(f'Graphic "{base}", 512, 1024\n{{ Graphic "CA_{label}_MUTED", {-512*(tier-1)}, 0 }}')
  shifts=[]
  for y in range(1024):
   xs=[x for x in range(512) if im.getpixel((512*(tier-1)+x,y))>=128]
   center=(min(xs)+max(xs))/2 if xs else pivot
   shifts.append(round((pivot-center)*0.5))
  assembled=[]
  for y,h,shift in groups(shifts):
   n=f'CA_{label}_THICK_{tier}_{y}'
   blocks.append(f'Graphic "{n}", 512, {h}\n{{ Graphic "{base}", {shift}, {-y} }}')
   assembled.append(f'    Graphic "{n}", 0, {y}')
  out=f'CA_{label}_THICK_{tier}'
  blocks.append(f'Graphic "{out}", 512, 1024\n{{\n'+ '\n'.join(assembled)+'\n}')
  for frame in 'ABC':
   sprite=f'D{16 if label=="SB" else 17}{tier}{frame}0';pattern=rf'(Sprite "{sprite}", 512, 1024\s*\{{)(.*?)(\n\}})'
   m=re.search(pattern,s,re.S);assert m,sprite
   body=re.sub(r'XScale [\d.]+',f'XScale {scale/2:.2f}',m[2]);body=re.sub(r'Graphic "CA_\w+", -?\d+, 0',f'Graphic "{out}", 0, 0',body)
   s=s[:m.start()]+m[1]+body+m[3]+s[m.end():]
p.write_text(s+'\n'+'\n\n'.join(blocks)+'\n')
out=ROOT/'assets/first_person_v7';out.mkdir(exist_ok=True)
(out/'COMPOSITION.json').write_text(json.dumps({'flail_degrees':-39.5,'previous_degrees':-62,'handle_exposed_fraction':0.5,'bow_thickness_factor':2,'raster_files_modified':0},indent=2)+'\n')
print('Native composition:',len(blocks),'definitions')
