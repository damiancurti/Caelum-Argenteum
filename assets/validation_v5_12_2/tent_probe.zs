// Dos cuerpos nativos y dos sacos propios; la carpa conserva un solo título.
class CA436ClockProbe : EventHandler
{
    int Phase,Start,Received[MAXPLAYERS];
    CaelumDeployedTent Tent;
    CaelumSleepingBag Bags[2];
    CaelumRestBag Mats[2];
    CaelumCooperativeTime Vote;
    ui bool Sent;
    ui int SentVote;
    void Check(bool value,String text){Console.Printf("CA436 %s %s",value?"PASS":"FAIL",text);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(!Sent && Phase>=1){Sent=true;SendNetworkEvent("ca436_tent_ready",consoleplayer);}
        if(Phase==3 && Vote!=null && Vote.Opened && Vote.Serial!=SentVote)
        {SentVote=Vote.Serial;SendNetworkEvent("ca_cooperative_time",CaelumCooperativeTime.ACCEPT,Vote.Serial);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca436_tent_ready" && e.Args[0]==e.Player){Received[e.Player]++;Console.Printf("CA436 EVENT peer=%d sender=%d serial=%d",consoleplayer,e.Player,e.Player);}}
    override void WorldTick()
    {
        if(Phase==5 || level.time<105)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(Phase==0)
        {
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);user.SetOrigin((96,400+i*64,0),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=20;
                user.CombatTimeRemaining=0;
                if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
                user.player.ConversationNPC=null;user.player.ConversationPC=null;
                Bags[i]=CaelumSleepingBag(user.GiveInventoryType('CaelumSleepingBag'));
                CaelumLockRules.Character(user,true);
            }
            Tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',(0,432,0),NO_REPLACE));Tent.Title=CaelumLockRules.Character(a);
            Check(Tent.Prepare(),"real tent geometry prepared");
            Check(Bags[0]!=Bags[1] && Bags[0].Owner==a && Bags[1].Owner==b,"each player owns a separate physical bag");
            Check(!CaelumLockRules.SameTitle(Tent.Title,CaelumLockRules.Character(b)),"guest does not acquire tent ownership");
            Check(!CaelumCampTask.BeginPack(b,Tent),"guest cannot dismantle owner's tent");
            Check(CaelumTentRest.Begin(a,Tent,Bags[0],60),"owner enters first real berth");
            Check(CaelumRestState.IsActive(a) && !CaelumRestState.IsActive(b),"one player sleeps while the other stays active");
            Mats[0]=CaelumRestBag.ReservedBag(a);Start=level.time;Phase=1;return;
        }
        if(Phase==1 && level.time>=Start+35)
        {
            Check(CaelumRestState.IsActive(a) && !CaelumCooperativeTime.View(a),"individual sleep does not start shared acceleration");
            Check(CaelumTentRest.Begin(b,Tent,Bags[1],60),"cooperative guest enters second real berth");
            Mats[1]=CaelumRestBag.ReservedBag(b);
            Check(Mats[0]!=null && Mats[1]!=null && Mats[0]!=Mats[1] && Mats[0].Tent==Tent && Mats[1].Tent==Tent,"two physical mats occupy the same tent");
            Check(Tent.Covers(a) && Tent.Covers(b) && a.Distance2D(b)>=a.Radius+b.Radius,"both bodies fit without overlapping collisions");
            Check(!CaelumCampTask.BeginPack(a,Tent),"owner cannot dismantle an occupied tent");
            Check(CaelumCooperativeTime.Open(a),"sleeping players can propose a shared duration");
            Vote=CaelumCooperativeTime.View(a);Phase=2;Start=level.time;return;
        }
        if(Phase==2 && level.time>=Start+35)
        {
            Check(Vote!=null && !Vote.Running,"no acceleration before unanimous consent");
            if(Vote==null){Phase=5;return;}Phase=3;return;
        }
        if(Phase==3 && Vote.Running)
        {
            Check(Received[0]==1 && Received[1]==1 && Vote.Accepted==Vote.Mask,"both native peers accepted the same duration");
            CaelumRestState.Cancel(a);Start=level.time;Phase=4;return;
        }
        if(Phase==4 && level.time>=Start+2)
        {
            Check(!Vote.Running && !Vote.Opened,"waking one participant cancels shared acceleration");
            Check(!CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"other participant keeps individual sleep");
            Check(Bags[0].Owner==a && Bags[1].Owner==b && Bags[0].Amount==1 && Bags[1].Amount==1,"standing retains both original bags without duplicate grants");
            CaelumRestState.Cancel(b);
            Check(!Tent.HasRestingOccupant(),"last wake releases the tent");
            Phase=5;Console.Printf("CA436 RESULT peer=%d tent",consoleplayer);
        }
    }
}
