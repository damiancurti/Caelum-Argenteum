// Los comandos nativos de cada proceso mueven, golpean y activan su propio Tarot.
class CA435ImpactTarget : Actor
{
    int Hits,Attacker;
    Default { Health 10000; Radius 18; Height 56; +SHOOTABLE +SOLID +NOGRAVITY }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        let user=CaelumPlayer(source);
        if(user!=null){Hits++;Attacker=user.PlayerNumber();}
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA435SessionProbe : StaticEventHandler
{
    bool Started,Placed,Done;
    CA435ImpactTarget Targets[MAXPLAYERS];
    double StartX[MAXPLAYERS],LastAnima[MAXPLAYERS],Paid[MAXPLAYERS];
    int Activations[MAXPLAYERS];
    bool Active[MAXPLAYERS];
    ui bool Saved;
    void Check(bool value,String label){Console.Printf("CA435SESSION %s %s",value?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(Done && !Saved && consoleplayer==0)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA435 native combat checkpoint");manager.RemoveNewSaveNode();
        }
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        if(!Started)
        {
            bool ready=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
                ready=ready && CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo));
            if(!ready)return;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);
                user.SetOrigin((-400,-448+i*128,0),false);user.Vel=(0,0,0);user.Angle=0;user.Pitch=0;
                StartX[i]=user.Pos.X;
                let record=user.GetPersistentCharacterState(false);
                record.DemoNarrativeDelivered|=CaelumDemoNarrative.ObservedEvents(record);record.DemoNarrativePending=0;
                if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
                user.player.ConversationNPC=null;user.player.ConversationPC=null;
                user.CharacterAllocation.AttributeBonus[CaelumConstants.ATTRIBUTE_PATIENCE]=100;
                user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
                user.CurrentAir=user.DerivedStats.MaximumAir;
                CaelumTarotService.EnsureRevision(record);
                for(int c=0;c<CaelumConstants.TAROT_CARD_COUNT;c++)record.TarotSelected[c]=false;
                int card=CaelumConstants.TAROT_MAJOR_COUNT+i;
                record.TarotOwned[card]=true;record.TarotSelected[card]=true;
                record.TarotEffectTics=0;record.TarotCooldownTics=0;
                user.WeaponModel.Equipped=false;user.EnsureUnarmedFallback();
                LastAnima[i]=user.CurrentAnima;user.PersistCharacterState();
            }
            Started=true;
            Check(true,"real native peers initialize distinct owned combat actors");
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
            bool isActive=record.TarotCooldownTics>0;
            if(isActive && !Active[i]){Activations[i]++;Paid[i]+=LastAnima[i]-user.CurrentAnima;}
            Active[i]=isActive;LastAnima[i]=user.CurrentAnima;
        }
        if(!Placed && level.time>=210)
        {
            bool moved=true,weapons=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);
                moved=moved && user.Pos.X>StartX[i]+1;
                weapons=weapons && user.player.ReadyWeapon!=null && user.player.ReadyWeapon.GetClassName()=='CaelumUnarmedWeapon';
                Targets[i]=CA435ImpactTarget(Actor.Spawn('CA435ImpactTarget',user.Pos+(48,0,0),NO_REPLACE));
                Targets[i].Attacker=-1;
            }
            Check(moved,"native movement commands advance every actual owner");
            Check(weapons,"each actual native weapon belongs to its own player");Placed=true;
        }
        if(level.time<330)return;
        bool impacts=true,owners=true,once=true,costs=true,inactive=true;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let target=Targets[i];let record=user.GetPersistentCharacterState(false);
            impacts=impacts && target!=null && target.Hits==1 && target.health<10000;
            owners=owners && target!=null && target.Attacker==i;
            if(i%2==0)
            {
                once=once && Activations[i]==1 && record.TarotEffectTics>0;
                costs=costs && Abs(Paid[i]-CaelumConstants.TAROT_ACTIVATION_ANIMA)<1;
            }
            else inactive=inactive && Activations[i]==0 && record.TarotCooldownTics==0 && record.TarotEffectTics==0;
            Console.Printf("CA435SESSION STATE slot=%d x=%.6f health=%d hits=%d attacker=%d casts=%d paid=%.6f cooldown=%d",i,user.Pos.X,target==null?-1:target.health,target==null?-1:target.Hits,target==null?-1:target.Attacker,Activations[i],Paid[i],record.TarotCooldownTics);
        }
        Check(impacts,"one native attack causes one real impact per client");
        Check(owners,"each impact attributes damage to its actual sender");
        Check(once,"repeated Tarot input cannot bypass the owned cooldown");
        Check(costs,"each successful Tarot activation pays its approved Anima cost once");
        Check(inactive,"players who did not activate retain their own ability state");
        Done=true;Console.Printf("CA435SESSION RESULT combat peer=%d",consoleplayer);
    }
}
