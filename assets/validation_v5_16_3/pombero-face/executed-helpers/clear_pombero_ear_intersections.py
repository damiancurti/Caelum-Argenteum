from pathlib import Path
import json

path=Path(__file__).resolve().parent/'work-455/assets/source/art/pombero_455/DESIGN.json'
design=json.loads(path.read_text(encoding='utf-8'))
for shape in design['shapes']:
    if shape['name']=='back and side hair':shape['angles']=[85,275]
    if shape['name'].startswith('side hair '):
        for row in shape['rows']:row[0]-=2
path.write_bytes((json.dumps(design,indent=2)+'\n').encode('utf-8'))
