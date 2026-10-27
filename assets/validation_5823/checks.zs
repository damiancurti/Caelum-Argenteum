class CA502HistoryChecks : EventHandler
{
    Actor Probe;
    int Passed,Failed;
    double SavedStamp,SavedAmbient,SavedArea;
    void Check(bool condition,String label)
    {if(condition)Passed++;else Failed++;Console.Printf("CA502H %s %s",condition?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Profile(CaelumPlayer user)
    {
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        user.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        user.GetPersistentCharacterState(true).ProfileCommitted=true;
        user.A_SetBlend("Black",0,1);user.CurrentHunger=100;
    }
    void Setup(CaelumPlayer user)
    {
        Profile(user);
        if(Probe==null){Probe=Actor.Spawn('CaelumRestChair',(640,-896,0),NO_REPLACE);Probe.ChangeTid(905230);}
    }
    void Core(CaelumPlayer user)
    {
        Setup(user);let state=CaelumContaminationStorage.Get(Probe,true);
        let node=state.Exposure;Check(node!=null,"spawn owns one exposure node");if(node==null)return;
        node.Advance();double now=node.Stamp;
        Check(node.HistoryReady && node.Revision==2 && node.HistoryAmbient>=0,"actual Limbo climate records revision2 constant interval");
        CaelumContaminationStorage.Set(Probe,0);double ambient=node.HistoryAmbient,area=node.HistoryArea;
        node.HistoryStamp=now-600;node.Ready=false;
        double expected=CaelumContaminationObjectBalance.Evolve(0,ambient,0,area,600);
        Check(Near(CaelumContaminationStorage.Value(Probe),expected),"first value query settles saved absence before contact");
        Check(Near(node.HistoryStamp,now) && node.Ready,"settlement advances anchor once");
        Check(Near(CaelumContaminationStorage.Value(Probe),expected),"repeated query cannot duplicate absence");
        CaelumContaminationStorage.Set(Probe,90);node.Ready=false;node.HistoryStamp=now-86400000;
        Check(Near(CaelumContaminationStorage.Value(Probe),90),"long clean-ambient absence cannot wash prior dirt");
        CaelumContaminationStorage.Set(Probe,7);node.Revision=1;node.Ready=false;node.HistoryStamp=now-600;
        node.Advance();Check(Near(state.Concentration,7) && node.Revision==2,"legacy migration preserves dirt without retroactive exposure");
        Check(node.HistoryReady && Near(node.HistoryStamp,now),"migration begins new history at current clock");
        node.HistoryStamp=now+60;node.Ready=false;double future=node.HistoryStamp;
        Check(Near(CaelumContaminationStorage.Value(Probe),7) && Near(node.HistoryStamp,future),"backward clock cannot backdate anchor or charge exposure");
        node.HistoryStamp=now;node.Advance();
        let weather=CaelumThermalWorld.Get().ReferenceWeather;int profile=weather.Profile;
        weather.Profile=CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL;node.Advance();
        Check(!node.HistoryReady,"variable exterior climate is not frozen into a false constant history");
        weather.Profile=profile;node.Advance();
        CaelumContaminationStorage.Set(Probe,0);node.Ready=false;node.HistoryStamp=now-315360000;
        double began=MSTimeF();double value=CaelumContaminationStorage.Value(Probe);double elapsed=MSTimeF()-began;
        Check(Near(value,node.HistoryAmbient),"ten-year constant interval settles analytically");
        Console.Printf("CA502H TIMING ten_year_ms=%.6f",elapsed);
        node.Ready=false;node.HistoryStamp=now-600;CaelumContaminationStorage.Set(Probe,0);
        Check(Near(state.Concentration,0) && Near(node.HistoryStamp,now),"explicit cleaning settles prior history before setting clean value");
        Check(Near(CaelumContaminationStorage.Value(Probe),0),"prior absence cannot contaminate a just-cleaned object again");
    }
    void Seed(CaelumPlayer user)
    {
        Setup(user);let node=CaelumContaminationStorage.Get(Probe,true).Exposure;node.Advance();
        SavedStamp=node.Stamp;SavedAmbient=node.Ambient;SavedArea=CaelumContaminationObject.Area(Probe);
        CaelumContaminationStorage.Set(Probe,0);Check(node.HistoryReady,"seed retains actual constant-climate metadata");
    }
    void Resume(CaelumPlayer user)
    {
        if(Probe==null){let found=ActorIterator.Create(905230);Probe=found.Next();}
        Check(Probe!=null,"saved map actor identity restored");if(Probe==null)return;
        let node=CaelumContaminationStorage.Get(Probe).Exposure;
        node.Advance();
        double now=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(user));
        double expected=CaelumContaminationObjectBalance.Evolve(0,SavedAmbient,0,SavedArea,now-SavedStamp);
        Check(Near(CaelumContaminationStorage.Value(Probe),expected),"native save or hub retains elapsed constant exposure");
        Check(node.Revision==2 && node.HistoryReady,"native snapshot preserves history revision and ownership");
    }
    void Legacy(CaelumPlayer user)
    {
        Check(Probe!=null,"previous package actor restored");if(Probe==null)return;
        let node=CaelumContaminationStorage.Get(Probe).Exposure;node.Advance();
        Check(Near(CaelumContaminationStorage.Value(Probe),77),"previous saved dirt is conserved");
        Check(node.Revision==2 && node.HistoryReady,"previous node gains current snapshot idempotently");
    }
    void View(CaelumPlayer user)
    {
        if(Probe==null)return;
        user.player.camera=user;
        user.SetOrigin(Probe.Pos+(-64,0,0),false);user.FindFloorCeiling();user.Vel=(0,0,0);
        user.Angle=0;user.Pitch=ATan2(user.ViewHeight-Probe.Height/2,64);
        Check(Probe.TestMobjLocation(),"manual fixture has unobstructed placement");
        Check(user.TestMobjLocation(),"manual viewpoint has unobstructed placement");
        Console.Printf("CA502H MANUAL sink contamination=%.3f /100, ambient=%.3f",CaelumContaminationStorage.Value(Probe),SavedAmbient);
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        let user=CaelumPlayer(players[event.Player].mo);if(user==null)return;
        if(event.Name=='ca502h_profile')Profile(user);
        else if(event.Name=='ca502h_manualprepare')
        {
            let installation=CaelumMansionBathrooms.Find();
            Check(installation!=null,"manual bathroom installation exists");
            if(installation!=null)Probe=installation.Fixtures[0];
            Check(Probe!=null,"manual uses existing mansion sink");
        }
        else if(event.Name=='ca502h_prepare')Setup(user);
        else if(event.Name=='ca502h_core')Core(user);
        else if(event.Name=='ca502h_seed')Seed(user);
        else if(event.Name=='ca502h_resume')Resume(user);
        else if(event.Name=='ca502h_legacy')Legacy(user);
        else if(event.Name=='ca502h_view')View(user);
        else if(event.Name=='ca502h_away')CaelumWorldClock.Get(user).AdvanceTics(CaelumWorldClock.TicsPerHour()/2);
        else return;
        Console.Printf("CA502H RESULT passed=%d failed=%d",Passed,Failed);
    }
}
class CA502HistoryProp : Actor
{Default {Radius 8;Height 16;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
