"""Collect final #471 visual evidence and compare the native PK3 to every source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile
from PIL import Image,ImageDraw

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue471'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
manifest=json.loads((ROOT/'assets/generators/alchemy_ingredients_manifest.json').read_text(encoding='utf-8'))
package=WORK/'current/caelum_argenteum_dev.pk3'
source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist())==set(source),'Package membership differs'
    mismatches=[name for name,p in source.items() if archive.read(name)!=p.read_bytes()]
assert not mismatches,mismatches
report={'issue':471,'release':'5.7.6','package_sha256':sha(package),
        'package_members':len(source),'exact_source_matches':len(source),'runs':[],'captures':{},
        'author_acceptance':'Pending CA471-ART-01','save_schema':'Unchanged; no stateful gameplay modifications'}
(HERE/'native').mkdir(exist_ok=True)
for label in ('verified-views','verified-inventory'):
    record=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    log=WORK/f'{label}.txt';text=log.read_text(encoding='utf-8',errors='replace')
    assert record['package_sha256'].lower()==report['package_sha256']
    assert record['exit_code']==0 and not record.get('timed_out')
    assert not re.search(r'CA471 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR',text)
    assert text.count('CA471 PASS')==12
    shutil.copyfile(log,HERE/'native'/log.name)
    report['runs'].append({'label':label,'pass':12,'fail':0,'log_sha256':sha(log),'record':record})
visuals=HERE/'visuals';visuals.mkdir(exist_ok=True)
for batch,indices in enumerate((range(6),range(6,11))):
    sheet=Image.new('RGB',(960,len(indices)*264),(34,31,29));draw=ImageDraw.Draw(sheet)
    for row,i in enumerate(indices):
        for view in range(3):
            spec=manifest['assets'][i];path=WORK/f'{spec["key"]}-{view}.png'
            capture=Image.open(path);assert capture.size==(1280,720)
            report['captures'][path.name]=sha(path)
            sheet.paste(capture.crop((480,240,800,480)),(view*320,row*264+24))
            draw.text((view*320+8,row*264+6),f'{spec["en"]} / view {view}',fill=(238,222,192))
    sheet.save(visuals/f'native-views-{batch+1}.png')
for filename in ('iodine-0.png','saltpeter-0.png','sulfur_deposit-1.png','iodine-inventory.png'):
    shutil.copyfile(WORK/filename,visuals/filename)
    report['captures'][filename]=sha(WORK/filename)
report['review_sheets']={'crop_xyxy':[480,240,800,480], 'resize':'none',
                        'hashes':{p.name:sha(p) for p in visuals.glob('native-views-*.png')}}
validation=json.loads((WORK/'project-validation.json').read_text(encoding='utf-8-sig'))
assert validation['errors']==[],validation
(HERE/'project-validation.json').write_text(json.dumps(validation,indent=2)+'\n',encoding='utf-8',newline='\n')
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(f'PASS: {len(source)} exact package/source matches; 24 native PASS; 33 model views and real inventory capture.')
