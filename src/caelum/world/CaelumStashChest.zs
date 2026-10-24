// Las tres mallas OBJ son estáticas. Un actor visual separado permite cambiar
// de archivo sin superponerlos como adjuntos dentro de un mismo MODELDEF.
class CaelumStashChestVisual : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null)
        {
            Destroy();
            return;
        }

        SetOrigin(master.Pos, false);
        Angle = master.Angle;
    }

    Default
    {
        Radius 0;
        Height 0;
        +NOGRAVITY
        +NOBLOCKMAP
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CAHC A -1;
        Stop;
    }
}

class CaelumStashChestClosedVisual : CaelumStashChestVisual {}
class CaelumStashChestOpenVisual : CaelumStashChestVisual
{
    States
    {
    Spawn:
        CAHC B -1;
        Stop;
    }
}

class CaelumStashChestLockedVisual : CaelumStashChestVisual
{
    States
    {
    Spawn:
        CAHC C -1;
        Stop;
    }
}

// #381: el Actor.Inv es el único dueño de los contenidos físicos del cofre.
class CaelumStashChest : Actor
{
    bool ChestOpen;
    bool ChestUnlocked;
    bool UseLatched;
    Actor LastChestUser;
    CaelumStashChestVisual ChestVisual;
    int StorageRevision, StorageTier;
    CaelumChestCargo Cargo;
    int LawfulRevision, TheftOpenings;
    CaelumLawfulIdentity LawfulOwner;
    CaelumLockItem InstalledPadlock;
    bool PadlockReleased;

    void EnsureLawfulAccess()
    {
        if(LawfulRevision>=CaelumLockRules.REVISION)return;
        // Los cofres anteriores siguen públicos/sin clasificar; no se adjudican.
        LawfulRevision=CaelumLockRules.REVISION;
    }
    void GrantLawfulTitle(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        EnsureLawfulAccess();LawfulOwner=CaelumLockRules.Character(user,true);
    }
    bool IsLawfulOwner(CaelumPlayer user)
    {return CaelumLockRules.SameTitle(LawfulOwner,CaelumLockRules.Character(user));}
    bool TogglePadlock(CaelumPlayer user)
    {
        if(!CanStore(user) || !ChestOpen || !IsLawfulOwner(user) || GetChestLockNumber()>0)return false;
        if(InstalledPadlock!=null)
        {
            user.RefreshCarriedInventorySummary();
            if(Cargo==null && !user.CanAddWeightToPersonalInventory(InstalledPadlock.GetUnitWeight()))return false;
            let item=InstalledPadlock;InstalledPadlock=null;RemoveInventory(item);item.AttachToOwner(user);
            bShootable=false;
        }
        else
        {
            CaelumLockItem selected=null;
            for(Inventory item=user.Inv;item!=null;item=item.Inv)
            {
                let candidate=CaelumLockItem(item);
                if(candidate!=null && candidate.LockItemType==StorageTier && !candidate.InMagicBox
                    && candidate.PairIdentity!=null && candidate.LimboQuestUnits==0){selected=candidate;break;}
            }
            if(selected==null)return false;
            user.RemoveInventory(selected);selected.AttachToOwner(self);InstalledPadlock=selected;
            bShootable=true;
        }
        let session=CaelumContainerSession.Get(user);if(session!=null)session.Close();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();RefreshChestVisual();
        return true;
    }
    void CommitTheft(CaelumPlayer user)
    {
        if(LawfulOwner==null || IsLawfulOwner(user))return;
        TheftOpenings++;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_LOCK_THEFT",false));
        CaelumTheftWitnesses.Alert(user);
    }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double hitAngle)
    {
        let user=CaelumPlayer(source);let npc=CaelumCombatActor(source);
        bool blunt=(user!=null && user.ThermalBluntDelivery) || (npc!=null && npc.ThermalBluntDelivery);
        if(damage<=0 || !blunt || InstalledPadlock==null || PadlockReleased || GetChestLockNumber()>0)return 0;
        let padlock=InstalledPadlock;InstalledPadlock=null;padlock.Destroy();
        bShootable=false;
        ChestOpen=true;RefreshChestVisual();
        if(user!=null)CommitTheft(user);
        return 1;
    }

    void EnsureStorage()
    {
        EnsureLawfulAccess();
        if(StorageRevision>=CaelumContainerRules.REVISION)return;
        StorageTier=args[4]>0 ? Clamp(args[4]-1,0,2) : CaelumContainerRules.MEDIUM;
        StorageRevision=CaelumContainerRules.REVISION;
        // El cofre anterior sigue siendo mediano; no se cambia su geometría.
        if(StorageTier!=CaelumContainerRules.MEDIUM)ApplyStorageSize();
        Mass=CaelumContainerRules.Capacity(StorageTier)*CaelumContainerRules.EMPTY_WEIGHT_FRACTION;
    }
    void ApplyStorageSize()
    {
        double factor=CaelumContainerRules.ScaleFor(StorageTier);
        let defaults=GetDefaultByType("CaelumStashChest");
        A_SetSize(defaults.Radius*factor,defaults.Height*factor,false);
        Mass=CaelumContainerRules.Capacity(StorageTier)*CaelumContainerRules.EMPTY_WEIGHT_FRACTION;
        RefreshChestVisual();
    }
    virtual bool IsStorageItem(Inventory item)
    {
        return item!=null && item!=InstalledPadlock && item.Owner==self && item.Amount>0;
    }
    virtual int StorageSlots()
    {
        int count=0;
        for(Inventory item=Inv;item!=null;item=item.Inv)
            if(IsStorageItem(item))count++;
        return count;
    }
    virtual double StorageWeight(CaelumPlayer user)
    {
        double weight=0;
        for(Inventory item=Inv;item!=null;item=item.Inv)
            if(IsStorageItem(item))weight+=CaelumContainerRules.Weight(user,item);
        return weight;
    }
    double TotalStorageWeight(CaelumPlayer user)
    {
        return CaelumContainerRules.Capacity(StorageTier)*CaelumContainerRules.EMPTY_WEIGHT_FRACTION
            +StorageWeight(user)+(InstalledPadlock!=null ? InstalledPadlock.GetUnitWeight() : 0.0);
    }
    bool CanReachStorage(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.CreationWizardOpen)return false;
        if(Cargo!=null)return Cargo.Owner==user;
        return user.Distance3D(self)<=user.UseRange+Radius && user.CheckSight(self);
    }
    virtual bool CanStore(CaelumPlayer user)
    {
        return CanReachStorage(user) && !IsChestLocked();
    }
    void HideCarriedStorage()
    {
        bSolid=false;bNoGravity=true;bInvisible=true;
        A_ChangeLinkFlags(1,1);
        if(ChestVisual!=null){ChestVisual.Destroy();ChestVisual=null;}
    }
    void RestoreWorldStorage(vector3 position)
    {
        bNoGravity=false;bInvisible=false;bSolid=true;
        A_ChangeLinkFlags(0,0);SetOrigin(position,false);
        RefreshChestVisual();
    }
    bool TryPlaceStorage(CaelumPlayer user)
    {
        if(Cargo==null || Cargo.Owner!=user)return false;
        vector3 original=Pos;
        double offset=user.Radius+Radius+1.0;
        vector3 destination=user.Pos+(Cos(user.Angle)*offset,Sin(user.Angle)*offset,0);
        if(!CaelumPlacementGeometry.Fits(user,destination,Radius,Height,self))return false;
        bSolid=true;A_ChangeLinkFlags(0,0);SetOrigin(destination,false);
        if(!TestMobjLocation() || !user.CheckSight(self,SF_IGNOREVISIBILITY))
        {SetOrigin(original,false);HideCarriedStorage();return false;}
        let token=Cargo;Cargo=null;token.Chest=null;token.Destroy();
        RestoreWorldStorage(destination);
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
        return true;
    }
    override void OnDestroy()
    {
        InstalledPadlock=null;
        if(Cargo!=null)
        {
            let token=Cargo;Cargo=null;token.Chest=null;token.Destroy();
        }
        Inventory item=Inv;
        while(item!=null)
        {
            Inventory next=item.Inv;
            if(IsStorageItem(item))
            {
                let equipment=CaelumEquipmentItem(item);
                bool unclaimed=equipment!=null && !equipment.AcquisitionResolved;
                CaelumContainerRules.SetBoxed(item,false);
                item.BecomePickup();item.SetOrigin(Pos,false);
                if(unclaimed)item.bDropped=false;
            }
            item=next;
        }
        if(ChestVisual!=null){ChestVisual.Destroy();ChestVisual=null;}
        Super.OnDestroy();
    }

    virtual int GetChestLockNumber()
    {
        return 0;
    }

    bool IsChestLocked()
    {
        return (GetChestLockNumber() > 0 && !ChestUnlocked) || (InstalledPadlock!=null && !PadlockReleased);
    }

    void RefreshChestVisual()
    {
        if (ChestVisual != null)
        {
            ChestVisual.Destroy();
            ChestVisual = null;
        }
        if(Cargo!=null)return;

        String visualClass = "CaelumStashChestClosedVisual";
        if (IsChestLocked())
        {
            visualClass = "CaelumStashChestLockedVisual";
        }
        else if (ChestOpen)
        {
            visualClass = "CaelumStashChestOpenVisual";
        }

        ChestVisual = CaelumStashChestVisual(Spawn(
            visualClass,
            Pos,
            NO_REPLACE
        ));
        if (ChestVisual != null)
        {
            ChestVisual.master = self;
            ChestVisual.Angle = Angle;
            double factor=CaelumContainerRules.ScaleFor(StorageTier);
            ChestVisual.Scale=(factor,factor);
        }
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        EnsureStorage();
        RefreshChestVisual();
    }

    override void Tick()
    {
        Super.Tick();
        EnsureStorage();
        if(Cargo!=null)return;

        // Si una partida antigua o una transición no conserva el ayudante
        // visual, se reconstruye desde el estado persistente del alijo.
        if (ChestVisual == null)
        {
            RefreshChestVisual();
        }

        // Mantener Use no puede abrir y cerrar el alijo varias veces. La
        // siguiente interacción sólo se habilita después de soltar la tecla.
        if (UseLatched)
        {
            PlayerPawn userPawn = PlayerPawn(LastChestUser);
            if (userPawn == null
                || userPawn.player == null
                || (userPawn.player.cmd.buttons & BT_USE) == 0)
            {
                UseLatched = false;
                LastChestUser = null;
            }
        }
    }

    override bool Used(Actor user)
    {
        let playerUser=CaelumPlayer(user);
        if(!CanReachStorage(playerUser) || !CaelumUseGeometry.AimedAt(playerUser,self))return false;
        if (UseLatched && LastChestUser == user)
        {
            return true;
        }
        UseLatched = true;
        LastChestUser = user;
        if((playerUser.player.cmd.buttons & BT_SPEED)!=0)
        {
            CaelumInventoryService.CarryStorageChest(playerUser,self);
            return true;
        }

        if (GetChestLockNumber()>0 && !ChestUnlocked)
        {
            int lockNumber = GetChestLockNumber();
            if (user == null || !user.CheckKeys(lockNumber, false))
            {
                A_StartSound("caelum/world/door_locked", CHAN_BODY);
                return true;
            }

            // CheckKeys sólo comprueba posesión: la llave de plata permanece
            // en el inventario y el estado desbloqueado se guarda con el actor.
            ChestUnlocked = true;
        }

        CaelumContainerSession.Open(playerUser,self);
        A_StartSound("caelum/world/door_open", CHAN_BODY);
        return true;
    }

    Default
    {
        Tag "$CA_STASH_CHEST";
        Radius 32;
        Height 60;
        Mass 1000;
        +SOLID
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumLockedStashChest : CaelumStashChest
{
    override int GetChestLockNumber()
    {
        return CaelumConstants.LOCK_CAELUM_SILVER_STASH;
    }
}
