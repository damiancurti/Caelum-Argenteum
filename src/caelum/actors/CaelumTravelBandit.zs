// Perfil humano ya existente; sin identidad narrativa, sueldo ni vivienda.
// Cada arma y cada cartucho son inventario nativo, no un premio fabricado.
class CaelumTravelBandit : CaelumPortDefender
{
    bool BanditInitialized;
    CaelumWeaponPickup Gear;
    virtual int BanditWeapon(){return CaelumConstants.WEAPON_TYPE_MACHETE;}
    override bool Used(Actor user){return false;}
    override bool CarbineTarget(Actor victim)
    {return victim!=null && victim!=self && (!(victim is 'CaelumTravelBandit') || victim.bFriendly!=bFriendly);}
    override double GetAttackCarriedWeight(){return CaelumTheftTransfer.Carried(self);}

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();if(BanditInitialized)return;BanditInitialized=true;
        Shield=null;ClearCombatArmorToBaseClothing();RecalculateCombatStatistics();
        int kind=BanditWeapon();
        let model=new('CaelumWeaponModel');model.InitializeDefaults();
        model.WeaponType=kind;model.Tier=CaelumPortData.EQUIPMENT_TIER;
        model.Size=CaelumConstants.EQUIPMENT_SIZE_M;model.Equipped=true;
        model.Durability=model.GetMaximumDurability();
        if(kind==CaelumConstants.WEAPON_TYPE_CARBINE)
        {
            Sword=null;Carbine=new('CaelumCityCarbine');Carbine.Initialize(self);Carbine.Weapon=model;Carbine.FiniteReserve=true;
            let rounds=Inventory(Spawn('CaelumCarbineAmmo',Pos,NO_REPLACE));
            if(rounds!=null){rounds.Amount=CaelumTravelIncidentData.CARTRIDGES;rounds.AttachToOwner(self);}
            Carbine.Magazine=Carbine.LoadCount();
        }
        else
        {Sword=model;MeleeRange=CaelumWeaponCatalogue.GetPrimaryRange(CaelumConstants.CATALOGUE_WEAPON_MACHETE);}
        Gear=CaelumWeaponPickup(Spawn('CaelumWeaponPickup',Pos,NO_REPLACE));
        if(Gear!=null)
        {
            Gear.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Gear.ItemType=kind;
            Gear.Tier=model.Tier;Gear.EquipmentSize=model.Size;Gear.Durability=model.Durability;
            Gear.UnitWeight=model.GetWeightFor(kind,model.Tier,model.Size);
            Gear.PickupDataInitialized=true;Gear.AcquisitionResolved=true;
            Gear.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
            Gear.Equipped=true;Gear.InMagicBox=false;
            model.ContaminationState=new('CaelumContaminationState');Gear.ContaminationState=model.ContaminationState;
            Gear.AttachToOwner(self);
        }
        CaelumTheftWorld.Register(self);
    }
    action void A_TravelChase()
    {
        let body=CaelumTravelBandit(self);if(body==null)return;
        if(body.PulseResourceRecovery())return;
        if(body.Carbine!=null && body.Carbine.Attack(body,body.target))return;
        body.A_CaelumBudgetedChase();
    }
    action void A_TravelMachete()
    {
        let body=CaelumTravelBandit(self);
        if(body==null || body.Sword==null || body.Sword.Durability<=0 || !body.WithinAttackRange(false))return;
        if(!body.SpendPhysicalAttackAir(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_MACHETE),
            CaelumThermalData.WeaponWork(CaelumConstants.WEAPON_TYPE_MACHETE)))return;
        int damage=body.PrepareActorOutgoingDamage(CaelumWeaponCatalogue.GetPrimaryDamage(CaelumConstants.CATALOGUE_WEAPON_MACHETE)
            *body.CalculateActorType1Percent(body.CombatStrength)/100.0,false,true);
        if(damage<=0 || !body.WeaponMeleeAimHits(body.Sword)){body.PendingCombatCriticalDelivery=false;return;}
        int before=body.target.health;body.DeliverContactMelee(damage,"weapons/swordhit");
        if(body.target.health<before)
        {
            double wear=before-body.target.health;
            int loss=int(wear/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
            double remainder=wear-loss*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
            if(Random[CaelumWeaponDurability](0,999999)/10000.0<remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT)loss++;
            body.Sword.Durability=Max(0,body.Sword.Durability-loss);
            body.ApplyActorAttackPush(body.target,body.AngleTo(body.target),body.CombatPhysicalPushMultiplier);
        }
        body.PendingCombatCriticalDelivery=false;
    }
    override void Die(Actor source,Actor inflictor,int dmgflags,Name mod)
    {
        Super.Die(source,inflictor,dmgflags,mod);
        if(health>0 || !bKilled)return;
        let model=Carbine!=null?Carbine.Weapon:Sword;
        if(Gear!=null && Gear.Owner==self && model!=null)
        {Gear.Durability=model.Durability;Gear.ContaminationState=model.ContaminationState;Gear.Equipped=false;}
        // CreateTossable retira la cantidad real y conserva sus lotes/estado.
        // Una segunda llamada no encuentra esas pertenencias en el inventario.
        Inventory item=Inv;
        while(item!=null)
        {
            Inventory next=item.Inv;
            if(item.Amount>0 && CaelumInventoryService.GetFormalInventoryEntryKind(null,item)>=0)
            {
                let drop=item.CreateTossable(item.Amount);
                if(drop!=null){drop.SetOrigin(Pos,false);drop.TossItem();}
            }
            item=next;
        }
        Gear=null;Sword=null;
        if(Carbine!=null){Carbine.Select(false);Carbine.Weapon=null;}
    }
    Default {Tag "$CA_TRAVEL_BANDIT";-FRIENDLY Species "CaelumTravelBandit";}
    States
    {
    Spawn: DOID A 10 A_CaelumBudgetedLook;Loop;
    See: DOWK AB 4 A_TravelChase;Loop;
    Melee:
    AbsentMeleePrepare:
        DOMI K 7 A_CaelumBeginResourceAttack(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_MACHETE),CaelumConstants.WEAPON_TYPE_MACHETE,false,CaelumAttackRules.SWING_IMPACT);
    AbsentMeleeRelease: DOMI L 0 A_TravelMachete;
    AbsentMeleeRecovery: DOMI Q 7 A_CaelumWeaponRecovery;Goto See;
    }
}
class CaelumTravelCarbineBandit : CaelumTravelBandit
{
    override int BanditWeapon(){return CaelumConstants.WEAPON_TYPE_CARBINE;}
}

// Registro local del encuentro: el hub conserva exactamente estos cuerpos,
// su inventario, bajas y botin, incluso si el viajero huye y vuelve despues.
class CaelumTravelAmbush : Actor
{
    int Route,Contract,Encounter,Cursor;
    double Trigger;
    Array<CaelumTravelBandit> Bandits;
    static void Enter(CaelumPlayer user,CaelumTransportBooking booking)
    {
        let events=CaelumTravelIncidents.Get(booking);
        if(events==null || !events.AmbushPending || !CaelumTransportSceneData.IsRural(level.MapName))return;
        let search=ThinkerIterator.Create('CaelumTravelAmbush');CaelumTravelAmbush group;
        while((group=CaelumTravelAmbush(search.Next()))!=null)
            if(group.Route==booking.Ticket.Route && group.Contract==booking.Sequence && group.Encounter==events.EncounterSequence && group.Trigger==events.AmbushAt)break;
        if(group==null)
        {
            group=CaelumTravelAmbush(Spawn('CaelumTravelAmbush',(0,0,0),NO_REPLACE));if(group==null)return;
            group.Route=booking.Ticket.Route;group.Contract=booking.Sequence;group.Encounter=events.EncounterSequence;group.Trigger=events.AmbushAt;
        }
        group.Populate(user);events.AmbushPending=false;events.AmbushMap=level.MapName;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_TRAVEL_AMBUSH",false));
    }
    void Populate(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || Cursor>=CaelumTravelIncidentData.BANDITS)return;
        let probe=CaelumRestPlacementProbe(Spawn('CaelumRestPlacementProbe',(0,0,0),NO_REPLACE));if(probe==null)return;
        probe.A_SetSize(GetDefaultByType('CaelumPlayer').Radius,CaelumPortData.DEFENDER_HEIGHT);
        for(int i=0;i<6 && Cursor<CaelumTravelIncidentData.BANDITS;i++)
        {
            vector3 point=CaelumTravelIncidentData.BanditPoint(i);FCheckPosition fit;probe.SetOrigin(point,false);
            if(!probe.CheckPosition(point.XY,false,fit) || fit.floorz!=point.Z || fit.ceilingz-point.Z<probe.Height)continue;
            class<CaelumTravelBandit> kind=Cursor==2?'CaelumTravelCarbineBandit':'CaelumTravelBandit';
            let body=CaelumTravelBandit(Spawn(kind,point,NO_REPLACE));if(body==null)continue;
            body.target=user;body.A_CaelumFacePerceivedTarget();body.SetState(body.SeeState);
            Bandits.Push(body);Cursor++;
        }
        probe.Destroy();
    }
    override void Tick()
    {
        Super.Tick();if(Cursor>=CaelumTravelIncidentData.BANDITS || level.time%TICRATE!=0)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i]){Populate(CaelumPlayer(players[i].mo));break;}
    }
    Default {+NOINTERACTION +NOBLOCKMAP +NOSECTOR}
    States {Spawn:TNT1 A -1;Stop;}
}
