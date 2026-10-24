"""Build deterministic private property checks without altering campaign geometry."""
from pathlib import Path
import importlib.util
import zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue411'
def main():
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA411Checks" }\ncluster 8411 { hub }\nmap CAM411 "Property checks" { cluster=8411 }\nmap CAM411B "Travel checks" { cluster=8411 }\n',
        'maps/CAM411.wad':module.wad(module.room(),'CAM411'),
        'maps/CAM411B.wad':module.wad(module.room(),'CAM411B')}
    WORK.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    legacy=(HERE/'legacy_checks.zs').read_text()
    for variant in ['baseline','bridge']:
        extra='' if variant=='baseline' else """
                Check(roster.PropertyRevision==1 && roster.PropertyChestScanned,"idempotent property migration marked");
                Check(roster.Residents[69].ResidentMap=="CAH070","original resident moved to nearby house");
                if(level.MapName=="CAH070")Check(roster.RelocatingChest==null && !proof.OriginalChest.bInvisible
                    && proof.OriginalChest.Pos==CaelumPropertyData.RelocatedChestPosition(),"original chest placed in destination");
                else Check(roster.RelocatingChest==proof.OriginalChest && proof.OriginalChest.bInvisible,"original chest held for relocation");
        """
        returned='' if variant=='baseline' else '            Check(roster.PropertyRevision==1 && roster.PropertyChestScanned,"migration remains marked after return");\n            Check(proof!=null && roster.RelocatingChest==null,"placed chest is not reclaimed on return");\n            bool absent=true; let chests=ThinkerIterator.Create("CaelumStashChest"); CaelumStashChest chest; while((chest=CaelumStashChest(chests.Next()))!=null) if(chest.LawfulOwner!=null && chest.LawfulOwner.Token=="house:CAH069")absent=false; Check(absent,"old belongings absent from offered house on return");\n            Check(roster.Residents[69].ResidentMap=="CAH070","resident remains in relocated house");'
        path=WORK/variant/'legacy-checks.pk3';path.parent.mkdir(parents=True,exist_ok=True)
        with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as archive:
            for name,blob in {'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n',
                'legacy.zs':legacy.replace('VERIFY_MIGRATION',extra).replace('VERIFY_RETURN',returned).encode(),
                'MAPINFO':b'GameInfo { AddEventHandlers="CA411Legacy" }\n'}.items():
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    scripts={'routes':'wait 70; netevent ca411_routes; netevent ca411_cost; wait 5; quit',
        'cross':'wait 105; netevent ca411_preview; wait 35; netevent ca411_cross; wait 210; netevent ca411_city; wait 5; quit',
        'preview':'wait 105; netevent ca411_preview; wait 35; screenshot property-preview.png; wait 5; quit',
        'author-check':'wait 105; netevent ca411_author; wait 35; screenshot property-author.png; wait 5; quit',
        'access':'wait 105; netevent ca411_access; wait 5; quit',
        'interactive':'bind F1 \"netevent ca411_expire\"; wait 105; netevent ca411_author',
        'core':'wait 70; netevent ca411_core; save ca411-property; wait 5; quit',
        'load':'wait 70; netevent ca411_verify; wait 5; quit',
        'hub':'wait 70; netevent ca411_verify; changemap CAM411B; wait 70; netevent ca411_verify; changemap CAM411; wait 70; netevent ca411_verify; wait 5; quit',
        'legacy-save':'wait 105; netevent ca411_legacy_seed; save ca411-original; wait 5; quit',
        'legacy-load':'wait 105; netevent ca411_legacy_verify; save ca411-migrated; wait 5; quit',
        'legacy-hub':'wait 105; netevent ca411_legacy_verify; changemap CAH070; wait 105; netevent ca411_legacy_verify; save ca411-relocated; wait 5; quit',
        'legacy-return':'wait 105; netevent ca411_legacy_verify; changemap CAH069; wait 105; netevent ca411_return; changemap CAH070; wait 105; netevent ca411_legacy_verify; wait 5; quit',
        'legacy-rollback':'wait 105; netevent ca411_legacy_verify; wait 5; quit',
        'house':'wait 105; netevent ca411_house; wait 5; quit'}
    for name,script in scripts.items():(WORK/(name+'.cfg')).write_bytes((script+'\n').encode())
if __name__=='__main__':main()
