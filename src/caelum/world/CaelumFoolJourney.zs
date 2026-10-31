// El retorno pertenece a esta visita, no a la partida personal exportable.
class CaelumFoolJourney : Inventory
{
    int Revision;
    bool Active, Returning, PendingReturn, PendingConversation, OrdinaryConversation;
    const CONVERSATION = 43700;
    String OriginMap;
    vector3 OriginPosition;
    double OriginAngle;
    CaelumPalomo ReturnSpeaker;
    static clearscope CaelumFoolJourney View(CaelumPlayer user)
    {return user!=null?CaelumFoolJourney(user.FindInventory('CaelumFoolJourney')):null;}
    static CaelumFoolJourney Get(CaelumPlayer user)
    {
        let visit=View(user);
        if(visit==null && CaelumPlayerAuthority.CanMutate(user))
            visit=CaelumFoolJourney(user.GiveInventoryType('CaelumFoolJourney'));
        return visit;
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        if(PendingReturn && user!=null && !user.HasActiveConversation())
        {PendingReturn=false;CaelumFoolTravel.ProposeReturn(user,ReturnSpeaker);}
        if(PendingConversation && user!=null && !user.HasActiveConversation())
        {PendingConversation=false;OrdinaryConversation=true;user.OpenPalomoDialogue(ReturnSpeaker);OrdinaryConversation=false;}
    }
    static void Arrive(CaelumPlayer user)
    {
        let visit=View(user);if(visit==null || !visit.Returning || level.MapName!=visit.OriginMap)return;
        visit.Returning=false;visit.Active=false;
        // El muerto recupera su lugar de muerte, no el lugar del viaje del grupo.
        if(user.health>0)
        {user.SetOrigin(visit.OriginPosition,false);user.Angle=visit.OriginAngle;user.Vel=(0,0,0);user.FindFloorCeiling();user.ClearInterpolation();}
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

// El espíritu conserva la identidad muerta. Sólo recibe movimiento y diálogo;
// no ejecuta PlayerThink material, armas, supervivencia ni recogidas.
class CaelumSpirit : Object play
{
    static clearscope bool Active(CaelumPlayer user)
    {
        let body=CaelumDeadTraveler.View(user);
        return CaelumPlayerAuthority.CanRead(user) && user.health<=0 && level.MapName=="MAP01"
            && body!=null && body.Stored && body.BodyMap!="MAP01" && !body.InTransit;
    }
    static clearscope bool CanConverse(CaelumPlayer user)
    {return CaelumPlayerAuthority.CanRead(user) && (user.health>0 || Active(user));}
    static void Arrive(CaelumPlayer user)
    {
        if(!Active(user))return;
        user.bInvisible=false;user.bSolid=false;user.bShootable=false;
        user.bCorpse=false;user.bNoInteraction=false;user.A_ChangeLinkFlags(0,0);
        user.A_SetSize(user.DerivedStats.ActorRadius,user.DerivedStats.ActorHeight);
        user.SetState(user.SpawnState);user.Pitch=0;user.Vel=(0,0,0);
        user.player.viewheight=user.ViewHeight;user.player.deltaviewheight=0;
        user.FindFloorCeiling();user.ClearInterpolation();
    }
    static void Use(CaelumPlayer user)
    {
        if(!Active(user) || !CaelumPlayerAuthority.CanMutate(user) || user.HasActiveConversation())return;
        Actor nearest=null;double distance=user.UseRange;
        let nearby=BlockThingsIterator.Create(user,user.UseRange);
        while(nearby.Next())
        {
            let other=nearby.thing;
            if(CaelumPalomo(other)==null && CaelumAnchoredResident(other)==null)continue;
            if(other.health<=0 || other.bInvisible || !CaelumUseGeometry.AimedAt(user,other)
                || !user.CheckSight(other))continue;
            double gap=Max(0,user.Distance2D(other)-other.Radius);
            if(gap<=distance){distance=gap;nearest=other;}
        }
        if(CaelumPalomo(nearest)!=null)user.OpenPalomoDialogue(nearest);
        else if(CaelumAnchoredResident(nearest)!=null)
            CaelumMainM00SocialDialogue.Open(user,CaelumAnchoredResident(nearest));
    }
}

// Los datos personales conservan la promesa, no una segunda copia del objeto.
class CaelumSpiritRewards : Object play
{
    enum Reward { DECK, BOX, SILVER_KEY }
    static bool Queue(CaelumPlayer user,int reward)
    {
        if(!CaelumSpirit.Active(user))return false;
        let record=user.GetPersistentCharacterState(false);if(record==null)return false;
        record.SpiritRewardRevision=1;
        if(reward==DECK){if(record.TarotDeckGranted)return true;record.SpiritDeckPending=true;}
        else if(reward==BOX){if(record.MagicBoxOwned)return true;record.SpiritBoxPending=true;}
        else if(reward==SILVER_KEY)record.SpiritSilverKeyPending=true;
        else return false;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_SPIRIT_REWARD_PENDING",false));
        user.PersistCharacterState();return true;
    }
    static void Deliver(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0)return;
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        bool changed=false;
        if(record.SpiritBoxPending && (record.MagicBoxOwned || user.GrantMagicBoxFromPalomo(false)))
        {record.SpiritBoxPending=false;changed=true;}
        if(record.SpiritDeckPending && CaelumTarotDeckRules.Grant(user,false))
        {record.SpiritDeckPending=false;changed=true;}
        // La llave única sigue en poder de Argento hasta su entrega autorizada;
        // no se fabrica otra si el dueño está en un mapa inactivo.
        if(changed)user.PersistCharacterState();
    }
}

class CaelumFoolReturnAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);let visit=CaelumFoolJourney.View(user);
        let speaker=user!=null && user.player!=null?CaelumPalomo(user.player.ConversationNPC):null;
        if(visit==null || !visit.Active || speaker==null || !CaelumSpirit.CanConverse(user))return false;
        visit.ReturnSpeaker=speaker;visit.PendingReturn=true;return true;
    }
}
class CaelumFoolConversationAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);let visit=CaelumFoolJourney.View(user);
        let speaker=user!=null && user.player!=null?CaelumPalomo(user.player.ConversationNPC):null;
        if(visit==null || !visit.Active || speaker==null || !CaelumSpirit.CanConverse(user))return false;
        visit.ReturnSpeaker=speaker;visit.PendingConversation=true;return true;
    }
}

class CaelumFoolTravel : Object play
{
    static bool AllDead()
    {
        bool found=false;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);
            if(!CaelumWorldClockTicker.Ready(user) || CaelumCooperativeTime.Living(user))return false;
            found=true;
        }
        return found;
    }
    static bool CanPay(CaelumPlayer user,bool exceptional)
    {
        if(!CaelumWorldClockTicker.Ready(user) || level.MapName=="MAP01")return false;
        if(exceptional ? !AllDead() : !CaelumCooperativeTime.Living(user))return false;
        let visit=CaelumFoolJourney.View(user);if(visit!=null && visit.Active)return false;
        let record=user.GetPersistentCharacterState(false);
        return record!=null && CaelumTarotService.HasTarotCard(record,CaelumConstants.TAROT_THE_FOOL)
            && record.TarotCooldownTics==0 && record.TarotEffectTics==0
            && user.CurrentAnima>=CaelumConstants.TAROT_ACTIVATION_ANIMA;
    }
    static bool Valid(CaelumCooperativeTravel vote)
    {
        let user=CaelumPlayer(vote.Owner);if(!CaelumPlayerAuthority.CanMutate(user))return false;
        if(vote.Kind==CaelumCooperativeTravel.LIMBO)
        {
            if(!CanPay(user,vote.ExceptionalFool))return false;
            let record=user.GetPersistentCharacterState(false);
            for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
                if(vote.TarotSelection[card] && !CaelumTarotService.HasTarotCard(record,card))return false;
            return (user.Pos-vote.OriginPosition).Length()<=64;
        }
        let visit=CaelumFoolJourney.View(user);
        return level.MapName=="MAP01" && visit!=null && visit.Active
            && visit.OriginMap==vote.Destination && vote.FoolSpeaker!=null
            && !vote.FoolSpeaker.bDestroyed
            && user.Distance2D(vote.FoolSpeaker)<=CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            && Abs(user.Pos.Z-vote.FoolSpeaker.Pos.Z)<=48 && user.CheckSight(vote.FoolSpeaker);
    }
    static bool Propose(CaelumPlayer user,bool exceptional=false)
    {
        if(!CanPay(user,exceptional))
        {CaelumTarotService.Feedback(user,"CA_TAROT_POWER_CONTEXT");return false;}
        let vote=CaelumCooperativeTravel.Draft(user,exceptional,true);if(vote==null)return false;
        vote.Kind=CaelumCooperativeTravel.LIMBO;vote.Destination="MAP01";vote.Entry=0;
        vote.ExceptionalFool=exceptional;vote.FoolSpeaker=null;
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
            vote.TarotSelection[card]=exceptional?card==CaelumConstants.TAROT_THE_FOOL:record.TarotSelected[card];
        if(!vote.Publish())return false;
        if(!multiplayer)vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial);
        return true;
    }
    static bool ProposeReturn(CaelumPlayer user,CaelumPalomo speaker)
    {
        let visit=CaelumFoolJourney.View(user);
        if(visit==null || !visit.Active || level.MapName!="MAP01" || speaker==null
            || !CaelumUseGeometry.AimedAt(user,speaker))return false;
        let vote=CaelumCooperativeTravel.Draft(user,true,true);if(vote==null)return false;
        vote.Kind=CaelumCooperativeTravel.LIMBO_RETURN;vote.Destination=visit.OriginMap;
        vote.Entry=0;vote.FoolSpeaker=speaker;
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            let other=CaelumFoolJourney.View(vote.Members[i]);
            if(other==null || !other.Active || other.OriginMap!=vote.Destination)return false;
        }
        if(!vote.Publish())return false;
        if(!multiplayer)vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial);
        return true;
    }
    static bool Commit(CaelumCooperativeTravel vote)
    {
        if(!Valid(vote))return false;
        // Preparar todos los registros antes del pago único del activador.
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null && CaelumFoolJourney.Get(vote.Members[i])==null)return false;
        if(vote.Kind==CaelumCooperativeTravel.LIMBO)
        {
            let user=CaelumPlayer(vote.Owner);let record=user.GetPersistentCharacterState(false);
            user.CurrentAnima-=CaelumConstants.TAROT_ACTIVATION_ANIMA;
            record.TarotCooldownTics=CaelumConstants.TAROT_COOLDOWN_SECONDS*TICRATE;
            bool minor=false;
            for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
            {
                record.TarotActive[card]=vote.TarotSelection[card] && card!=CaelumConstants.TAROT_THE_FOOL;
                minor=minor || record.TarotActive[card];
            }
            record.TarotEffectTics=minor?CaelumConstants.TAROT_EFFECT_SECONDS*TICRATE:0;
            if(user.health>0)user.ApplyCharacterProfile();
            user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
        }
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            let user=vote.Members[i];let visit=CaelumFoolJourney.Get(user);
            visit.Revision=1;visit.Returning=vote.Kind==CaelumCooperativeTravel.LIMBO_RETURN;
            if(!visit.Returning)
            {visit.Active=true;visit.OriginMap=level.MapName;visit.OriginPosition=user.Pos;visit.OriginAngle=user.Angle;}
            CaelumTransportTrip.CloseActivities(user);user.PersistCharacterState();
        }
        return true;
    }
}
