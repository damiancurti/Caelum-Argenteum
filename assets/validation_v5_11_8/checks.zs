// Native disease policy checks. No production actor or damage substitutions.
class CA586Checks : EventHandler
{
    Array<CaelumCombatActor> Bodies;
    int Failures;
    bool Done;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA586 PASS %s",label);else{Failures++;Console.Printf("CA586 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca586_seed')
        {
            if(Bodies.Size()>0)return;
            players[0].mo.bInvulnerable=true;
            players[0].mo.SetOrigin((-1300,0,0),false);players[0].mo.Angle=0;
            for(int i=0;i<4;i++)
            {
                Name kind=i==0?'CaelumMandinga':i==1?'CaelumZupayColossus':i==2?'CaelumGiantRat':'CaelumCaella';
                let body=CaelumCombatActor(Actor.Spawn(kind,(-600+i*700,300,0),NO_REPLACE));
                body.bDormant=true;Bodies.Push(body);
                CaelumContaminationStorage.Get(body,true).Concentration=100;
            }
            Console.Printf("CA586 RESULT original bodies seeded for save/upgrade");
        }
        if(e.Name=='ca586_check')
        {
            if(Done){Console.Printf("CA586 RESULT checks already complete failures=%d",Failures);return;}
            for(int i=0;i<Bodies.Size();i++)
            {
                let body=Bodies[i];let entry=CaelumContaminationStorage.Get(body,true);entry.Concentration=100;
                // Dormancy blocks all native damage. Activate only during the
                // synchronous policy sample; keep the display actors still.
                body.bDormant=false;
                int before=body.health;
                Check(before>0,String.Format("living original %s",body.GetTag()));
                for(int t=0;t<35;t++)CaelumContaminationNPC.IllnessStep(body);
                Check(i<3?body.health==before:body.health<before,String.Format("active disease policy %s",body.GetTag()));
                Check(entry.Concentration==100,String.Format("contamination retained %s",body.GetTag()));
                let away=new('CaelumContaminationAbsence');away.Life=body.health;away.NativePolicy(body);
                int awayBefore=away.Life;away.Physiology(body,60);
                Check(i<3?away.Life==awayBefore:away.Life<awayBefore,String.Format("absent disease policy %s",body.GetTag()));
                // Use a hit above the giant's existing natural defense; a
                // flat 100-point hit can be entirely absorbed before the filter.
                before=body.health;body.DamageMobj(null,null,Max(100,body.CombatMaximumHealth/4),'Normal',DMG_NO_ARMOR);
                Check(body.health<before,String.Format("ordinary damage retained %s",body.GetTag()));
                body.bDormant=true;
            }
            Done=true;Console.Printf("CA586 RESULT disease policies failures=%d",Failures);
        }
        if(e.Name=='ca586_reload')
        {
            for(int i=0;i<3;i++)
            {
                let body=Bodies[i];int before=body.health;
                body.bDormant=false;
                double concentration=CaelumContaminationStorage.Get(body,true).Concentration;
                body.DamageMobj(null,null,100,'CaelumDiseaseDOT',DMG_NO_ARMOR);
                Check(body.health==before,String.Format("restored disease immunity %s",body.GetTag()));
                Check(CaelumContaminationStorage.Get(body,true).Concentration==concentration,
                    String.Format("restored concentration preserved %s",body.GetTag()));
                body.bDormant=true;
            }
            Console.Printf("CA586 RESULT restored policies failures=%d",Failures);
        }
        if(e.Name=='ca586_visit')
        {
            players[0].mo.SetOrigin((-1300,0,0),false);players[0].mo.Angle=0;
            for(int i=0;i<Bodies.Size();i++)Console.Printf("CA586 STATUS %s health=%d contamination=%.3f",
                Bodies[i].GetTag(),Bodies[i].health,CaelumContaminationStorage.Get(Bodies[i],true).Concentration);
        }
        if(e.Name=='ca586_baseline')
        {
            for(int i=0;i<3;i++)
            {
                int retained=Bodies[i].TakeSpecialDamage(null,null,100,'CaelumDiseaseDOT');
                Check(i<2?retained>0:retained==0,String.Format("original save and prior species policy %s",Bodies[i].GetTag()));
            }
            Console.Printf("CA586 RESULT original-save rollback failures=%d",Failures);
        }
    }
}
