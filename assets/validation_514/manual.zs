// Author inspection fixture: applies a selected setup once, then normal play continues.
class CA140Manual : StaticEventHandler
{
    int LastCase;
    CaelumCombatActor Bull,Rat;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(level.time==1)
        {
            user.InitializeDirectMapCharacter();user.CreationWizardOpen=false;
            let climate=Actor.Spawn("CaelumClimateRegion",(0,0,0));climate.args[0]=1;climate.args[1]=5;
            Bull=CaelumCombatActor(Actor.Spawn("CaelumBull",user.Pos+(300,180,0)));
            Rat=CaelumCombatActor(Actor.Spawn("CaelumGiantRat",user.Pos+(300,-180,0)));
            if(Bull!=null)Bull.bFRIENDLY=true;if(Rat!=null)Rat.bFRIENDLY=true;
            Console.Printf("CA140 MANUAL: set ca140_case 1..9. 1/2 male fatigue, 3/4 female fatigue, 5 recovery, 6/7 heat, 8 wet heat, 9 animal heat.");
        }
        int selected=CVar.GetCVar("ca140_case").GetInt();
        if(selected<1 || selected>9 || selected==LastCase || level.time<3)return;
        LastCase=selected;
        user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
        user.health=user.CaelumMaximumHealth;user.player.health=user.health;
        user.CurrentAir=user.DerivedStats.MaximumAir;user.CurrentAnima=user.DerivedStats.MaximumAnima;
        let s=CaelumThermalBody.Get(user,true);s.Exposure=0;
        if(selected<=4)
        {
            user.CharacterProfile.Sex=selected<=2 ? CaelumConstants.SEX_MALE : CaelumConstants.SEX_FEMALE;
            user.CurrentAir=user.DerivedStats.MaximumAir*(selected%2==0 ? 0.05 : 0.4);
        }
        if(selected==6 || selected==7)s.Exposure=(selected==6 ? 11 : 21)*CaelumThermalRules.ThresholdScale(s.Toughness);
        if(selected==8)
        {
            s.Exposure=5;
            for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(user,s,slot,0.04);
            user.CurrentAir=user.DerivedStats.MaximumAir*0.4;user.CurrentAnima=user.DerivedStats.MaximumAnima*0.4;
        }
        if(selected==9)
        {
            if(Bull!=null){let b=CaelumThermalBody.Get(Bull,true);b.Exposure=8;b.Hydration=100;}
            if(Rat!=null){let r=CaelumThermalBody.Get(Rat,true);r.Exposure=8;r.Hydration=100;}
        }
        Console.Printf("CA140 MANUAL applied case %d once; ordinary simulation continues.",selected);
    }
}
