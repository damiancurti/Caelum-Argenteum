// One matched authored pair cycles during diagnostic timing; no campaign edits.
class CA318DoorActivator : Actor
{
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA318DoorMotionObserver : EventHandler
{
    int Begin,Requests,Peak;
    bool Started,Reported;
    Actor Activator;
    CaelumHingedDoorLeaf Door;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca318_begin" || !CVar.GetCVar("ca318_door_motion").GetBool())return;
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(leaf.args[0]==CaelumCityData.DoorGroup(0) && leaf.args[1]<0){Door=leaf;break;}
        if(Door==null){Console.Printf("CA318 FAIL missing diagnostic door");return;}
        Activator=Actor.Spawn("CA318DoorActivator",Door.ClosedPosition+(128,0,0));
        Begin=level.time;Started=true;
    }
    override void WorldTick()
    {
        if(!Started)return;int age=level.time-Begin;
        if(age%140==1 && age<490)
        {
            bool accepted=Door.RequestDoorGroup(Activator);Requests++;
            Console.Printf("CA318 DOOR_REQUEST tic=%d accepted=%d group=%d",level.time,accepted,Door.args[0]);
            if(!accepted)Console.Printf("CA318 FAIL diagnostic door request rejected");
        }
        Peak=Max(Peak,Door.SlideProgress);
        if(age==489 && !Reported)
        {
            Reported=true;Console.Printf("CA318 DOOR_MOTION requests=%d peak=%d progress=%d",Requests,Peak,Door.SlideProgress);
            if(Peak!=64)Console.Printf("CA318 FAIL diagnostic door never fully opened");
        }
    }
}
