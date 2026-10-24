"""Build private regional-discovery checks and old-save compatibility bridge."""
from pathlib import Path
import importlib.util
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue415'

def main():
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA415Checks" }\ncluster 8415 { hub }\nmap CAM415 "Regional discovery checks" { cluster=8415 }\nmap CAM415B "Event destination" { cluster=8415 }\n',
        'maps/CAM415.wad':module.wad(module.room(),'CAM415'),
        'maps/CAM415B.wad':module.wad(module.room(),'CAM415B')}
    WORK.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    scripts={'core':'wait 35; netevent ca415_core; save ca415-discovery; wait 5; quit',
        'load':'wait 35; netevent ca415_verify 0; wait 5; quit',
        'hub':'wait 35; netevent ca415_verify 0; changemap CAM415B; wait 35; netevent ca415_verify 1; changemap CAM415; wait 35; netevent ca415_verify 1; wait 5; quit'}
    for name,script in scripts.items():(WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
    common='''class CA415Legacy : EventHandler
    {
        override void NetworkProcess(ConsoleEvent e)
        {
            let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
            let agenda=CaelumScheduleState.Get(user,true);
            if(e.Name=="ca415_legacy_seed")
            {
                agenda.AddAfter(user,"legacy",CaelumScheduleRules.NOTICE,"CA_EVENT_NOTICE","CAM415B",0);
                CaelumScheduleState.Sync(user);
                Console.Printf("CA415 %s legacy seed",agenda.FindKey("legacy").Processed==1 ? "PASS":"FAIL");
            }
            else if(e.Name=="ca415_legacy_verify")
            {
                CaelumScheduleState.Sync(user);let entry=agenda.FindKey("legacy");
                Console.Printf("CA415 %s legacy actual outcome",entry!=null && entry.Processed==1 ? "PASS":"FAIL");
                VERIFY
            }
            else return;
            Console.Printf("CA415 RESULT legacy check complete");
        }
    }
    '''
    for variant in ['baseline','bridge']:
        verify=''
        if variant=='bridge':
            verify='''if(entry!=null){
                Console.Printf("CA415 %s migrated knowledge",entry.KnowledgeRevision==1 && entry.KnownProcessed==1 ? "PASS":"FAIL");
                int before=agenda.Notices;agenda.EnsureKnowledge();CaelumScheduleState.Sync(user);
                Console.Printf("CA415 %s idempotent knowledge",entry.KnownProcessed==1 && agenda.Notices==before ? "PASS":"FAIL");}'''
        path=WORK/variant/'legacy-checks.pk3';path.parent.mkdir(parents=True,exist_ok=True)
        legacy={**members,'checks.zs':common.replace('VERIFY',verify).encode(),
            'MAPINFO':members['MAPINFO'].replace(b'CA415Checks',b'CA415Legacy')}
        with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as archive:
            for name,blob in sorted(legacy.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    (WORK/'legacy-save.cfg').write_text('wait 35; netevent ca415_legacy_seed; save ca415-original; wait 5; quit\n')
    (WORK/'legacy-load.cfg').write_text('wait 35; netevent ca415_legacy_verify; save ca415-migrated; wait 5; quit\n')
    (WORK/'legacy-rollback.cfg').write_text('wait 35; netevent ca415_legacy_verify; wait 5; quit\n')
    (WORK/'interactive.cfg').write_text('bind F1 "changemap CAM415B"\nbind F2 "changemap CAM415"\nbind F3 "netevent ca415_report"\nwait 35; netevent ca415_preview\n')

if __name__=='__main__':main()
