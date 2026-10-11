class CA195ToolBull : CaelumM00Bull
{
    override void Tick(){}
}
class CA195Tools : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumAnchoredResident Npc;
    CaelumM00Bull Bull;
    CaelumResidentTools Kit;
    CaelumBolasFlight Flight;
    CaelumEquipmentItem OriginalBolas;
    CaelumAnchoredResident Residents[4];
    int ChargeStart,AttackStart,ImpactTic;
    double AirBefore,Cost,Duration;
    void Check(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;if(ok)Passes++;else Failures++;
        Console.Printf("CA195 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void InventoryChecks()
    {
        Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
        for(int i=0;i<4;i++)
        {
            let resident=Residents[i];
            resident.StoryAnchored=true;double before=resident.GetCollisionEffectiveMass();resident.EnsureResidentTools();
            let kit=resident.ResidentTools;double load=0;int count=0;
            for(Inventory item=resident.Inv;item!=null;item=item.Inv)
            {let equipment=CaelumEquipmentItem(item);if(equipment!=null){count++;load+=equipment.UnitWeight*equipment.Amount;}}
            Check("native item count",count,i<2?4:3);
            Check("load counted once",resident.GetCollisionEffectiveMass(),before+load);
            Check("one bolas",kit.Bolas.Amount,1);Check("utility pickaxe owned",kit.Pickaxe.Owner==resident,1);
            Check("staff owned",kit.Staff.Owner==resident,1);
            Check("combat tier",kit.Melee.Tier,1);
            Check("combat size",kit.Melee.EquipmentSize,resident.CombatArmor.Size[1]);
            resident.EnsureResidentTools();Check("same finite item on ensure",resident.ResidentTools.Bolas==kit.Bolas,1);
            Console.Printf("CA195 TRACE inventory npc=%d natural=%.3f load=%.3f total=%.3f type=%d size=%d",
                i,resident.Mass,load,resident.GetCollisionEffectiveMass(),kit.Melee.ItemType,kit.Melee.EquipmentSize);
            resident.Destroy();
        }
    }
    void HoldNpc(){Npc.SetStateLabel("ResidentToolUse");Npc.Vel=(0,0,0);}
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
            for(int i=0;i<4;i++)Residents[i]=CaelumAnchoredResident(Actor.Spawn(types[i],(800+i*100,1200,0)));
            Npc=CaelumAnchoredResident(Actor.Spawn("CaelumRulo",(0,0,0)));
            Bull=CaelumM00Bull(Actor.Spawn("CA195ToolBull",(90,0,0)));
        }
        if(Age==6)
        {
            InventoryChecks();
            Npc.StoryAnchored=true;Npc.EnsureResidentTools();Kit=Npc.ResidentTools;OriginalBolas=Kit.Bolas;
            Npc.RuloPartyMode=2;Npc.RuloPartyBull=Bull;Npc.target=Bull;Npc.bFriendly=true;
            Bull.TrialReleased=true;Bull.bShootable=true;Bull.bInvulnerable=false;Bull.Angle=180;
            HoldNpc();AirBefore=Npc.CurrentCombatAir;Cost=CaelumBolas.ThrowCost(Npc);
            Check("priority begins bolas",Kit.TryStart(),1);Check("bolas preparation selected",Kit.Phase,Kit.BOLAS_PREPARATION);
        }
        if(Age==40){Check("bolas still preparing after34tics",Kit.BolasThrows,0);Check("preparation does not spend",Npc.CurrentCombatAir>=AirBefore,1);}
        if(Age==42)
        {
            Check("one native throw after35tics",Kit.BolasThrows,1);
            Check("same actual item moved",OriginalBolas.Owner is "CaelumBolasFlight",1);
            Flight=CaelumBolasFlight(OriginalBolas.Owner);Check("paid throw",Npc.CurrentCombatAir<AirBefore,1);
        }
        if(Age==52)
        {
            Check("native flight reached bull",CaelumBolas.Restrained(Bull),1);
            Check("bull cannot cut",CaelumBolas.CuttingDuration(Bull),-1);
            Kit.Cancel();HoldNpc();
            double anima=Npc.CurrentCombatAnima;
            Check("priority begins ice after binding",Kit.TryStart(),1);Check("ice selected",Kit.Phase,Kit.ICE_EMISSION);
            Kit.Tick();Check("ice pays anima",Npc.CurrentCombatAnima<anima,1);
            Check("ice freezes",Bull.ElementalStatus.FreezeRemaining>0,1);
            Check("ice preserves binding",CaelumBolas.Restrained(Bull),1);
            Kit.Cancel();HoldNpc();
            double before=Npc.CurrentCombatAnima;
            Kit.Equip(Kit.Staff);Check("resident fire rejected",CaelumUtilityStaff.Emit(Npc,Kit.Staff,CaelumUtilityStaffRules.FIRE),0);
            Check("rejected fire no payment",Npc.CurrentCombatAnima,before);Kit.Cancel();HoldNpc();
            Flight.Resolve(false);OriginalBolas.SetOrigin(Npc.Pos,false);
            Check("recover actual same item",Kit.RecoverBolas(),1);Check("recovered owner",OriginalBolas.Owner==Npc,1);
            Check("no duplicated bolas",Kit.Bolas==OriginalBolas,1);
            Kit.Equip(Kit.Bolas);Flight=CaelumBolas.ThrowItem(Npc,Kit.Bolas,35);Flight.AttachVictim(Bull);
            CaelumBolas.FireContact(Bull);Check("fire destroys binding even without HP damage",CaelumBolas.Restrained(Bull),0);
            Npc.EnsureResidentTools();Check("no replacement after destruction",Kit.Bolas==null || Kit.Bolas.bDestroyed,1);
            Kit.Cancel();HoldNpc();Bull.SetOrigin((60,0,0),false);Bull.health=Bull.CombatMaximumHealth;
            Check("charged attack begins",Kit.BeginMelee(false,true),1);ChargeStart=Age;
            AirBefore=Npc.CurrentCombatAir;Cost=Kit.AttackCost(false,true);Duration=Kit.AttackDuration(Kit.Melee);
        }
        if(Age>52 && Age<170)
        {
            if(AttackStart==0 && Kit.Phase==Kit.MELEE_CYCLE)
            {
                AttackStart=Age;
                double prep=2*100/Npc.CalculateActorType4Percent(Npc.CombatDexterity+Npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY));
                Check("preparation completes before normal cycle",Age-ChargeStart,Ceil(prep*35));
                Check("normal cycle duration retained",Kit.CycleDuration,Duration);
                Check("charged action recorded",Kit.ChargedUses,1);
            }
            if(ImpactTic==0 && Kit.StrikeResolved)
            {
                ImpactTic=Age;Check("impact waits through normal swing",Age-AttackStart,Ceil(Duration*0.5));
                Console.Printf("CA195 TRACE charged raw=%d actual=%d critical=%d grade=%d prep=%d cycle=%.6f impact=%d",
                    Kit.LastStrikeRawDamage,Kit.LastStrikeDamage,Kit.LastStrikeCritical,Kit.LastStrikeGrade,AttackStart-ChargeStart,Duration,Age-AttackStart);
            }
            if(AttackStart>0 && Kit.Phase==Kit.IDLE)HoldNpc();
        }
        if(Age==170)
        {
            Check("charged attack struck",ImpactTic>0,1);
            Kit.BeginMelee(false,true);Npc.SetStateLabel("Pain");Kit.Tick();Check("pain cancels preparation",Kit.Phase,Kit.IDLE);
            Npc.SetStateLabel("ResidentToolUse");Npc.CurrentCombatAir=0;Check("cannot attack without air",Kit.BeginMelee(false,false),0);
            Check("double damage shared",CaelumWeaponUseRules.PhysicalDamage(220,1,3,true),1320);
            Check("double cost shared",Kit.AttackCost(false,true),2*Kit.AttackCost(false,false));
            Npc.CurrentCombatAir=Npc.MaximumCombatAir;Npc.CombatDexterity=10000;
            Kit.Equip(Kit.Melee);Kit.Charged=true;Kit.Aim();
            FLineTraceData hit;vector3 origin=Npc.Pos+(0,0,Npc.Height/2);
            bool traced=Npc.LineTrace(Npc.Angle,76,Npc.Pitch,TRF_ABSPOSITION,origin.Z,origin.X,origin.Y,hit);
            Console.Printf("CA195 TRACE melee geometry x=%.3f/%.3f z=%.3f/%.3f pitch=%.3f traced=%d hit=%d friend=%d shootable=%d",
                Npc.Pos.X,Bull.Pos.X,Npc.Pos.Z,Bull.Pos.Z,Npc.Pitch,traced,hit.HitActor==Bull,Npc.IsFriend(Bull),Bull.bShootable);
            Kit.Strike();Check("accurate native charged damage",Kit.LastStrikeRawDamage>0,1);
            Check("native charged War Axe raw",Kit.LastStrikeRawDamage,1324);
            Check("native critical delivered",Kit.LastStrikeCritical,1);
            Check("charged native hit gets through toughness",Kit.LastStrikeDamage>0,1);
            Check("hit grants adrenaline",Npc.CurrentCombatAdrenaline>0,1);
            Bull.health=Bull.CombatMaximumHealth;Kit.Charged=false;Kit.Strike();
            Check("native normal War Axe raw",Kit.LastStrikeRawDamage,662);
            Kit.Cancel();HoldNpc();Bull.ElementalStatus.FreezeRemaining=0;Kit.BeginIce();
            Bull.SetOrigin((500,0,0),false);double anima=Npc.CurrentCombatAnima;Kit.Tick();
            Check("ice ends when target exits range",Kit.Phase,Kit.IDLE);
            Check("lost target does not spend",Npc.CurrentCombatAnima,anima);
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
