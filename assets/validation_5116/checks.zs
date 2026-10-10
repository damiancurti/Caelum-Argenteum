// Isolated service assertions; native movement/collision runs are separate.
class CA163Passive : CaelumBull { override void Tick() {} }
class CA163Checks : EventHandler
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
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time!=60)return;
        Check("append-only IDs and family 1",CaelumConstants.WEAPON_TYPE_BOLAS==22
            && CaelumConstants.CRAFTING_BOLAS_RECIPE==133 && u.GetWeaponFamilyForType(22)==1);
        for(int t=1;t<=3;t++)Check(String.Format("requested tier %d resolves T1",t),CaelumWeaponModel.ResolveTierFor(22,t)==1);
        Check("M reference mass and binary intact state",Abs(u.WeaponModel.GetWeightFor(22,1,2)-1.018)<0.000001
            && u.WeaponModel.GetMaximumDurabilityFor(22,3,4)==1);
        Check("approved bronze 800g leather 218g",CaelumCraftingRules.GetPrimaryMaterial(18)==CaelumConstants.MATERIAL_BRONZE_INGOT
            && CaelumCraftingRules.GetSecondaryMaterial(18)==CaelumConstants.MATERIAL_LEATHER
            && CaelumCraftingRules.GetRequiredTierMaterialUnits(18,1.018)==800
            && CaelumCraftingRules.GetRequiredBasicMaterialUnits(18,1.018)==218);
        Check("spread early at zero is 60",CaelumBolasRules.Spread(0)==60);
        Check("spread interpolates linearly",Abs(CaelumBolasRules.Spread(17)-(60-54*17/35.0))<0.000001);
        Check("spread at one second and beyond is 6",CaelumBolasRules.Spread(35)==6 && CaelumBolasRules.Spread(999)==6);
        Check("zero direct damage; approved 6 Air",CaelumWeaponCatalogue.GetPrimaryDamage(18)==0
            && CaelumWeaponCatalogue.GetSecondaryDamage(18)==0 && CaelumWeaponCatalogue.GetPrimaryAirCost(18)==6);
        Check("damage-capability classification includes dagger secondary",CaelumBolasRules.Cuts(CaelumConstants.WEAPON_TYPE_DAGGER));
        Check("firearms and utility staff do not cut",!CaelumBolasRules.Cuts(2) && !CaelumBolasRules.Cuts(21));
        Check("Strength zero never breaks",!CaelumBolasRules.Breaks(0,0) && !CaelumBolasRules.Breaks(-1,0));
        Check("Strength 50 has exact half-open probability",CaelumBolasRules.Breaks(50,499999) && !CaelumBolasRules.Breaks(50,500000));
        Check("Strength 100 and above always break",CaelumBolasRules.Breaks(100,999999) && CaelumBolasRules.Breaks(150,999999));
        let npc=Body();let bind=Bind(u,npc);let source=bind.SourceItem;
        Check("one native item attached; bull cannot cut",source.Owner==bind && npc.BolasBinding==bind && CaelumBolas.CuttingDuration(npc)<0);
        Check("visible arms and legs follow authoritative binding",bind.Ropes[0]!=null && bind.Ropes[1]!=null);
        npc.SetOrigin(npc.Pos+(30,40,0),false);bind.UpdateVisuals();
        Check("ropes follow body while mouth remains free",bind.Ropes[0].Pos.Z<npc.Pos.Z+npc.Height*0.75 && bind.Pos==npc.Pos);
        for(int i=0;i<174;i++)bind.Tick();
        Check("no early Strength roll or release",bind.Remaining==1 && bind.ExpiryRolls==0 && CaelumBolas.Restrained(npc));
        bind.Tick();
        Check("zero Strength expiry drops intact once",source!=null && source.Owner==null && !source.bDestroyed && !CaelumBolas.Restrained(npc));
        Actor recipient=u;source.SetOrigin(u.Pos,false);
        Check("native recovery succeeds",source.CallTryPickup(recipient));
        Check("recovery has exactly one owned native item",source.Owner==u && source.Durability==1);
        source.Destroy();
        npc.CombatStrength=100;bind=Bind(u,npc);source=bind.SourceItem;
        for(int i=0;i<175;i++)bind.Tick();
        Check("Strength 100 expiry permanently destroys",(source==null || source.bDestroyed) && !CaelumBolas.Restrained(npc));
        bind=Bind(u,npc);source=bind.SourceItem;
        CaelumBolas.FireContact(npc);CaelumBolas.FireContact(npc);
        Check("fire resolves once with no item drop",(source==null || source.bDestroyed) && !CaelumBolas.Restrained(npc));
        bind=Bind(u,npc);source=bind.SourceItem;
        CaelumElementalStream.ApplyContact(u,npc,true);
        Check("ice contact does not burn ropes",CaelumBolas.Restrained(npc));
        CaelumElementalStream.ApplyContact(u,npc,false);
        Check("utility fire contact burns ropes",!CaelumBolas.Restrained(npc) && (source==null || source.bDestroyed));
        bind=Bind(u,npc);source=bind.SourceItem;
        CaelumBolas.FireAttack(npc,null,'Fire');
        Check("zero-damage classified fire burns ropes",!CaelumBolas.Restrained(npc) && (source==null || source.bDestroyed));
        bind=Bind(u,npc);source=bind.SourceItem;npc.health=0;bind.Tick();
        Check("early death drops intact without Strength roll",source!=null && !source.bDestroyed && source.Owner==null);
        source.Destroy();npc.health=100000;
        bind=Bind(u,npc);let old=bind.SourceItem;
        let incoming=CaelumBolasFlight(Actor.Spawn("CaelumBolasFlight",npc.Pos,NO_REPLACE));
        incoming.SourceItem=Item(u);source=incoming.SourceItem;u.RemoveInventory(source);source.AttachToOwner(incoming);
        incoming.SpecialMissileHit(npc);
        Check("repeated hit retains original timer and recovers incoming",npc.BolasBinding==bind && bind.Remaining==175 && source.Owner==null && old.Owner==bind);
        source.Destroy();bind.Resolve(false);old.Destroy();
        npc.bINVULNERABLE=true;
        Check("native invulnerability respected",!CaelumBolas.Eligible(npc));npc.bINVULNERABLE=false;
        let knife=Item(u,CaelumConstants.WEAPON_TYPE_DAGGER);knife.Equipped=false;
        bind=Bind(u,u);source=bind.SourceItem;
        Check("player movement and attack gate active",u.IsPhysicallyImmobilized());
        double duration=CaelumBolas.CuttingDuration(u);
        Check("unequipped possessed blade allows shared speed cut",duration>0);
        CaelumBolas.RequestCut(u);bind.Tick();
        Check("Reload escape starts progress",bind.Cutting && bind.CutProgress>0);
        u.PainImmobilizationRemaining=1;bind.Tick();
        Check("pain cancels and clears cut progress",!bind.Cutting && bind.CutProgress==0);
        u.PainImmobilizationRemaining=0;CaelumBolas.RequestCut(u);bind.Remaining=10000;
        for(int i=0;i<int(Ceil(duration));i++)if(CaelumBolas.Restrained(u))bind.Tick();
        Check("cut completes at shared duration and destroys",!CaelumBolas.Restrained(u) && (source==null || source.bDestroyed));
        bind=Bind(u,u);u.LucidityPhysicalStunRemaining=3;bind.Resolve(true);
        Check("release preserves unrelated stun",u.IsPhysicallyImmobilized() && u.LucidityPhysicalStunRemaining==3);u.LucidityPhysicalStunRemaining=0;
        knife.Destroy();npc.Destroy();
        let victim=Body();bind=Bind(u,victim);source=bind.SourceItem;victim.Destroy();bind.Tick();
        Check("target removal recovers intact item",source!=null && !source.bDestroyed && source.Owner==null);source.Destroy();
        bind=Bind(u,u);u.ForcedSleepTics=5;bind.Cutting=true;bind.CutProgress=0.5;bind.Tick();
        Check("sleep cancels cutting",!bind.Cutting && bind.CutProgress==0);u.ForcedSleepTics=0;bind.Resolve(true);
        bind=Bind(u,u);source=bind.SourceItem;bind.Remaining=1;bind.Cutting=true;bind.CutProgress=1;CaelumBolas.FireContact(u);
        Check("fire wins simultaneous pending cut and expiry once",u.BolasBinding==null && (source==null || source.bDestroyed));
        Check("binary tool excluded from repair and salvage",!u.IsDurabilityTaskEquipment(Item(u)));
        Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
