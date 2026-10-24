// Diagnóstico privado: separación entre resultado y conocimiento.
class CA415Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String message)
    {if(ok)Passed++;else Failed++;Console.Printf("CA415 %s %s",ok?"PASS":"FAIL",message);}
    CaelumScheduleState Fresh(CaelumPlayer user)
    {
        let old=CaelumScheduleState.Get(user);if(old!=null)old.Destroy();
        return CaelumScheduleState.Get(user,true);
    }
    void Core(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user,true);
        CaelumCalendarState.Get(user,true).EnsureCampaign(clock);
        let agenda=Fresh(user);
        let old=new('CaelumScheduledEvent');old.Processed=7;old.EnsureKnowledge();
        Check(old.ObservedCount()==7 && old.KnowledgeRevision==1,"legacy outcomes remain known");
        old.KnownProcessed=3;old.EnsureKnowledge();
        Check(old.ObservedCount()==3,"knowledge migration is idempotent");
        Check(CaelumScheduleRules.SameRegion("MAP03","MAP03")
            && !CaelumScheduleRules.SameRegion("MAP03","MAP01")
            && !CaelumScheduleRules.SameRegion("CAM415B","CAM415"),"region identity does not merge unknown maps");
        let remote=agenda.AddAfter(user,"remote",CaelumScheduleRules.NOTICE,"CA_EVENT_NOTICE","CAM415B",0);
        let hidden=agenda.AddAfter(user,"hidden",CaelumScheduleRules.NOTICE,"CA_EVENT_NOTICE","CAM415B",0);hidden.Visible=false;
        CaelumScheduleState.Sync(user);
        Check(remote.Processed==1 && remote.ObservedCount()==0,"remote outcome occurs without disclosure");
        Check(agenda.Notices==0 && !hidden.Visible,"remote hidden event sends no notice and remains hidden");
        Check(remote.KnownStatusKey()=="CA_EVENT_UNCONFIRMED" && remote.KnownNextStamp()==remote.FirstStamp(),"calendar retains unconfirmed planned date");
        int revision=agenda.Revision;CaelumScheduleState.Sync(user);
        Check(agenda.Notices==0 && agenda.Revision==revision && remote.Processed==1,"repeated synchronization does not replay");
        Check(agenda.Discover("CAM415B")==2 && hidden.Visible && remote.ObservedCount()==1,"return reveals both known and previously hidden outcomes");
        Check(agenda.Discover("CAM415B")==0 && remote.KnownNextStamp()<0,"repeated return does not duplicate discovery");
        let local=agenda.AddAfter(user,"local",CaelumScheduleRules.NOTICE,"CA_EVENT_NOTICE",level.MapName,0);
        CaelumScheduleState.Sync(user);
        Check(local.Processed==1 && local.ObservedCount()==1 && agenda.Notices==1,"local outcomes disclose immediately exactly once");
        let recurring=agenda.AddAfter(user,"recurring",CaelumScheduleRules.RENT,"CA_EVENT_RENT","CAM415B",0,1,0);recurring.Value=2;
        clock.AdvanceTics(CaelumWorldClock.TicsPerDay()*100);
        Check(recurring.Processed==144001 && recurring.KnownProcessed==0 && recurring.Debt()==288002
            && recurring.KnownDebt()==0,"long skip reconciles arithmetic counters without revealing remote debt");
        Check(agenda.Discover("CAM415B")==1 && recurring.KnownDebt()==288002,"discovery reveals accumulated outcome");
        agenda=Fresh(user);
        let record=user.GetPersistentCharacterState(true);int quest=CaelumConstants.QUEST_TRIAL_ROUTE;
        record.QuestState[quest]=CaelumConstants.QUEST_STATE_ACTIVE;
        int objective=quest*CaelumConstants.QUEST_OBJECTIVE_CAPACITY;
        record.QuestObjectiveTarget[objective]=1;record.QuestObjectiveProgress[objective]=0;
        let later=agenda.AddAfter(user,"later",CaelumScheduleRules.QUEST,"CA_EVENT_QUEST","CAM415C",2);later.Value=quest;
        let earlier=agenda.AddAfter(user,"earlier",CaelumScheduleRules.QUEST,"CA_EVENT_QUEST","CAM415B",1);earlier.Value=quest;
        clock.AdvanceTics(CaelumWorldClock.TicsPerHour()/20);
        Check(earlier.DeadlineFailed && !later.DeadlineFailed,"deadlines resolve in due order rather than insertion order");
        Check(record.QuestState[quest]==CaelumConstants.QUEST_STATE_FAILED
            && CaelumQuestCatalogue.State(record,quest)==CaelumConstants.QUEST_STATE_ACTIVE,"remote failure is authoritative while journal retains prior knowledge");
        user.RefreshSocialJournalSnapshot();
        Check(user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_ACTIVE,"refreshing journal cannot expose remote failure");
        Check(agenda.Discover("CAM415C")==1 && CaelumQuestCatalogue.State(record,quest)==CaelumConstants.QUEST_STATE_ACTIVE,"visiting later unrelated deadline region does not disclose earlier cause");
        agenda.Discover("CAM415B");
        Check(CaelumQuestCatalogue.State(record,quest)==CaelumConstants.QUEST_STATE_FAILED,"return to failed quest region reveals failure");
        Array<CaelumScheduledEvent> due;
        for(int i=0;i<CaelumScheduleRules.MAX_RECORDS;i++)
        {let event=new('CaelumScheduledEvent');event.EventId=i;event.DueDay=10;event.DueTic=(2047-i)/2;event.Limit=1;due.Push(event);}
        double started=MSTimeF();CaelumScheduleState.SortDue(due);
        Console.Printf("CA415 TIMING maximum queue sort ms=%.6f",MSTimeF()-started);
        bool ordered=true;
        for(int i=1;i<due.Size();i++)if(!CaelumScheduleState.Earlier(due[i-1],due[i]))ordered=false;
        Check(ordered && due.Size()==2048,"maximum queue sorts by timestamp and stable ID");
        agenda=Fresh(user);let seed=agenda.AddAfter(user,"persist",CaelumScheduleRules.NOTICE,"CA_EVENT_NOTICE","CAM415B",0);
        CaelumScheduleState.Sync(user);user.PersistCharacterState();
        Check(seed.Processed==1 && seed.KnownProcessed==0,"seed undisclosed outcome for native persistence");
    }
    void Verify(CaelumPlayer user,int expectedKnown)
    {
        let agenda=CaelumScheduleState.Get(user);let event=agenda!=null ? agenda.FindKey("persist") : null;
        Check(event!=null && event.Processed==1 && event.KnowledgeRevision==1,"native save/hub keeps actual outcome and schema");
        if(event==null)return;
        int before=agenda.Notices;CaelumScheduleState.Sync(user);
        Check(event.KnownProcessed==expectedKnown,"native location disclosure preserves known history");
        Check(agenda.Notices==before,"cached synchronization does not duplicate notices");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca415_preview")
        {
            let agenda=Fresh(user);
            agenda.AddAfter(user,"preview",CaelumScheduleRules.NOTICE,"CA_EVENT_NOTICE","CAM415B",0);
            CaelumScheduleState.Sync(user);
            Console.Printf("CA415 RESULT preview ready: event resolved elsewhere; travel with F1, return with F2.");
            return;
        }
        if(e.Name=="ca415_report")
        {
            let agenda=CaelumScheduleState.Get(user);let entry=agenda!=null ? agenda.FindKey("preview") : null;
            if(entry!=null)Console.Printf("CA415 RESULT map=%s actual=%d known=%d notices=%d",level.MapName,entry.Processed,entry.ObservedCount(),agenda.Notices);
            return;
        }
        if(e.Name=="ca415_core")Core(user);
        else if(e.Name=="ca415_verify")Verify(user,e.Args[0]);
        else return;
        Console.Printf("CA415 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
