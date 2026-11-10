class CA448Port : CaelumPortSiege { override void Tick() {} }
class CA448Defender : CaelumPortDefender { override void Tick() {} }
class CA448Commander : CaelumCompanionSubcaptain { override void Tick() {} }

class CA448Checks : EventHandler
{
    CA448Port Port;
    CA448Defender First,Second;
    CA448Commander Commander;
    int Checks,Failures,Stage,OrderSerial;
    vector3 SavedPoint;
    CaelumPortDefender Walker;
    vector3 WalkStart,WalkGoal;
    int WalkTic;

    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA448 %s %s",okay?"PASS":"FAIL",label);}

    void Seed()
    {
        if(Port!=null)return;
        Port=CA448Port(Actor.Spawn('CA448Port',(0,256,0),NO_REPLACE));
        Port.args[0]=3;Port.SetupRevision=3;Port.SiegeStarted=true;Port.RosterSealed=true;
        Commander=CA448Commander(Actor.Spawn('CA448Commander',(-256,256,0),NO_REPLACE));
        First=CA448Defender(Actor.Spawn('CA448Defender',(-128,256,0),NO_REPLACE));
        Second=CA448Defender(Actor.Spawn('CA448Defender',(0,256,0),NO_REPLACE));
        Commander.Port=First.Port=Second.Port=Port;
        Commander.Station=Commander.Pos;First.Station=First.Pos;Second.Station=Second.Pos;
        Port.Subcaptain=Commander;Port.Defenders.Push(Commander);Port.Defenders.Push(First);Port.Defenders.Push(Second);
        for(int i=0;i<98;i++)
        {
            let body=CA448Defender(Actor.Spawn('CA448Defender',(-1000+(i%10)*96,1000+(i/10)*96,0),NO_REPLACE));
            body.Port=Port;body.Station=body.Pos;Port.Defenders.Push(body);
        }
        Port.Reinforcements=new('CaelumSiegeReinforcements');Port.Reinforcements.Remaining=1;
        Stage=1;Console.Printf("CA448 SEEDED");
    }

    void Initial()
    {
        let user=CaelumPlayer(players[0].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        let record=user.GetPersistentCharacterState(true);record.ProfileCommitted=true;record.EnsureQuestStateInitialized();
        record.FactionMember[0]=false;record.FactionReputation[0]=50;
        record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;
        Check(CaelumMilitaryCommand.Access(user)=="CA_MILITARY_MEMBERSHIP","rank and reputation cannot bypass membership");
        record.FactionMember[0]=true;record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_UNDISCOVERED;
        Check(CaelumMilitaryCommand.Access(user)=="CA_MILITARY_OFFICE","membership cannot bypass recognized office");
        record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;record.FactionReputation[0]=49;
        Check(CaelumMilitaryCommand.Access(user)=="CA_MILITARY_REPUTATION","49 reputation fails the approved boundary");
        record.FactionReputation[0]=50;
        Check(CaelumMilitaryCommand.Access(user)=="","all three approved conditions permit command");
        Port.Military=new('CaelumMilitaryCommand');Port.Military.Initialize(Port);
        let command=Port.Military;let group=command.Groups[0];let formation=group.Formation;
        Check(command.Revision==CaelumMilitaryData.REVISION && command.Groups.Size()==2,"revisioned migration enrolls 101 actual bodies");
        Check(formation.Capacity==100 && formation.Members.Size()==100 && command.Groups[1].Formation.Members.Size()==1,"military groups enforce 100 members independently");
        Check(formation.PlayerLeader==null && formation.Leader.Body==Commander,"recognized NPC priority leads without a player-party anchor");
        command.Initialize(Port);Check(command.Groups.Size()==2 && formation.Members.Size()==100,"migration does not duplicate identities");
        CaelumPoiKnowledge.Record(user,"ca448_known",CaelumPoiData.ROOM,"CA_MILITARY_HERE",(512,0,0));
        user.SetOrigin(First.Pos-(64,0,0),false);user.Angle=0;user.Pitch=0;
        user.FolkloreInteractionUseLatched=false;user.player.cmd.buttons|=BT_CROUCH|BT_USE;
        bool opened=First.Used(user);user.player.cmd.buttons&=~(BT_CROUCH|BT_USE);
        Check(opened && CaelumMilitarySession.Find(user)!=null,"crouch and native Use open command on the aimed nearby guard");
        let session=CaelumMilitarySession.Find(user);
        Check(session.Ready && session.Group==group,"session resolves the capable commander of the contacted group");
        session.Act(1);Check(group.Order==CaelumMilitaryData.HOLD && First.MilitaryHoldPoint==First.Pos,"hold preserves individual current positions");
        int prior=Second.MilitaryOrderSerial;vector3 secondPoint=Second.Pos;
        Second.SetOrigin((1536,256,0),false);session.Act(3);
        Check(group.Order==CaelumMilitaryData.REGROUP && Second.MilitaryOrderSerial==prior
            && Second.MilitaryOrderKind==CaelumMilitaryData.HOLD,"out-of-range soldier retains the last received order");
        Check(group.Recipients>0 && group.Recipients<formation.Members.Size(),"command recipients respect the existing communication radius");
        Second.SetOrigin(secondPoint,false);session.Act(1);
        let party=new('CaelumFormation');party.SetPlayerLeader(user);
        Check(party.Capacity==8 && formation.Capacity==100 && formation.PlayerLeader==null,"military command cannot expand or replace the player party");
        record.FactionMember[0]=false;int serial=group.Serial;session.Act(4);
        Check(group.Serial==serial,"live revocation prevents a stale menu order");record.FactionMember[0]=true;
        session.Act(2);Check(group.Point==user.Pos && group.Order==CaelumMilitaryData.ADVANCE,"advance captures the current known player position");
        Check(session.Points.Size()==2,"menu contains only current-map personal knowledge and own position");
        session.Act(7);session.Act(2);SavedPoint=group.Point;OrderSerial=group.Serial;
        Check(SavedPoint==(512,0,0),"known destination uses the saved observation");
        let invented=new('CaelumKnownPoi');invented.MapId=level.MapName;invented.PoiId="ca448_unknown";
        session.Points.Push(invented);session.Selection=session.Points.Size()-1;int saved=group.Serial;session.Act(2);
        Check(group.Serial==saved && session.Status=="CA_MILITARY_UNKNOWN","unrecorded destination fails closed at authoritative execution");
        session.Selection=0;
        session.Act(5);Check(Port.Reinforcements.Remaining==1,"friendly request cannot spend or create hostile reserves");
        Check(session.Status=="CA_MILITARY_NO_RESERVES","empty friendly reserve is reported without creating soldiers");
        Stage=2;Console.Printf("CA448 CHECKPOINT READY failures=%d",Failures);
    }

    void Restored()
    {
        Check(Stage==2 && Port!=null,"common save retains the intended command checkpoint");
        Port.Military.Initialize(Port);
        let group=Port.Military.Groups[0];let formation=group.Formation;
        Check(group.Point==SavedPoint && group.Serial==OrderSerial && group.Order==CaelumMilitaryData.ADVANCE,"save retains exact destination and order serial");
        Check(First.MilitaryGroup==group && First.Formation.Group==formation,"save retains exact membership and formation identity");
        Commander.health=0;Commander.Die(null,null,0,'None');formation.PulseReady=false;group.Refresh();
        Check(formation.Leader!=null && formation.Leader.Body==First,"commander death elects the earliest capable remaining member");
        Check(group.Point==SavedPoint && group.Order==CaelumMilitaryData.ADVANCE,"succession preserves the prior known order");
        for(int i=0;i<formation.Members.Size();i++)formation.Members[i].Body.ForcedSleepTics=100;
        formation.PulseReady=false;group.Refresh();
        Check(formation.Retreat && group.Order==CaelumMilitaryData.WITHDRAW,"no capable successor orders withdrawal");
        First.ForcedSleepTics=0;First.Station=First.Pos+(128,0,0);
        vector3 before=First.Pos;int health=First.health;group.Withdraw(First);
        Check((First.Pos-before).Length()<=First.Speed && First.health==health,"withdrawal uses bounded native movement without healing");
        Check(First.health>0 && !First.bDestroyed && Port.Defenders[1]==First,"withdrawing soldier remains a living registered identity");
        Walker=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',(-512,-512,0),NO_REPLACE));
        Walker.Port=Port;Walker.Station=Walker.Pos;
        let walking=new('CaelumMilitaryGroup');walking.Port=Port;walking.Formation=new('CaelumFormation');walking.Formation.Initialize();
        walking.Formation.Add(Walker,CaelumFormationData.MELEE,CaelumMilitaryData.MEMBER_PRIORITY);Walker.MilitaryGroup=walking;
        walking.Refresh();WalkStart=Walker.Pos;WalkGoal=WalkStart+(256,0,0);walking.SetOrder(CaelumMilitaryData.ADVANCE,WalkGoal);
        Stage=3;WalkTic=level.time;
    }

    override void WorldTick()
    {
        if(Stage!=3 || Walker==null)return;
        int arrival=int(Ceil((WalkGoal-WalkStart).Length()/Max(0.1,Walker.Speed)))*4+TICRATE;
        if(level.time<WalkTic+arrival)return;
        Stage=4;
        Console.Printf("CA448 MOTION pos=%f,%f,%f goal=%f,%f speed=%f order=%d serial=%d leader=%d capable=%d birth=%d see=%d",
            Walker.Pos.X,Walker.Pos.Y,Walker.Pos.Z,WalkGoal.X,WalkGoal.Y,Walker.Speed,Walker.MilitaryOrderKind,
            Walker.MilitaryOrderSerial,int(Walker.MilitaryGroup.Formation.Leader!=null),int(CaelumFormation.Capable(Walker)),
            int(Walker.DefenderBirthInitialized),int(Walker.InStateSequence(Walker.CurState,Walker.SeeState)));
        Check(Walker!=null && !Walker.bDestroyed && Walker.health>0,"native moving soldier remains alive and owned");
        Check((Walker.Pos-WalkStart).Length()>128 && (Walker.Pos-WalkGoal).Length()<=Walker.Radius,"real native actor states execute the received advance order");
        Check(Walker.MilitaryGroup.Formation.Members[0].Body==Walker,"native movement preserves formation identity");
        let walking=Walker.MilitaryGroup;Walker.health=0;Walker.Die(null,null,0,'None');
        let memory=CaelumRedemptionBody(Walker.GiveInventoryType('CaelumRedemptionBody'));memory.Remember();
        bool raised=CaelumResurrection.Restore(Walker,Walker.Pos);
        walking.Formation.PulseReady=false;walking.Refresh();
        Check(raised && Walker.health>0,"same-tic native resurrection retains the real moving body");
        Check(Walker.Formation==null && walking.Formation.Members.Size()==0
            && CaelumMilitaryGroup.Find(Walker)==null,"raised body cannot remain a historical military commander");
        Console.Printf("CA448 RESULT %s checks=%d failures=%d",Failures==0?"PASS":"FAIL",Checks,Failures);
    }

    void LegacyRestored()
    {
        Check(Stage==2 && Port.Military==null,"original pre-command save has no synthesized order");
        int count=Port.Defenders.Size();Port.Military=new('CaelumMilitaryCommand');Port.Military.Initialize(Port);
        Check(Port.Military.Revision==CaelumMilitaryData.REVISION && Port.Military.Groups.Size()==2,"old native save creates revisioned command groups");
        Check(Port.Defenders.Size()==count && Port.Defenders[1]==First && Port.Defenders[2]==Second,"migration retains original defender identities");
        Check(Port.Reinforcements.Remaining==1,"command migration does not reset finite reserves");
        Port.Military.Initialize(Port);Check(Port.Military.Groups.Size()==2,"repeated old-save migration is idempotent");
        Console.Printf("CA448 LEGACY %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    void Catchup() {}
    void VerifyTravel()
    {
        let group=Port.Military.Groups[0];
        Check(Stage==2 && group.Point==SavedPoint && group.Serial==OrderSerial,"hub return retains known destination and exact command serial");
        Check(First.MilitaryGroup==group && group.Formation.Leader.Body==Commander,"hub return retains group and commander identities");
        Check(Port.Defenders.Size()==101 && Port.Reinforcements.Remaining==1,"hub return creates no troops or reserves");
        Console.Printf("CA448 TRAVEL %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca448_seed")Seed();
        else if(e.Name=="ca448_initial")Initial();
        else if(e.Name=="ca448_restored")Restored();
        else if(e.Name=="ca448_legacy")LegacyRestored();
        else if(e.Name=="ca448_travel")Level.ChangeLevel('T448',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca448_return")Level.ChangeLevel('MAP03',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca448_verifytravel")VerifyTravel();
    }
}
