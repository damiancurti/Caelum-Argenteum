// Experimento #121: formación sintética sobre MAP06, nunca código de producción.
// La variante individual decide por miembro; la compartida decide por cien.
class CA121Camera : Actor
{
    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA121Formation : EventHandler
{
    Array<CaelumSiegeCombatant> Members;
    Array<double> InitialX, InitialY;
    int GroupSize, Ready, Attempts, Moved, Plans;
    override void WorldTick()
    {
        let port=CaelumPortSiege.Get();if(port==null || !port.RosterSealed)return;
        if(!Ready)
        {
            GroupSize=CVar.GetCVar("ca121_group_size").GetInt();
            if(GroupSize!=1 && GroupSize!=100)ThrowAbortException("CA121 group size must be 1 or 100");
            for(int i=0;i<port.Attackers.Size();i++)
            {
                let entry=port.Attackers[i];if(!(entry.Body is "CaelumMandinga"))continue;
                int n=Members.Size(),g=n/100,s=n%100;
                int column=(g%20)*10+s%10,row=(g/20)*10+s/10;
                vector3 spot=CaelumPortData.FormationPosition(row*200+column);
                entry.Body.SetOrigin(spot,false);entry.Body.Vel=(0,0,0);entry.Body.CA121FormationActive=true;
                entry.Lane=CaelumPortSiege.NearestLane(spot.X);
                entry.Body.SetStateLabel("CA121Formation");
                Members.Push(entry);InitialX.Push(spot.X);InitialY.Push(spot.Y);
            }
            let camera=Actor.Spawn("CA121Camera",CaelumPortData.FormationPosition(90)+(0,1500,768));
            camera.Angle=270;camera.Pitch=20;players[0].camera=camera;
            Ready=1;
            Console.Printf("CA121 FORMATION_INIT tic=%d size=%d members=%d groups=%d",level.time,GroupSize,Members.Size(),Members.Size()/GroupSize);
            Console.Printf("CA121 CAMERA x=%.3f y=%.3f z=%.3f angle=%.3f pitch=%.3f",camera.Pos.X,camera.Pos.Y,camera.Pos.Z,camera.Angle,camera.Pitch);
        }
        CA121Profiler p;if(level.time%37==0){p=CA121Profiler.Get();p.Begin(26);}
        if(level.time%4==0)
        {
            for(int start=0;start<Members.Size();start+=GroupSize)
            {
                CaelumSiegeCombatant leader;
                for(int j=start;j<Min(start+GroupSize,Members.Size());j++)
                    if(Members[j].Body!=null && Members[j].Body.health>0){leader=Members[j];break;}
                if(leader==null)continue;
                let victim=port.AttackerTarget(leader);Plans++;
                if(p!=null)p.Decisions++;
                if(victim==null)continue;
                vector2 delta=victim.Pos.XY-leader.Body.Pos.XY;
                if(delta.Length()<=leader.Body.Radius)continue;
                vector2 step=delta.Unit()*Min(leader.Body.Speed,delta.Length());
                double facing=VectorAngle(step.X,step.Y);
                for(int j=start;j<Min(start+GroupSize,Members.Size());j++)
                {
                    let b=Members[j].Body;
                    if(b==null || b.health<=0 || b.ForcedSleepTics>0 || b.CombatLucidityPhysicalStunRemaining>0)continue;
                    b.Angle=facing;b.target=victim;b.Vel.X=0;b.Vel.Y=0;
                    Attempts++;if(p!=null)p.Commands++;
                    if(b.TryMove(b.Pos.XY+step,0))Moved++;
                }
            }
        }
        if(p!=null)p.End(26);
        if(level.time%35==0)
        {
            double error=0;int count=0;
            for(int i=0;i<Members.Size();i++)
            {
                let b=Members[i].Body;let lead=Members[(i/100)*100].Body;
                if(b==null || lead==null || b.health<=0 || lead.health<=0)continue;
                vector2 offset=(InitialX[i]-InitialX[(i/100)*100],InitialY[i]-InitialY[(i/100)*100]);
                vector2 difference=b.Pos.XY-lead.Pos.XY-offset;
                error+=difference.Length();count++;
            }
            Console.Printf("CA121 FORMATION tic=%d size=%d plans=%d attempts=%d moved=%d relative_error=%.6f observed=%d",level.time,GroupSize,Plans,Attempts,Moved,count>0?error/count:0,count);
            Plans=0;Attempts=0;Moved=0;
        }
    }
}
