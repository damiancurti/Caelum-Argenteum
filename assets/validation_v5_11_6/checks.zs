class CA582Checks : EventHandler
{
    CaelumGiantRat Rat;
    CaelumMandinga Mandinga;
    int Failures;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA582 PASS %s",label);else{Failures++;Console.Printf("CA582 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca582_seed')
        {
            players[0].mo.bInvulnerable=true;
            Rat=CaelumGiantRat(Actor.Spawn('CaelumGiantRat',(-200,0,0)));
            Mandinga=CaelumMandinga(Actor.Spawn('CaelumMandinga',(200,0,0)));
        }
        if(e.Name=='ca582_check')
        {
            let entry=CaelumContaminationStorage.Get(Rat,true);entry.Concentration=100;
            int before=Rat.health;
            for(int i=0;i<350;i++)CaelumContaminationNPC.IllnessStep(Rat);
            Check(Rat.health==before,"rat survives ten seconds of maximum active disease");
            Check(entry.Concentration==100,"immunity preserves contamination for contact transmission");
            let away=new('CaelumContaminationAbsence');away.Life=Rat.health;away.NativePolicy(Rat);
            away.Physiology(Rat,60);
            Check(away.Life==before,"absent rat survives one minute of maximum disease");
            Rat.DamageMobj(null,null,10,'Normal',DMG_NO_ARMOR);
            Check(Rat.health<before,"ordinary damage still harms the rat");
            let other=CaelumContaminationStorage.Get(Mandinga,true);other.Concentration=100;
            before=Mandinga.health;
            for(int i=0;i<35;i++)CaelumContaminationNPC.IllnessStep(Mandinga);
            Check(Mandinga.health<before,"Mandinga retains its existing disease susceptibility");
            Console.Printf("CA582 RESULT disease immunity failures=%d",Failures);
        }
        if(e.Name=='ca582_reload')
        {
            int before=Rat.health;Rat.DamageMobj(null,null,100,'CaelumDiseaseDOT',DMG_NO_ARMOR);
            Check(Rat.health==before,"saved rat remains disease-immune without resetting health");
            Check(CaelumContaminationStorage.Get(Rat).Concentration>0,"saved contamination is retained");
            Console.Printf("CA582 RESULT reload failures=%d",Failures);
        }
    }
}
