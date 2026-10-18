// Diagnóstico de #325; usa interacciones, diálogo y estados de producción.
class CA325Probe : CA319Probe
{
    CaelumRestBed Bed;
    Actor Threat;
    bool Revised;

    void SafetyCase(vector3 point,bool blocked,String label)
    {
        Threat.SetOrigin(point,false);
        String rest=CaelumRestState.BlockReason(User);
        String fast=CaelumTimeAdvanceState.BlockReason(User,true,true);
        String skip=CaelumTimeSkipRules.BlockReason(User);
        Console.Printf("CA325 SAFETY %s distance=%.6f sight=%d rest=%s fast=%s skip=%s",label,User.Distance2D(Threat),User.CheckSight(Threat,SF_IGNOREVISIBILITY),rest,fast,skip);
        if(Revised)Check(blocked ? rest=="CA_REST_ENEMY" && fast==rest && skip==rest
            : rest.Length()==0 && fast.Length()==0 && skip.Length()==0,label);
        else Check(rest.Length()==0 && fast.Length()!=0,"baseline lying-down/acceleration discrepancy: "..label);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c325_seed")
        {
            Seed();Revised=e.Args[0]!=0;
            User.SetOrigin((0,512,0),false);User.Vel=(0,0,0);User.Angle=User.Pitch=0;
            User.bInvulnerable=false;User.CombatTimeRemaining=0;User.CurrentSleep=50;
            User.PersistCharacterState();
        }
        if(e.Name=="c325_safety")
        {
            Threat=Actor.Spawn("CaelumMandinga",(1025,512,0),NO_REPLACE);
            Threat.bDormant=true;
            SafetyCase((1023,512,0),true,"enemy just inside 32 metres");
            SafetyCase((1024,512,0),true,"enemy exactly on inclusive 32 metres");
            SafetyCase((1025,512,0),false,"enemy just outside 32 metres");
            User.SetOrigin((0,0,0),false);
            SafetyCase((1024,0,0),false,"opaque pillar hides enemy inside radius");
            User.SetOrigin((0,512,0),false);Threat.bFriendly=true;
            SafetyCase((256,512,0),false,"living friendly body does not block rest");
            Threat.bFriendly=false;Threat.health=0;
            SafetyCase((256,512,0),false,"dead hostile body does not block rest");
            Threat.Destroy();Threat=null;
            User.CombatTimeRemaining=1;
            Check(CaelumRestState.BlockReason(User).Length()!=0 && CaelumTimeAdvanceState.BlockReason(User,true,true).Length()!=0,"active combat still blocks both");
            User.CombatTimeRemaining=0;
            if(Revised)Check(CaelumRestState.BlockReason(User)=="" && CaelumTimeAdvanceState.BlockReason(User,true,true)=="","combat ended and no visible enemy permits both");
        }
        if(e.Name=="c325_bagopen")
        {
            Manual=true;User.InvSel=Bag;
            Check(User.UseInventory(Bag),"native inventory use opens carried bag rest dialogue");
        }
        if(e.Name=="c325_bedopen")
        {
            Manual=true;Bed=CaelumRestBed(Actor.Spawn("CaelumRestBed",(64,512,0),NO_REPLACE));
            User.Pitch=-VectorAngle(64,Bed.Height/2-User.ViewHeight);
            User.player.cmd.buttons|=BT_USE;
            Check(Bed.Used(User),"ordinary aimed Use opens native bed rest dialogue");
            User.player.cmd.buttons&=~BT_USE;
        }
        if(e.Name=="c325_choose")
        {
            let guide=CaelumRestGuide(User.player.ConversationNPC);
            Check(guide!=null && guide.Subject==User,"native rest conversation owns this player");
            let choiceItem=Inventory(Actor.Spawn("CaelumRestSleep60Action"));choiceItem.AttachToOwner(User);
            Check(choiceItem.Use(false),"production dialogue action queues one-hour sleep");
            choiceItem.Destroy();Manual=false;
        }
        if(e.Name=="c325_accelerate")
        {
            Check(CaelumRestState.IsSleeping(User),"native dialogue starts sleeping on selected support");
            String reason=CaelumTimeAdvanceState.BlockReason(User);
            Console.Printf("CA325 ACCELERATION reason=%s",reason);
            Check(CaelumTimeAdvanceState.Toggle(User)==Revised,Revised?"ordinary acceleration starts where lying down was allowed":"baseline rejects acceleration after allowing sleep");
        }
        if(e.Name=="c325_accelerated")
        {
            let advance=CaelumTimeAdvanceState.Get(User);
            Check(advance!=null && advance.SimulatedTics>=104,"real pump advances personal tics from ordinary rest");
            Manual=true;
            Check(CaelumTimeSkipState.OpenMenu(User),"date advance opens from the same resting place");
            let skip=CaelumTimeSkipState.Get(User);
            skip.UseTaskDefault=false;skip.TargetDay=CaelumTimeSkipState.NowDay(User);
            skip.TargetTics=CaelumTimeSkipState.NowTics(User);skip.Shift(User,1);
            Check(CaelumTimeSkipState.Start(User),"date advance starts without a second geographic veto");
        }
        if(e.Name=="c325_skipped")
        {
            let skip=CaelumTimeSkipState.Get(User);
            Check(skip!=null && skip.Completed && skip.LastReason=="CA_SKIP_COMPLETE" && skip.ElapsedTics>0,"date advance reaches the requested minute");
            CaelumTimeSkipState.FinishSkip(User,"CA_SKIP_CANCELLED",true);
        }
        if(e.Name=="c325_done")Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
    }
}
