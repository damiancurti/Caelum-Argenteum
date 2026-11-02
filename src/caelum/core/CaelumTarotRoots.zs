// Cada lanzador conserva una creación; varios pueden sujetar el mismo cuerpo.
class CaelumTarotPlantState : Inventory
{
    CaelumTarotRoots Roots;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotRooted : Inventory
{
    int Revision;
    Array<CaelumTarotRoots> Sources;
    static clearscope CaelumTarotRooted View(Actor body)
    {
        let user=CaelumPlayer(body);if(user!=null)return user.TarotRoots;
        let npc=CaelumCombatActor(body);return npc!=null?npc.TarotRoots:null;
    }
    static CaelumTarotRooted Get(Actor body)
    {
        let status=View(body);if(status!=null)return status;
        status=CaelumTarotRooted(body.GiveInventoryType('CaelumTarotRooted'));
        status.Revision=CaelumMajorArcanaData.ROOTS_REVISION;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null)user.TarotRoots=status;else if(npc!=null)npc.TarotRoots=status;
        return status;
    }
    static clearscope bool Active(Actor body)
    {
        let status=View(body);if(status==null || body.health<=0)return false;
        // A lo sumo una raíz por jugador: sin búsquedas de actores ni inventarios.
        for(int i=0;i<status.Sources.Size();i++)
        {let root=status.Sources[i];if(root!=null && !root.bDestroyed && root.RemainingTics>0)return true;}
        return false;
    }
    void Remove(CaelumTarotRoots root)
    {for(int i=Sources.Size()-1;i>=0;i--)if(Sources[i]==root || Sources[i]==null)Sources.Delete(i);}
    override void OnDestroy()
    {
        let user=CaelumPlayer(Owner);let npc=CaelumCombatActor(Owner);
        if(user!=null && user.TarotRoots==self)user.TarotRoots=null;
        if(npc!=null && npc.TarotRoots==self)npc.TarotRoots=null;
        for(int i=Sources.Size()-1;i>=0;i--)if(Sources[i]!=null)Sources[i].Destroy();
        Super.OnDestroy();
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotRoots : Actor
{
    int Revision,RemainingTics,PulseTics;
    double DamagePerSecond,DamageRemainder;
    CaelumPlayer Caster;
    Actor Victim;
    CaelumTarotPlantState Ledger;
    CaelumTarotRooted Binding;

    static bool Place(CaelumPlayer user,Actor victim,int duration,CaelumTarotGroundAim snapshot)
    {
        if(snapshot==null || duration<=0 || !CaelumMajorTargets.Visible(user,victim)
            || victim.health<=0 || !victim.bShootable || victim.bNoInteraction || victim.bDormant
            || (!(victim is 'CaelumPlayer') && !(victim is 'CaelumCombatActor')))return false;
        let holder=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState'));
        if(holder==null)holder=CaelumTarotPlantState(user.GiveInventoryType('CaelumTarotPlantState'));
        let root=CaelumTarotRoots(Actor.Spawn('CaelumTarotRoots',victim.Pos,NO_REPLACE));
        root.Revision=CaelumMajorArcanaData.ROOTS_REVISION;
        root.Caster=user;root.Victim=victim;root.Ledger=holder;
        root.RemainingTics=duration;
        root.DamagePerSecond=Max(0.0,snapshot.Damage)/CaelumConstants.TAROT_EFFECT_SECONDS;
        root.Binding=CaelumTarotRooted.Get(victim);root.Binding.Sources.Push(root);
        root.UpdateAppearance();
        if(holder.Roots!=null)holder.Roots.Destroy();holder.Roots=root;
        CaelumMajorWorldEvents.TimeSourcesChanged();
        victim.Vel.X=0;victim.Vel.Y=0;
        let player=CaelumPlayer(victim);
        if(player!=null)CaelumMovementImpulse.Clear(player);
        return true;
    }
    override void Tick()
    {Super.Tick();AdvanceEffect();}
    void AdvanceEffect()
    {
        let player=CaelumPlayer(Victim);
        if((Caster!=null && Caster.SessionIdentityPending) || (player!=null && player.SessionIdentityPending))return;
        if(Caster==null || Victim==null || Victim.bDestroyed || Victim.health<=0 || RemainingTics<=0)
        {Destroy();return;}
        UpdateAppearance();
        RemainingTics--;PulseTics++;DamageRemainder+=DamagePerSecond/TICRATE;
        if(PulseTics>=TICRATE || RemainingTics==0)
        {
            PulseTics=0;int damage=int(DamageRemainder+1e-8);DamageRemainder-=damage;
            if(damage>0)Victim.DamageMobj(self,Caster,damage,'CaelumTarotPiercing',0,AngleTo(Victim));
        }
        if(RemainingTics<=0)Destroy();
    }
    override void OnDestroy()
    {
        if(Ledger!=null && Ledger.Roots==self)Ledger.Roots=null;
        if(Binding!=null)Binding.Remove(self);
        Super.OnDestroy();
    }
    void UpdateAppearance()
    {
        // La geometría normalizada nace del suelo y rodea el cuerpo real.
        SetOrigin((Victim.Pos.X,Victim.Pos.Y,Victim.FloorZ),false);
        Scale=(Victim.Radius,Max(1.0,Victim.Pos.Z-Victim.FloorZ+Victim.Height));
    }
    Default {+NOINTERACTION +NOGRAVITY +NODAMAGETHRUST}
    States {Spawn:CAHC A -1;Stop;}
}
