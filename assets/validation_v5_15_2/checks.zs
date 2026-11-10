class CA449Port : CaelumPortSiege replaces CaelumPortSiege { override void Tick() {} }
class CA449Body : CaelumMandinga { override void Tick() {} }
class CA449Checks : EventHandler
{
    CA449Port Port;
    CaelumCannon Gun;
    CaelumBatteringRam Ram;
    CaelumSiegeCombatant Guard;
    int Failures,Checks,SavedHealth;
    CaelumBarricade Built;
    CaelumCannon WorkGun;
    double SavedWork;
    void Stock(CaelumPlayer user,int material,int units)
    {
        let item=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,material,1);
        if(item==null){item=user.CreateDetachedMaterialStack(material,1,units);item.AttachToOwner(user);}
        item.Amount=units;item.InMagicBox=true;
    }
    void WorkChecks()
    {
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(true);
        user.MagicBoxOwned=true;Stock(user,CaelumConstants.MATERIAL_WOOD,2000000);Stock(user,CaelumConstants.MATERIAL_IRON_INGOT,2000000);
        user.CombatTimeRemaining=100;
        Check(CaelumMachineWork.Begin(user,Gun,Gun.Blocks[3],CaelumMachineWork.REPAIR,0),"native repair can start during combat with material reservations");
        if(!CaelumMachineWork.Active(user))return;
        if(playeringame[1])
        {
            let peer=CaelumPlayer(players[1].mo);peer.SetOrigin(Gun.Pos+(0,-64,0),false);
            Check(!CaelumMachineWork.Begin(peer,Gun,Gun.Blocks[0],CaelumMachineWork.SABOTAGE,0),"another player cannot take over an owned active work reservation");
        }
        let work=CaelumMachineWork.Find(user);double before=user.CraftingTaskRemainingSeconds;
        Check(Abs(before-28800.0*100/Gun.Structure.StructuralMaximum)<0.001
            && user.GetCraftingTaskReservedUnitTotal()==CaelumMachineData.Grams(CaelumMachineData.CANNON,0,100.0/Gun.Structure.StructuralMaximum)
                +CaelumMachineData.Grams(CaelumMachineData.CANNON,1,100.0/Gun.Structure.StructuralMaximum),"damage repair reserves proportional materials and duration before any progress");
        CaelumMachineWork.Advance(user);
        Check(Abs(before-user.CraftingTaskRemainingSeconds-CaelumThermalRuntime.WorldTicSeconds())<0.001,"repair uses world-time work");
        double progress=user.CraftingTaskRemainingSeconds;
        Gun.Structure.DamageMobj(null,null,50,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(!CaelumMachineWork.Attended(user) && work.Paused && user.CraftingTaskRemainingSeconds==progress,"damage pauses repair without losing completed effort");
        CaelumMachineWork.Resume(user);user.CraftingTaskRemainingSeconds=0;CaelumMachineWork.Advance(user);
        Check(!user.CraftingTaskActive && Gun.health==Gun.Structure.StructuralMaximum-50,"repair restores only the damage paid for before interruption");
        user.SetOrigin((-2048,-2048,0),false);user.CombatTimeRemaining=0;
        let station=CaelumWorkbenchStation(Actor.Spawn('CaelumWorkbenchStation',user.Pos+(64,0,0)));
        user.player.cmd.buttons|=BT_USE;user.CraftingStationUseLatched=false;station.OpenForActivator(user);user.player.cmd.buttons&=~BT_USE;
        int recipe=CaelumMachineData.FIRST_RECIPE;record.LearnCraftingRecipe(recipe);
        record.RecipeRereadings[CaelumRecipeLearning.Slot(recipe,1)]=CaelumRecipeLearning.MAX_READINGS;
        record.RecipePractice[CaelumRecipeLearning.Slot(recipe,1)]=CaelumRecipeLearning.PracticeLimit(recipe);
        user.CraftingSelectionRecipe=recipe;user.CraftingEfficiencyIndex=2;user.RefreshCraftingPreview();
        Check(user.CraftingBasicRequired==50000 && user.CraftingTierRequired==5000,"construction preview uses approved materials at full efficiency");
        user.CraftingEfficiencyIndex=0;user.RefreshCraftingPreview();
        Check(user.CraftingBasicRequired==200000 && user.CraftingTierRequired==20000,"quarter efficiency uses four times the approved recipe materials");
        user.CraftingEfficiencyIndex=1;user.RefreshCraftingPreview();
        Check(user.CraftingBasicRequired==100000 && user.CraftingTierRequired==10000,"half efficiency uses twice the approved recipe materials");
        user.CraftingEfficiencyIndex=2;user.RefreshCraftingPreview();
        vector3 site=user.Pos-(128,0,0);
        Check(!CaelumMachineWork.BeginBuild(user,1,site,0),"construction cannot select a faction without membership");
        int wood=user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1);
        Check(CaelumMachineWork.BeginBuild(user,0,site,0),"learned construction uses the actual workshop and clear world placement");
        if(CaelumMachineWork.Active(user))
        {
            user.CraftingTaskRemainingSeconds=0;CaelumMachineWork.Advance(user);
            Built=Port.ConstructedDefenses.Size()>0?CaelumBarricade(Port.ConstructedDefenses[0]):null;
            Check(Built!=null && Built.Mass==55 && Built.StructureHeight()==48 && Built.OwnerFaction==0,"construction creates one approved faction-owned barricade");
            Check(user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==wood-50000,"construction consumes exact reserved inputs once");
        }
        Actor.Spawn('CaelumForgeStation',user.Pos-(64,0,0));Actor.Spawn('CaelumAnvilStation',user.Pos+(0,64,0));
        station.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());
        recipe++;record.LearnCraftingRecipe(recipe);
        record.RecipeRereadings[CaelumRecipeLearning.Slot(recipe,1)]=CaelumRecipeLearning.MAX_READINGS;
        record.RecipePractice[CaelumRecipeLearning.Slot(recipe,1)]=CaelumRecipeLearning.PracticeLimit(recipe);
        user.CraftingSelectionRecipe=recipe;user.RefreshCraftingPreview();
        Check(user.CraftingBasicRequired==100000 && user.CraftingTierRequired==750000 && user.CraftingSelectedInfrastructureAvailable,"cannon construction uses the approved workshop and smithing network");
        Check(CaelumMachineWork.BeginBuild(user,0,user.Pos-(0,128,0),0),"native cannon construction starts in a clear world position");
        if(CaelumMachineWork.Active(user))
        {
            user.CraftingTaskRemainingSeconds=0;CaelumMachineWork.Advance(user);
            let builtGun=Port.ConstructedDefenses.Size()>1?CaelumCannon(Port.ConstructedDefenses[1]):null;
            Check(builtGun!=null && builtGun.Mass==850 && builtGun.OwnerFaction==0 && builtGun.UnlimitedAmmunition,"world cannon has the approved mass faction and ammunition policy");
        }
        user.CloseCraftingStationSession();
        WorkGun=CaelumCannon(Actor.Spawn('CaelumCannon',(-1024,-2048,0)));WorkGun.InitializeCannon(false);
        user.SetOrigin(WorkGun.Pos+(0,64,0),false);
        Check(CaelumMachineWork.Begin(user,WorkGun,WorkGun.Blocks[3],CaelumMachineWork.SABOTAGE,0),"sabotage starts beside an uncrewed enemy machine");
        if(CaelumMachineWork.Active(user))
        {
            double seconds=user.CraftingTaskRemainingSeconds;CaelumMachineWork.Advance(user);
            Check(Abs(seconds-user.CraftingTaskRemainingSeconds-1.0/TICRATE)<0.000001,"sabotage uses real native seconds instead of world acceleration");
            Check(CaelumTimeAdvanceState.BlockReason(user)=="CA_MACHINE_REAL_TIME","time advance cannot skip capture or sabotage work");
            CaelumMachineWork.Interrupt(user);SavedWork=user.CraftingTaskRemainingSeconds;
        }
        SavedHealth=Gun.health;
    }
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA449 %s %s",okay?"PASS":"FAIL",label);}
    void Seed()
    {
        Port=CA449Port(CaelumPortSiege.Get());
        if(Port==null)Port=CA449Port(Actor.Spawn('CA449Port',(0,0,0)));
        Gun=CaelumCannon(Actor.Spawn('CaelumCannon',(0,512,0)));
        Gun.InitializeCannon(false);Port.RegisterMachine(Gun);
        Ram=CaelumBatteringRam(Actor.Spawn('CaelumBatteringRam',(-1024,512,0)));
        Ram.InitializeRam();Port.RegisterMachine(Ram);
        let body=CA449Body(Actor.Spawn('CA449Body',(0,768,0)));
        Guard=Port.RegisterAttacker(body);Gun.RememberGuard(Guard);
        Port.SealRoster();Gun.ActivateCannon(0);
        Console.Printf("CA449 SEEDED");
    }
    void Initial()
    {
        Check(Gun.MachineRevision==1 && Gun.Structure!=null,"cannon creates one revisioned structural owner");
        Check(Gun.Structure.Toughness==75 && Gun.Structure.Mass==850,"cannon uses approved mass and armored-gate toughness");
        Check(Ram.Structure!=null && Ram.Structure.Toughness==50,"ram uses approved reinforced-gate toughness");
        let structure=Gun.Structure;Gun.EnsureMachine();
        Check(Gun.Structure==structure && Gun.Blocks[0].master==structure,"repeated initialization preserves physical component identity");
        Guard.ConfirmedDead=true;Guard.Body.health=0;
        Gun.ObserveGuards();
        Check(!Gun.ObjectiveNeutralized() && !Gun.Neutralized,"guard deaths no longer complete the machine objective");
        int before=Gun.health;
        Gun.Blocks[0].DamageMobj(null,null,100,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(Gun.health==before-100 && structure.health==Gun.health,"native collision proxy applies structural damage once");
        Check(Gun.DamageSerial==1,"damage interruption serial increments once");
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(true);
        for(int i=0;i<CaelumConstants.FACTION_COUNT;i++)record.FactionMember[i]=false;
        Check(!CaelumMachineOwnership.Capture(Gun,user,CaelumConstants.FACTION_UNITARIOS),"capture requires current membership");
        record.FactionMember[CaelumConstants.FACTION_UNITARIOS]=true;
        Check(CaelumMachineOwnership.Capture(Gun,user,CaelumConstants.FACTION_UNITARIOS),"capture transfers ownership to an approved current membership");
        Check(Gun.ObjectiveNeutralized() && !Gun.Neutralized && Gun.Operational(),"captured machine completes objective while remaining operable");
        Check(Gun.health==before-100 && !Gun.CapturedIntact,"capture never repairs damage or marks damaged equipment intact");
        user.SetOrigin(Gun.Pos+(0,64,0),false);
        Check(CaelumMachineOwnership.Assign(Gun,user) && Gun.OperatorsPresent()==1,"membership alone allows a native player operator");
        record.FactionMember[CaelumConstants.FACTION_UNITARIOS]=false;
        Check(Gun.OperatorsPresent()==0,"membership revocation stops operation without recreating a machine");
        record.FactionMember[CaelumConstants.FACTION_UNITARIOS]=true;
        WorkChecks();SavedHealth=Gun.health;
        Console.Printf("CA449 CHECKPOINT READY failures=%d",Failures);
    }
    void Restored()
    {
        let user=CaelumPlayer(players[0].mo);
        Check(CaelumMachineWork.Active(user) && CaelumMachineWork.Find(user).Paused && user.CraftingTaskRemainingSeconds==SavedWork,"saved interrupted work retains its native reservation and exact remaining time");
        user.CancelCraftingTask();
        Check(Gun.health==SavedHealth && Gun.Structure.health==SavedHealth,"saved structural damage persists");
        let structure=Gun.Structure;Gun.EnsureMachine();
        Check(Gun.Structure==structure,"save reload does not replace the structural owner");
        Gun.Structure.DamageMobj(null,null,Gun.health,'CaelumImpact',DMG_NO_ARMOR,0);
        Check(Gun.TarotDestroyed && Gun.ObjectiveNeutralized() && Gun.Blocks.Size()==0,"destruction completes objective and clears collision parts");
        int count=Gun.NeutralizationCount;Gun.DestroyByTarot();
        Check(Gun.NeutralizationCount==count && count==1,"destruction outcome is idempotent");
        Console.Printf("CA449 RESULT %s checks=%d failures=%d",Failures==0?"PASS":"FAIL",Checks,Failures);
    }
    void LegacyRestored() {}
    void Catchup() {}
    void VerifyTravel()
    {
        let user=CaelumPlayer(players[0].mo);let work=CaelumMachineWork.Find(user);
        Check(CaelumMachineWork.Active(user) && work!=null && work.Paused && user.CraftingTaskRemainingSeconds==SavedWork,"hub return retains exact interrupted work and reservations");
        Console.Printf("CA449 HUB machine=%d null=%d worker=%d empty=%d contact=%d",int(work.Machine==WorkGun),int(work.Machine==null),int(WorkGun.Worker==user),int(WorkGun.Worker==null),int(work.Contact!=null));
        Check(work!=null && work.Machine==WorkGun && WorkGun.Worker==user,"hub return preserves the original machine and worker ownership");
        Check(Port.ConstructedDefenses.Size()==2 && Port.ConstructedDefenses[0]==Built,"hub return does not duplicate constructed defenses");
        Check(Gun.health==SavedHealth && Gun.OwnerFaction==0,"hub return preserves captured ownership and damage");
        Console.Printf("CA449 TRAVEL %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca449_seed")Seed();
        else if(e.Name=="ca449_initial")Initial();
        else if(e.Name=="ca449_restored")Restored();
        else if(e.Name=="ca449_travel")Level.ChangeLevel('T449',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca449_return")Level.ChangeLevel('MAP03',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca449_verifytravel")VerifyTravel();
        else if(e.Name=="ca449_visual")
        {
            let user=CaelumPlayer(players[0].mo);user.CancelCraftingTask();user.SetOrigin(Built.Pos+(0,176,0),false);
            user.Angle=270;user.Pitch=10;user.SetCraftingJournalState(false);
            let session=CaelumMachineSession.Find(user);if(session!=null)session.Open=false;
        }
        else if(e.Name=="ca449_panel")
        {let user=CaelumPlayer(players[0].mo);user.SetOrigin(WorkGun.Pos+(0,64,0),false);CaelumMachineSession.Show(user,WorkGun,WorkGun.Blocks[3]);}
    }
}
