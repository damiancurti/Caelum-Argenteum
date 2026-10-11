"""Prepare focused #169 native UI observations using the existing isolated map."""
from pathlib import Path
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue163'

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish the native run before replacing packages.')
    OUT.mkdir(parents=True, exist_ok=True)
    spec=importlib.util.spec_from_file_location('bolas_fixture',ROOT/'assets/validation_5116/prepare.py')
    helper=importlib.util.module_from_spec(spec);spec.loader.exec_module(helper)
    if not (OUT/'baseline.pk3').exists():
        subprocess.run(['git','archive','--format=zip',f'--output={OUT / "baseline.pk3"}','dc757efe:src'],cwd=ROOT,check=True)
    fixture=helper.package(OUT/'medikits.pk3',{
        'ZSCRIPT': b'version "4.14"\n#include "names.zs"\n',
        'names.zs': (HERE/'names.zs').read_bytes(),
        'maps/CA163.wad': helper.test_map(),
        'CVARINFO': b'server int ca169_stage=0;\n',
        'MAPINFO': b'map CA163 "Medikit naming validation" {}\nGameInfo { AddEventHandlers="CA169Names" }\n'})
    runtime=helper.package(OUT/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes()
        for p in (ROOT/'src').rglob('*') if p.is_file()})
    for lang in ('es','enu'):
        script=f'unbindall; wait 80; +forward; wait 110; -forward; wait 10; screenshot medikit-pickup-{lang}.png; ca169_stage 1; wait 10; screenshot medikit-small-{lang}.png; ca169_stage 2; wait 10; screenshot medikit-medium-{lang}.png; ca169_stage 3; wait 10; screenshot medikit-large-{lang}.png; save ca169-{lang}; wait 5; quit\n'
        (OUT/f'medikits-{lang}.cfg').write_text(script,encoding='utf-8')
    (OUT/'medikits-manifest.json').write_text(json.dumps({'runtime':runtime,'fixture':fixture},indent=2)+'\n',encoding='utf-8')
    print('Prepared #169 native UI packages:',runtime,fixture)

if __name__=='__main__':main()
