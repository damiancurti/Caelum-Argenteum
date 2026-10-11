class CA163LoadObserver : StaticEventHandler
{
    int Prepared;
    override void WorldLoaded(WorldEvent e)
    {
        if(e.IsSaveGame)
        {
            let u=CaelumPlayer(players[0].mo);Prepared=u!=null ? u.BolasPreparedTics : -1;
            Console.Printf("CA163 LOAD prepared=%d time=%d",Prepared,level.time);
        }
    }
}
// Isolated service assertions; native movement/collision runs are separate.
class CA163Passive : CaelumBull { override void Tick() {} }
class CA163Inputs : EventHandler
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
    int Stage,Age,BolasId,TargetHealth,LoadedPreparedTics;
    override void WorldLoaded(WorldEvent e)
    {if(e.IsSaveGame){let u=CaelumPlayer(players[0].mo);LoadedPreparedTics=u!=null ? u.BolasPreparedTics : -1;}}
    bool ReloadVerified;
    CaelumEquipmentItem Tool;
    CaelumCombatActor TargetBody;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            Tool=Item(u);Tool.Equipped=true;BolasId=Tool.ItemId;
            u.ActivateExactEquippedWeapon(Tool);u.EnsureWeaponFamilySelectors();u.SelectNativeWeaponConfiguration(22,0,1);
            u.SetOrigin((2048,2048,0),false);u.Angle=0;u.Pitch=40;
        }
        int requested=CVar.FindCVar('ca163_stage').GetInt();
        if(requested!=Stage){Stage=requested;Age=0;Console.Printf("CA163 STAGE %d",Stage);}Age++;
        if(Stage==1 && Age==10)Check("held secondary prepares early below one second",u.BolasPreparedTics>=8 && u.BolasPreparedTics<35);
        if(Stage==2 && Age==20)Check("long held secondary caps preparation at one second",u.BolasPreparedTics==35);
        if(Stage==3 && Age==5)Check("release secondary cancels with owned item intact",u.BolasPreparedTics==0 && Tool!=null && Tool.Owner==u);
        if(Stage==4 && Age==7)Check("primary throws during secondary preparation",Tool!=null && Tool.Owner!=u && u.FindNativeEquipmentItemById(BolasId)==null);
        if(Stage==4 && Age==60)
        {
            Check("native miss lands recoverable without restraint delay",Tool!=null && Tool.Owner==null && Abs(Tool.Pos.Z-Tool.FloorZ)<0.1);
            Check("miss retains integrity and exact item ID",Tool!=null && Tool.Durability==1 && Tool.ItemId==BolasId);
            if(Tool!=null)
            {
                Tool.SetOrigin(u.Pos,false);Actor recipient=u;
                Check("miss native pickup succeeds",Tool.CallTryPickup(recipient));
                Tool.Equipped=true;u.ActivateExactEquippedWeapon(Tool);u.SelectNativeWeaponConfiguration(22,0,1);
            }
            u.Pitch=0;
            TargetBody=Body();TargetBody.SetOrigin(u.Pos+(96,0,0),false);TargetBody.CombatStrength=0;
            TargetBody.A_SetSize(40,96);
        }
        if(Stage==5 && Age==1){TargetHealth=TargetBody.health;TargetBody.CombatStrength=0;}
        if(Stage==5 && Age==20)Check("actual flight collision attaches without damage",TargetBody!=null && CaelumBolas.Restrained(TargetBody) && TargetBody.health==TargetHealth);
        if(Stage==5 && Age==30 && TargetBody!=null && TargetBody.BolasBinding!=null)
        {
            Check("native target restraint displays both rope sprites",TargetBody.BolasBinding.Ropes[0]!=null && TargetBody.BolasBinding.Ropes[1]!=null);
            TargetBody.BolasBinding.Remaining=175;
        }
        if(Stage==6 && Age==10)
        {
            Check("actual natural expiry leaves one recoverable item",Tool!=null && Tool.Owner==null && !CaelumBolas.Restrained(TargetBody));
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
        if(Stage==7 && Age==1)
        {
            u.Pitch=0;u.Angle=0;u.SetOrigin((2048,2048,0),false);
            TargetBody=Body();TargetBody.SetOrigin((2160,2048,0),false);
            Item(u,3);
        }
        if(Stage==7 && Age==5 && TargetBody!=null)TargetBody.CombatStrength=0;
        if(Stage==8 && Age==1)Bind(u,u);
        if(Stage==11 && Age==1)
        {
            if(Tool==null || Tool.Owner!=u){Tool=Item(u);Tool.Equipped=true;BolasId=Tool.ItemId;}
            u.ToggleEquipmentMenu();u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            u.EquipmentSelectionItemId=BolasId;u.EquipmentSelectionWeaponType=22;
            u.EquipmentSelectionTier=1;u.EquipmentSelectionSize=2;u.RefreshEquipmentSelectionPreview();
        }
        if(Stage==10 && !ReloadVerified)
        {
            ReloadVerified=true;
            Check("save restores one attached native item and timer",TargetBody!=null && TargetBody.BolasBinding!=null
                && TargetBody.BolasBinding.SourceItem==Tool && Tool.ItemId==BolasId && TargetBody.BolasBinding.Remaining<175);
            Check("save restores both restraint visuals",TargetBody.BolasBinding!=null && TargetBody.BolasBinding.Ropes[0]!=null && TargetBody.BolasBinding.Ropes[1]!=null);
            let bind=TargetBody.BolasBinding;
            Check("old bound save adds both rear layers at revision 2",bind!=null && bind.Revision==2 && bind.BackRopes[0]!=null && bind.BackRopes[1]!=null);
            if(bind!=null)
            {
                let back=bind.BackRopes[0];bind.UpdateVisuals();bind.UpdateVisuals();
                int count=0;let it=ThinkerIterator.Create("CaelumBolasRopes");while(it.Next()!=null)count++;
                Check("visual migration is idempotent with exactly four layers",bind.BackRopes[0]==back && count==4);
            }
        }
        if(Stage==10 && Age==190)
        {
            Check("loaded natural expiry recovers exactly one piece",Tool!=null && Tool.Owner==null && !CaelumBolas.Restrained(TargetBody));
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
        if(Stage==9 && !ReloadVerified)
        {
            ReloadVerified=true;
            Check("saved preparation retains its owned item identity",Tool!=null && Tool.Owner==u && Tool.ItemId==BolasId);
            Check("save serializes prepared simulation tics",CA163LoadObserver(StaticEventHandler.Find("CA163LoadObserver")).Prepared==35);
            Check("released input after load cancels preparation",u.BolasPreparedTics==0);
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
