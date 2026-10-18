// Whole-map structural and functional checks; no diagnostic mutation is shipped.
class CA318NativeMapChecks : EventHandler
{
    int Checks,Failures,Start;
    CaelumHingedDoorLeaf Selected;
    CaelumPlayer User;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="mapdoors_begin")
        {
            User=CaelumPlayer(players[0].mo);User.CharacterCreationComplete=true;
            User.CreationWizardOpen=false;User.ApplyCharacterProfile();User.bInvulnerable=true;
            let registry=CaelumPolyDoorEvents.Get();Check(registry!=null && registry.Leaves.Size()==961,"All 960 native IDs registered");
            let port=CaelumPortSiege.Get();Check(port!=null && port.args[4]==1,"MAP06 native geometry marker set");
            Check(port.Defenders.Size()==600 && !port.SiegeStarted,"Existing peaceful population and phase preserved");
            int leaves=0,blockers=0;let it=ThinkerIterator.Create("CaelumSlidingDoorLeaf");
            while(it.Next()!=null)leaves++;
            it=ThinkerIterator.Create("CaelumSlidingDoorBlocker");while(it.Next()!=null)blockers++;
            Check(leaves==960 && blockers==0,"960 visual leaves replace 7680 collision actors");
            Check(ThinkerIterator.Create("CaelumPolyDoorMotion").Next()==null,"Closed city has no door motion guards");
            int badGeometry=0,badClosed=0,badRoof=0,badIds=0;
            let body=Actor.Spawn("CA318NativeBody",User.Pos);
            for(int id=1;id<=960;id++)
            {
                let leaf=registry.Leaves[id];if(leaf==null){badIds++;continue;}
                if(leaf.args[4]!=id || leaf.NativeFaces.Size()!=4 || registry.Peer(leaf)==null){badIds++;continue;}
                vector2 center=(0,0);
                for(int f=0;f<4;f++)
                {
                    let line=leaf.NativeFaces[f];center+=line.v1.p;
                    bool valid;double top,bottom;[valid,top,bottom]=line.GetMidTexturePosition(0);
                    if(!valid || top!=120 || bottom!=0)badGeometry++;
                }
                if((center/4-leaf.ClosedPosition.XY).Length()>0.001)badGeometry++;
                body.SetOrigin(leaf.ClosedPosition,false);if(body.TestMobjLocation())badClosed++;
                body.SetOrigin(leaf.ClosedPosition+(0,0,184),false);if(!body.TestMobjLocation())badRoof++;
            }
            Check(badIds==0,"All IDs including values above 360 resolve to their pairs");
            Check(badGeometry==0,"All 3840 native faces match authored positions and finite heights");
            Check(badClosed==0,"All 960 closed leaf centers block a walking body");
            Check(badRoof==0,"All 960 above-roof samples remain traversable");
            Console.Printf("CA318 MAPDOORS bad_ids=%d bad_geometry=%d bad_closed=%d bad_roof=%d",badIds,badGeometry,badClosed,badRoof);
            body.Destroy();
            for(int id=1;id<=960;id+=6)
            {
                let leaf=registry.Leaves[id];let peer=registry.Peer(leaf);
                User.SetOrigin(leaf.ClosedPosition+(128,0,0),false);User.Vel=(0,0,0);
                if(CaelumPolyDoors.SweepOccupied(leaf,64) || CaelumPolyDoors.SweepOccupied(peer,64))continue;
                if(leaf.RequestDoorGroup(User)){Selected=leaf;break;}
            }
            Check(Selected!=null,"An unobstructed authored front pair accepts use");Start=level.time;
        }
        if(e.Name=="mapdoors_open")
        {
            Check(Selected!=null && Selected.SlideProgress==64 && CaelumPolyDoorEvents.Get().Peer(Selected).SlideProgress==64,"Authored front pair opens through native motion");
            let body=Actor.Spawn("CA318NativeBody",Selected.ClosedPosition);
            Check(body.TestMobjLocation(),"Open authored doorway admits a walking body");body.Destroy();
        }
        if(e.Name=="mapdoors_done")
        {
            Check(Selected!=null && Selected.SlideProgress==0 && Selected.NativeMotion==null,"Authored front pair closes and retires guard");
            Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);
        }
    }
}
