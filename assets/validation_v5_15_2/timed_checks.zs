class CA449Port : CaelumPortSiege replaces CaelumPortSiege { override void Tick() {} }
class CA449Checks : EventHandler
{
    CaelumCannon Gun;
    int Stage,Started,Failures,Checks;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA449 %s %s",okay?"PASS":"FAIL",label);}
    void Seed()
    {
        let port=CaelumPortSiege.Get();if(port==null)port=CaelumPortSiege(Actor.Spawn('CA449Port',(0,0,0)));
        Gun=CaelumCannon(Actor.Spawn('CaelumCannon',(0,512,0)));Gun.InitializeCannon(false);Gun.UnlimitedAmmunition=true;port.RegisterMachine(Gun);port.SealRoster();Gun.ActivateCannon(0);
        let user=CaelumPlayer(players[0].mo);user.SetOrigin(Gun.Pos+(0,64,0),false);
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.GetPersistentCharacterState(true).FactionMember[0]=true;
    }
    void Initial()
    {
        let user=CaelumPlayer(players[0].mo);
        Check(Gun.Blocks[3].Used(user) && CaelumMachineSession.Find(user).Open,"actual native Use opens the machine panel");
        CaelumMachineSession.Find(user).Act(2);
        Check(CaelumMachineWork.Active(user),"native menu starts sabotage");
        Check(!Gun.ObjectiveNeutralized(),"starting sabotage does not neutralize original equipment");
        Started=level.time;Stage=1;
    }
    override void WorldTick()
    {
        if(Stage==0)return;let user=CaelumPlayer(players[0].mo);int elapsed=level.time-Started;
        if(Stage==1)
        {
            if(elapsed==TICRATE || elapsed==TICRATE*29)
            {
                let w=CaelumMachineWork.Find(user);
                Console.Printf("CA449 DIAG remaining=%f progressing=%d attended=%d paused=%d owner=%d frozen=%d reach=%d map=%s active=%d station=%d",
                    user.CraftingTaskRemainingSeconds,int(user.CraftingTaskProgressing),int(CaelumMachineWork.Attended(user)),int(w.Paused),int(Gun.Worker==user),int(user.isFrozen()),int(CaelumMachineWork.Reach(user,w.Contact)),w.OriginMap,int(user.CraftingTaskActive),int(user.ActiveCraftingStationActor==w.Contact));
            }
            if(elapsed==TICRATE*29)Check(!Gun.Sabotaged && CaelumMachineWork.Active(user),"sabotage remains incomplete before thirty real seconds");
            if(elapsed<TICRATE*30+2)return;
            Check(Gun.Sabotaged && !CaelumMachineWork.Active(user),"native task finishes sabotage after thirty real seconds");
            if(!Gun.Sabotaged){Stage=0;return;}
            Check(!Gun.ObjectiveNeutralized() && !Gun.Operational(),"temporary sabotage disables operation without granting objective");
            Check(!Gun.RequestShot((1000,512,40)),"disabled cannon rejects a shot request");
            Check(CaelumMachineWork.Begin(user,Gun,Gun.Blocks[3],CaelumMachineWork.CAPTURE,0),"capture can start on disabled enemy equipment");
            Started=level.time;Stage=2;
        }
        else if(Stage==2)
        {
            if(elapsed==TICRATE*29)Check(!Gun.Captured,"capture remains incomplete before thirty real seconds");
            if(elapsed<TICRATE*30+2)return;
            Check(Gun.Captured && Gun.Sabotaged && !Gun.CapturedIntact,"native capture transfers disabled equipment without repairing it");
            if(!Gun.Captured){Stage=0;return;}
            Check(Gun.ObjectiveNeutralized(),"capturing original equipment completes its objective");
            // Exact cost for the separately approved ten-percent sabotage repair.
            user.MagicBoxOwned=true;
            let wood=user.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_WOOD,1,10000);wood.InMagicBox=true;wood.AttachToOwner(user);
            let iron=user.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_IRON_INGOT,1,75000);iron.InMagicBox=true;iron.AttachToOwner(user);
            Check(CaelumMachineWork.Begin(user,Gun,Gun.Blocks[3],CaelumMachineWork.REPAIR,0),"sabotage repair reserves the approved ten-percent materials");
            Console.Printf("CA449 REPAIR seconds=%f health=%d maximum=%d kind=%d",user.CraftingTaskRemainingSeconds,Gun.health,Gun.Structure.StructuralMaximum,CaelumMachineWork.Find(user).Kind);
            Check(Abs(user.CraftingTaskRemainingSeconds-2880)<0.001,"sabotage repair uses ten percent of approved construction time");
            user.CraftingTaskRemainingSeconds=0;CaelumMachineWork.Advance(user);
            Check(Gun.Operational() && !user.CraftingTaskActive,"finishing repair restores operability");
            CaelumMachineSession.Show(user,Gun,Gun.Blocks[3]);CaelumMachineSession.Find(user).Act(4);
            Check(CaelumMachineOperator.Find(user).Controlling,"native menu assigns and enters player control");
            user.Angle=0;user.Pitch=0;
            Started=level.time;Stage=3;
        }
        else if(Stage==3)
        {
            if(elapsed==60)Check((Gun.Requested || Gun.Shots>0) && Gun.AimPoint.X>Gun.Pos.X+1000,"native Attack aims beyond own physical machine parts");
            if(elapsed<CaelumCannonData.CYCLE*CaelumCannonData.CREW+70)return;
            Check(Gun.Shots==1 && Gun.LastOperator==user,"native cannon fires one unlimited-ammunition shot credited to its player operator");
            Started=level.time;Stage=4;
        }
        else if(Stage==4 && elapsed>=100)
        {
            Check(!CaelumMachineOperator.Find(user).Controlling && Gun.OperatorsPresent()==0,"alternate attack releases the operator bond");
            Console.Printf("CA449 TIMED %s checks=%d failures=%d",Failures==0?"PASS":"FAIL",Checks,Failures);Stage=0;
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca449_seed")Seed();else if(e.Name=="ca449_initial")Initial();}
}
