// This exact fixture compiles against 5.1.9 and the candidate package.
class CA154Persistence : StaticEventHandler
{
    int Elapsed,Passed,Failed,ItemCount,WeaponId;
    bool Loaded,GateOpen;
    double HP,Anima,Air,Adrenaline,NHP,NAnima,NAir,NAdrenaline,GateRatio,OldConstitution,OldGravity;
    CaelumGiantRat Rat;
    CaelumBreakableGate Gate;
    void Check(String label,double actual,double expected,double tolerance=0.0006)
    {
        bool ok=Abs(actual-expected)<=tolerance;
        if(ok)Passed++;else Failed++;
        Console.Printf("CA154 %s %s actual=%.12f expected=%.12f",ok ? "PASS" : "FAIL",label,actual,expected);
    }
    int Items(CaelumPlayer u)
    {int count=0;for(Inventory item=u.Inv;item!=null;item=item.Inv)count++;return count;}
    void Remember(CaelumPlayer u)
    {
        HP=double(u.health)/u.CaelumMaximumHealth;Anima=u.CurrentAnima/u.DerivedStats.MaximumAnima;
        Air=u.CurrentAir/u.DerivedStats.MaximumAir;Adrenaline=u.CurrentAdrenaline/u.DerivedStats.MaximumAdrenaline;
        let it=ThinkerIterator.Create("CaelumGiantRat");Rat=CaelumGiantRat(it.Next());
        if(Rat!=null)
        {NHP=double(Rat.health)/Rat.CombatMaximumHealth;NAnima=Rat.CurrentCombatAnima/Rat.MaximumCombatAnima;NAir=Rat.CurrentCombatAir/Rat.MaximumCombatAir;NAdrenaline=Rat.CurrentCombatAdrenaline/Rat.MaximumCombatAdrenaline;}
        let gates=ThinkerIterator.Create("CaelumBreakableGate");Gate=CaelumBreakableGate(gates.Next());
        if(Gate!=null){GateRatio=double(Gate.health)/Gate.StructuralMaximum;GateOpen=Gate.Opened;}
        OldConstitution=u.Attributes.Constitution;ItemCount=Items(u);WeaponId=u.ActiveWeaponItemId;OldGravity=level.gravity;
        Console.Printf("CA154 SAVE remembered hp=%.9f anima=%.9f air=%.9f adrenaline=%.9f NPC=%.9f,%.9f,%.9f,%.9f gate=%.9f items=%d weapon=%d max=%d/%.9f/%.9f/%.9f gravity=%.9f",HP,Anima,Air,Adrenaline,NHP,NAnima,NAir,NAdrenaline,GateRatio,ItemCount,WeaponId,u.CaelumMaximumHealth,u.DerivedStats.MaximumAnima,u.DerivedStats.MaximumAir,u.DerivedStats.MaximumAdrenaline,level.gravity);
    }
    override void WorldLoaded(WorldEvent e)
    {
        Elapsed=0;Loaded=e.IsSaveGame;
        let u=CaelumPlayer(players[0].mo);
        if(Loaded && u!=null)Remember(u);
    }
    override void WorldTick()
    {
        Elapsed++;let u=CaelumPlayer(players[0].mo);if(u==null || u.DerivedStats==null)return;
        if(!Loaded && Elapsed==20)
        {
            u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.bNOTARGET=true;
            u.health=int(u.CaelumMaximumHealth*0.4);u.player.health=u.health;
            u.CurrentAnima=u.DerivedStats.MaximumAnima*0.3;u.CurrentAir=u.DerivedStats.MaximumAir*0.2;
            u.CurrentAdrenaline=u.DerivedStats.MaximumAdrenaline*0.1;
            u.UnderwaterAirRecoveryDebt=u.DerivedStats.MaximumAir*0.04;
            u.CurrentHunger=90;u.CurrentThirst=80;u.CurrentSleep=70;u.PersistCharacterState();
            Rat=CaelumGiantRat(Actor.Spawn("CaelumGiantRat",(5000,0,0)));
            Rat.InitializeCombatProfile(100,100,100,100,100,100,100,100,100,100,100,100);
            Rat.health=int(Rat.CombatMaximumHealth*0.4);Rat.CurrentCombatAnima=Rat.MaximumCombatAnima*0.3;
            Rat.CurrentCombatAir=Rat.MaximumCombatAir*0.2;Rat.CurrentCombatAdrenaline=Rat.MaximumCombatAdrenaline*0.1;
            Gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",(7000,0,0)));Gate.InitializeGate();
            Gate.health=int(Gate.StructuralMaximum*0.6);Gate.Opened=true;
            Remember(u);
        }
        if(!Loaded && Elapsed==22)
        {
            Rat.InitializeCombatProfile(100,100,100,100,100,100,100,100,100,100,100,100);
            Rat.health=int(Rat.CombatMaximumHealth*0.4);Rat.CurrentCombatAnima=Rat.MaximumCombatAnima*0.3;
            Rat.CurrentCombatAir=Rat.MaximumCombatAir*0.2;Rat.CurrentCombatAdrenaline=Rat.MaximumCombatAdrenaline*0.1;
            Gate.Opened=true;Gate.HoldTimer=350;Remember(u);
        }
        if(Loaded && Elapsed==2)
        {
            Check("migrated health fraction",double(u.health)/u.CaelumMaximumHealth,HP);
            Check("migrated anima fraction",u.CurrentAnima/u.DerivedStats.MaximumAnima,Anima);
            Check("migrated air fraction",u.CurrentAir/u.DerivedStats.MaximumAir,Air);
            Check("migrated adrenaline fraction",u.CurrentAdrenaline/u.DerivedStats.MaximumAdrenaline,Adrenaline);
            Check("attributes preserved",u.Attributes.Constitution,OldConstitution,0);
            Check("inventory preserved",Items(u),ItemCount,0);Check("weapon identity preserved",u.ActiveWeaponItemId,WeaponId,0);
            if(Rat!=null)
            {
                Check("NPC health fraction",double(Rat.health)/Rat.CombatMaximumHealth,NHP);
                Check("NPC anima fraction",Rat.CurrentCombatAnima/Rat.MaximumCombatAnima,NAnima);
                Check("NPC air fraction",Rat.CurrentCombatAir/Rat.MaximumCombatAir,NAir);
                Check("NPC adrenaline fraction",Rat.CurrentCombatAdrenaline/Rat.MaximumCombatAdrenaline,NAdrenaline);
            }
            if(Gate!=null){Check("gate damage fraction",double(Gate.health)/Gate.StructuralMaximum,GateRatio);Check("gate open retained",Gate.Opened,GateOpen,0);}
            double beforeHP=u.health,beforeAnima=u.CurrentAnima,beforeAir=u.CurrentAir,beforeAdrenaline=u.CurrentAdrenaline;
            u.ApplyCharacterProfile();u.ApplyCharacterProfile();
            Check("repeat profile health",u.health,beforeHP,0);Check("repeat profile anima",u.CurrentAnima,beforeAnima,0);
            Check("repeat profile air",u.CurrentAir,beforeAir,0);Check("repeat profile adrenaline",u.CurrentAdrenaline,beforeAdrenaline,0);
            Check("gravity not compounded",level.gravity,OldGravity,0);
            Console.Printf("CA154 PERSISTENCE COMPLETE pass=%d fail=%d balance=%d max=%d/%.9f/%.9f/%.9f gravity=%.9f",Passed,Failed,u.AttributeBalanceVersion,u.CaelumMaximumHealth,u.DerivedStats.MaximumAnima,u.DerivedStats.MaximumAir,u.DerivedStats.MaximumAdrenaline,level.gravity);
        }
    }
}
