"""Render actual production tent states without a MODELDEF override."""
from pathlib import Path
import importlib.util,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
WORK=ROOT/'build/issue411-placement'

def main():
    spec=importlib.util.spec_from_file_location('gallery',HERE.parent/'tent/prepare.py')
    gallery=importlib.util.module_from_spec(spec);spec.loader.exec_module(gallery)
    gallery.main()
    with zipfile.ZipFile(ROOT/'build/issue411-tent/gallery.pk3') as z:
        room=z.read('maps/CTG411.wad')
    members={'ZSCRIPT':b'version "4.14"\n#include "binding.zs"\n',
        'binding.zs':(HERE/'checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo {AddEventHandlers="CA411BindingChecks"}\nmap CTG411 "Production tent bindings" {}\n',
        'maps/CTG411.wad':room}
    with zipfile.ZipFile(WORK/'binding.pk3','w',zipfile.ZIP_STORED) as z:
        for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    (WORK/'binding-views.cfg').write_text('wait 35; netevent ca411b_wide; wait 10; screenshot binding-wide.png; netevent ca411b_side; wait 10; screenshot binding-side.png; netevent ca411b_legacy; wait 10; screenshot binding-legacy.png; wait 5; quit\n',encoding='utf-8')

if __name__=='__main__':main()
