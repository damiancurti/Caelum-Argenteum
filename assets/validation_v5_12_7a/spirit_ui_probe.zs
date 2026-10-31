// Prueba nativa: no suplanta Capture ni fuerza SocialPageReady.
class CA602Ledger : Inventory
{
    int Phase, Seen;
    double AnimaBefore, Wallet[MAXPLAYERS];
    CaelumPalomo Speakers[MAXPLAYERS];
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA602Probe : StaticEventHandler
{
    bool Started, Reloaded;
    ui int SentPhase, SentSerial;
    ui bool Saved, Closed, Replied, BindingChecked;
    void Check(bool value,String label){Console.Printf("CA602 %s %s",value?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_social_page")
        {
            Check(CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true)!=null,"page request follows native identity admission");
            return;
        }
        if(e.Name!="ca602_visible")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);
        let owner=CaelumPlayer(players[0].mo);
        let ledger=owner==null?null:CA602Ledger(owner.FindInventory('CA602Ledger'));
        if(ledger!=null && user!=null && user.HasActiveConversation() && CaelumSocialization.ValidSession(user))
            ledger.Seen|=1<<e.Player;
    }
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0 || !Started)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let owner=CaelumPlayer(players[0].mo);
        let ledger=owner==null?null:CA602Ledger(owner.FindInventory('CA602Ledger'));
        if(ledger==null)return;
        if(!BindingChecked)
        {
            BindingChecked=true;Array<int> keys;Bindings.GetAllKeysForCommand(keys,"+user3");bool found=false;
            for(int i=0;i<int(keys.Size());i++)found=found || KeyBindings.NameKeys(keys[i],0)~=="T";
            Console.Printf("CA602 %s default T binding",found?"PASS":"FAIL");
        }
        let vote=CaelumCooperativeTravel.View(user);
        if(vote!=null && vote.Opened && SentSerial!=vote.Serial)
        {SentSerial=vote.Serial;EventHandler.SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.ACCEPT,vote.Serial);}
        let menu=CaelumHistoryConversationMenu(Menu.GetCurrentMenu());
        if(menu!=null && menu.SocialPageReady && SentPhase!=ledger.Phase)
        {
            SentPhase=ledger.Phase;
            Console.Printf("CA602 VISIBLE peer=%d phase=%d",consoleplayer,ledger.Phase);
            EventHandler.SendNetworkEvent("ca602_visible");
        }
        if(ledger.Phase==3 && !Reloaded && consoleplayer==0 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA602 open spirit conversations");}
        if(ledger.Phase==4 && menu!=null && menu.SocialPageReady && !Closed)
        {Closed=true;menu.MenuEvent(Menu.MKEY_Back,false);}
        if(ledger.Phase==5 && menu!=null && menu.SocialPageReady && !Replied)
        {
            Replied=true;
            // La primera respuesta real de Palomo solicita el regreso; el otro cierra.
            menu.MenuEvent(consoleplayer==0?Menu.MKEY_Enter:Menu.MKEY_Back,false);
        }
    }
    override void WorldTick()
    {
        if(level.time<180)return;
        let owner=CaelumPlayer(players[0].mo);
        if(!CaelumWorldClockTicker.Ready(owner) || !CaelumWorldClockTicker.Ready(CaelumPlayer(players[1].mo)))return;
        let ledger=CA602Ledger(owner.FindInventory('CA602Ledger'));
        if(!Started)
        {
            Started=true;
            if(ledger!=null && ledger.Phase==3)
            {Reloaded=true;ledger.Seen=0;Console.Printf("CA602 RELOAD open spirit conversation");}
        }
        if(ledger==null)
        {
            ledger=CA602Ledger(owner.GiveInventoryType('CA602Ledger'));ledger.Phase=1;ledger.AnimaBefore=owner.CurrentAnima;
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);ledger.Wallet[i]=user.GetOwnedMoneyCopperValue();
                user.health=user.player.health=0;user.Die(null,null,0,'None');
                Check(!CaelumSpirit.CanConverse(user),"campaign corpse cannot converse");
            }
            Check(CaelumFoolTravel.AllDead(),"both native characters are dead before Tarot input");return;
        }
        if(ledger.Phase==1 && level.MapName=="MAP01")
        {
            Check(Abs(owner.CurrentAnima-(ledger.AnimaBefore-CaelumConstants.TAROT_ACTIVATION_ANIMA))<0.01,"native User3 dispatch charges activator once");
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);
                Check(CaelumSpirit.Active(user) && user.health<=0,"dead traveler becomes a spirit without revival");
                user.SetOrigin((-256+i*512,0,0),false);user.Angle=90;
                let speaker=CaelumPalomo(Actor.Spawn('CaelumPalomo',user.Pos+(0,48,0),NO_REPLACE));
                speaker.args[0]=1;speaker.MerchantAnchored=true;speaker.WanderEnabled=false;
                speaker.NarrativeRevealRequired=true;speaker.DepartureDone=true;ledger.Speakers[i]=speaker;
                Check(user.OpenPalomoDialogue(speaker),"spirit starts native Palomo conversation");
            }
            ledger.Phase=2;ledger.Seen=0;return;
        }
        if(ledger.Phase==2 && ledger.Seen==3)
        {
            Check(true,"both spirit menus receive authoritative page acknowledgement");
            // Reproduce el guardado anterior: interlocutor abierto, sin página
            // confirmada. La carga debe solicitar una confirmación nueva real.
            for(int i=0;i<2;i++)CaelumSocialization.Clear(CaelumPlayer(players[i].mo));
            ledger.Phase=3;Console.Printf("CA602 RESULT initial");return;
        }
        if(ledger.Phase==3 && Reloaded && ledger.Seen==3)
        {Check(true,"common reload restores both visible spirit conversations");ledger.Phase=4;return;}
        if(ledger.Phase==4)
        {
            for(int i=0;i<2;i++)if(CaelumPlayer(players[i].mo).HasActiveConversation())return;
            Check(true,"Back releases both spirit conversation locks");
            for(int i=0;i<2;i++)Check(CaelumPlayer(players[i].mo).OpenPalomoDialogue(ledger.Speakers[i]),"spirit can reopen Palomo after closing");
            ledger.Phase=5;ledger.Seen=0;return;
        }
        if(ledger.Phase==5 && level.MapName=="MAP03")
        {
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);
                Check(user.health<=0 && !CaelumSpirit.Active(user) && !CaelumSpirit.CanConverse(user),"native Palomo reply returns original dead body");
                Check(user.GetOwnedMoneyCopperValue()==ledger.Wallet[i],"round trip preserves personal wallet");
            }
            ledger.Phase=6;Console.Printf("CA602 RESULT reload-return");
        }
    }
}
