// Isolated service assertions; native movement/collision runs are separate.
class CA163Passive : CaelumBull { override void Tick() {} }
class CA163QuietMandinga : CaelumMandinga { override void Tick() {} }
class CA163QuietZupay : CaelumZupayColossus { override void Tick() {} }
class CA163Npcs : EventHandler
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
    CaelumCombatActor Mandinga,Boss;
    CaelumPortDefender Soldier;
    CaelumBull Bull;
    CaelumEquipmentItem SoldierItem,BullItem,MandingaItem;
    vector3 SoldierStart,BullStart;
    int CutStarted,AmmoBefore;
    double ExpectedCut;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            Mandinga=CaelumCombatActor(Actor.Spawn("CA163QuietMandinga",(3000,3000,0),NO_REPLACE));
            Boss=CaelumCombatActor(Actor.Spawn("CA163QuietZupay",(3300,3300,0),NO_REPLACE));
            Soldier=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(2700,2000,0),NO_REPLACE));
            Bull=CaelumBull(Actor.Spawn("CaelumBull",(2600,2600,0),NO_REPLACE));
            Mandinga.CaelumDiagnosticPassiveAI=true;Boss.CaelumDiagnosticPassiveAI=true;
            Soldier.CaelumDiagnosticPassiveAI=true;Bull.CaelumDiagnosticPassiveAI=true;
        }
        if(level.time==60)
        {
            Check("Mandinga possesses a cutting sidearm",CaelumBolas.CuttingDuration(Mandinga)>0);
            Soldier.Carbine=new("CaelumCityCarbine");Soldier.Carbine.Initialize(Soldier);Soldier.Carbine.Select(true);
            Check("soldier holding carbine still possesses cutting sword",Soldier.Carbine.Held && CaelumBolas.CuttingDuration(Soldier)>0);
            int durability=Soldier.Sword.Durability;Soldier.Sword.Durability=0;
            Check("broken sidearm cannot grant cut via firearm",CaelumBolas.CuttingDuration(Soldier)<0);Soldier.Sword.Durability=durability;
            Check("bull and Zupay natural attacks cannot cut",CaelumBolas.CuttingDuration(Bull)<0 && CaelumBolas.CuttingDuration(Boss)<0);
            for(int i=0;i<2;i++)
            {
                let demon=i==0 ? Mandinga : Boss;
                demon.CaelumDiagnosticPassiveAI=false;demon.target=null;demon.RecoveryPhase=0;demon.SetState(demon.SpawnState);
                demon.CurrentCombatAnima=0;
                let bind=Bind(u,demon);let source=bind.SourceItem;
                CaelumDemonService.UpdateBreath(demon);
                Check(String.Format("demon %d cannot escape without payable Anima",i),CaelumBolas.Restrained(demon) && demon.CurrentCombatAnima==0);
                int before=0;let flashes=ThinkerIterator.Create("CaelumBolasBurnVisual");while(flashes.Next()!=null)before++;
                Check(String.Format("demon %d insufficient Anima has no burn flash",i),before==i);
                demon.CurrentCombatAnima=100;
                double cost=demon.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
                CaelumDemonService.UpdateBreath(demon);
                Check(String.Format("demon %d own paid breath burns ropes immediately",i),!CaelumBolas.Restrained(demon)
                    && (source==null || source.bDestroyed) && Abs(demon.CurrentCombatAnima-(100-cost))<0.000001);
                CaelumDemonService.StopBreath(demon);demon.CaelumDiagnosticPassiveAI=true;
                int after=0;flashes=ThinkerIterator.Create("CaelumBolasBurnVisual");while(flashes.Next()!=null)after++;
                Check(String.Format("demon %d paid release leaves one independent flash",i),after==before+1);
            }
            Mandinga.CurrentCombatAnima=0;
            MandingaItem=Bind(u,Mandinga).SourceItem;
            Soldier.target=u;Soldier.SetState(Soldier.SeeState);Soldier.CaelumDiagnosticPassiveAI=true;
            let bind=Bind(u,Soldier);SoldierItem=bind.SourceItem;SoldierStart=Soldier.Pos;CutStarted=level.time;
            ExpectedCut=CaelumBolas.CuttingDuration(Soldier);AmmoBefore=Soldier.Carbine.Magazine;
            Check("carbine direct attack is blocked while bound",!Soldier.Carbine.Attack(Soldier,u));
            bind=Bind(u,Bull);BullItem=bind.SourceItem;BullStart=Bull.Pos;
            Bull.target=u;Bull.SetState(Bull.SeeState);Bull.CombatStrength=150;Bull.CaelumDiagnosticPassiveAI=true;
            Check("native bull charge is canceled by restraint",!Bull.BullChargeActive);
        }
        if(level.time>60 && CaelumBolas.Restrained(Soldier))
        {
            if(Soldier.Pos!=SoldierStart)Check("bound soldier remains stationary",false);
            if(Soldier.Carbine.Magazine!=AmmoBefore)Check("cut never consumes firearm ammunition",false);
        }
        if(level.time==90)
        {
            Check("all finite fire flashes expire",ThinkerIterator.Create("CaelumBolasBurnVisual").Next()==null);
            Check("bound bull cannot chase despite live target",Bull.Pos==BullStart && CaelumBolas.Restrained(Bull));
            Check("automatic NPC cut progresses below shared duration",Soldier.BolasBinding!=null && Soldier.BolasBinding.CutProgress>0 && level.time-CutStarted<ExpectedCut);
        }
        if(level.time==60+int(Ceil(ExpectedCut))+2)
        {
            Check("automatic soldier cut finishes at shared speed",!CaelumBolas.Restrained(Soldier) && (SoldierItem==null || SoldierItem.bDestroyed));
            Check("cut preserves held carbine ammunition",Soldier.Carbine.Magazine==AmmoBefore);
        }
        if(level.time==170)Check("automatic Mandinga cut with insufficient breath resource",!CaelumBolas.Restrained(Mandinga) && (MandingaItem==null || MandingaItem.bDestroyed));
        if(level.time==230)Check("high Strength bull has no early escape",CaelumBolas.Restrained(Bull) && Bull.BolasBinding.ExpiryRolls==0);
        if(level.time==240)
        {
            Check("high Strength bull breaks only at natural expiry",!CaelumBolas.Restrained(Bull) && (BullItem==null || BullItem.bDestroyed));
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
