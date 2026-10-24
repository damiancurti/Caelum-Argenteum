"""Build isolated camp checks; never overwrite accepted property evidence."""
from pathlib import Path
import importlib.util,zipfile,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
WORK=ROOT/'build/issue411-camp'
def main():
    WORK.mkdir(parents=True,exist_ok=True)
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA411CampChecks" }\ncluster 8411 { hub }\nmap CAM411 "Camp checks" { cluster=8411 }\nmap CAM411B "Travel checks" { cluster=8411 }\n',
        'maps/CAM411.wad':module.wad(module.room(),'CAM411'),
        'maps/CAM411B.wad':module.wad(module.room(),'CAM411B')}
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    scripts={name:f'wait 70; netevent ca411_camp_{name}; wait 5; quit' for name in ['physics','items','craft','shop','transfer']}
    scripts['interactive']='bind F1 \"netevent ca411_camp_author_shop\"; wait 70; netevent ca411_camp_author'
    scripts['preview']='wait 70; netevent ca411_camp_author; ca_journal_page 0; ca_journal_open true; wait 35; screenshot camp-inventory.png; wait 5; quit'
    scripts['save']='wait 70; netevent ca411_camp_save; save ca411-camp; wait 5; quit'
    scripts['load']='wait 70; netevent ca411_camp_verify; wait 5; quit'
    scripts['hub']='wait 70; netevent ca411_camp_verify; changemap CAM411B; wait 70; netevent ca411_camp_verify; changemap CAM411; wait 70; netevent ca411_camp_verify; wait 5; quit'
    for name,script in scripts.items():(WORK/(name+'.cfg')).write_bytes((script+'\n').encode())
    legacy=(HERE/'legacy.zs').read_text(encoding='utf-8')
    for mode in ['old','bridge']:
        extra='' if mode=='old' else 'ok=ok && record.RecipeBookVersion==15 && !record.KnowsCraftingRecipe(201,1) && !record.KnowsCraftingRecipe(202,1);'
        with zipfile.ZipFile(WORK/('legacy-'+mode+'.pk3'),'w',zipfile.ZIP_STORED) as archive:
            for name,data in {'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n','legacy.zs':legacy.replace('VERIFY_APPENDED',extra).encode('utf-8'),'MAPINFO':b'GameInfo { AddEventHandlers="CA411CampLegacy" }\n'}.items():
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    for name,script in {'legacy-seed':'wait 70; netevent ca411_camp_legacy_seed; save ca411-camp-original; wait 5; quit','legacy-load':'wait 70; netevent ca411_camp_legacy_verify; wait 5; quit'}.items():
        (WORK/(name+'.cfg')).write_bytes((script+'\n').encode('utf-8'))
    if len(sys.argv)>1:
        output=WORK/sys.argv[1]/'caelum_argenteum_dev.pk3'
        if output.exists():raise SystemExit('Preserve earlier probes: choose another label')
        output.parent.mkdir(parents=True,exist_ok=True)
        with zipfile.ZipFile(output,'w',zipfile.ZIP_STORED) as archive:
            for source in sorted((ROOT/'src').rglob('*')):
                if source.is_file():archive.writestr(zipfile.ZipInfo(source.relative_to(ROOT/'src').as_posix(),(2000,1,1,0,0,0)),source.read_bytes())
        print(output)
if __name__=='__main__':main()
