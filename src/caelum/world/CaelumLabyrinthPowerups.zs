// #614: registro de 8/16 puntos, actualizado una vez por tic por la partida.
class CaelumLabyrinthPowerups : Object play
{
    int Revision;
    Array<CaelumLabyrinthPowerup> Points;
    void Initialize()
    {
        if(Revision>0)return;Revision=1;
        for(int i=0;i<CaelumPowerupData.PointCount();i++)
        {
            let point=CaelumLabyrinthPowerup(Actor.Spawn('CaelumLabyrinthPowerup',CaelumPowerupData.Point(i),NO_REPLACE));
            if(point!=null){Points.Push(point);point.Refill();}
        }
    }
    void Tick(CaelumStandaloneMatch match)
    {
        for(int i=0;i<Points.Size();i++)
        {let point=Points[i];if(point!=null && point.ReadyAt>0 && level.time>=point.ReadyAt)point.Refill();}
    }
    static clearscope bool Awakened(CaelumEquipmentItem item)
    {
        let match=CaelumStandaloneMatch.View();
        return item!=null && item.MatchAwakened && item.MatchPowerOwner!=null
            && item.Owner==item.MatchPowerOwner && item.MatchPowerOwner.health>0
            && match!=null && match.Started && !match.Finished;
    }
    static bool Compatible(CaelumEquipmentItem item,int kind)
    {
        if(!CaelumAwakening.Eligible(item) || !item.Equipped || item.InMagicBox)return false;
        if(kind==CaelumPowerupData.WEAPONS)return item.EquipmentKind!=CaelumConstants.EQUIPMENT_KIND_ARMOR;
        if(kind==CaelumPowerupData.ARMOR)return item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR;
        return kind==CaelumPowerupData.UPGRADE;
    }
    static void GuardEquipment(CaelumEquipmentItem item)
    {
        if(item.MatchPowerOwner==null)return;
        let match=CaelumStandaloneMatch.View();
        if(match!=null && !match.Finished && item.MatchPowerOwner.health>0)return;
        let owner=CaelumPlayer(item.Owner);
        if(item.MatchOriginalTier>0)
        {
            item.Tier=item.MatchOriginalTier;item.MatchOriginalTier=0;
            CaelumPlayer reference=owner;if(reference==null)reference=item.MatchPowerOwner;
            item.UnitWeight=CaelumInventoryService.GetEquipmentTaskWeight(reference,item);
            item.Durability=Min(item.Durability,reference.GetEquipmentTaskMaximumDurability(item));
            item.UpdateWorldSprite();
            if(owner!=null)
            {
                if(item.Equipped)
                {
                    if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR)
                    {owner.ArmorModel.Tier[item.ArmorSlot]=item.Tier;owner.ArmorModel.Durability[item.ArmorSlot]=item.Durability;}
                    else if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
                    {owner.ShieldModel.Tier=item.Tier;owner.ShieldModel.Durability=item.Durability;}
                    else if(owner.ActiveWeaponItemId==item.ItemId)
                    {owner.WeaponModel.Tier=item.Tier;owner.WeaponModel.Durability=item.Durability;}
                }
            }
        }
        item.MatchAwakened=false;item.MatchPowerOwner=null;
        if(owner!=null){owner.RepairActiveEquipmentItemReferences();owner.ApplyCharacterProfile();owner.OnNativeInventoryChanged();}
    }
    static void Improve(CaelumPlayer user,CaelumEquipmentItem item,bool upgrade)
    {
        item.MatchPowerOwner=CaelumStandalonePlayer(user);item.MatchAwakened=true;
        if(upgrade && item.Tier<CaelumPowerupData.MAX_TIER)
        {if(item.MatchOriginalTier==0)item.MatchOriginalTier=item.Tier;item.Tier++;}
        item.Durability=user.GetEquipmentTaskMaximumDurability(item);
        item.UnitWeight=CaelumInventoryService.GetEquipmentTaskWeight(user,item);
        // Mantener identidad y modelo equipado al cambiar tier o durabilidad.
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {user.ArmorModel.Tier[item.ArmorSlot]=item.Tier;user.ArmorModel.Durability[item.ArmorSlot]=item.Durability;}
        else if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {user.ShieldModel.Tier=item.Tier;user.ShieldModel.Durability=item.Durability;}
        else if(user.ActiveWeaponItemId==item.ItemId)
        {user.WeaponModel.Tier=item.Tier;user.WeaponModel.Durability=item.Durability;}
        item.UpdateWorldSprite();
    }
    static bool Apply(CaelumPlayer user,int kind)
    {
        let match=CaelumStandaloneMatch.View();
        if(!CaelumCaptureArcana.Eligible(match,user) || CaelumTarotHunt.Held(user) || user.DerivedStats==null)return false;
        if(kind==CaelumPowerupData.REST || kind==CaelumPowerupData.SLEEP)
        {CaelumPowerupRestModel.Apply(user,kind==CaelumPowerupData.SLEEP);return true;}
        if(kind==CaelumPowerupData.REPLENISH)
        {
            user.CurrentAnima=Min(user.DerivedStats.MaximumAnima,user.CurrentAnima+user.DerivedStats.MaximumAnima*CaelumPowerupData.ANIMA_FRACTION);
            let weapon=user.WeaponModel;
            int type=weapon!=null && weapon.Equipped?weapon.WeaponType:-1;
            int capacity=CaelumRangedRules.MagazineCapacity(type);
            if(capacity>0)
            {
                int needed=Max(0,capacity-user.GetRangedMagazineCount(type));
                // La munición nativa cuenta también lo cargado: añadir sólo el faltante.
                if(needed>0)user.GiveInventory(user.GetAmmunitionClassName(CaelumRangedRules.AmmoType(type)),needed);
                user.SetRangedMagazineCount(type,capacity);user.CancelRangedReload();
            }
            user.OnNativeInventoryChanged();return true;
        }
        Array<CaelumEquipmentItem> candidates;
        bool canUpgrade=false;
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);if(!Compatible(item,kind))continue;
            candidates.Push(item);if(item.Tier<CaelumPowerupData.MAX_TIER)canUpgrade=true;
        }
        if(candidates.Size()==0)return false;
        if(kind==CaelumPowerupData.UPGRADE)
        {
            Array<CaelumEquipmentItem> eligible;
            for(int i=0;i<candidates.Size();i++)if(!canUpgrade || candidates[i].Tier<CaelumPowerupData.MAX_TIER)eligible.Push(candidates[i]);
            Improve(user,eligible[Random[CaelumLabyrinthPowerup](0,eligible.Size()-1)],true);
        }
        else for(int i=0;i<candidates.Size();i++)Improve(user,candidates[i],false);
        user.RepairActiveEquipmentItemReferences();user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();user.RefreshFormalInventorySnapshot();user.OnNativeInventoryChanged();
        return true;
    }
}

class CaelumLabyrinthPowerup : Inventory
{
    int Kind,ReadyAt;
    CaelumPowerupEmblem Emblem;
    void Refill()
    {
        Kind=Random[CaelumLabyrinthPowerup](0,99)<CaelumPowerupData.COMMON_PERCENT
            ?Random[CaelumLabyrinthPowerup](0,3):Random[CaelumLabyrinthPowerup](4,5);
        ReadyAt=0;bInvisible=false;bSpecial=true;frame=Kind>=4?1:0;
        if(Emblem==null)Emblem=CaelumPowerupEmblem(Actor.Spawn('CaelumPowerupEmblem',Pos,NO_REPLACE));
        Emblem.frame=Kind;Emblem.bInvisible=false;
        SetTag(String.Format("$CA_POWERUP_%s",CaelumPowerupData.Key(Kind)));
    }
    override bool TryPickup(in out Actor toucher)
    {
        let user=CaelumPlayer(toucher);
        if(ReadyAt!=0 || !CaelumCaptureArcana.Touches(user,self))return false;
        // Reservar antes de aplicar: la simulación puede matar/capturar al usuario.
        ReadyAt=level.time+CaelumPowerupData.RESPAWN_TICS;bSpecial=false;
        if(!CaelumLabyrinthPowerups.Apply(user,Kind)){ReadyAt=0;bSpecial=true;return false;}
        bInvisible=true;if(Emblem!=null)Emblem.bInvisible=true;
        CaelumNotifications.Notify(user,StringTable.Localize(String.Format("CA_POWERUP_%s",CaelumPowerupData.Key(Kind)),false));
        return false;
    }
    Default {Radius 14;Height 56;RenderStyle "Translucent";Alpha 0.32;+NOGRAVITY +INVENTORY.UNDROPPABLE}
    States {Spawn:CPU0 A -1 Bright;Stop;}
}
class CaelumPowerupEmblem : Actor
{
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:CPU1 A -1 Bright;Stop;}
}
