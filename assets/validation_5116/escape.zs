// Isolated service assertions; native movement/collision runs are separate.
class CA163Passive : CaelumBull { override void Tick() {} }
class CA163Escape : EventHandler
{
    int Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA163 %s %s",ok?"PASS":"FAIL",label);}
    CaelumEquipmentItem Item(CaelumPlayer u,int type=22)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;
        item.Tier=1;item.EquipmentSize=2;item.Durability=u.WeaponModel.GetMaximumDurabilityFor(type,1,2);
        item.UnitWeight=u.WeaponModel.GetWeightFor(type,1,2);item.PickupDataInitialized=true;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.AttachToOwner(u);u.EnsureEquipmentItemId(item);return item;
    }
    CaelumCombatActor Body()
    {
        let npc=CaelumCombatActor(Actor.Spawn("CA163Passive",(2600,2200,0),NO_REPLACE));
        npc.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        npc.health=100000;npc.CombatStrength=0;npc.ElementalStatus=new("CaelumElementalStatus");return npc;
    }
    CaelumBolasFlight Bind(CaelumPlayer u,Actor body)
    {
        let bind=CaelumBolasFlight(Actor.Spawn("CaelumBolasFlight",body.Pos,NO_REPLACE));
        let item=Item(u);bind.SourceItem=item;bind.Target=u;bind.SourceMap=level.MapName;
        u.RemoveInventory(item);item.AttachToOwner(bind);bind.AttachVictim(body);return bind;
    }
    int Stage,Age,AmmoBefore,BindingId;
    vector3 StartPoint;
    bool ReloadVerified;
    CaelumEquipmentItem BoundItem;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            let gun=Item(u,2);gun.Equipped=true;Item(u,3);
            u.ActivateExactEquippedWeapon(gun);u.SelectNativeWeaponConfiguration(2,0,1);
            u.CarbineMagazine=3;
        }
        int requested=CVar.FindCVar('ca163_stage').GetInt();
        if(requested!=Stage){Stage=requested;Age=0;}Age++;
        if(Stage==1 && Age==1)
        {
            let bind=Bind(u,u);BoundItem=bind.SourceItem;BindingId=BoundItem.ItemId;
            StartPoint=u.Pos;AmmoBefore=u.CarbineMagazine;
        }
        if(Stage==1 && Age==15)
        {
            Check("real forward input cannot move bound player",u.Pos.XY==StartPoint.XY);
            Check("real attack cannot consume ammunition while bound",u.CarbineMagazine==AmmoBefore);
            Check("real Reload starts dedicated cut",u.BolasBinding!=null && u.BolasBinding.Cutting && u.BolasBinding.CutProgress>0);
            Check("escape is not a firearm reload",!u.RangedReloadActive);
        }
        if(Stage==2 && Age==1)u.PainImmobilizationRemaining=10.0/35;
        if(Stage==2 && Age==16)
            Check("pain cancellation needs a new player Reload press",u.BolasBinding!=null && !u.BolasBinding.Cutting && u.BolasBinding.CutProgress==0);
        if(Stage==3 && Age==15)
            Check("new Reload press restarts cut from zero",u.BolasBinding!=null && u.BolasBinding.Cutting && u.BolasBinding.CutProgress>0);
        if(Stage==4 && Age==1)
        {
            Check("finished real cut releases and destroys exact item",u.BolasBinding==null && (BoundItem==null || BoundItem.bDestroyed));
            Check("real cut consumes no ammo",u.CarbineMagazine==AmmoBefore);
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
        if(Stage==9 && !ReloadVerified)
        {
            ReloadVerified=true;
            Check("saved cut restores same unique bound item",u.BolasBinding!=null && u.BolasBinding.SourceItem!=null && u.BolasBinding.SourceItem.ItemId==BindingId);
            Check("saved cut retains elapsed progress and timer",u.BolasBinding!=null && u.BolasBinding.Cutting && u.BolasBinding.CutProgress>0.2 && u.BolasBinding.Remaining<175);
            Check("saved cut remains separate from reload ammo",u.CarbineMagazine==AmmoBefore && !u.RangedReloadActive);
        }
        if(Stage==9 && Age==90)
        {
            Check("loaded cut completes once without duplicate item",u.BolasBinding==null && u.FindNativeEquipmentItemById(BindingId)==null && (BoundItem==null || BoundItem.bDestroyed));
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
