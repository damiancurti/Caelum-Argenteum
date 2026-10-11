// Isolated service assertions; native movement/collision runs are separate.
class CA163Passive : CaelumBull { override void Tick() {} }
class CA163Travel : StaticEventHandler
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
    int Age,Visits,OwnedId,PlayerDropId,NPCId,RemainingBefore;
    override void WorldLoaded(WorldEvent e){Age=0;Visits++;}
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(Visits==1 && Age==5)u.InitializeDirectMapCharacter();
        if(Visits==1 && Age==20)
        {
            let tool=Item(u);OwnedId=tool.ItemId;tool.Equipped=true;
            u.ActivateExactEquippedWeapon(tool);u.SelectNativeWeaponConfiguration(22,0,1);
            let npc=Body();npc.SetOrigin((3000,3000,0),false);npc.CombatStrength=0;
            let bind=Bind(u,npc);NPCId=bind.SourceItem.ItemId;
            bind=Bind(u,u);PlayerDropId=bind.SourceItem.ItemId;
        }
        if(Visits==1 && Age==45)
        {
            u.BolasPreparedTics=17;u.BolasPreparedItem=OwnedId;
            let it=ThinkerIterator.Create("CaelumBolasFlight");CaelumBolasFlight bind;
            while((bind=CaelumBolasFlight(it.Next()))!=null)
                if(bind.SourceItem!=null && bind.SourceItem.ItemId==NPCId)RemainingBefore=bind.Remaining;
            u.PersistCharacterState();Level.ChangeLevel("CA163B",0,CHANGELEVEL_NOINTERMISSION);
        }
        if(Visits==2 && Age==5)
        {
            Check("hub departure clears only player binding and preparation",u.BolasBinding==null && u.BolasPreparedTics==0 && u.BolasPreparedItem==0);
            Check("owned bolas survives travel with same identity",u.FindNativeEquipmentItemById(OwnedId)!=null);
            Check("bound item is not duplicated into traveler",u.FindNativeEquipmentItemById(NPCId)==null && u.FindNativeEquipmentItemById(PlayerDropId)==null);
        }
        if(Visits==2 && Age==30)Level.ChangeLevel("CA163",0,CHANGELEVEL_NOINTERMISSION);
        if(Visits==3 && Age==5)
        {
            int found=0;let it=ThinkerIterator.Create("CaelumBolasFlight");CaelumBolasFlight bind;
            while((bind=CaelumBolasFlight(it.Next()))!=null)
            {
                if(bind.SourceItem!=null && bind.SourceItem.ItemId==NPCId)
                {
                    found++;Check("inactive hub pauses NPC restraint timer",bind.Remaining<=RemainingBefore && bind.Remaining>=RemainingBefore-8);
                    Check("returned NPC has matching binding and rope visuals",CaelumBolas.Binding(bind.Victim)==bind && bind.Ropes[0]!=null && bind.Ropes[1]!=null);
                }
            }
            Check("hub returns exactly one attached bolas",found==1);
            int drops=0;let items=ThinkerIterator.Create("CaelumEquipmentItem");CaelumEquipmentItem item;
            while((item=CaelumEquipmentItem(items.Next()))!=null)if(item.ItemId==PlayerDropId)drops++;
            if(drops==0 && u.FindNativeEquipmentItemById(PlayerDropId)!=null)drops=1;
            Check("departure drops player restraint intact in original hub",drops==1 && u.BolasBinding==null);
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
