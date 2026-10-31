// El montaje se guarda para no reemplazar mesas ni asientos al reanudar.
class CA512AuthorLedger : Inventory
{
    CaelumPortableSmallTable Table;
    CaelumPalomo Speaker;
    CaelumRestChair Chairs[MAXPLAYERS];
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
// Escenas manuales aisladas: sólo preparan datos; las acciones usan servicios reales.
class CA512AuthorScene : StaticEventHandler
{
    const SCENE=0;
    bool Ready;
    CaelumPortableSmallTable Table;
    CaelumPalomo Speaker;
    CaelumRestChair Chairs[MAXPLAYERS];

    void Status(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        let clock=CaelumWorldClock.Get(user);
        Console.Printf("CA512 player=%d map=%s health=%d anima=%.2f money=%d rest=%d spirit=%d clock=%d profile=%s",
            user.PlayerNumber()+1,level.MapName,user.health,user.CurrentAnima,user.GetOwnedMoneyCopperValue(),
            CaelumRestState.IsActive(user),CaelumSpirit.Active(user),clock!=null?clock.DayTics:-1,
            record!=null?record.ExternalProfileId:"");
    }
    override void WorldTick()
    {
        if(Ready || level.time<105)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            if(!CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let leader=CaelumPlayer(players[0].mo);
        let ledger=CA512AuthorLedger(leader.FindInventory('CA512AuthorLedger'));
        if(ledger!=null)
        {
            Table=ledger.Table;Speaker=ledger.Speaker;
            for(int i=0;i<MAXPLAYERS;i++)Chairs[i]=ledger.Chairs[i];
            Ready=true;Console.Printf("CA512 READY restored scene=%d player=%d",SCENE,consoleplayer+1);return;
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
            user.SetOrigin((-128+i*256,0,0),false);user.Angle=90;user.Pitch=0;user.Vel=(0,0,0);
            user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
            user.CurrentAnima=user.DerivedStats.MaximumAnima;
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
            record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
            record.TarotSelected[CaelumConstants.TAROT_THE_FOOL]=true;
            record.TarotCooldownTics=0;
            if(SCENE==1)
            {
                Chairs[i]=CaelumRestChair(Actor.Spawn('CaelumRestChair',user.Pos+(0,48,0),NO_REPLACE));
            }
        }
        if(SCENE==3 || SCENE==4)
        {
            let first=CaelumPlayer(players[0].mo);
            Speaker=CaelumPalomo(Actor.Spawn('CaelumPalomo',first.Pos+(0,48,0),NO_REPLACE));
            Speaker.args[0]=1;Speaker.MerchantAnchored=true;Speaker.WanderEnabled=false;
        }
        if(SCENE==5 || SCENE==6)
        {
            Table=CaelumPortableSmallTable(Actor.Spawn('CaelumPortableSmallTable',(0,512,0),NO_REPLACE));
            if(Table==null || !Table.ConfigureParts()){Console.Printf("CA512 FAIL table");return;}
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];
                user.SetOrigin(chair.Pos+(0,i==0?-48:48,0),false);user.Vel=(0,0,0);
                if(!CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,480,chair))
                    Console.Printf("CA512 FAIL seating player=%d",i+1);
            }
            CaelumPlayer(players[1].mo).GiveInventoryType('CaelumTarotDeck');
        }
        ledger=CA512AuthorLedger(leader.GiveInventoryType('CA512AuthorLedger'));
        ledger.Table=Table;ledger.Speaker=Speaker;
        for(int i=0;i<MAXPLAYERS;i++)ledger.Chairs[i]=Chairs[i];
        Ready=true;Console.Printf("CA512 READY scene=%d player=%d - F1 estado; F2 accion; F3 secundaria; F4 resucitar (solo escenario 437)",SCENE,consoleplayer+1);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(!Ready || (e.Name!="ca512_status" && e.Name!="ca512_action" && e.Name!="ca512_secondary" && e.Name!="ca512_restore"))return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);if(user==null)return;
        if(e.Name=="ca512_status"){Status(user);return;}
        if(e.Name=="ca512_restore")
        {if(SCENE==2 && level.MapName!="MAP01" && user.health<=0)CaelumResurrection.Restore(user,user.Pos);return;}
        if(e.Name=="ca512_secondary")
        {
            if(SCENE==1 || SCENE==5 || SCENE==6)CaelumRestState.Cancel(user);
            else if(SCENE==2 && user.health>0 && level.MapName!="MAP01")
            {user.health=user.player.health=0;user.Die(null,null,0,'None');}
            else if(SCENE==3 || SCENE==4)CaelumArena.ProposeReturn(user);
            Status(user);return;
        }
        if(SCENE==0){user.GiveInventory('CaelumCopperCoin',1);user.PersistCharacterState();Status(user);}
        else if(SCENE==1)
        {
            if(!CaelumRestState.IsActive(user))
                CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,480,Chairs[e.Player]);
            else CaelumCooperativeTime.Open(user);
        }
        else if(SCENE==2)
        {
            if(level.MapName=="MAP01")
            {
                if(Speaker==null)
                {
                    Speaker=CaelumPalomo(Actor.Spawn('CaelumPalomo',user.Pos+(48,0,0),NO_REPLACE));
                    Speaker.args[0]=1;Speaker.MerchantAnchored=true;Speaker.WanderEnabled=false;
                    Speaker.NarrativeRevealRequired=true;Speaker.DepartureDone=true;
                }
                user.OpenPalomoDialogue(Speaker);
            }
            else if(user.health<=0)CaelumFoolTravel.Propose(user,true);
            else CaelumTarotService.Activate(user);
        }
        else if(SCENE==3 || SCENE==4)
        {
            if(CaelumArenaData.IsMap(level.MapName)){CaelumArena.ProposeReturn(user);return;}
            if(CaelumArena.Open(user,Speaker))CaelumArenaState.View(user).Venue=SCENE-3;
        }
        else if(SCENE==5 || SCENE==6)CaelumCardSeat.Interact(user);
    }
}
