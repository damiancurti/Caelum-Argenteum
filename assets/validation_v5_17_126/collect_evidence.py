"""Retain bounded #465 final evidence, with failed/superseded runs separate."""
from pathlib import Path
import hashlib,json,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=Path(__file__).with_name('evidence')

def main():
    source=ROOT/'build/issue465-final01';native=json.loads((source/'SUMMARY.json').read_text())
    assert len(native['phases'])==11 and all(p['passed'] for p in native['phases'])
    for row in native['phases']:
        case=source/row['name'];target=EVIDENCE/'native'/row['name'];target.mkdir(parents=True,exist_ok=True)
        for name in ['native.log','stdout.txt','command.json','commands.cfg','session.ini']:
            shutil.copyfile(case/name,target/name)
    captures=['640x400-es-scale0/credits.png','640x400-es-scale0/main.png',
        '1280x720-es-scale2/credits.png','1920x1080-en-scale0/credits.png']
    for name in captures:
        target=EVIDENCE/'native'/name;shutil.copyfile(source/name,target)
    attempts={
        'issue465-native01':'Full root ZSCRIPT overlay loaded duplicate classes; rejected.',
        'issue465-native02':'Synthetic UIEvent.Type is read-only; rejected fixture.',
        'issue465-native03':'Partial font-folder overlay omitted original glyphs; command checks were not visual evidence.',
        'issue465-native04':'Superseded partial-font matrix; stopped after visual inspection.',
        'issue465-native05':'Complete font folders restored; reading body subsequently enlarged to CaelumText.',
        'issue465-native06':'Bounded single-case verification before locale repairs and final matrix.',
        'issue465-native07':'Requested 640x360 was clamped to 640x400; resolution assertion rejected it.',
        'issue465-native08':'Oversized decorated 1920x1080 window was clamped; resolution assertion rejected it.',
        'issue465-native09':'Native general Spanish fallback confirmed before copied es aliases.',
        'issue465-native10':'All 814 command assertions passed; screenshot was queued until after the following menu switch. Final package rerun inserts a frame wait and retains correct images.'}
    for name,reason in attempts.items():
        directory=ROOT/'build'/name;target=EVIDENCE/'attempts'/name;target.mkdir(parents=True,exist_ok=True)
        if (directory/'SUMMARY.json').exists():shutil.copyfile(directory/'SUMMARY.json',target/'SUMMARY.json')
        for log in directory.glob('*/stdout.txt'):
            shutil.copyfile(log,target/(log.parent.name+'-stdout.txt'))
    validation=json.loads((ROOT/'build/issue465-validation.json').read_text(encoding='utf8'))
    assert not validation['errors'] and validation['version']=='5.17.126'
    shutil.copyfile(ROOT/'build/issue465-validation.json',EVIDENCE/'project-validation.json')
    package=ROOT/'build/issue465-review01.pk3'
    with zipfile.ZipFile(package) as z:
        build={'package':package.name,'sha256':hashlib.sha256(package.read_bytes()).hexdigest(),'files':len(z.namelist()),
            'log':(ROOT/'build/issue465-build.txt').read_text(encoding='utf8')}
    (EVIDENCE/'build.json').write_bytes((json.dumps(build,indent=2)+'\n').encode())
    report={'issue':465,'version':'5.17.126','native':native,'native_checks':sum(int(p['counts'][0][0]) for p in native['phases']),
        'static':'static.json','full_project_validation':'project-validation.json','build':'build.json',
        'attempts':attempts,'author_acceptance':'Pending CA465-UI-01; earlier 110 checks retained',
        'limits':['Scripted controller event paths are tested; physical controller and wheel review remain pending.',
            'Legal notices retain original language; no translation or new rights grant is asserted.',
            'No gameplay/save code changed; existing inventory/model validation remains in the full validator.']}
    (EVIDENCE/'SUMMARY.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(json.dumps({'native_checks':report['native_checks'],'phases':len(native['phases']),'package_files':build['files']}))

if __name__=='__main__':main()
