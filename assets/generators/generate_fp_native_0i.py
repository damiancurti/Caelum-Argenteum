#!/usr/bin/env python3
"""Native flail composition and deterministic bow-stave crop caches.
Original artwork is read-only; generated caches retain native palette effects.
"""
from pathlib import Path
from PIL import Image
import re,json
ROOT=Path(__file__).resolve().parents[2]
p=ROOT/'src/TEXTURES';s=p.read_text(encoding='utf-8');marker='// BEGIN NATIVE FP 4.36.0i'
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
 source=Image.open(ROOT/f'src/graphics/caelum/first_person/v3/{family}.png').convert('RGBA')
 im=source.getchannel('A')
 for tier,pivot in enumerate(offsets,1):
  column=source.crop((512*(tier-1),0,512*tier,1024))
  cached=Image.new('RGBA',(512,1024))
  shifts=[]
  for y in range(1024):
   xs=[x for x in range(512) if im.getpixel((512*(tier-1)+x,y))>=128]
   center=(min(xs)+max(xs))/2 if xs else pivot
   shifts.append(round((pivot-center)*0.5))
  for y,h,shift in groups(shifts):
   # Copy each disjoint strip without a mask: alpha must not be multiplied.
   cached.paste(column.crop((0,y,512,y+h)),(shift,y))
  out=f'CA_{label}_THICK_{tier}'
  cache_path=f'graphics/caelum/first_person/bow_cache/{family}_t{tier}.png'
  destination=ROOT/'src'/cache_path
  destination.parent.mkdir(parents=True,exist_ok=True)
  cached.save(destination,format='PNG',compress_level=9,optimize=False)
  blocks.append(f'Graphic "{out}_RAW", 512, 1024\n{{ Patch "{cache_path}", 0, 0 }}')
  # Keep the existing native color operations in the same order, once per
  # assembled stave. Read their authored parameters from TEXTURES.
  desaturate=re.search(rf'Graphic "CA_{label}_MUTED_D",.*?\{{ Translation ([^}}]+)\}}',s,re.S)
  blend=re.search(rf'Graphic "CA_{label}_MUTED",.*?\{{ Blend ([^}}]+)\}}',s,re.S)
  assert desaturate and blend, f'Missing palette definition for {family}'
  blocks.append(f'Graphic "{out}_D", 512, 1024\n{{ Graphic "{out}_RAW", 0, 0 {{ Translation {desaturate[1].strip()} }} }}')
  blocks.append(f'Graphic "{out}", 512, 1024\n{{ Graphic "{out}_D", 0, 0 {{ Blend {blend[1].strip()} }} }}')
  for frame in 'ABC':
   sprite=f'D{16 if label=="SB" else 17}{tier}{frame}0';pattern=rf'(Sprite "{sprite}", 512, 1024\s*\{{)(.*?)(\n\}})'
   m=re.search(pattern,s,re.S);assert m,sprite
   body=re.sub(r'XScale [\d.]+',f'XScale {scale/2:.2f}',m[2]);body=re.sub(r'Graphic "CA_\w+", -?\d+, 0',f'Graphic "{out}", 0, 0',body)
   s=s[:m.start()]+m[1]+body+m[3]+s[m.end():]
p.write_text(s+'\n'+'\n\n'.join(blocks)+'\n',encoding='utf-8',newline='\n')
out=ROOT/'assets/first_person_v7';out.mkdir(exist_ok=True)
(out/'COMPOSITION.json').write_text(json.dumps({'flail_degrees':-39.5,'previous_degrees':-62,'handle_exposed_fraction':0.5,'bow_thickness_factor':2,'raster_files_modified':0},indent=2)+'\n')
print('Native composition:',len(blocks),'definitions')
