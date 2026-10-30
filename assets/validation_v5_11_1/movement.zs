class CA429Movement : EventHandler
{
    CaelumFormation Group;
    Array<CA429Body> Bodies;
    bool Active,SawColumn,SawRecovery,Overlapped,Finished;
    int Started,Failures;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA429 PASS %s",label);else{Failures++;Console.Printf("CA429 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca429_march')return;
        let user=CaelumPlayer(players[0].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();
        user.bInvulnerable=true;user.bNoClip=true;user.bShootable=false;user.SetOrigin((-900,300,0),false);
        Group=new('CaelumFormation');Group.Initialize();
        for(int i=0;i<5;i++)
        {
            let body=CA429Body(Actor.Spawn('CA429Body',(-700,-96+i*48,0),NO_REPLACE));
            Bodies.Push(body);Group.Add(body,0,i==2?1:2);
        }
        Group.Refresh();Group.Heading=0;
        Started=level.time;Active=true;
    }
    override void WorldTick()
    {
        if(!Active || Finished)return;
        Group.Refresh();let leader=Group.Leader.Body;
        if(leader.Pos.X<800)leader.ThermalTryMove((Min(800,leader.Pos.X+leader.Speed),0));
        for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=leader)Group.Follow(Bodies[i].Formation);
        if(Group.SingleFile)SawColumn=true;
        if(SawColumn && !Group.SingleFile && leader.Pos.X>384)SawRecovery=true;
        for(int a=0;a<Bodies.Size();a++)for(int b=a+1;b<Bodies.Size();b++)
            if((Bodies[a].Pos.XY-Bodies[b].Pos.XY).Length()<Bodies[a].Radius+Bodies[b].Radius-0.001)Overlapped=true;
        if((level.time-Started)%175==0)
            Console.Printf("CA429 MARCH t=%d lead=%.1f tail=%.1f column=%d",level.time-Started,leader.Pos.X,Bodies[4].Pos.X,int(Group.SingleFile));
        if(level.time-Started<1400)return;
        Finished=true;bool arrived=true;
        for(int i=0;i<Bodies.Size();i++)
        {Console.Printf("CA429 BODY %d %.3f %.3f",i,Bodies[i].Pos.X,Bodies[i].Pos.Y);if(Bodies[i].Pos.X<384)arrived=false;}
        Check(SawColumn,"blocked formation enters single file");
        Check(arrived,"every body crosses narrow passage with native collision");
        Check(SawRecovery && !Group.SingleFile,"open ground restores selected formation");
        Check(!Overlapped,"march never overlaps collision bodies");
        Console.Printf("CA429 RESULT movement complete failures=%d",Failures);
    }
}
