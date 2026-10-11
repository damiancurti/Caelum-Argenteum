// Compatible con ambos ejecutables del contenido: conserva el original.
class CA188Persistence : StaticEventHandler
{
    int Age,Visits;
    bool Loaded;
    double SavedBurn,SavedPoison,SavedToughness;
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {
        Age=0;Loaded=e.IsSaveGame;Visits++;
        let u=CaelumPlayer(players[0].mo);
        if(u!=null && u.ElementalStatus!=null)
        {
            SavedBurn=u.ElementalStatus.BurnRemaining;SavedPoison=u.ElementalStatus.PoisonRemaining;
            SavedToughness=u.Attributes.Toughness;
            Console.Printf("CA188 SAVED loaded=%d map=%s burn=%.9f poison=%.9f N=%.9f",Loaded,level.MapName,SavedBurn,SavedPoison,SavedToughness);
        }
    }
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null || u.DerivedStats==null)return;
        int mode=CVar.GetCVar("ca188_stage").GetInt();
        if(!Loaded && Visits==1 && Age==20)
        {
            u.InitializeDirectMapCharacter();u.bNOTARGET=true;u.Attributes.Toughness=mode==5 ? 150 : 20;
            u.health=u.player.health=Max(1,u.CaelumMaximumHealth/2);
            u.ElementalStatus=new("CaelumElementalStatus");
            u.ElementalStatus.BurnRemaining=10;u.ElementalStatus.BurnPower=1;u.ElementalStatus.BurnDamagePerSecond=1;
            u.ElementalStatus.PoisonRemaining=8;u.ElementalStatus.PoisonPower=1;u.ElementalStatus.PoisonDamagePerSecond=1;
        }
        if(Loaded && Age==20)
        {
            double response=mode==1 ? 1-(SavedToughness*SavedToughness+25*SavedToughness)/12500 : 1;
            double burn=Max(0,SavedBurn*response-20.0/35),poison=Max(0,SavedPoison*response-20.0/35);
            bool ok=Abs(u.ElementalStatus.BurnRemaining-burn)<0.04 && Abs(u.ElementalStatus.PoisonRemaining-poison)<0.04;
            Console.Printf("CA188 %s save mode%d burn=%.9f expected=%.9f poison=%.9f expected=%.9f",ok?"PASS":"FAIL",mode,u.ElementalStatus.BurnRemaining,burn,u.ElementalStatus.PoisonRemaining,poison);
            Console.Printf("CA188 DONE failures=%d",ok?0:1);
        }
        if(!Loaded && Visits>1 && Age==20)
        {
            double response=1-(SavedToughness*SavedToughness+25*SavedToughness)/12500;
            bool ok=u.ElementalStatus!=null && Abs(u.ElementalStatus.BurnRemaining-(SavedBurn/0.928*response-20.0/35))<0.04
                && Abs(u.ElementalStatus.PoisonRemaining-(SavedPoison/0.928*response-20.0/35))<0.04;
            Console.Printf("CA188 %s travel retains active statuses map=%s burn=%.9f poison=%.9f",ok?"PASS":"FAIL",level.MapName,u.ElementalStatus.BurnRemaining,u.ElementalStatus.PoisonRemaining);
            Console.Printf("CA188 DONE failures=%d",ok?0:1);
        }
        if(!Loaded && Visits==1 && Age==40)
        {
            Console.Printf("CA188 CHECKPOINT burn=%.9f poison=%.9f",u.ElementalStatus.BurnRemaining,u.ElementalStatus.PoisonRemaining);
            if(mode==4){u.PersistCharacterState();Level.ChangeLevel("MAP02",0,CHANGELEVEL_NOINTERMISSION,-1);}
            else Console.Printf("CA188 DONE failures=0");
        }
    }
}
