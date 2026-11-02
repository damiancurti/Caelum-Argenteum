class CA600MatchProbe : StaticEventHandler
{
    bool Done,Checked;int Boundary;
    void Check(bool ok,String label){Console.Printf("CA600 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Capture==null)return;
        let f=m.Capture;
        if(!Checked)
        {
            Checked=true;
            Check(f.Dropped[1] && f.Carrier[1]==-1 && f.ReturnAt[1]==1225,"recovery preserves dropped token and original deadline");
            Check(f.Objectives[1].Pos==(192,192,0),"recovery preserves drop position");
            Check(m.Score[0]==0 && m.Score[1]==0,"recovery does not invent captures");
            Boundary=level.time+3;f.ReturnAt[1]=Boundary;
        }
        if(level.time==Boundary-1)Check(f.Dropped[1],"return does not occur before saved boundary");
        if(level.time==Boundary+1)
        {
            Check(f.Home(1) && f.Objectives[1].Pos==f.Bases[1].Pos,"recovered deadline restores token to its own base");
            Console.Printf("CA600 RESULT deathmatch");Done=true;
        }
    }
}
