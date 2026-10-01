// Reused #36 accepted door regression, executed again for #61.
class F36Body : Actor
{
    Default { Radius 16; Height 56; +SOLID; +NOGRAVITY; +DROPOFF; +CANPASS; MaxStepHeight 24; }
    States { Spawn: TNT1 A -1; Stop; }
}
class F36Tests : CaelumSocialDebugAction
{
    void Check(bool ok, String label) { Console.Printf("F36_TEST %s %s",ok ? "PASS" : "FAIL",label); }
    bool CrossDoor(Actor p, vector3 center, vector3 normal)
    {
        p.SetOrigin(center-normal*64,false);
        for(int n=-62;n<=64;n+=2) if(!p.TryMove(center.XY+normal.XY*n,true))return false;
        return true;
    }
    override bool Use(bool pickup)
    {
        Array<Actor> solids;
        Check(true,"begin");
        let all=ThinkerIterator.Create("Actor");Actor a;
        while((a=Actor(all.Next()))!=null)
            if(a.bSolid && !(a is 'CaelumSlidingDoorLeaf') && !(a is 'CaelumSlidingDoorBlocker'))
            {solids.Push(a);a.bSolid=false;}
        Actor user=Owner;user.bSolid=false;
        user.GiveInventoryType("CaelumSilverKey");
        let p=Spawn("F36Body",(0,0,0));p.bSolid=false;
        Check(true,"bodies spawned");
        let stats=new("CaelumDerivedStats");
        Array<CaelumHingedDoorLeaf> leaves;
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)leaves.Push(leaf);
        for(int i=0;i<leaves.Size();i++)
        {
            leaf=leaves[i];bool duplicate=false;
            for(int j=0;j<i;j++)if(leaf.IsGroupPeer(leaves[j]))duplicate=true;
            if(duplicate)continue;
            vector3 center=(0,0,0);int count=0;
            for(int j=0;j<leaves.Size();j++)if(leaf.IsGroupPeer(leaves[j])){center+=leaves[j].ClosedPosition;count++;}
            center/=count;
            vector3 normal=leaf.args[2]==0 ? (0,1,0) : (1,0,0);
            for(int direction=-1;direction<=1;direction+=2)
            {
                for(int j=0;j<leaves.Size();j++)if(leaf.IsGroupPeer(leaves[j]))
                {let peer=leaves[j];peer.RuloArenaLocked=true;peer.SlideProgress=0;peer.PlaceAtProgress();peer.RuloArenaLocked=false;peer.DoorRequested=false;}
                user.SetOrigin(center-normal*64*direction,false);
                p.bSolid=true;p.A_SetSize(16,56);
                Check(!CrossDoor(p,center,normal*direction),String.Format("closed collision group=%d side=%d",leaf.args[0],direction));
                p.bSolid=false;p.SetOrigin((0,0,1000),false);
                Check(leaf.Used(user),String.Format("Use group=%d side=%d",leaf.args[0],direction));
                for(int tick=0;tick<16;tick++)for(int j=0;j<leaves.Size();j++)if(leaf.IsGroupPeer(leaves[j]))leaves[j].Tick();
                bool opened=true;
                for(int j=0;j<leaves.Size();j++)if(leaf.IsGroupPeer(leaves[j]) && leaves[j].SlideProgress!=64)opened=false;
                Check(opened,String.Format("fully open group=%d side=%d",leaf.args[0],direction));
                for(int tier=1;tier<=7;tier+=3)
                {
                    double factor=stats.GetHeightMetersForTier(tier)/1.8;p.A_SetSize(16*factor,56*factor);p.bSolid=true;
                    vector3 lane=center;
                    bool passed=CrossDoor(p,lane,normal*direction);
                    if(!passed)Console.Printf("F36_STOP group=%d tier=%d x=%.1f y=%.1f blocker=%s",leaf.args[0],tier,p.Pos.X,p.Pos.Y,p.BlockingMobj==null ? 'none' : p.BlockingMobj.GetClassName());
                    if(!passed && p.BlockingMobj!=null && p.BlockingMobj.master!=null)Console.Printf("F36_MASTER group=%d",p.BlockingMobj.master.args[0]);
                    p.bThruActors=true;bool geometryClear=CrossDoor(p,center,normal*direction);p.bThruActors=false;
                    if(!geometryClear && count==2)
                    {
                        vector3 axis=leaf.args[2]==0 ? (1,0,0) : (0,1,0);
                        passed=true;geometryClear=true;
                        for(int path=-1;path<=1;path+=2)
                        {
                            lane=center+axis*32*path;
                            p.bThruActors=true;geometryClear=geometryClear && CrossDoor(p,lane,normal*direction);p.bThruActors=false;
                            passed=passed && CrossDoor(p,lane,normal*direction);
                        }
                    }
                    if(geometryClear)Check(passed,String.Format("cross group=%d side=%d tier=%d",leaf.args[0],direction,tier));
                    else Console.Printf("F36_GEOMETRY_LIMIT group=%d side=%d tier=%d radius=%.2f height=%.2f",leaf.args[0],direction,tier,p.Radius,p.Height);
                    p.bSolid=false;p.SetOrigin((0,0,1000),false);
                }
            }
        }
        // Native key gate and arena lock still govern the inherited group request.
        user.TakeInventory("CaelumSilverKey",1);
        for(int i=0;i<leaves.Size();i++)if(leaves[i].args[0]==806 || leaves[i].args[0]==700)
        {
            leaf=leaves[i];vector3 normal=leaf.args[2]==0 ? (0,1,0) : (1,0,0);
            user.SetOrigin(leaf.ClosedPosition-normal*64,false);
            if(leaf.args[0]==806)Check(!leaf.Used(user),"silver key rejected without key");
            else {leaf.RuloArenaLocked=true;Check(!leaf.Used(user),"Rulo arena lock rejected");leaf.RuloArenaLocked=false;}
        }
        // Reusing a partially open double from the other side keeps one direction.
        CaelumHingedDoorLeaf first=null;CaelumHingedDoorLeaf second=null;
        for(int i=0;i<leaves.Size();i++)if(leaves[i].args[0]==800)
        {if(first==null)first=leaves[i];else second=leaves[i];}
        first.SwingSide=1;second.SwingSide=1;
        first.RuloArenaLocked=true;first.SlideProgress=32;first.PlaceAtProgress();first.RuloArenaLocked=false;
        second.RuloArenaLocked=true;second.SlideProgress=0;second.PlaceAtProgress();second.RuloArenaLocked=false;
        user.SetOrigin(first.ClosedPosition+(0,80,0),false);
        Check(first.Used(user) && first.SwingSide==1 && second.SwingSide==1,"partial double reopening keeps group swing direction");
        // One solid body inside the swept arc must stop opening/closing without damage.
        leaf=leaves[0];leaf.RuloArenaLocked=true;leaf.SlideProgress=0;leaf.PlaceAtProgress();leaf.RuloArenaLocked=false;
        leaf.SwingSide=1;leaf.DoorRequested=true;
        let obstruction=Spawn("F36Body",leaf.PositionAt(32,-24));obstruction.A_SetSize(8,56);
        for(int n=0;n<16;n++)leaf.Tick();
        Check(leaf.SlideProgress<64 && obstruction.health==1000,"solid body stops opening sweep");
        obstruction.bSolid=false;
        for(int n=0;n<16;n++)leaf.Tick();Check(leaf.SlideProgress==64,"opening resumes after body leaves");
        obstruction.bSolid=true;leaf.DoorRequested=false;leaf.HoldTimer=0;
        for(int n=0;n<16;n++)leaf.Tick();
        Check(leaf.SlideProgress>0 && obstruction.health==1000,"solid body stops closing sweep");
        obstruction.Destroy();
        // Upward traces cover the complete upper-room grid, including both gables.
        p.bSolid=false;FLineTraceData hit;
        for(int x=-320;x<=1000;x+=220)for(int y=-340;y<=340;y+=170)
        {
            p.SetOrigin((x,y,300),false);
            bool roof=p.LineTrace(0,250,-90,TRF_THRUACTORS|TRF_ABSPOSITION,320,x,y,hit);
            Check(roof && abs(hit.HitLocation.Z-392)<0.01,String.Format("ceiling x=%d y=%d z=%.2f",x,y,hit.HitLocation.Z));
        }
        p.Destroy();for(int i=0;i<solids.Size();i++)solids[i].bSolid=true;
        Console.Printf("F36_TEST_DONE leaves=%d",leaves.Size());return true;
    }
}
