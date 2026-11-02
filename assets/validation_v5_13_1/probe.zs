class CA441Ledger : Inventory
{
    int Phase;
    int At;
    int SavedTimer;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CA441Probe : StaticEventHandler
{
    ui int Frames;
    ui bool Submitted;
    ui bool Saved;
    bool Entered;
    bool Reloaded;
    void Check(bool ok,String detail)
    {Console.Printf("CA441 %s %s",ok?"PASS":"FAIL",detail);}

    override void RenderOverlay(RenderEvent e)
    {
        if(consoleplayer!=0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let ledger=user!=null?CA441Ledger(user.FindInventory('CA441Ledger')):null;
        if(ledger!=null && ledger.Phase==5 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA441 completed collection and active essence");}
        let menu=CaelumFoolConversationMenu(Menu.GetCurrentMenu());
        if(menu==null){Frames=0;Submitted=false;return;}
        Frames++;
        if(Frames>=25 && menu.SocialPageReady && !Submitted)
        {Submitted=true;menu.MenuEvent(Menu.MKEY_Enter,false);}
    }

    override void WorldTick()
    {
        if(level.time<105 || !CaelumArcanaSources.Ready())return;
        for(int i=0;i<2;i++)if(!CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let user=CaelumPlayer(players[0].mo);
        let other=CaelumPlayer(players[1].mo);
        let record=user.GetPersistentCharacterState(false);
        let ledger=CA441Ledger(user.FindInventory('CA441Ledger'));
        let source=CaelumRewardEssence(CaelumArcanaSources.Find(ledger==null || ledger.Phase<=2?1:77));
        if(!Entered){Reloaded=ledger!=null;Entered=true;}
        if(Reloaded && ledger!=null && ledger.Phase==5)
        {
            Check(source!=null && source.Configured && source.CardId()==77,"load rebuilds source registry");
            Check(CaelumUnifiedTarot.Owned(record) && !source.IsAvailable(user),"load preserves all captures without replay");
            Check(record.UnifiedTarotTics>0 && record.UnifiedTarotTics<=ledger.SavedTimer,"load preserves paid effect time");
            Check(!CaelumUnifiedTarot.Activate(user),"load cannot repeat paid activation");
            CaelumTarotService.Advance(user,record.UnifiedTarotTics);
            Check(!CaelumUnifiedTarot.Active(user) && record.TarotCooldownTics>0,"expiry removes effect but retains shared cooldown");
            record.TarotCooldownTics=0;user.CurrentAnima=2000;
            Check(CaelumUnifiedTarot.Activate(user),"power can reactivate after cooldown");
            user.DamageMobj(null,null,user.health+1000,'None',DMG_FORCED,0);
            Check(user.health<=0 && record.UnifiedTarotTics==0 && CaelumUnifiedTarot.Owned(record),"normal death ends effect and preserves collection");
            ledger.Phase=6;Console.Printf("CA441 RESULT reload");return;
        }
        if(ledger==null)
        {
            user.GiveInventoryType('CA441Ledger');ledger=CA441Ledger(user.FindInventory('CA441Ledger'));
            for(int i=0;i<2;i++)
            {
                let peer=CaelumPlayer(players[i].mo);let data=peer.GetPersistentCharacterState(false);
                peer.SetOrigin((-128,-i*64,0),false);peer.Angle=90;peer.Pitch=0;peer.Vel=(0,0,0);
                peer.CurrentHunger=100;peer.CurrentThirst=100;peer.CurrentSleep=100;
                data.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
                data.TarotOwned[1]=false;data.ArcanaAvailable[1]=false;data.ArcanaRevealed[1]=false;
                CaelumInventoryService.GrantMagicBoxFromPalomo(peer,false);
                CaelumTarotDeckRules.Grant(peer,false);
                CaelumTarotDeckRules.Owned(peer).InMagicBox=true;
                peer.RefreshSocialJournalSnapshot();
            }
            Check(CaelumArcanaSources.PlaceReward(user,-1,user.Pos)==null,"reject invalid reward ID");
            Check(CaelumArcanaSources.PlaceReward(user,0,user.Pos)==null,"preserve original Fool story gate");
            source=CaelumArcanaSources.PlaceReward(user,1,(-128,48,0));
            Check(source!=null && !record.TarotOwned[1],"mission places source without acquiring essence");
            Check(CaelumArcanaSources.PlaceReward(user,1,(512,512,0))==source,"retry reuses same world source");
            Check(!source.IsAvailable(other),"unrewarded participant has no capture entitlement");
            Check(CaelumArcanaSources.PlaceReward(other,1,(-128,48,0))==source,"shared reward keeps personal entitlement");
            Check(!CaelumTarotService.CommitCapture(user,source),"commit requires actual capture transaction");
            ledger.Phase=1;ledger.At=level.time;
        }
        if(ledger.Phase==1 && level.time-ledger.At>35)
        {
            Check(source.Used(user),"real USDF opens for new Major");
            ledger.Phase=2;ledger.At=level.time;
        }
        if(ledger.Phase==2 && record.TarotOwned[1])
        {
            Check(record.ArcanaRevealed[1],"rendered dialogue and timed capture grant personal essence");
            Check(!other.GetPersistentCharacterState(false).TarotOwned[1],"capture does not grant other participant");
            Check(!source.IsAvailable(user) && source.IsAvailable(other),"source remains for other eligible participant");
            Check(CaelumArcanaSources.PlaceReward(user,1,user.Pos)==null,"owned reward cannot be replayed");
            Check(!CaelumTarotService.CommitCapture(user,source),"duplicate capture does not grant twice");
            source=CaelumArcanaSources.PlaceReward(user,77,(-128,48,0));
            for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
            {
                if(card!=77)record.TarotOwned[card]=true;
                Check(Actor.GetSpriteIndex(CaelumTarotArt.FrontSprite(card))>=0,String.Format("registered front %d",card));
            }
            record.TarotOwned[77]=false;record.TarotSelected[21]=true;
            record.TarotCooldownTics=0;record.TarotEffectTics=0;user.CurrentAnima=2000;
            Check(!CaelumUnifiedTarot.Activate(user) && user.CurrentAnima==2000,"77 essences cannot activate unified power");
            ledger.Phase=3;ledger.At=level.time;
        }
        if(ledger.Phase==3 && level.time-ledger.At>35)
        {Check(source.Used(user),"real USDF opens last Minor");ledger.Phase=4;ledger.At=level.time;}
        if(ledger.Phase==4 && source.CaptureTics>=4)
        {user.SetOrigin((-128,-200,0),false);ledger.Phase=40;ledger.At=level.time;}
        if(ledger.Phase==40 && level.time-ledger.At>3)
        {
            Check(source.CaptureUser==null && !record.TarotOwned[77],"leaving during capture interrupts without ownership");
            user.SetOrigin((-128,0,0),false);ledger.Phase=41;ledger.At=level.time;
        }
        if(ledger.Phase==41 && level.time-ledger.At>35)
        {Check(source.Used(user),"interrupted source can be retried");ledger.Phase=42;ledger.At=level.time;}
        if(ledger.Phase==42 && record.TarotOwned[77])
        {
            Check(CaelumUnifiedTarot.Owned(record),"final real capture completes unified essence");
            record.TarotSelected[21]=false;
            Check(!CaelumUnifiedTarot.Activate(user),"complete collection still requires equipped World");
            record.TarotSelected[21]=true;user.CurrentAnima=999;
            Check(!CaelumUnifiedTarot.Activate(user) && user.CurrentAnima==999,"insufficient Anima rejects without payment");
            user.CurrentAnima=2000;
            Check(CaelumUnifiedTarot.Activate(user) && user.CurrentAnima==1000,"activation charges once");
            Check(record.UnifiedTarotTics==60*TICRATE && record.TarotCooldownTics==600*TICRATE,"approved duration and shared cooldown");
            Check(!CaelumUnifiedTarot.Activate(user) && user.CurrentAnima==1000,"repeat activation cannot double charge");
            user.ProfileDeparted=true;
            Check(!CaelumUnifiedTarot.Active(user),"departed profile cannot retain damage permission");
            user.ProfileDeparted=false;user.SessionIdentityPending=true;
            Check(!CaelumUnifiedTarot.Active(user),"unadmitted identity cannot retain damage permission");
            user.SessionIdentityPending=false;
            let deity=CaelumPalomo(Actor.Spawn('CaelumPalomo',(-400,400,0),NO_REPLACE));
            deity.bInvulnerable=false;int before=deity.health;
            deity.DamageMobj(other,other,100,'CaelumImpact',DMG_FORCED,0);
            Check(deity.health==before,"deity rejects source without unified power");
            deity.DamageMobj(user,user,100,'CaelumImpact',DMG_FORCED,0);
            Check(deity.health<before,"unified source can damage real Palomo");
            before=deity.health;deity.bInvisible=true;
            deity.DamageMobj(user,user,100,'CaelumImpact',DMG_FORCED,0);
            Check(deity.health==before,"hidden narrative scene remains protected");
            ledger.SavedTimer=record.UnifiedTarotTics;
            ledger.Phase=5;Console.Printf("CA441 RESULT capture");
        }
        if(ledger.Phase==2 && level.time-ledger.At>350)
        {Check(false,"capture timeout");ledger.Phase=9;}
        if(ledger.Phase==4 && level.time-ledger.At>350)
        {Check(false,"last capture timeout");ledger.Phase=9;}
    }
}
