class CA435SessionProbe : StaticEventHandler
{
    bool Started,Done,Managed;
    int Received[MAXPLAYERS],Before[MAXPLAYERS],Start,Invalid;
    ui bool Sent,Saved;
    override void WorldLoaded(WorldEvent e){Start=-1;}
    void Check(bool value,String text){Console.Printf("CA435SESSION %s %s",value?"PASS":"FAIL",text);}
    override void UiTick()
    {
        if(Started && Managed && !Sent)
        {
            Sent=true;
            EventHandler.SendNetworkEvent("ca435_session_touch",(consoleplayer+1)%MAXPLAYERS,1);
            EventHandler.SendNetworkEvent("ca435_session_touch",consoleplayer,1);
            EventHandler.SendNetworkEvent("ca435_session_touch",consoleplayer,1);
        }
        if(Done && !Saved && consoleplayer==0)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA435 native common checkpoint");manager.RemoveNewSaveNode();
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca435_session_touch" || !Started || Done)return;
        let owner=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);
        if(owner==null || e.Args[0]!=e.Player || e.Args[1]!=1){Invalid++;return;}
        if(Received[e.Player]!=0)return;
        Received[e.Player]=1;owner.GiveInventory('CaelumCopperCoin',e.Player+1);
        owner.PersistCharacterState();
    }
    override void WorldTick()
    {
        if(Start<0){Start=level.time;return;}
        if(Done || level.time<Start+105)return;
        if(!Started)
        {
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(user) || user.SessionIdentityPending)return;
                let record=user.GetPersistentCharacterState(false);if(record==null)return;
                Managed=record.ExternalProfileCampaign.Length()>0;
                if(!Managed){let coin=user.GiveInventoryType('CaelumCopperCoin');coin.Amount=1000+i;user.PersistCharacterState();}
                Before[i]=user.GetOwnedMoneyCopperValue();
            }
            Started=true;
            Check(true,"every native slot has a ready owned character");
            if(!Managed){Done=true;Console.Printf("CA435SESSION RESULT peer=%d seed",consoleplayer);return;}
        }
        int count=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i]){count++;if(Received[i]==0)return;}
        if(Invalid<count)return;
        Check(Invalid==count,"wrong claimed slots rejected on every peer");
        bool wallets=true,identities=true;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);wallets=wallets && user.GetOwnedMoneyCopperValue()==Before[i]+i+1;
            identities=identities && user.PlayerNumber()==i && user.GetPersistentCharacterState(false).Owner==user && !user.SessionIdentityPending;
        }
        // GiveInventoryType añade una unidad además de la cantidad diagnóstica.
        Check(wallets,"duplicate requests change each sender wallet only once");
        Check(identities,"profile gate releases only matching native identities");
        Done=true;Console.Printf("CA435SESSION RESULT peer=%d managed",consoleplayer);
    }
}
