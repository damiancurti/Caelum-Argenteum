// Los restos fraccionarios pertenecen al receptor, no al lanzador ni al aura.
class CaelumLoversRemainder : Inventory
{
    int Revision;
    double DamageFraction,HealingFraction;
    static int Portion(Actor body,double portion,bool healing)
    {
        let item=CaelumLoversRemainder(body.FindInventory('CaelumLoversRemainder'));
        if(item==null)item=CaelumLoversRemainder(body.GiveInventoryType('CaelumLoversRemainder'));
        if(item==null)return 0;
        item.Revision=CaelumMajorArcanaData.LOVERS_REVISION;
        double pending=portion+(healing?item.HealingFraction:item.DamageFraction);
        int whole=int(pending+1e-8);double remainder=Max(0.0,pending-whole);
        if(healing)item.HealingFraction=remainder;else item.DamageFraction=remainder;
        return whole;
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CaelumLoversRecipients : Object
{
    Array<Actor> Bodies;
    void Add(Actor body)
    {for(int i=0;i<Bodies.Size();i++)if(Bodies[i]==body)return;Bodies.Push(body);}
}
class CaelumTarotLovers : Object play
{
    static bool Living(Actor body)
    {
        if(body==null || body.bDestroyed || body.health<=0 || body.bNoInteraction)return false;
        let user=CaelumPlayer(body);
        return user==null || (user.player!=null && user.player.mo==user
            && !user.SessionIdentityPending && !user.ProfileDeparted);
    }
    static bool AlliedPlayers(CaelumPlayer first,CaelumPlayer second)
    {
        if(first==null || second==null)return false;
        if(first==second)return true;
        int relation=CaelumStandaloneMatch.Relation(first,second);if(relation>=0)return relation==0;
        let entry=CaelumArenaState.View(first),other=CaelumArenaState.View(second);
        let match=entry!=null?entry.MatchState:null;
        if(match!=null && match.Status==CaelumArenaMatch.FIGHTING)
        {
            int a=first.PlayerNumber(),b=second.PlayerNumber();
            return other!=null && other.MatchState==match && a>=0 && b>=0
                && match.Mode==1 && match.Teams[a]==match.Teams[b]
                && (match.Withdrawn&((1<<a)|(1<<b)))==0;
        }
        return !deathmatch || first.IsTeammate(second);
    }
    static bool Member(CaelumPlayer caster,Actor body)
    {
        let user=CaelumPlayer(body);if(user!=null)return AlliedPlayers(caster,user);
        let npc=CaelumCombatActor(body);let bond=npc!=null?npc.Companion:null;
        return bond!=null && bond.Body==body && bond.Enlisted && !bond.SlotReleased
            && !bond.Parked && AlliedPlayers(caster,bond.Leader());
    }
    static bool Reached(CaelumPlayer caster,Actor body,double radius)
    {
        return Living(body) && Member(caster,body) && (body.Pos-caster.Pos).Length()<=radius
            && (body==caster || caster.CheckSight(body,SF_IGNOREVISIBILITY));
    }
    static CaelumLoversRecipients Recipients(Actor original,bool healing)
    {
        if(!Living(original))return null;
        CaelumLoversRecipients result;
        // Sólo ocho jugadores y sus registros acotados; nunca todos los actores.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let caster=CaelumPlayer(players[i].mo);
            if(!Living(caster) || caster.DerivedStats==null)continue;
            let record=CaelumPersistentCharacterState(caster.FindInventory('CaelumPersistentCharacterState'));
            if(!CaelumTarotService.IsActive(record,6) && (healing || !CaelumTarotLoadout.Passive(record,6)))continue;
            double radius=CaelumMajorArcanaData.AREA_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER
                *Max(0.0,caster.DerivedStats.AbilityRangePercent)/100.0;
            if(!Reached(caster,original,radius))continue;
            if(result==null){result=new('CaelumLoversRecipients');result.Add(original);}
            for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
            {
                let member=CaelumPlayer(players[p].mo);
                if(member==null || !AlliedPlayers(caster,member))continue;
                if(Reached(caster,member,radius))result.Add(member);
                let party=CaelumCompanionParty.Get(member);if(party==null)continue;
                for(int n=0;n<party.Roster.Size();n++)
                {let bond=party.Roster[n];if(bond!=null && Reached(caster,bond.Body,radius))result.Add(bond.Body);}
            }
        }
        return result;
    }
    static bool Immune(Actor body,int damage)
    {
        if(!Living(body) || body.bNoDamage || body.bDormant)return true;
        let user=CaelumPlayer(body);
        if(user!=null && (user.CreationWizardOpen && !user.CharacterCreationComplete))return true;
        if(user!=null && (user.player.cheats&CF_GODMODE2)!=0)return true;
        return damage<CaelumCrushingDamage.NATIVE_TELEFRAG_THRESHOLD
            && (body.bInvulnerable || (user!=null && (user.player.cheats&CF_GODMODE)!=0));
    }
    static int Damage(Actor original,Actor inflictor,Actor source,int damage,Name mod)
    {
        if(damage<=0 || Immune(original,damage))return damage;
        let recipients=Recipients(original,false);
        if(recipients==null || recipients.Bodies.Size()<=1)return damage;
        double portion=double(damage)/recipients.Bodies.Size();int retained=0;
        for(int i=0;i<recipients.Bodies.Size();i++)
        {
            Actor body=recipients.Bodies[i];
            if(body!=original && Immune(body,int(Ceil(portion))))continue;
            int share=CaelumLoversRemainder.Portion(body,portion,false);
            if(body==original){retained=share;continue;}
            if(share<=0 || Immune(body,share))continue;
            let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
            if(user!=null)user.ApplyLoversDamage(inflictor,source,share,mod);
            else if(npc!=null)npc.ApplyLoversDamage(inflictor,source,share,mod);
        }
        return retained;
    }
    static int MaximumHealth(Actor body)
    {
        if(body==null)return 0;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        return user!=null?user.CaelumMaximumHealth:npc!=null?npc.CombatMaximumHealth:body.GetMaxHealth();
    }
    static void HealDirect(Actor body,int amount)
    {
        if(!Living(body))return;
        int maximum=MaximumHealth(body);
        if(body.health>=maximum)
        {let rest=CaelumLoversRemainder(body.FindInventory('CaelumLoversRemainder'));if(rest!=null)rest.HealingFraction=0;return;}
        if(amount<=0)return;
        body.health=Min(maximum,body.health+amount);
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null){user.player.health=user.health;user.UpdateHealthStateEffects();}
        else if(npc!=null)npc.UpdateCombatHealthEffects();
        if(body.health>=maximum)
        {let rest=CaelumLoversRemainder(body.FindInventory('CaelumLoversRemainder'));if(rest!=null)rest.HealingFraction=0;}
    }
    static void Heal(Actor original,int amount)
    {
        if(!Living(original) || amount<=0)return;
        // Sólo repartir la Vida que este efecto habría recuperado originalmente.
        amount=Min(amount,Max(0,MaximumHealth(original)-original.health));
        if(amount<=0)return;
        let recipients=Recipients(original,true);
        if(recipients==null || recipients.Bodies.Size()<=1){HealDirect(original,amount);return;}
        double portion=double(amount)/recipients.Bodies.Size();
        for(int i=0;i<recipients.Bodies.Size();i++)
        {
            let body=recipients.Bodies[i];
            HealDirect(body,CaelumLoversRemainder.Portion(body,portion,true));
        }
    }
}
