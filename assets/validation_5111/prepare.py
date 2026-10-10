"""Package the isolated #156 input observer; never edit original saves."""
from pathlib import Path
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue156'

def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

def main():
    assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower()
    OUT.mkdir(exist_ok=True)
    package(OUT/'observer.pk3',{
        'MAPINFO':b'GameInfo { AddEventHandlers="CA156Input" }\n',
        'ZSCRIPT':b'version "4.14"\n#include "input.zs"\n',
        'input.zs':(HERE/'input.zs').read_bytes()})
    package(OUT/'checks.pk3',{
        'MAPINFO':b'GameInfo { AddEventHandlers="CA156Checks" }\n',
        'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes()})
    (OUT/'checks.cfg').write_text('unbindall; wait 620; save ca156-fixed; wait 35; quit\n',encoding='utf-8')
    (OUT/'reload').mkdir(exist_ok=True)
    package(OUT/'reload/checks.pk3',{
        'MAPINFO':b'GameInfo { AddEventHandlers="CA156Reload" }\n',
        'ZSCRIPT':b'version "4.14"\n#include "reload.zs"\n',
        'reload.zs':(HERE/'reload.zs').read_bytes()})
    (OUT/'reload.cfg').write_text('unbindall; wait 70; save ca156-reloaded; wait 35; quit\n',encoding='utf-8')
    with zipfile.ZipFile(OUT/'baseline/caelum_argenteum_dev.pk3') as z:
        members={name:z.read(name) for name in z.namelist()}
    name='caelum/hud/CaelumJournalOverlay.zs'
    code=members[name].decode('utf-8').replace('\r\n','\n')
    code=code.replace('ui bool MouseInput(UiEvent e)\n    {', 'ui bool MouseInput(UiEvent e)\n    {\n        if(e.Type==UiEvent.Type_KeyDown)Console.Printf("CA156 GUI char=%d string=%s menu=%d",e.KeyChar,e.KeyString,menuactive);')
    code=code.replace('override bool InputProcess(InputEvent e)\n    {','override bool InputProcess(InputEvent e)\n    {\n        if(e.Type==InputEvent.Type_KeyDown)Console.Printf("CA156 JOURNAL RAW scan=%d char=%d string=%s menu=%d",e.KeyScan,e.KeyChar,e.KeyString,menuactive);')
    assert code.count('CA156')==2
    members[name]=code.encode('utf-8')
    (OUT/'instrumented').mkdir(exist_ok=True)
    package(OUT/'instrumented/caelum_argenteum_dev.pk3',members)
    runner=(ROOT/'assets/validation_5110/run_native.ps1').read_text(encoding='utf-8').replace('issue154','issue156').replace('CA154','CA156')
    (HERE/'run_native.ps1').write_text(runner,encoding='utf-8',newline='\n')
    print('Prepared #156 input observer and isolated runner.')

if __name__=='__main__':main()
