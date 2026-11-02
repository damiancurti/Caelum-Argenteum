class CA440TowerBlock : Actor
{
    Default {Radius 20;Height 128;+SOLID +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440TowerLedger : Inventory
{
    int Phase;
    CaelumCannon Gun;
    CaelumBatteringRam Ram;
    CaelumSiegeEncounter Encounter;
    CaelumCombatActor Operator;
    int OperatorHealth;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440R %s %s",ok?"PASS":"FAIL",label);}
    void Aim(CaelumPlayer user,Actor body)
    {
        vector3 delta=body.Pos+(0,0,body.Height/2)-CaelumTelekinesisRules.Eye(user);
        user.Angle=VectorAngle(delta.X,delta.Y);user.Pitch=-VectorAngle(delta.XY.Length(),delta.Z);
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440TowerLedger(user.FindInventory('CA440TowerLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(Reloaded)
        {
            if(ledger.Phase!=5)return;
            Check(ledger.Gun!=null && ledger.Ram!=null,"load retains exact objective records");
            Check(ledger.Gun.TarotDestroyed && ledger.Ram.TarotDestroyed,"load retains destroyed flags");
            ledger.Gun.InitializeCannon();ledger.Ram.InitializeRam();
            Check(ledger.Gun.Blocks.Size()==0 && ledger.Ram.Head==null && ledger.Ram.FrameBlocks.Size()==0,"load does not recreate collision parts");
            Check(!ledger.Ram.ActivateRam() && !ledger.Gun.ArmMachine(),"destroyed machines cannot rearm");
            Check(ledger.Operator.health==ledger.OperatorHealth && ledger.Operator.SiegeCombatant.CrewMachine==null,"operator remains alive and released after load");
            ledger.Encounter.ResolveVictory();
            Check(ledger.Encounter.Victory && ledger.Encounter.VictoryCount==1,"load does not repeat encounter victory");
            Check(!CaelumMajorTargets.Tower(ledger.Gun),"repeat destruction is rejected");
            ledger.Phase=6;Console.Printf("CA440R RESULT reload");return;
        }
        if(ledger!=null)
        {
            // El perfil/armadura del NPC termina su recálculo nativo después
            // del Spawn. Guardar su salud estabilizada, no el máximo inicial.
            if(ledger.Phase==4){ledger.OperatorHealth=ledger.Operator.health;ledger.Phase=5;user.PersistCharacterState();}
            return;
        }
        ledger=CA440TowerLedger(user.GiveInventoryType('CA440TowerLedger'));
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotEffectTics=0;record.TarotCooldownTics=0;record.TarotOrderCount=0;record.TarotLoadoutRevision=1;
        user.SetOrigin((-256,0,0),false);other.SetOrigin((-600,-600,0),false);
        let gun=CaelumCannon(Actor.Spawn('CaelumCannon',(0,0,0),NO_REPLACE));gun.InitializeCannon();ledger.Gun=gun;
        let ram=CaelumBatteringRam(Actor.Spawn('CaelumBatteringRam',(400,400,0),NO_REPLACE));ram.InitializeRam();ledger.Ram=ram;
        let encounter=CaelumSiegeEncounter(Actor.Spawn('CaelumSiegeEncounter',(700,700,0),NO_REPLACE));ledger.Encounter=encounter;
        encounter.RegisterMachine(gun);encounter.RegisterMachine(ram);
        for(int i=0;i<10;i++)
        {let dummy=CaelumHostileMachine(Actor.Spawn('CaelumHostileMachine',(750,750,0),NO_REPLACE));dummy.Neutralized=true;encounter.RegisterMachine(dummy);}
        let boss=new('CaelumSiegeCombatant');boss.ConfirmedDead=true;encounter.Boss=boss;
        let crew=CaelumCombatActor(Actor.Spawn('CaelumMandinga',(500,-500,0),NO_REPLACE));crew.bDormant=true;
        encounter.RegisterAttacker(crew);Check(gun.AssignOperator(crew),"native cannon accepts real living operator");ledger.Operator=crew;ledger.OperatorHealth=crew.health;
        encounter.RosterSealed=true;
        CaelumTarotService.Select(user,16);CaelumTarotService.Select(user,9);user.CurrentAnima=user.DerivedStats.MaximumAnima;
        Actor part=gun.Blocks[12];Aim(user,part);
        Check(CaelumMajorTargets.Machine(CaelumMajorTargets.Aim(user))==gun,"native reticle resolves collision part to exact machine");
        double range=user.DerivedStats.AbilityRangePercent;user.DerivedStats.AbilityRangePercent=1;
        Check(CaelumMajorTargets.Machine(CaelumMajorTargets.Aim(user))==null,"target beyond scaled range is omitted");user.DerivedStats.AbilityRangePercent=range;
        let block=Actor.Spawn('CA440TowerBlock',(-128,0,0),NO_REPLACE);
        Check(CaelumMajorTargets.Machine(CaelumMajorTargets.Aim(user))==null,"solid obstacle blocks machine targeting");block.Destroy();
        Check(!CaelumMajorTargets.Tower(crew),"ordinary character cannot be destroyed by Tower");
        double anima=user.CurrentAnima;
        Check(CaelumTarotService.Activate(user),"native Tower sequence activates");
        Check(gun.TarotDestroyed && gun.Neutralized && gun.NeutralizationCount==1 && gun.health==0,"destruction records one resolved objective");
        Check(gun.Blocks.Size()==0 && gun.Frame==null && gun.Barrel==null,"cannon visual and collision parts are removed");
        Check(crew.health==ledger.OperatorHealth && crew.SiegeCombatant.CrewMachine==null,"operator keeps Health and leaves machine assignment");
        Check(encounter.Machines[0]==gun && !encounter.Victory,"objective identity remains and unfinished ram blocks victory");
        Check(record.TarotRemaining[16]==0 && abs(user.CurrentAnima-(anima-1000))<0.0001,"instant Tower is not repeated by Hermit and pays once");
        Check(!CaelumMajorTargets.Tower(gun) && gun.NeutralizationCount==1,"repeat invocation cannot count same machine twice");
        Check(CaelumMajorTargets.Tower(ram.Head),"ram head resolves to its machine");
        Check(ram.Head==null && ram.FrameBlocks.Size()==0 && ram.FaceBlocks.Size()==0 && ram.Rods.Size()==0,"ram removes all collision and suspension parts");
        Check(encounter.Victory && encounter.VictoryCount==1,"twelve resolved machines and defeated commander complete encounter");
        ledger.Phase=4;Console.Printf("CA440R RESULT capture");
    }
}
