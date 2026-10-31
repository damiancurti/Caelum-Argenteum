// Shared save/restart uses isolated per-peer directories, never user saves.
class CA436ClockProbe : EventHandler
{
    int Phase;
    bool Reloaded,Verified;
    ui bool Saved;
    CaelumRestChair Chairs[2];
    CaelumCooperativeTime Proposal;
    int SavedSerial;
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame)Reloaded=true;}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca436_verify_reload" && e.Player==0)Reloaded=true;
    }
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer!=0 || Reloaded || Saved || Phase!=1)return;
        Saved=true;
        // DoSave(0) selects an unused filename in this new isolated directory.
        SavegameManager.GetManager().DoSave(0,"CA436 shared pending consent");
    }
    override void WorldTick()
    {
        if(Verified || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!Reloaded && Phase==0)
        {
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);user.SetOrigin((i*256-128,400,0),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=50;
                Chairs[i]=CaelumRestChair(Actor.Spawn('CaelumRestChair',(i*256-128,448,0),NO_REPLACE));
                Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,Chairs[i]),"seat starts before shared save");
            }
            Check(CaelumCooperativeTime.Open(a),"pending unanimous proposal is serializable");
            Proposal=CaelumCooperativeTime.View(a);
            Check(Proposal.Request(a,CaelumCooperativeTime.ACCEPT,Proposal.Serial) && !Proposal.Running,"only first consent stored before checkpoint");
            SavedSerial=Proposal.Serial;Phase=1;
            Console.Printf("CA436 RESULT peer=%d fresh",consoleplayer);return;
        }
        if(Reloaded && Phase==1)
        {
            Check(CaelumCooperativeTime.View(a)==Proposal && CaelumCooperativeTime.View(b)==Proposal,"both native peers restore same proposal reference");
            Check(Proposal!=null && Proposal.Serial==SavedSerial && Proposal.Accepted==1 && !Proposal.Running,"saved consent and revision survive restart");
            Check(CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b) && Chairs[0].Occupant==a && Chairs[1].Occupant==b,"actual seats and occupants survive restart");
            let x=CaelumWorldClock.Get(a);let y=CaelumWorldClock.Get(b);
            Check(x.DayTics==y.DayTics && x.CompletedDays==y.CompletedDays && x.LimboSubTics==y.LimboSubTics,"shared clock survives restart");
            Check(!Proposal.Request(a,CaelumCooperativeTime.ACCEPT,SavedSerial),"replaying saved consent remains rejected");
            Check(Proposal.Request(b,CaelumCooperativeTime.CANCEL,SavedSerial) && CaelumCooperativeTime.View(a)==null && CaelumCooperativeTime.View(b)==null,"other peer can cancel restored proposal");
            Verified=true;Console.Printf("CA436 RESULT peer=%d restored",consoleplayer);
        }
    }
}
