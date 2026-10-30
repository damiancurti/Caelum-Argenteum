class CA432Observer : CaelumCombatActor
{
    override void Tick() { }
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +NOBLOCKMAP }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA432Checks : EventHandler
{
    CaelumContaminationTile Saved;
    CA432LegacyTile Reference;
    int Passes,Failures;
    double SavedStamp;
    CaelumContaminationMap Sheet;
    CA432Observer Observer;
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA432 PASS %s",label);}else{Failures++;Console.Printf("CA432 FAIL %s",label);}}
    void SetCase(CaelumContaminationTile tile,CA432LegacyTile old,int index)
    {
        tile.Profile=old.Profile=1+index%5;
        tile.Region=old.Region=1;tile.Seed=old.Seed=432+index;
        tile.Shelter=old.Shelter=index%5;tile.Covered=old.Covered=index%2==0;
        tile.Reference=old.Reference=CaelumContaminationData.Reference(1+index%4);
        tile.Stamp=old.Stamp=double(CaelumCalendarRules.DaysBeforeYear(CaelumCalendarRules.CAMPAIGN_START_YEAR))*86400+86330.25;
        tile.Concentration=old.Concentration=index%3==0?90:index%3==1?0:23.5;
    }
    void Compare(CaelumContaminationTile tile,CA432LegacyTile old,double end,String label)
    {
        let outside=new('CaelumWeatherSample');let local=new('CaelumWeatherSample');
        if(Sheet==null){Sheet=new('CaelumContaminationMap');Sheet.Epoch=tile.Stamp;}
        Sheet.Sync(tile,end);old.Sync(end,0,outside,local);
        Check(Abs(tile.Concentration-old.Concentration)<0.000000001
            && tile.Stamp==old.Stamp && tile.Rain==old.Rain && tile.Ambient==old.Ambient,label);
    }
    void Seed()
    {
        let user=CaelumPlayer(players[0].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
        for(int i=0;i<40;i++)
        {
            let tile=new('CaelumContaminationTile');let old=new('CA432LegacyTile');SetCase(tile,old,i);
            Compare(tile,old,tile.Stamp+600.5,String.Format("case %d climate and concentration across midnight",i));
            double value=tile.Concentration;Compare(tile,old,tile.Stamp,"same timestamp is idempotent");
            Check(tile.Concentration==value,"no duplicate exposure");
        }
        Saved=new('CaelumContaminationTile');Reference=new('CA432LegacyTile');SetCase(Saved,Reference,6);
        Compare(Saved,Reference,Saved.Stamp+3600.5,"evicted date recomputes the same climate");
        SavedStamp=Saved.Stamp;
        Check(CaelumContaminationWorld.Get().HistoryWeather.Days.Size()<=CaelumContaminationWeatherCache.MAX_DAYS,
            "shared climate cache retains existing memory bound");
        let a=new('CaelumContaminationTile');let ar=new('CA432LegacyTile');SetCase(a,ar,7);
        let b=new('CaelumContaminationTile');let br=new('CA432LegacyTile');SetCase(b,br,7);
        a.Concentration=ar.Concentration=90;b.Concentration=br.Concentration=0;
        Compare(a,ar,a.Stamp+10,"dirty tile keeps individual concentration");
        Compare(b,br,b.Stamp+10,"clean tile keeps individual concentration");
        Check(a.Concentration!=b.Concentration,"shared weather never shares contamination");
        let c=new('CaelumContaminationTile');let cr=new('CA432LegacyTile');SetCase(c,cr,7);
        Compare(c,cr,c.Stamp+10,"identical pristine interval reuses derived result");
        double retained=c.Concentration;b.Concentration=99;
        Check(c.Concentration==retained,"subsequent contact cannot mutate another tile");
        Check(Sheet.Pristine.Size()<=CaelumContaminationMap.PRISTINE_CACHE_LIMIT,"pristine result memory remains bounded");
        Observer=CA432Observer(Actor.Spawn('CA432Observer',user.Pos+(0,0,200),NO_REPLACE));
        bool exact=true;
        for(int attribute=-100;attribute<=1000;attribute+=17)
        {
            Observer.CombatAgility=Observer.CombatEffectiveInsight=attribute;
            double expected=CaelumGrowthRules.Multiplier(attribute,2);
            double stealth=Clamp(Observer.CalculateActorType2Percent(attribute),0.0,100.0);
            if(CaelumVisualPerception.InsightFactor(Observer)!=expected || CaelumVisualPerception.Stealth(Observer)!=stealth)exact=false;
            if(CaelumVisualPerception.InsightFactor(Observer)!=expected || CaelumVisualPerception.Stealth(Observer)!=stealth)exact=false;
        }
        Check(exact,"attribute caches remain bit-exact including same-tic stat changes");
        Check(CaelumVisualPerception.Stealth(user)==Clamp(user.EffectiveStealthPercent,0.0,100.0)
            && CaelumVisualPerception.InsightFactor(null)==1,"player stealth and null reference remain unchanged");
        Console.Printf("CA432 RESULT shared surface weather complete passes=%d failures=%d",Passes,Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca432_seed')Seed();
        if(e.Name=='ca432_reload')
        {
            Check(Saved!=null && Saved.Stamp==SavedStamp,"original surface timestamp survives save");
            Compare(Saved,Reference,SavedStamp+3600.5,"save reload rebuilds climate without changing exposure");
            if(Observer!=null)
                Check(CaelumVisualPerception.InsightFactor(Observer)==CaelumGrowthRules.Multiplier(Observer.CombatEffectiveInsight,2),
                    "derived visual cache rebuilds after save load");
            Console.Printf("CA432 RESULT reload complete passes=%d failures=%d",Passes,Failures);
        }
    }
}
