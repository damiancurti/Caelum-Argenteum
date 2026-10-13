// Compatible con 5.3.1 para crear una copia antigua y comprobar su reversión.
class CA257Legacy : StaticEventHandler
{
    int Failures;
    CaelumDiningTable Table;
    CaelumConsumableItem Food;
    CaelumWaterContainer Water;
    bool Watching;
    int LastFlags;
    void Check(bool ok,String label)
    {Console.Printf("CA257 %s %s",ok?"PASS":"FAIL",label);if(!ok)Failures++;}
    override void ConsoleProcess(ConsoleEvent e)
    {if(e.Name=="c257_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !Watching)return;
        let rest=CaelumRestState.Get(u);if(rest==null)return;
        int flags=int(rest.AutoEating)+int(rest.AutoDrinking)*2;
        if(flags!=LastFlags)
        {
            LastFlags=flags;
            Console.Printf("CA257 INPUT_STATE tic=%d food=%d water=%d hunger=%.6f thirst=%.6f",
                level.maptime,rest.AutoEating,rest.AutoDrinking,u.CurrentHunger,u.CurrentThirst);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca_table_eat" || e.Name=="ca_table_drink" || e.Name=="ca_time_fast")
            Console.Printf("CA257 INPUT_EVENT %s tic=%d",e.Name,level.maptime);
        if(e.Name=="c257_setup")
        {
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.ConversationPC=null;
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.ApplyCharacterProfile();
            let r=u.GetPersistentCharacterState(true);r.ProfileCommitted=true;
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.RecordMainM00UnknownVoiceHeard();
            CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
            u.CombatTimeRemaining=0;u.CurrentHunger=u.CurrentThirst=80;u.CurrentSleep=70;
            Food=CaelumConsumableItem(Actor.Spawn("CaelumFoodRation"));Food.Amount=3;
            Food.InMagicBox=true;Food.AttachToOwner(u);
            Water=CaelumWaterContainer(Actor.Spawn("CaelumCanteenLarge"));Water.WaterLiters=1;
            Water.InMagicBox=true;Water.AttachToOwner(u);
            u.PersistCharacterState();
        }
        if(e.Name=="c257_scene")
        {
            Table=CaelumDiningWorld.Find(105);
            Check(Table!=null && Table.Chairs[0]!=null,"authored-map01-chair-and-table");
            if(Table==null || Table.Chairs[0]==null)return;
            u.SetOrigin(Table.Chairs[0].Pos+(0,48,0),false);u.Vel=(0,0,0);
        }
        if(e.Name=="c257_sit")
        {
            let chair=Table.Chairs[0];
            Check(CaelumRestState.Begin(u,chair.RestMode(),0,chair),"native-begin-authored-chair");
            Watching=true;LastFlags=-1;
        }
        if(e.Name=="c257_old_seed")
        {
            Check(CaelumDiningSession.ConsumeReserve(u,false) && CaelumDiningSession.ConsumeReserve(u,true),"old-native-in-flight-reserve-portions");
            let rest=CaelumRestState.Get(u);rest.AutoEating=false;rest.AutoDrinking=false;
        }
        if(e.Name=="c257_snapshot")
        {
            if(Food==null)Food=CaelumConsumableItem(u.FindInventory("CaelumFoodRation"));
            if(Water==null)Water=CaelumWaterContainer(u.FindInventory("CaelumCanteenLarge"));
            let rest=CaelumRestState.Get(u);
            let f=CaelumRegenerationPower(u.FindInventory("CaelumHungerRegeneration"));
            let w=CaelumRegenerationPower(u.FindInventory("CaelumThirstRegeneration"));
            Console.Printf("CA257 SAVE map=%s food=%d boxed=%d liters=%.8f waterboxed=%d foodEffect=%d waterEffect=%d rest=%d auto=%d/%d hunger=%.6f thirst=%.6f",
                level.MapName,Food!=null?Food.Amount:-1,Food!=null?Food.InMagicBox:false,
                Water!=null?Water.WaterLiters:-1,Water!=null?Water.InMagicBox:false,
                f!=null?f.EffectTics:0,w!=null?w.EffectTics:0,rest!=null?rest.Status:-1,
                rest!=null?rest.AutoEating:false,rest!=null?rest.AutoDrinking:false,u.CurrentHunger,u.CurrentThirst);
        }
        if(e.Name=="c257_done")Console.Printf("CA257 DONE failures=%d",Failures);
    }
}
