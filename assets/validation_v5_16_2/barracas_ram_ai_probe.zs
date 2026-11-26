// Dotaciones reales, sin teletransporte ni avance fisico acelerado.
class CA454RamAIProbe : EventHandler
{
    CaelumBatteringRam Rams[2];
    CaelumBreakableGate Gates[2];
    bool Done[2],Running;
    int StartTick,Passed,Failures;

    void Begin()
    {
        let port=CaelumPortSiege.Get();let user=players[0].mo;
        user.bInvulnerable=true;user.bNoTarget=true;
        for(int test=0;test<2;test++)
        {
            int gateIndex=test==0?3:1;
            vector3 p=CA454RamData.GatePoint(gateIndex);double outward=CA454RamData.GateAngle(gateIndex);
            vector3 normal=(Cos(outward),Sin(outward),0),tangent=(-Sin(outward),Cos(outward),0);
            let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",p,NO_REPLACE));
            gate.Angle=outward+90;gate.args[1]=CA454RamData.GateMaterial(gateIndex);gate.args[2]=1;gate.InitializeGate();Gates[test]=gate;
            let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",p+normal*512+tangent*256,NO_REPLACE));
            ram.Angle=outward+180;ram.Large=test==1;ram.InitializeRam();ram.UseBarracasCrewLayout();
            port.RegisterMachine(ram);Rams[test]=ram;
            for(int slot=0;slot<ram.RequiredCrew;slot++)
            {
                let body=CaelumMandinga(Actor.Spawn("CaelumMandinga",ram.CrewPosition(slot),NO_REPLACE));
                let entry=port.RegisterAttacker(body);
                bool ok=entry!=null && ram.AssignCrew(entry) && entry.CrewSlot==slot && body.TestMobjLocation();
                if(!ok){Failures++;Console.Printf("CA454 RAM AI SPAWN FAIL test=%d slot=%d",test,slot);}
            }
            ram.SetRoute(gate,outward+180,true);ram.AddRoutePoint(p+normal*512);
            ram.AddRoutePoint(p+normal*CaelumRamData.TRIAL_CONTACT_DISTANCE*ram.SizeFactor);
        }
        port.SealRoster();port.SiegeStarted=true;
        for(int test=0;test<2;test++)if(!Rams[test].ActivateRam()){Failures++;Console.Printf("CA454 RAM AI ACTIVATE FAIL test=%d",test);}
        StartTick=level.time;Running=true;
        Console.Printf("CA454 RAM AI START crews=%d,%d failures=%d",Rams[0].Crew.Size(),Rams[1].Crew.Size(),Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_ram_ai_start")Begin();
        if(e.Name=="ca454_ram_ai_resume")
        {
            bool ok=Running;
            for(int test=0;test<2;test++)
            {
                let ram=Rams[test];if(ram==null || ram.CrewLayoutRevision!=1 || !ram.FollowRouteHeading){ok=false;continue;}
                for(int slot=0;slot<ram.Crew.Size();slot++)
                    if(ram.Crew[slot]==null || ram.Crew[slot].CrewSlot!=slot || ram.Crew[slot].Body==null)ok=false;
            }
            Console.Printf("CA454 RAM AI RESUME %s elapsed=%d",ok?"PASS":"FAIL",level.time-StartTick);
            if(!ok)Failures++;
        }
        for(int test=0;test<2;test++)if(e.Name==String.Format("ca454_ram_ai_view%d",test))
        {
            let user=players[0].mo;let ram=Rams[test];if(user==null || ram==null)return;
            user.SetOrigin(ram.Pos+(-Cos(ram.Angle)*512-Sin(ram.Angle)*512,-Sin(ram.Angle)*512+Cos(ram.Angle)*512,0),false);
            user.Angle=ram.Angle-45;user.Pitch=0;user.Vel=(0,0,0);user.ClearInterpolation();
        }
    }

    override void WorldTick()
    {
        if(!Running)return;
        bool finished=true;
        for(int test=0;test<2;test++)
        {
            if(Done[test])continue;
            let ram=Rams[test];double maximum=0;int worst=0;
            for(int i=0;i<ram.Crew.Size();i++)if(ram.Crew[i]!=null && ram.Crew[i].Body!=null)
            {double distance=(ram.Crew[i].Body.Pos-ram.Pos).Length();if(distance>maximum){maximum=distance;worst=i;}}
            if((level.time-StartTick)%350==0)Console.Printf("CA454 RAM AI PROGRESS test=%d elapsed=%d route=%d angle=%.2f crew=%d max_distance=%.2f blocked=%d",test,level.time-StartTick,ram.RouteIndex,ram.Angle,ram.FullCrewPresent(),maximum,ram.Obstructed);
            if((level.time-StartTick)%350==0)
            {
                let entry=ram.Crew[worst];let body=entry.Body;vector3 post=entry.CrewPost();
                Console.Printf("CA454 RAM AI DETAIL test=%d slot=%d stored=%d pos=(%.1f,%.1f) post=(%.1f,%.1f) vel=(%.3f,%.3f) see=%d health=%d target=%s",test,worst,entry.CrewSlot,body.Pos.X,body.Pos.Y,post.X,post.Y,body.Vel.X,body.Vel.Y,body.InStateSequence(body.CurState,body.SeeState),body.health,body.target!=null?body.target.GetClassName():'None');
                vector2 delta=post.XY-body.Pos.XY;vector2 next=delta.Length()>0?body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length()):body.Pos.XY;
                FCheckPosition fit;bool clear=body.CheckPosition(next,false,fit);
                Console.Printf("CA454 RAM AI STEP test=%d speed=%.3f clear=%d floor=%.1f ceiling=%.1f same_entry=%d same_machine=%d blocker=%s rooted=%d held=%d",test,body.Speed,clear,fit.floorz,fit.ceilingz,body.SiegeCombatant==entry,body.SiegeCombatant!=null && body.SiegeCombatant.CrewMachine==ram,body.BlockingMobj!=null?body.BlockingMobj.GetClassName():'None',CaelumTarotRooted.Active(body),CaelumTelekinesisRules.Held(body));
            }
            if(ram.ImpactCount>0 || level.time-StartTick>=4200)
            {
                let block=CaelumGateBlocker(ram.LastContact);
                bool ok=ram.ImpactCount==1 && block!=null && block.master==Gates[test] && ram.LastDamage>0 && ram.FullCrewPresent();
                if(ok)Passed++;else Failures++;
                Console.Printf("CA454 RAM AI CASE %s test=%d elapsed=%d impacts=%d damage=%d crew=%d max_distance=%.2f",ok?"PASS":"FAIL",test,level.time-StartTick,ram.ImpactCount,ram.LastDamage,ram.FullCrewPresent(),maximum);
                Done[test]=true;ram.Enabled=false;
            }
            else finished=false;
        }
        if(finished){Running=false;Console.Printf("CA454 RAM AI COMPLETE passed=%d failures=%d",Passed,Failures);}
    }
}
