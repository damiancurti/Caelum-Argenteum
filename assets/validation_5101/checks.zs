class CA426Probe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER }
    override void Tick() { }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA426Checks : EventHandler
{
    int Checks,Failures,Stage,Start,EventTic;
    CA426Probe Listener,Source;
    vector3 SavedPoint;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA426 %s %s",ok?"PASS":"FAIL",label);}
    void Reset()
    {Listener.VisualEvidence=new("CaelumVisualEvidence");Listener.VisualEvidence.Initialize();}
    void Seed(CaelumPlayer user)
    {
        user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
        Listener=CA426Probe(Actor.Spawn("CA426Probe",(0,0,0)));
        Source=CA426Probe(Actor.Spawn("CA426Probe",(256,0,0)));
        Listener.CombatEffectiveInsight=0;Source.CombatAgility=0;
        Listener.Angle=180;Listener.CurSector.SetLightLevel(255);
        Reset();
        Check(CaelumNoiseData.MetersFor(CaelumNoiseData.FIREARM)==160
            && CaelumNoiseData.MetersFor(CaelumNoiseData.EXPLOSION)==250
            && CaelumNoiseData.MetersFor(CaelumNoiseData.MAGIC)==64
            && CaelumNoiseData.MetersFor(CaelumNoiseData.IMPACT)==16
            && CaelumNoiseData.MetersFor(CaelumNoiseData.SWING)==8
            && CaelumNoiseData.MetersFor(CaelumNoiseData.DOOR)==8
            && CaelumNoiseData.MetersFor(CaelumNoiseData.SHOUT)==64,"approved sound ranges");
        CaelumNoise.Emit(Source,CaelumNoiseData.STEP,512);
        Check(Abs(Listener.VisualEvidence.Suspicion-25)<.001,"half range produces 25 suspicion behind listener");
        Check(Listener.VisualEvidence.Subject==null && Listener.VisualEvidence.IdentifiedSubject==null
            && Listener.target==null && Listener.LastEnemy==null,"hearing grants no identity or target");
        Check(Listener.VisualEvidence.NoisePosition==Source.Pos,"heard point snapshots event origin");
        vector3 point=Source.Pos;Source.SetOrigin((300,0,0),false);
        Check(Listener.VisualEvidence.NoisePosition==point,"moving source cannot update recorded point");
        Source.SetOrigin((512,0,0),false);Reset();CaelumNoise.Emit(Source,CaelumNoiseData.STEP,512);
        Check(!Listener.VisualEvidence.HasHeardNoise,"range boundary is silent");
        Listener.CombatEffectiveInsight=100;CaelumPopulationState.Get().Refresh();
        CaelumNoise.Emit(Source,CaelumNoiseData.STEP,512);
        Check(Abs(Listener.VisualEvidence.Suspicion-37.5)<.001,"Insight M2 increases actual spatial hearing range fourfold");
        Listener.CombatEffectiveInsight=0;CaelumPopulationState.Get().Refresh();
        Listener.SetOrigin((384,768,0),false);Source.SetOrigin((704,768,0),false);Reset();
        CaelumNoise.Emit(Source,CaelumNoiseData.STEP,1280);
        Check(!Listener.VisualEvidence.HasHeardNoise,"solid obstruction quarters range at boundary");
        CaelumNoise.Emit(Source,CaelumNoiseData.STEP,2560);
        Check(Abs(Listener.VisualEvidence.Suspicion-25)<.001,"occluded intensity uses reduced range");
        Listener.SetOrigin((0,0,0),false);Source.SetOrigin((128,0,0),false);
        Check(CaelumNoiseData.TerrainFactor('CaelumGrass',false)==.5
            && CaelumNoiseData.TerrainFactor('CaelumSoil',false)==.5
            && CaelumNoiseData.TerrainFactor('CaelumWood',false)==1
            && CaelumNoiseData.TerrainFactor('CaelumMetal',false)==1.5
            && CaelumNoiseData.TerrainFactor('CaelumWood',true)==1.25,"approved surface factors");
        Source.CombatArmor=new("CaelumArmorModel");Source.CombatArmor.InitializeDefaults();
        Check(CaelumNoise.EquipmentFactor(Source)==1,"base clothing keeps equipment factor one");
        Source.CombatArmor.ArmorType[0]=CaelumConstants.ARMOR_TYPE_MEDIUM;
        Check(CaelumNoise.EquipmentFactor(Source)==1.5,"worn metal multiplies sound");
        Source.CombatArmor.ArmorType[1]=CaelumConstants.ARMOR_TYPE_HEAVY;
        Check(CaelumNoise.EquipmentFactor(Source)==1.5,"multiple metal pieces do not multiply repeatedly");
        Source.CombatArmor.ArmorType[0]=Source.CombatArmor.ArmorType[1]=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
        Reset();let projectile=CaelumCarbineProjectile(Actor.Spawn("CaelumCarbineProjectile",(128,0,0)));
        projectile.A_CaelumImpactNoise();
        Check(Listener.VisualEvidence.NoiseKind==CaelumNoiseData.IMPACT && Abs(Listener.VisualEvidence.Suspicion-37.5)<.001,"projectile impact emits at contact position");
        projectile.A_CaelumImpactNoise();
        Check(Abs(Listener.VisualEvidence.Suspicion-37.5)<.001,"projectile contact cannot emit twice");projectile.Destroy();
        Reset();Source.NoiseStepScheduled=false;Source.CombatAgility=0;
        CaelumNoise.NPCStep(Source,false,100);
        Check(Listener.VisualEvidence.HasHeardNoise,"real NPC step emits");
        double first=Listener.VisualEvidence.Suspicion;CaelumNoise.NPCStep(Source,false,100);
        Check(Listener.VisualEvidence.Suspicion==first,"same-tic repeated movement emits no extra step");
        Reset();Source.NoiseStepScheduled=false;Source.CombatAgility=100;CaelumNoise.NPCStep(Source,false,100);
        Check(!Listener.VisualEvidence.HasHeardNoise,"full stealth silences movement");Source.CombatAgility=0;
        Reset();Source.CurrentCombatAir=0;
        Check(!Source.SpendPhysicalAttackAir(1) && !Listener.VisualEvidence.HasHeardNoise,"failed action does not make swing noise");
        Source.CurrentCombatAir=100000;
        Check(Source.SpendPhysicalAttackAir(1) && Listener.VisualEvidence.NoiseKind==CaelumNoiseData.SWING,"paid physical attack emits once");
        Reset();Source.CurrentCombatAnima=0;
        Check(!Source.SpendBasicMagic() && !Listener.VisualEvidence.HasHeardNoise,"failed magic stays silent");
        Source.CurrentCombatAnima=100000;
        Check(Source.SpendBasicMagic() && Listener.VisualEvidence.NoiseKind==CaelumNoiseData.MAGIC,"paid NPC magic emits");
        let door=CaelumSlidingDoorLeaf(Actor.Spawn("CaelumSlidingDoorLeaf",(128,128,0)));
        Reset();Check(door.RequestDoorGroup(Source) && Listener.VisualEvidence.NoiseKind==CaelumNoiseData.DOOR,"opening real door emits");
        double doorNoise=Listener.VisualEvidence.Suspicion;door.RequestDoorGroup(Source);
        Check(Listener.VisualEvidence.Suspicion==doorNoise,"already requested door does not emit again");
        Reset();user.SetOrigin((128,-256,0),false);Listener.SetOrigin((0,-256,0),false);
        user.WeaponModel=new("CaelumWeaponModel");user.WeaponModel.InitializeDefaults();
        user.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SHOTGUN;user.WeaponModel.Equipped=true;
        user.WeaponModel.Durability=user.WeaponModel.GetMaximumDurability();user.CurrentAir=100000;
        user.SetRangedMagazineCount(CaelumConstants.WEAPON_TYPE_SHOTGUN,0);user.PerformCarbineAttack();
        Check(!Listener.VisualEvidence.HasHeardNoise,"empty player firearm stays silent");
        user.SetRangedMagazineCount(CaelumConstants.WEAPON_TYPE_SHOTGUN,2);user.PerformCarbineAttack();
        Check(user.LastCarbineFired && Abs(Listener.VisualEvidence.Suspicion-48.75)<.001,"shotgun commits one sound for entire cartridge");
        user.SetOrigin((-1700,-1700,0),false);Listener.SetOrigin((0,0,0),false);Source.SetOrigin((256,0,0),false);
        Reset();CaelumNoise.Emit(Source,CaelumNoiseData.FIREARM);
        CaelumNoise.Emit(Source,CaelumNoiseData.FIREARM);CaelumNoise.Emit(Source,CaelumNoiseData.FIREARM);
        Check(Listener.VisualEvidence.Suspicion==100,"sound alert clamps to 100");
        Listener.Angle=0;Check(!CaelumVisualPerception.Identify(Listener,Source),"maximum acoustic alert cannot skip visual identification");
        Stage=1;Start=level.time;
    }
    override void WorldTick()
    {
        if(Stage!=1)return;
        bool identified=CaelumVisualPerception.Identify(Listener,Source);
        int age=level.time-Start;
        if(age==35)Check(!identified,"one second of sight after noise remains unidentified");
        if(age==70)
        {
            Check(identified,"two seconds of sight after noise identify");
            Reset();CaelumNoise.Emit(Source,CaelumNoiseData.MAGIC);
            SavedPoint=Source.Pos;EventTic=Listener.VisualEvidence.NoiseTic;
            Source.SetOrigin((-256,0,0),false);Stage=2;
            Console.Printf("CA426 RESULT checks=%d failures=%d",Checks,Failures);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca426_seed")Seed(user);
        if(e.Name=="ca426_reload")
        {
            Check(Stage==2 && Listener.VisualEvidence.HasHeardNoise,"hearing state restored");
            Check(Listener.VisualEvidence.NoisePosition==SavedPoint && Listener.VisualEvidence.NoiseTic==EventTic,"heard point and original event tic survive save");
            Check(Listener.VisualEvidence.Subject==null && Listener.VisualEvidence.IdentifiedSubject==null && Listener.target==null,"save never creates source identity");
            Console.Printf("CA426 RESULT checks=%d failures=%d",Checks,Failures);
        }
        if(e.Name=="ca426_migration")
        {
            Check(Stage==3 && Listener.health==321,"legacy actor preserved");
            Check(Listener.VisualEvidence.Subject==Source && Listener.VisualEvidence.Suspicion==28,"legacy visual evidence preserved");
            Check(!Listener.VisualEvidence.HasHeardNoise && Listener.VisualEvidence.NoiseRevision==0,"legacy save invents no heard event");
            CaelumNoise.Emit(Source,CaelumNoiseData.MAGIC);
            Check(Listener.VisualEvidence.NoiseRevision==CaelumNoiseData.REVISION && Listener.VisualEvidence.HasHeardNoise,"first real noise initializes hearing");
            let record=Listener.VisualEvidence;CaelumVisualPerception.Evidence(Listener);
            Check(record==Listener.VisualEvidence,"hearing migration idempotent");
            Console.Printf("CA426 RESULT checks=%d failures=%d",Checks,Failures);
        }
    }
}
