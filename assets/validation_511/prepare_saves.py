"""Shared 5.1.0/5.1.1 native save fixture, executed by prepare.py."""
persistence=(ROOT/'assets/validation_510/persistence.zs').read_text(encoding='utf-8').replace('CA130','CA131').replace('QA130','QA131')
persistence=persistence.replace('item.Durability=123;', 'item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;item.Durability=123;')
seed='''let thermal=CaelumThermalBody.Get(user,true);
            thermal.Exposure=7.25;thermal.Acclimation=4.5;thermal.ActivityWatts=12.5;thermal.DamageRemainder=0.3125;
            thermal.BaseWaterKg[0]=0.003;thermal.BaseWaterKg[1]=0.004;
            Console.Printf("CA131 SAVE SEEDED");'''
check='''let thermal=CaelumThermalBody.Get(user,true);
            let again=CaelumThermalBody.Get(user,true);
            Console.Printf("CA131 SAVE THERMAL E=%.9f accl=%.9f activity=%.9f fraction=%.9f water0=%.9f water1=%.9f revision=%d same=%d",
                thermal.Exposure,thermal.Acclimation,thermal.ActivityWatts,thermal.DamageRemainder,
                thermal.BaseWaterKg[0],thermal.BaseWaterKg[1],thermal.Revision,thermal==again && thermal==record.ThermalState);
            if(thermal!=again || thermal.Revision<CaelumThermalData.REVISION)Console.Printf("CA131 FAIL save authority");'''
manifest['persistence']=package('persistence.pk3',{
    'maps/QA131A.wad':wad,'maps/QA131B.wad':wad.replace(b'QA131A',b'QA131B'),
    'MAPINFO':b'map QA131A "Thermal persistence A" { levelnum=1311 cluster=131 next="QA131B" }\nmap QA131B "Thermal persistence B" { levelnum=1312 cluster=131 next="QA131A" }\ncluster 131 { hub }\nGameInfo { AddEventHandlers="CA131Persistence" }\n',
    'ZSCRIPT':b'version "4.14"\n#include "persistence.zs"\n',
    'persistence.zs':persistence.replace('// THERMAL_SEED',seed).replace('// THERMAL_CHECK',check).encode()})
for name,commands in {
    'save-baseline':'wait 70; save ca131_baseline; wait 5; quit',
    'save-upgrade':'wait 35; screenshot "ca131-save-upgraded.png"; save ca131_upgraded; wait 5; quit',
    'save-reload':'wait 35; save ca131_reloaded; wait 5; quit',
    'save-hub':'wait 5; changemap QA131B; wait 45; changemap QA131A; wait 45; screenshot "ca131-save-hub.png"; save ca131_hub; wait 5; quit',
    'save-rollback':'wait 35; save ca131_rollback; wait 5; quit',
    'save-reupgrade':'wait 35; save ca131_reupgraded; wait 5; quit',
}.items():
    (OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8')
    (OUT/('verified-'+name+'.cfg')).write_text(commands.replace('ca131_','ca131_verified_')+'\n',encoding='utf-8')
    (OUT/('final-'+name+'.cfg')).write_text(commands.replace('ca131_','ca131_final_')+'\n',encoding='utf-8')

performance=(ROOT/'assets/validation_510/performance.zs').read_text(encoding='utf-8').replace('CA130','CA131')
manifest['performance']=package('performance.pk3',{
    'ZSCRIPT':b'version "4.14"\n#include "performance.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers="CA131Performance" }\n',
    'performance.zs':performance.encode()})
(OUT/'performance.cfg').write_text('wait 735; quit\n',encoding='utf-8')
(OUT/'viewed.cfg').write_text('wait 65; addbot; wait 150; quit\n',encoding='utf-8')
for language in ['es','enu']:
    commands=['wait 80']
    for case in range(12):
        commands += [f'ca131_case {case}','wait 5',f'screenshot "ca131-{language}-{case:02}.png"']
    commands += ['ca131_case 12','ca_journal_open 1','ca_journal_page 2','wait 8',f'screenshot "ca131-{language}-journal.png"','ca_journal_open 0','wait 5','quit']
    (OUT/f'visual-{language}.cfg').write_text('; '.join(commands)+'\n',encoding='utf-8')
(OUT/'visual-wide.cfg').write_text('wait 80; ca131_case 3; screenblocks 11; hud_scale 2; wait 5; screenshot "ca131-wide-sb11.png"; screenblocks 12; hud_scale 3; wait 5; screenshot "ca131-wide-sb12.png"; screenblocks 10; hud_scale 0; wait 5; screenshot "ca131-wide-sb10.png"; wait 5; quit\n',encoding='utf-8')
