class CA502DiningChecks : CA410DiningChecks
{
    CaelumDiningTable Table()
    {let it=ThinkerIterator.Create('CaelumDiningTable');CaelumDiningTable t;while((t=CaelumDiningTable(it.Next()))!=null)if(t.Blocks[1]!=null)return t;return null;}
    void Freeze(Actor body)
    {let entry=CaelumContaminationStorage.Get(body);if(entry!=null && entry.Exposure!=null)entry.Exposure.Release();}
    void Core(CaelumPlayer u)
    {
        Profile(u);
        let t=Table();Check(t!=null,"real mansion table exists");if(t==null)return;
        Check(CaelumContaminationObject.Eligible(t),"non-solid table owns exposure");
        CaelumContaminationObject.Register(t);let entry=CaelumContaminationStorage.Get(t,true);
        Check(entry.Exposure!=null && entry.Exposure.Body==t,"one canonical exposure owner");
        int count=0;
        for(int i=0;i<32;i++)if(t.Blocks[i]!=null)
        {
            let b=t.Blocks[i];count++;
            Check(CaelumContaminationStorage.Get(b,true)==entry,"collision block shares table state");
            Check(!CaelumContaminationObject.Eligible(b),"no independent proxy exposure");
            CaelumContaminationObject.Register(b);
            Check(entry.Exposure.Body==t,"proxy registration retains table scheduler");
        }
        Check(count>1,"multiple real collision cells exercised");
        double area=CaelumContaminationRules.CylinderArea(Sqrt(t.LengthMU()*t.LengthMU()+t.WidthMU()*t.WidthMU())/2,t.Height);
        Check(Near(CaelumContaminationObject.Area(t),area),"area uses full existing collision envelope");
        Check(Near(CaelumContaminationObject.Area(t.Blocks[0]),area),"proxy reports same full area");
        Freeze(t);CaelumContaminationStorage.Set(t,80);
        let outer=CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_BODY);CaelumContaminationStorage.Set(outer,20);
        // The two callbacks must still count as one body contact this tic.
        u.SetOrigin(t.Blocks[0].Pos+(t.Blocks[0].Radius+u.Radius,0,0),false);u.FindFloorCeiling();
        CaelumContaminationContacts.Collision(u,t.Blocks[0]);
        double after=CaelumContaminationStorage.Value(outer);
        Check(after>20,"native collision callback transmits table dirt");
        CaelumContaminationContacts.Collision(u,t.Blocks[1]);
        Check(Near(CaelumContaminationStorage.Value(outer),after),"two cells do not double-charge contact");
        let links=CaelumContaminationContacts.Get(u);int matching=0;CaelumContaminationContact found;
        for(int i=0;i<links.Pairs.Size();i++)if(links.Pairs[i]!=null && CaelumDiningContamination.Owner(links.Pairs[i].Second)==t){matching++;found=links.Pairs[i];}
        Check(matching==1,"one live contact for the logical table");
        // Emulate two old saved links without changing the production topology.
        let duplicate=new('CaelumContaminationContact');duplicate.First=u;duplicate.Second=t.Blocks[0];links.Pairs.Push(duplicate);
        Check(duplicate.Duplicate(),"saved duplicate is recognized");int before=links.Pairs.Size();duplicate.Tick();
        Check(links.Pairs.Size()==before-1,"old duplicate removed before another dose");
        if(found!=null){CaelumContaminationContacts.Remove(u,found);found.Destroy();}
        CaelumContaminationStorage.Set(t.Blocks[0],0);
        Check(Near(CaelumContaminationStorage.Value(t),0),"cleaning proxy cleans authoritative table");
        CaelumDiningContamination.Ensure(t);
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[1]),0),"migration does not restore old dirt twice");
        CaelumContaminationObject.Register(t);let node=entry.Exposure;
        let world=CaelumThermalWorld.Get();double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        node.Ready=false;node.Revision=4;node.HistoryReady=true;node.HistoryVariable=false;node.HistoryTemporaryClimate=false;
        node.HistoryAmbient=80;node.HistoryRain=0;node.HistoryArea=area;node.HistoryStamp=now;
        entry.Concentration=20;node.Settle(now+10);
        double expected=CaelumContaminationRules.AfterContact(20,80,area,10);
        Check(Near(entry.Concentration,expected),"single full-area environmental integration");
        node.Release();
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[0]),expected),"contact sees settled exposure");
        t.ContaminationProxyRevision=0;
        t.ContaminationMigrating=true;
        let old=CaelumContaminationStorage.Get(t.Blocks[0],true,true);old.Concentration=95;old.Ensure();
        t.ContaminationMigrating=false;CaelumDiningContamination.Ensure(t);
        Check(Near(entry.Concentration,95),"legacy highest source retained without summing");
        CaelumContaminationStorage.Set(t,10);CaelumDiningContamination.Ensure(t);
        Check(Near(entry.Concentration,10),"revision makes adoption idempotent");
        let chair=t.Chairs[0];Freeze(chair);CaelumContaminationStorage.Set(chair,61);
        Check(CaelumContaminationStorage.Get(chair)!=entry && Near(CaelumContaminationStorage.Value(chair),61),"actual chair remains separate furniture");
        let orphan=CaelumDiningBlock(Actor.Spawn('CaelumDiningBlock',u.Pos));
        Check(!CaelumContaminationObject.Eligible(orphan),"unattached helper gets no scheduler");orphan.Destroy();
    }
    void Seed(CaelumPlayer u)
    {
        Profile(u);let p=Proof(u,true);let item=CaelumDiningSetItem(Actor.Spawn('CaelumNormalDiningSetItem'));item.AttachToOwner(u);
        Check(PlaceSet(u,item),"real dining set placement");if(item.Table==null)return;
        p.Sets[0]=item;p.Tables[0]=item.Table;let t=item.Table;t.ChangeTid(58450);
        CaelumContaminationObject.Register(t);Check(CaelumContaminationStorage.Get(t).Exposure!=null,"placed portable table registers exposure");
        Freeze(t);CaelumContaminationStorage.Set(t.Blocks[0],83);
        Check(Near(CaelumContaminationStorage.Value(item),83),"item shares placed body dirt");
        ApproachTable(u,t);Check(item.Carry(u),"carry actual dirty assembly");
        Check(!CaelumContaminationObject.Eligible(t) && CaelumContaminationStorage.Get(item).Exposure==null,"packed assembly stops environment");
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[0]),83),"packing preserves contamination");
        Check(PlaceSet(u,item),"replace actual assembly");Freeze(t);
        Check(Near(CaelumContaminationStorage.Value(t),83),"replacing retains dirt");
        ApproachTable(u,t);Check(item.Carry(u),"packed for native save/travel");
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);let p=Proof(u);Check(p!=null && p.Tables[0]!=null,"saved actual table survives");if(p==null || p.Tables[0]==null)return;
        let t=p.Tables[0];let item=p.Sets[0];
        Check(item.Table==t && t.PackedItem==item && t.TID==58450,"native identity and TID survive");
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[0]),83),"saved body and proxy dirt survive");
        Check(PlaceSet(u,item),"redeploy saved table");Freeze(t);
        Check(Near(CaelumContaminationStorage.Value(t),83),"saved redeployment does not clean");
        CaelumContaminationStorage.Set(t,0);
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[0]),0),"shared cleaning survives migration");
    }
    void Upgrade(CaelumPlayer u)
    {
        Profile(u);let t=Table();Check(t!=null,"old map/table loads");if(t==null)return;
        Freeze(t);Check(Near(CaelumContaminationStorage.Value(t),80),"old proxy hotspot adopted");
        Check(t.ContaminationProxyRevision==CaelumContaminationData.DINING_PROXY_REVISION,"migration revision stored");
        for(int i=0;i<32;i++)if(t.Blocks[i]!=null)Check(Near(CaelumContaminationStorage.Value(t.Blocks[i]),80),"legacy blocks resolve to canonical state");
        CaelumContaminationStorage.Set(t,5);CaelumDiningContamination.Ensure(t);
        Check(Near(CaelumContaminationStorage.Value(t),5),"new cleaning not undone by old carrier");
    }
    void NativeInput(CaelumPlayer u,int phase)
    {
        let t=Table();if(t==null){Check(false,"native contact table exists");return;}
        let foot=CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_FEET);
        if(phase==0)
        {
            Profile(u);Freeze(t);CaelumContaminationStorage.Set(t,80);CaelumContaminationStorage.Set(foot,0);
            let b=t.Blocks[0];u.bNoClip=false;u.bNoGravity=false;u.bSolid=true;
            u.SetOrigin(b.Pos+(0,0,b.Height+1),false);u.FindFloorCeiling();u.Vel=(0,0,-1);
            Check(u.TestMobjLocation(),"native landing starts in clear space");
        }
        else
        {
            let links=CaelumContaminationContacts.Get(u);bool linked=false;
            if(links!=null)for(int i=0;i<links.Pairs.Size();i++)if(links.Pairs[i]!=null
                && CaelumDiningContamination.Owner(links.Pairs[i].Second)==t && links.Pairs[i].Touching())linked=true;
            Check(linked,"native falling body creates real table contact");
            Check(CaelumContaminationStorage.Value(foot)>0,"native support transmits through feet");
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502d_core")Core(u);
        else if(e.Name=="ca502d_seed")Seed(u);
        else if(e.Name=="ca502d_resume")Resume(u);
        else if(e.Name=="ca502d_upgrade")Upgrade(u);
        else if(e.Name=="ca502d_input")NativeInput(u,e.Args[0]);
        else if(e.Name=="ca502d_away"){Level.ChangeLevel("CBTH410",0,CHANGELEVEL_NOINTERMISSION);return;}
        else if(e.Name=="ca502d_home"){Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;}
        else return;
        Result();Console.Printf("CA502D COMPLETE %s map=%s",e.Name,level.MapName);
    }
}
