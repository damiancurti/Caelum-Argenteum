"""Exercise actual native inputs and inspect finite glove grip variants."""
from pathlib import Path
import argparse,sys
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--glove',choices=['bare','GF','GC','GW','GP'],required=True)
opt,rest=parser.parse_known_args();sys.argv=[sys.argv[0],'--mode','motion']+rest
original=ROOT/'assets/validation_v5_17_107/run_wardrobe_continuity857.py';source=original.read_text()
fixture=(original.parent/'wardrobe_continuity857.zs').read_text()
fixture=fixture.replace('types[1]=CaelumClothingData.F;','types[1]=CaelumClothingData.CS;').replace('types[3]=CaelumClothingData.BP;','types[3]=CaelumClothingData.BS;')
if opt.glove!='bare':fixture=fixture.replace('types[2]=CaelumClothingData.GP;',f'types[2]=CaelumClothingData.{opt.glove};')
else:fixture=fixture.replace('let item=CaelumClothing.Create(User,types[region],size);','if(region==2)continue;\n            let item=CaelumClothing.Create(User,types[region],size);')
if opt.glove=='bare':
    fixture=fixture.replace('User.EquipmentMenuOpen=false;User.PersistCharacterState();Seeded=true;', '''let oldGloves=CaelumClothing.Equipped(User,2);
        if(oldGloves!=null){Select(oldGloves);User.UnequipSelectedNativeEquipment();}
        Check(CaelumClothing.Equipped(User,2)==null,"bare-hand case removes actual starting gloves");
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Seeded=true;''')
expected=['bare','GF','GC','GW','GP'].index(opt.glove)-1
fixture=fixture.replace('Snapshot();Refresh();','Snapshot();Refresh();\n        Check(CaelumWardrobePilotBody(User.PilotBody).HandKind=='+str(expected)+',"actual equipped hand kind matches requested grip case");')
fixture=fixture.replace('bool SeenPoses[24];','bool SeenPoses[24];int LastPose;')
fixture=fixture.replace('if(User!=null && User.PilotBody!=null)SeenPoses[Clamp(User.PilotBody.Pose,0,23)]=true;', '''if(User!=null && User.PilotBody!=null)
        {
            SeenPoses[Clamp(User.PilotBody.Pose,0,23)]=true;
            if(LastPose!=User.PilotBody.Pose){LastPose=User.PilotBody.Pose;Console.Printf("CA859 TRANSITION tic=%d pose=%d frame=%d",level.time,LastPose,User.PilotBody.ModelFrame);}
        }''')
fixture=fixture.replace('        Loaded(true);','        Check(Candidate(),"candidate remains selected through native motion");')
fixture=fixture.replace("        if(e.Name=='ca857seed')Seed();",'''        if(e.Name=='ca857seed')Seed();
        if(e.Name=='ca859detail' && Camera!=null)CA857Camera(Camera).Detail=e.Args[0];
        if(e.Name=='ca859snapshot' && User!=null && User.PilotBody!=null)
            Console.Printf("CA859 SNAPSHOT tic=%d pose=%d frame=%d speed=%.4f",level.time,User.PilotBody.Pose,User.PilotBody.ModelFrame,User.Vel.XY.Length());''')
fixture=fixture.replace('Actor Subject;int Side;','Actor Subject;int Side,Detail;')
fixture=fixture.replace('double yaw=Subject.Angle+Side*90;','double yaw=Subject.Angle+Side*45;double distance=Detail!=0?75:130;double height=Detail!=0?.47:.48;')
fixture=fixture.replace('Cos(yaw)*110,Sin(yaw)*110,Subject.Height*.55','Cos(yaw)*distance,Sin(yaw)*distance,(Subject.health<=0?35:Subject.Height*height)')
fixture=fixture.replace('Angle=AngleTo(Subject);Pitch=0;','Angle=AngleTo(Subject);Pitch=Subject.health<=0?10:0;')
source=source.replace("fixture=(helper/'wardrobe_continuity857.zs').read_text(encoding='utf-8').replace('    // SETUP',setup)","fixture="+repr(fixture)+"\nfixture=fixture.replace('    // SETUP',setup)")
begin='set ca_wardrobe_candidate true; screenblocks 12; con_notifytime 0; wait 100; netevent ca857seed; wait 15; '
plan=begin+'netevent ca859snapshot; screenshot idle.png; netevent ca859detail 1; wait 5; screenshot grip-front.png; netevent ca857view 1; wait 5; screenshot grip-quarter.png; netevent ca857view 7; wait 5; screenshot grip-other.png; netevent ca857view 0; netevent ca859detail 0; '
plan+='cl_run false; +forward; wait 25; netevent ca859snapshot; screenshot walk.png; +speed; wait 15; netevent ca859snapshot; screenshot run.png; -forward; -speed; wait 20; +attack; wait 7; netevent ca859snapshot; screenshot attack.png; -attack; wait 70; +zoom; wait 2; -zoom; wait 10; netevent ca859snapshot; screenshot guard.png; netevent ca857view 7; netevent ca859detail 1; wait 5; screenshot guard-grip.png; netevent ca859detail 0; netevent ca857view 0; +zoom; wait 2; -zoom; wait 15; '
plan+='+jump; wait 2; -jump; netevent ca859snapshot; screenshot jump-preparation.png; wait 10; netevent ca859snapshot; screenshot jump-air.png; wait 10; netevent ca859snapshot; screenshot jump-late.png; wait 12; netevent ca859snapshot; screenshot landing.png; wait 90; netevent ca857motion; netevent ca857kill; wait 70; netevent ca859snapshot; screenshot death.png; netevent ca857done; wait 35; quit\n'
plan=plan.replace('screenshot grip-other.png;','screenshot grip-other.png; netevent ca857view 4; wait 5; screenshot grip-rear.png;')
plan=plan.replace('screenshot guard-grip.png;','screenshot guard-grip.png; netevent ca857view 4; wait 5; screenshot guard-rear.png;')
plan=plan.replace('wait 12; netevent ca859snapshot; screenshot landing.png;','wait 20; netevent ca859snapshot; screenshot landing.png;')
plan=plan.replace('screenshot death.png;','screenshot death.png; netevent ca857view 2; wait 5; screenshot death-side.png;')
start=source.index(" 'motion':");end=source.index("\n 'seed':",start);source=source[:start]+" 'motion':"+repr(plan)+','+source[end:]
source=source.replace('if opt.mode in (\'death\',\'dead-load\'):',"if opt.mode in ('death','dead-load','motion'):")
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
