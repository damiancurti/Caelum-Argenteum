class F36LayoutView : Issue36View
{
    override bool Use(bool pickup)
    { Super.Use(pickup); Owner.SetOrigin((368,0,136),false); Owner.Angle=90; Owner.Pitch=0; return true; }
}
class F36LayoutTests : F36Tests
{
    override bool Use(bool pickup)
    {
        let p=Spawn("F36Body",(0,0,1000));p.bThruActors=true;
        for(int sign=-1;sign<=1;sign+=2)
        {
            for(int x=196;x<=540;x+=344)
            {
                p.SetOrigin((x-48,sign*368,136),false);
                bool blocked=false;
                for(int step=-46;step<=48;step+=2)if(!p.TryMove((x+step,sign*368),true)){blocked=true;break;}
                Check(blocked,String.Format("removed side door is solid wall x=%d y=%d",x,sign*368));
            }
            Check(!CrossDoor(p,(368,sign*196,136),(0,sign,0)),"central front wall closes old shared doorway");
        }
        p.Destroy();
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        CaelumHingedDoorLeaf left=null;CaelumHingedDoorLeaf right=null;
        int removed=0;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
        {
            if(leaf.args[0]==900 || leaf.args[0]==901 || leaf.args[0]==903 || leaf.args[0]==904)removed++;
            if(leaf.args[0]==910)left=leaf;
            if(leaf.args[0]==922)right=leaf;
        }
        Check(removed==0,"no obsolete side door actors");
        Owner.SetOrigin((282,132,136),false);
        Check(left.Used(Owner) && left.DoorRequested && !right.DoorRequested,"north front leaves operate independently");
        Console.Printf("F36_LAYOUT_DONE"); return true;
    }
}
class F36LayoutSouth : F36LayoutView
{
    override bool Use(bool pickup) {Super.Use(pickup);Owner.Angle=270;return true;}
}
class F36LayoutOpen : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(leaf.args[0]==910)Console.Printf("F36_LAYOUT_USE %d",leaf.Used(Owner));
        return true;
    }
}
class F36LayoutState : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(leaf.args[0]==910 || leaf.args[0]==922)
                Console.Printf("F36_LAYOUT_STATE group=%d progress=%d x=%.2f y=%.2f",leaf.args[0],leaf.SlideProgress,leaf.Pos.X,leaf.Pos.Y);
        return true;
    }
}
