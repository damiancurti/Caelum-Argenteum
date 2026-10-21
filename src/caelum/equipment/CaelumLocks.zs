// #382: identidades serializadas, independientes del dueño físico y del ItemId.
class CaelumLawfulIdentity : Object { String Token; }
class CaelumLockIdentity : Object { String Token; }

// Consulta espacial sólo al confirmar un robo. Nunca se recorre el mapa por tic.
class CaelumTheftWitnesses : Object play
{
    static bool HasTarget(CaelumCombatActor npc)
    {return npc!=null && npc.health>0 && CaelumPlayerAuthority.CanMutate(npc.TheftTarget)
        && npc.TheftTarget.health>0 && CaelumRedemption.Commander(npc)==null;}
    static bool CanReact(CaelumCombatActor npc)
    {
        if(npc==null || npc.health<=0 || !npc.bShootable || npc.bDormant
            || npc.FindState("See")==null
            || (npc.FindState("Melee")==null && npc.FindState("Missile")==null))return false;
        let resident=CaelumAnchoredResident(npc);
        return resident==null || (!resident.IsProtectedStoryResident()
            && (!resident.IsEscortPrisoner() || !resident.bInvulnerable));
    }
    static void Alert(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        double range=CaelumLockRules.WITNESS_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER;
        let nearby=BlockThingsIterator.Create(user,range);
        while(nearby.Next())
        {
            let npc=CaelumCombatActor(nearby.thing);
            if(!CanReact(npc) || npc.Distance3D(user)>range || !npc.CheckSight(user))continue;
            npc.TheftTarget=user;
            if(CaelumRedemption.Commander(npc)!=null)continue;
            npc.bFriendly=false;npc.Target=user;npc.LastEnemy=user;
            if(npc.ForcedSleepTics<=0 && npc.CombatLucidityPhysicalStunRemaining<=0
                && !npc.ResourceRecoveryActive() && !npc.bInConversation
                && !npc.InStateSequence(npc.CurState,npc.FindState("Melee"))
                && !npc.InStateSequence(npc.CurState,npc.FindState("Missile")))npc.SetState(npc.FindState("See"));
        }
    }
    static bool Pursue(CaelumCombatActor npc)
    {
        if(!HasTarget(npc))return false;
        if(npc.ForcedSleepTics>0 || npc.CombatLucidityPhysicalStunRemaining>0 || npc.bInConversation)return true;
        npc.Target=npc.TheftTarget;npc.LastEnemy=npc.TheftTarget;
        let soldier=CaelumPortDefender(npc);
        if(soldier!=null)
        {
            bool near=npc.Distance2D(npc.Target)<=npc.MeleeRange+npc.Target.Radius;
            if(soldier.Carbine!=null)
            {
                soldier.Carbine.Select(!near);
                if(!near && soldier.Carbine.Attack(soldier,npc.Target))return true;
            }
            npc.ThermalChase("Melee",null);
        }
        else npc.ThermalChase();
        return true;
    }
}

class CaelumLockRules : Object play
{
    const REVISION=1;
    const FIRST_RECIPE=136;
    const RECIPE_COUNT=5;
    const FIRST_ITEM=4;
    const PICKS=6;
    const MASTER=7;
    const WITNESS_METERS=32.0;

    // Un hub reconstruye copias de los grafos de mapa y jugador por separado.
    // Comparar su valor archivado, no el puntero del Object reconstruido.
    static String NewIdentity()
    {
        return String.Format("%08x%08x%08x%08x",
            Random[CaelumLawfulIdentity](0,2147483647),Random[CaelumLawfulIdentity](0,2147483647),
            Random[CaelumLawfulIdentity](0,2147483647),Random[CaelumLawfulIdentity](0,2147483647));
    }
    static bool SameTitle(CaelumLawfulIdentity a,CaelumLawfulIdentity b)
    {return a!=null && b!=null && a.Token!="" && a.Token==b.Token;}
    static bool SamePair(CaelumLockIdentity a,CaelumLockIdentity b)
    {return a!=null && b!=null && a.Token!="" && a.Token==b.Token;}

    static clearscope bool IsRecipe(int recipe)
    {return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+RECIPE_COUNT;}
    static clearscope int RecipeTier(int recipe)
    {return recipe<FIRST_RECIPE+3 ? recipe-FIRST_RECIPE+1 : 1;}
    static clearscope int RecipeItem(int recipe)
    {return recipe<FIRST_RECIPE+3 ? recipe-FIRST_RECIPE : recipe-FIRST_RECIPE+3;}
    static clearscope String NameKey(int item)
    {return String.Format("CA_LOCK_ITEM_%d",Clamp(item,0,MASTER));}
    static clearscope double Weight(int item)
    {
        if(item==PICKS)return 0.1;
        if(item==MASTER)return 0.5;
        return (1.0+2.0*(item%3))*(item>=3 ? 0.1 : 1.0);
    }
    static clearscope double RecipeWeight(int recipe)
    {
        int item=RecipeItem(recipe);
        return Weight(item)*(item<3 ? 1.1 : 1.0);
    }
    static double Value(int item)
    {
        int tier=item<6 ? item%3+1 : item==MASTER ? 3 : 1;
        double markup=tier==3 ? 2.0 : tier==2 ? 1.5 : 1.25;
        return Weight(item)/CaelumConstants.MATERIAL_UNIT_WEIGHT*markup
            *CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_STEEL_INGOT,1);
    }
    static int MissingStation(int recipe,int capabilities)
    {
        int required[4]={CaelumConstants.CRAFTING_STATION_WORKBENCH,
            CaelumConstants.CRAFTING_STATION_FORGE,CaelumConstants.CRAFTING_STATION_ANVIL,
            CaelumConstants.CRAFTING_STATION_MASTER_BENCH};
        int count=RecipeTier(recipe)==3 || RecipeItem(recipe)==MASTER ? 4 : 3;
        for(int i=0;i<count;i++)
            if(!CaelumCraftingRules.NetworkHasStation(capabilities,required[i]))return required[i];
        return CaelumConstants.CRAFTING_STATION_NONE;
    }
    static CaelumLawfulIdentity Character(CaelumPlayer user,bool create=false)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let record=user.GetPersistentCharacterState(create);
        if(record==null)return null;
        if(record.LawfulIdentity==null && create)
        {record.LawfulIdentity=new("CaelumLawfulIdentity");record.LawfulIdentity.Token=NewIdentity();}
        return record.LawfulIdentity;
    }
    static CaelumLockItem Create(int item,vector3 position,CaelumLockIdentity pair=null)
    {
        let result=CaelumLockItem(Actor.Spawn("CaelumLockItem",position,NO_REPLACE));
        if(result!=null)
        {
            if(pair!=null && pair.Token=="")pair.Token=NewIdentity();
            result.LockItemType=item;result.PairIdentity=pair;
        }
        return result;
    }
    static bool HasAccess(CaelumPlayer user,CaelumLockItem padlock)
    {
        if(padlock==null)return true;
        for(Inventory entry=user.Inv;entry!=null;entry=entry.Inv)
        {
            let tool=CaelumLockItem(entry);
            if(tool==null || tool.InMagicBox || tool.Amount<=0)continue;
            if(tool.LockItemType==PICKS || tool.LockItemType==MASTER)return true;
            if(tool.LockItemType==padlock.LockItemType+3
                && SamePair(tool.PairIdentity,padlock.PairIdentity))return true;
        }
        return false;
    }
    static void Complete(CaelumPlayer user)
    {
        if(!user.CraftingTaskCompleting || !user.CraftingSelectedInfrastructureAvailable
            || !user.ValidateCraftingTaskReservations())return;
        int type=RecipeItem(user.CraftingSelectionRecipe);
        CaelumLockIdentity pair=type<3 ? new("CaelumLockIdentity") : null;
        let product=Create(type,user.Pos,pair);
        if(product==null)return;
        CaelumLockItem key=type<3 ? Create(type+3,user.Pos,pair) : null;
        if(type<3 && key==null){product.Destroy();return;}
        if(!user.ConsumeSelectedWeaponCraftingMaterials())
        {if(key!=null)key.Destroy();product.Destroy();return;}
        product.AttachToOwner(user);
        if(key!=null){key.AttachToOwner(user);CaelumNotifications.Acquired(user,key,1);}
        CaelumNotifications.Acquired(user,product,1);
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_CREATED;
        user.OnNativeInventoryChanged();
    }
}

// Cada candado y cada llave son instancias distintas aunque compartan clase.
class CaelumLockItem : CaelumSpecialInventoryItem
{
    int LockItemType;
    CaelumLockIdentity PairIdentity;
    void ToggleBox(CaelumPlayer user)
    {
        if(Owner!=user || !CaelumPlayerAuthority.CanMutate(user) || !user.MagicBoxOwned || LimboQuestUnits>0)return;
        user.RefreshCarriedInventorySummary();
        if(InMagicBox)
        {if(!user.CanMoveRawWeightFromMagicBoxToPersonal(GetUnitWeight()))return;}
        else if(!user.HasNativeMagicBoxSlotAvailable() || !user.CanAddRawWeightToMagicBox(GetUnitWeight()))return;
        InMagicBox=!InMagicBox;user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
    }
    void DropInstance(CaelumPlayer user)
    {
        if(Owner!=user || !CaelumPlayerAuthority.CanMutate(user) || LimboQuestUnits>0)return;
        let dropped=CaelumLockItem(CreateTossable(1));
        if(dropped==null)return;
        dropped.InMagicBox=false;
        dropped.SetOrigin(user.Pos+(Cos(user.Angle)*48,Sin(user.Angle)*48,8),false);
        dropped.TossItem();user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
    }
    override int GetSpecialCategory(){return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;}
    override int GetSpecialType(){return CaelumLockRules.FIRST_ITEM+LockItemType;}
    override int GetSpecialTier(){return LockItemType<6 ? LockItemType%3+1 : 1;}
    override double GetUnitWeight(){return CaelumLockRules.Weight(LockItemType);}
    override bool HandlePickup(Inventory item)
    {return item is "CaelumLockItem" ? false : Super.HandlePickup(item);}
    void CopyLock(Inventory other)
    {
        let copy=CaelumLockItem(other);
        if(copy!=null && copy!=self){copy.LockItemType=LockItemType;copy.PairIdentity=PairIdentity;}
    }
    override Inventory CreateCopy(Actor other)
    {let copy=Super.CreateCopy(other);CopyLock(copy);return copy;}
    override Inventory CreateTossable(int amount)
    {let copy=Super.CreateTossable(amount);CopyLock(copy);return copy;}
    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_key.png";
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
    }
    States { Spawn: CKEY A -1; Stop; }
}
