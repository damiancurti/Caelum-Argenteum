// #312: receptores congelados para aislar el vaciado del trabajo ya acumulado.
// La prueba motion reutilizada conserva movimiento y callbacks nativos.
class CA312Probe : CA194Motion
{
    CaelumCombatActor Survivor, Removed, DeadSurvivor, DeadPeer;
    ImpactContactState RemovedContact, DeadContact;
    CaelumPlayer User;
    ImpactContactState PlayerContact;
    int PlayerBefore;

    void RemovalSetup()
    {
        Survivor=Fresh(); Survivor.SetOrigin((-512,0,32),false);
        Removed=Fresh(); Removed.SetOrigin(Survivor.Pos+(32,0,0),false);
        RemovedContact=Survivor.LatchImpactContact(Removed);
        CaelumImpactEnergy.CaptureWork(RemovedContact);
        RemovedContact.PendingWorkJoules=1000;
        Removed.Destroy(); Removed=null;

        DeadSurvivor=Fresh(); DeadSurvivor.SetOrigin((0,512,32),false);
        DeadPeer=Fresh(); DeadPeer.SetOrigin(DeadSurvivor.Pos+(32,0,0),false);
        DeadContact=DeadSurvivor.LatchImpactContact(DeadPeer);
        CaelumImpactEnergy.CaptureWork(DeadContact);
        DeadContact.PendingWorkJoules=1000;
        DeadPeer.health=0; DeadPeer.bCorpse=true;

        User=CaelumPlayer(players[0].mo);
        User.bInvulnerable=false;User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        User.Attributes.Toughness=0;User.DerivedStats.BaseMass=80;User.DerivedStats.TotalMass=80;
        User.CaelumMaximumHealth=User.health=User.player.health=10000000;
        User.EffectiveEvasionChance=0;User.CombatBlockModeActive=false;User.DebugShieldBlocking=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.ArmorModel=new("CaelumArmorModel");User.ArmorModel.InitializeDefaults();
        User.WeaponModel.Equipped=false;User.ShieldModel.Equipped=false;
        User.AnatomyProfile=new("CaelumAnatomyProfile");
        User.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
        User.SetOrigin((0,-512,0),false);User.Angle=0;
        let peer=Fresh();peer.SetOrigin(User.Pos+(32,0,0),false);
        PlayerContact=User.LatchImpactContact(peer);
        CaelumImpactEnergy.CaptureWork(PlayerContact);PlayerContact.PendingWorkJoules=1000;
        PlayerBefore=User.health;peer.Destroy();
    }

    void RemovalCheck()
    {
        Check("destroy clears saved peer pointer",RemovedContact.SecondActor==null,1);
        Survivor.UpdateImpactContactLatch();
        Check("destroyed peer flushes surviving NPC raw work",Survivor.LastImpactReceivedJoules,1000);
        Check("destroyed peer consumes pending work",RemovedContact.PendingWorkJoules,0);
        int health=Survivor.health;Survivor.UpdateImpactContactLatch();
        Check("destroyed peer cannot replay flush",Survivor.health,health);
        Check("destroyed contact removed",Survivor.GetImpactContactCount(),0);
        DeadSurvivor.UpdateImpactContactLatch();
        Check("dead peer flushes surviving NPC",DeadSurvivor.LastImpactReceivedJoules,1000);
        Check("dead peer receives no damage",DeadPeer.health,0);
        User.UpdateImpactContactLatch();
        Check("destroyed peer flushes surviving player raw work",User.LastImpactReceivedJoules,1000);
        Check("player flush consumes pending work",PlayerContact.PendingWorkJoules,0);
        Check("player retains full biological cushioning",User.LastImpactFinalDamage,0);
        health=User.health;User.UpdateImpactContactLatch();
        Check("player flush cannot replay",User.health,health);
        Survivor.Destroy();DeadSurvivor.Destroy();DeadPeer.Destroy();
    }

    void SupportGeometry()
    {
        let a=Fresh(),b=Fresh(),top=Fresh(200),cap=Fresh(100);
        a.SetOrigin((-16,0,0),false);b.SetOrigin((16,0,0),false);
        top.SetOrigin((0,0,56),false);top.bOnMobj=true;top.bNoGravity=false;top.Vel=(0,0,0);
        cap.SetOrigin((0,0,112),false);cap.bOnMobj=true;cap.bNoGravity=false;cap.Vel=(0,0,0);
        Check("two native-box supports",CaelumWeightPressure.SupportCount(top),2);
        Check("stack shares top load first",CaelumWeightPressure.MassAbove(a),150);
        Check("stack shares top load second",CaelumWeightPressure.MassAbove(b),150);
        b.SetOrigin((256,0,0),false);
        Check("remaining support gets full stack",CaelumWeightPressure.MassAbove(a),300);
        top.bNoGravity=true;
        Check("flying upper does not load support",CaelumWeightPressure.MassAbove(a),0);
        top.bNoGravity=false;top.Vel.Z=1;
        Check("moving vertical upper is not static pressure",CaelumWeightPressure.MassAbove(a),0);
        cap.Destroy();top.Destroy();a.Destroy();b.Destroy();
    }

    void InterruptedStatic()
    {
        for(int mode=0;mode<3;mode++)
        {
            let b=Fresh();
            let p=CaelumWeightPressure(b.GiveInventoryType("CaelumWeightPressure"));
            p.EnergyRevision=1;p.DamageCarry=1000;p.ContactTics=20;p.SupportedMass=10000;
            if(mode==0)b.bSolid=false;
            if(mode==1)b.bNoClip=true;
            if(mode==2){b.health=0;b.bCorpse=true;}
            CaelumWeightPressure.Update(b);
            Check("interrupted static clears pending work",p.DamageCarry,0);
            Check("interrupted static closes age",p.ContactTics,0);
            Check("interrupted static living flush or dead discard",b.health,mode==2?0:999080);
            b.bSolid=true;b.bNoClip=false;
            if(mode==2)b.health=1000000;
            int hp=b.health;CaelumWeightPressure.Update(b);
            Check("resumed body cannot replay old pressure",b.health,hp);
            b.Destroy();
        }
        let resident=new("CaelumHouseResident");
        resident.Body=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(1024,-512,0)));
        resident.Body.Mass=80;resident.Body.CombatToughness=0;resident.Body.health=1000000;
        resident.Body.CombatArmor=new("CaelumArmorModel");resident.Body.CombatArmor.InitializeDefaults();
        let p=CaelumWeightPressure(resident.Body.GiveInventoryType("CaelumWeightPressure"));
        p.EnergyRevision=1;p.DamageCarry=1000;p.ContactTics=20;
        resident.Suspend();
        Check("resident suspension closes static work before parking",p.DamageCarry,0);
        Check("resident suspension applies existing final toughness",resident.Body.health,999080);
        resident.Body.Destroy();
        let fatal=Fresh();fatal.health=1;
        let pending=CaelumWeightPressure(fatal.GiveInventoryType("CaelumWeightPressure"));
        pending.EnergyRevision=1;pending.DamageCarry=1000;pending.ContactTics=20;
        fatal.bSolid=false;CaelumWeightPressure.Update(fatal);
        Check("lethal static release remains dead",fatal==null || fatal.health<=0,1);
        Check("lethal static release clears state before damage",pending==null || (pending.DamageCarry==0 && pending.ContactTics==0),1);
        if(fatal!=null)fatal.Destroy();
        resident=new("CaelumHouseResident");
        resident.Body=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(1024,-512,0)));
        resident.Body.Mass=80;resident.Body.CombatToughness=0;resident.Body.health=1;
        resident.Body.CombatArmor=new("CaelumArmorModel");resident.Body.CombatArmor.InitializeDefaults();
        p=CaelumWeightPressure(resident.Body.GiveInventoryType("CaelumWeightPressure"));
        p.EnergyRevision=1;p.DamageCarry=1000;p.ContactTics=20;
        resident.Suspend();
        Check("lethal resident closure cannot revive",resident.Body==null || resident.Body.health<=0,1);
        Check("lethal resident closure consumes once",p==null || p.DamageCarry==0,1);
        if(resident.Body!=null)resident.Body.Destroy();
    }

    override void WorldTick()
    {
        Age++;
        if(Age==5)RemovalSetup();
        if(Age==7){RemovalCheck();SupportGeometry();InterruptedStatic();}
        if(Age==12)Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
    }
}

// Flujo real: Tick, callbacks pasivos y vaciado automático de producción.
class CA312Flow : CA194Motion
{
    CA194Moving A,B,C,D;
    CaelumCombatActor LoadBase,LoadTop;
    double PendingAtRemoval, StaticAtRelease;
    int BeforeRemoval,BeforeRelease,RestHealth,HitsAtRemoval;
    CA194Moving Make(Vector3 pos)
    {
        let b=Moving(pos);b.bNoGravity=true;
        b.CombatLucidityPhysicalStunRemaining=1000;
        return b;
    }
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            A=Make((-512,0,0));B=Make((-480,0,0));
            C=Make((512,0,0));D=Make((544,0,0));
            LoadBase=Fresh();LoadBase.SetOrigin((0,512,0),false);LoadBase.CombatStrength=0;
            LoadTop=Fresh(1000000);LoadTop.SetOrigin(LoadBase.Pos+(0,0,56),false);
            LoadTop.bNoGravity=false;LoadTop.bOnMobj=true;LoadTop.Vel=(0,0,0);
        }
        if(Age>=6 && Age<25)
        {
            A.SetOrigin((-512,0,0),false);B.SetOrigin((-480,0,0),false);
            A.Vel=(4*32.0/35.0,0,0);B.Vel=(-4*32.0/35.0,0,0);
        }
        if(Age>=6 && Age<48)
        {
            C.SetOrigin((512,0,0),false);D.SetOrigin((544,0,0),false);
            C.Vel=(4*32.0/35.0,0,0);D.Vel=(-4*32.0/35.0,0,0);
        }
        if(Age==15)
        {
            let pressure=CaelumWeightPressure(LoadBase.FindInventory("CaelumWeightPressure"));
            Check("static world update exists",pressure!=null,1);
            if(pressure!=null)Check("static raw fractional accumulation",pressure.DamageCarry,
                (pressure.ContactTics-1)*980.92152/35,0.000001);
            LoadTop.Mass=500000;
        }
        if(Age==25)
        {
            let contact=A.GetImpactContactState(B);
            Check("native partial pressure has saved geometry",contact!=null && contact.PendingGeometry!=null,1);
            if(contact!=null)
            {
                PendingAtRemoval=contact.PendingWorkJoules;
                Check("native unique-tic motion work",PendingAtRemoval,contact.SustainedTics*1280,0.00001);
                Check("native pressure pending before interval",PendingAtRemoval>0 && contact.SustainedTics<35,1);
            }
            HitsAtRemoval=A.CrushHits;BeforeRemoval=A.health;B.Destroy();B=null;A.Vel=(0,0,0);
            let pressure=CaelumWeightPressure(LoadBase.FindInventory("CaelumWeightPressure"));
            if(pressure!=null)
            {
                Check("changed support mass changes current rate",pressure.LastDamagePerSecond,490.42152);
                StaticAtRelease=pressure.DamageCarry;
            }
            BeforeRelease=LoadBase.health;LoadTop.Destroy();LoadTop=null;
        }
        if(Age==28)
        {
            Check("native removal flush raw",A.LastImpactReceivedJoules,PendingAtRemoval,0.00001);
            Check("native removal exactly one pressure hit",A.CrushHits-HitsAtRemoval,1);
            Check("native removal causes resolved damage",A.health<BeforeRemoval,1);
            let pressure=CaelumWeightPressure(LoadBase.FindInventory("CaelumWeightPressure"));
            Check("static release retains partial fractional work",pressure.LastWorkJoules,StaticAtRelease);
            Check("static release final toughness once",BeforeRelease-LoadBase.health,int(Max(0,StaticAtRelease-80)+0.5));
            Check("static release clears carry",pressure.DamageCarry,0);
            Check("static release clears contact age",pressure.ContactTics,0);
        }
        if(Age==43)
        {
            Check("continuous native pressure reaches interval",C.CrushHits>=1,1);
            Check("35 unique-tic samples per full pulse",C.LastImpactReceivedJoules,35*1280,0.00001);
            Check("both native receivers share raw work",D.LastImpactReceivedJoules,C.LastImpactReceivedJoules);
        }
        if(Age==48){C.Vel=D.Vel=(0,0,0);}
        if(Age==56)
        {
            Check("rest closes remaining work once",C.CrushHits,2);
            RestHealth=C.health;
        }
        if(Age==70)
        {
            Check("rest adds no motion work",C.health,RestHealth);
            Check("removed peer flush does not repeat",A.CrushHits-HitsAtRemoval,1);
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
