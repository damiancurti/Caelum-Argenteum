// Preparación aislada para revisión del autor; no se empaqueta en el juego.
class CA513ManualState : Inventory
{
    int Place;
    CaelumTravelBandit TargetBody;
    CaelumPalomo Deity;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CA513ManualScene : StaticEventHandler
{
    const SCENE=0;
    int Announced;
    override void WorldLoaded(WorldEvent e){Announced=0;}
    void Move(CaelumPlayer p,vector3 point,double facing=90)
    {p.Vel=(0,0,0);p.SetOrigin(point,false);p.Angle=facing;p.Pitch=0;p.ClearInterpolation();}
    void Status(CaelumPlayer p)
    {
        let r=p.GetPersistentCharacterState(false);let m=CaelumStandaloneMatch.View();
        Console.Printf("CA513 player=%d map=%s life=%d anima=%.2f owned=%d selected=%d cooldown=%.2fs",
            p.PlayerNumber(),level.MapName,p.health,p.CurrentAnima,CaelumTarotService.CountTarotCards(r),
            CaelumTarotService.SelectedCount(r),r.TarotCooldownTics/double(TICRATE));
        if(m!=null)Console.Printf("CA513 mode=%d score=%d team=%d finished=%d winner=%d captive=%d collected=%d",
            m.Mode,m.Score[p.PlayerNumber()],m.Team[p.PlayerNumber()],m.Finished,m.Winner,
            m.Hunt!=null && m.Hunt.Captive(p.PlayerNumber()),m.Hunt!=null?m.Hunt.Collected:0);
        for(int i=0;i<r.TarotOrderCount;i++)Console.Printf("CA513 sequence[%d]=%s",i,CaelumTarotArt.DisplayName(r.TarotOrder[i]));
    }
    override void WorldTick()
    {
        // La voz del prólogo no forma parte de estos escenarios aislados.
        if(SCENE<4 || SCENE==9)for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let p=CaelumPlayer(players[i].mo);if(p==null)continue;
            let r=p.GetPersistentCharacterState(false);if(r==null)continue;
            r.EnsureQuestStateInitialized();r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD]=true;
        }
        if(level.time<105)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let p=CaelumStandalonePlayer(players[i].mo);
            if(p==null || p.StandaloneRevision<1 || !CaelumWorldClockTicker.Ready(p))continue;
            let ledger=CA513ManualState(p.FindInventory('CA513ManualState'));
            if(ledger==null)
            {
                ledger=CA513ManualState(p.GiveInventoryType('CA513ManualState'));
                if(SCENE<4 || SCENE==9)
                {
                    let r=p.GetPersistentCharacterState(false);r.EnsureQuestStateInitialized();
                    r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD]=true;
                    r.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]=CaelumConstants.MAIN_M00_STATE_MET_PALOMO;
                    for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
                    {r.TarotOwned[card]=SCENE!=1 || card!=77;r.TarotSelected[card]=false;r.TarotActive[card]=false;r.TarotRemaining[card]=0;}
                    r.TarotOrderCount=0;r.TarotLoadoutRevision=1;r.TarotPowerRevision=2;r.TarotCooldownTics=r.TarotEffectTics=0;
                    CaelumInventoryService.GrantMagicBoxFromPalomo(p,false);CaelumTarotDeckRules.Grant(p,false);
                    CaelumTarotDeckRules.Owned(p).InMagicBox=true;
                    p.ApplyCharacterProfile();p.RefillAir();p.RefillAnima();p.RefillSurvivalResources();
                    p.health=p.CaelumMaximumHealth;p.player.health=p.health;
                    Move(p,SCENE==0 || SCENE==3?CaelumTarotExampleData.Arrival(0)+(i*64,0,0):(-128,i*96,0));
                    if(SCENE==1)
                    {
                        CaelumTarotService.Select(p,21);
                        CaelumArcanaSources.PlaceReward(p,77,(-128,48,0));
                        if(i==0)ledger.Deity=CaelumPalomo(Actor.Spawn('CaelumPalomo',(128,0,0),NO_REPLACE));
                    }
                    if(SCENE==9)CaelumTarotService.Select(p,0);
                    p.RefreshSocialJournalSnapshot();p.RefreshFormalInventorySnapshot();p.PersistCharacterState();
                }
            }
            if(!(Announced&(1<<i))){Announced|=1<<i;Console.Printf("CA513 READY scene=%d player=%d",SCENE,i);Status(p);}
            if(ledger.Deity!=null)
            {ledger.Deity.NarrativeRevealInitialized=true;ledger.Deity.NarrativeRevealRequired=false;ledger.Deity.bInvisible=false;ledger.Deity.bInvulnerable=false;ledger.Deity.bDormant=true;}
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let p=CaelumPlayer(players[e.Player].mo);if(p==null)return;
        let ledger=CA513ManualState(p.FindInventory('CA513ManualState'));if(ledger==null)return;
        let r=p.GetPersistentCharacterState(false);let m=CaelumStandaloneMatch.View();
        if(e.Name=='ca513_status'){Status(p);return;}
        if(e.Name=='ca513_finish_setup' && p.health>0)
        {
            if(m==null)p.DamageMobj(p,p,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            else if(!m.Finished && m.Hunt!=null)
            {
                for(int card=0;card<77;card++)if(!m.Hunt.Found[card])
                {Move(p,m.Hunt.Essences[card].Pos);m.Hunt.Collect(p,card);}
                Move(p,m.Hunt.Essences[77].Pos+(0,64,0),270);
            }
            else if(!m.Finished)
                m.Score[e.Player]=m.Capture!=null?CaelumStandaloneData.CAPTURE_LIMIT-1:CaelumStandaloneData.FRAG_LIMIT-1;
            return;
        }
        if(e.Name=='ca513_reset')
        {
            if(m!=null)
            {
                if(m.Hunt!=null)m.Hunt.CapturePlayer(p);
                else p.DamageMobj(p,p,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            }
            else if(p.health>0)
            {
                p.RefillAir();p.RefillAnima();p.RefillSurvivalResources();p.health=p.CaelumMaximumHealth;p.player.health=p.health;
                if(r.TarotEffectTics==0 && r.UnifiedTarotTics==0)r.TarotCooldownTics=0;
                Console.Printf("CA513 setup: resources restored; cooldown clears only after active powers expire.");
            }
            Status(p);return;
        }
        if(e.Name=='ca513_place')
        {
            if(m!=null && m.Hunt!=null)
            {
                for(int i=0;i<MAXPLAYERS;i++)if(m.Hunt.Captive(i))
                {Move(p,players[i].mo.Pos+(48,0,0),180);return;}
                Move(p,CaelumHuntData.Start(e.Player));
            }
            else if(m!=null && m.Capture!=null)
            {
                int other=1-m.Team[e.Player];Move(p,m.Capture.Bases[other].Pos);
            }
            else if(CaelumTarotExampleData.Present())
            {
                ledger.Place=(ledger.Place+1)%5;
                vector3 point=ledger.Place==0?CaelumTarotExampleData.Arrival(0):ledger.Place==1?CaelumTarotExampleData.Door(0)-(0,96,0)
                    :ledger.Place==2?CaelumTarotExampleData.Door(1)-(0,96,0):ledger.Place==3?CaelumTarotExampleData.Controller()-(0,96,0)
                    :CaelumTarotExampleData.Automaton()-(0,128,0);
                Move(p,point+(e.Player*64,0,0));
            }
            return;
        }
        if(e.Name=='ca513_target')
        {
            if(m!=null && m.Hunt!=null)
            {Move(p,CaelumHuntData.TrapPoint(ledger.Place%24)-(0,0,0.5));ledger.Place++;return;}
            if(m!=null && m.Capture!=null)
            {Move(p,m.Capture.Bases[m.Team[e.Player]].Pos);return;}
            if(m!=null)return;
            if(ledger.TargetBody==null || ledger.TargetBody.health<=0)
            {
                vector2 direction=(Cos(p.Angle),Sin(p.Angle));
                ledger.TargetBody=CaelumTravelBandit(Actor.Spawn('CaelumTravelBandit',p.Pos+(direction*192,0),NO_REPLACE));
                if(ledger.TargetBody!=null)ledger.TargetBody.bDormant=true;
            }
            else ledger.TargetBody.bDormant=!ledger.TargetBody.bDormant;
        }
    }
}
