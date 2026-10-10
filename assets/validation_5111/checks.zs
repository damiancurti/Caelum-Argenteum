// Isolated UI dispatch checks against a protected author checkpoint.
class CA156Checks : StaticEventHandler
{
    int Elapsed, Step, Passed, Failed, StartTics, InitialWork, InitialCount;
    ui int Sent;
    void Check(String label,bool ok)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA156 %s %s",ok?"PASS":"FAIL",label);
    }
    int Items(CaelumPlayer u)
    {int n=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)n++;return n;}
    override void WorldTick()
    {
        Elapsed++;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let s=CaelumTimeSkipState.Get(u);if(s==null)return;
        if(Elapsed==20)
        {
            Check("checkpoint loaded completed task",s.Open && s.Completed && !u.CraftingTaskActive);
            InitialWork=s.WorkTics;InitialCount=Items(u);
            StartTics=CaelumTimeSkipState.NowTics(u);Step=1;
        }
        if(Elapsed==55)
        {
            Check("Enter rejects past target",!s.Active && s.LastReason=="CA_SKIP_FUTURE");
            Check("invalid Enter cannot skip time",CaelumTimeSkipState.NowTics(u)-StartTics<10);
            Step=2;
        }
        if(Elapsed==90)
        {
            Check("Q closes completed panel",!s.Open);
            Check("Q preserves completed work and task",s.WorkTics==InitialWork && !u.CraftingTaskActive);
            Check("Q preserves inventory",Items(u)==InitialCount);
            CaelumTimeSkipState.OpenMenu(u);Step=3;
        }
        if(Elapsed==125)
        {Check("uppercase Q closes",!s.Open);CaelumTimeSkipState.OpenMenu(u);Step=4;}
        if(Elapsed==160)
        {Check("Tab closes",!s.Open);CaelumTimeSkipState.OpenMenu(u);Step=5;}
        if(Elapsed==195)
        {Check("controller B closes",!s.Open);CaelumTimeSkipState.OpenMenu(u);s.UseTaskDefault=false;s.HadTask=true;Step=6;}
        if(Elapsed==230)
        {
            Check("R refreshes task state",s.UseTaskDefault && !s.HadTask && s.Forecast==null);
            s.UseTaskDefault=false;s.HadTask=true;Step=7;
        }
        if(Elapsed==265)
        {
            Check("uppercase R refreshes",s.UseTaskDefault && !s.HadTask);
            s.UseTaskDefault=false;Step=8;
        }
        if(Elapsed==300)
        {
            Check("arrows edit selected field",s.Field==1);
            StartTics=s.TargetTics;Step=9;
        }
        if(Elapsed==335)
        {
            Check("up arrow advances one hour",s.TargetTics==StartTics+CaelumWorldClock.TicsPerHour());
            StartTics=CaelumTimeSkipState.NowTics(u);Step=10;
        }
        if(Elapsed==350)
        {
            Check("Enter starts future skip",s.Active);
            Check("valid skip advances clock",CaelumTimeSkipState.NowTics(u)>StartTics);
            Step=11;
        }
        if(Elapsed==370)
        {
            Check("Q stops active skip but leaves panel",!s.Active && s.Open && s.Completed);
            InitialWork=s.WorkTics;Step=12;
        }
        if(Elapsed==405)
        {
            Check("second Q closes stopped panel",!s.Open && s.WorkTics==InitialWork);
            CaelumTimeSkipState.OpenMenu(u);Step=13;
        }
        if(Elapsed==440)
        {
            Check("released Q does not close panel",s.Open);
            Step=14;
        }
        if(Elapsed==475)
        {Check("Escape leaves modal state intact",s.Open);Step=15;}
        if(Elapsed==510)
        {Check("console key leaves modal state intact",s.Open);Step=16;}
        if(Elapsed==545)
        {
            Check("confirmation can be cancelled",!s.Open && !s.ConfirmPending);
            Console.Printf("CA156 RESULT passed=%d failed=%d",Passed,Failed);Step=17;
        }
        // Fixture-only pending confirmation: do not invent a crafting recipe.
        if(Elapsed==509)s.ConfirmPending=true;
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(Step==0 || Step==Sent || Step>16)return;
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        int scan=0,character=0,type=InputEvent.Type_KeyDown;
        if(Step==1 || Step==10)scan=InputEvent.Key_Enter;
        else if(Step==4)scan=InputEvent.Key_Tab;
        else if(Step==5)scan=InputEvent.Key_Pad_B;
        else if(Step==6 || Step==7){scan=19;character=Step==6?114:82;}
        else if(Step==8)scan=InputEvent.Key_RightArrow;
        else if(Step==9)scan=InputEvent.Key_UpArrow;
        else if(Step==14)scan=InputEvent.Key_Escape;
        else if(Step==15)scan=InputEvent.Key_Grave;
        else {scan=16;character=Step==3?81:113;if(Step==13)type=InputEvent.Type_KeyUp;}
        // Empty KeyString exercises the stable character path, not a fake 'q'.
        bool handled=CaelumTimeSkipPanel.Key(type,scan,character,"",u);
        Console.Printf("CA156 DISPATCH step=%d handled=%d type=%d scan=%d char=%d",Step,handled,type,scan,character);
        Sent=Step;
    }
}
