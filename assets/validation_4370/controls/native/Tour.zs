class Issue61TourView : Issue61View
{
    void SetDoorView(int group, vector3 point, double yaw)
    {
        Owner.SetOrigin(point,false);Owner.Angle=yaw;Owner.Pitch=-16;
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
        {
            leaf.RuloArenaLocked=true;leaf.SlideProgress=0;leaf.PlaceAtProgress();leaf.RuloArenaLocked=false;leaf.DoorRequested=false;
        }
    }
}
class Issue61TourOpen : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        Owner.GiveInventoryType("CaelumSilverKey");
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(abs(leaf.ClosedPosition.Z-Owner.Pos.Z)<1 && Owner.Distance2D(leaf)<180)leaf.Used(Owner);
        return true;
    }
}
class Issue61V700a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(700,(-297.0,84.0,136.0),90);return true; }
}
class Issue61V700b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(700,(-297.0,308.0,136.0),270);return true; }
}
class Issue61V716a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(716,(-297.0,-308.0,136.0),90);return true; }
}
class Issue61V716b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(716,(-297.0,-84.0,136.0),270);return true; }
}
class Issue61V717a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(717,(1033.0,84.0,136.0),90);return true; }
}
class Issue61V717b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(717,(1033.0,308.0,136.0),270);return true; }
}
class Issue61V718a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(718,(1033.0,-308.0,136.0),90);return true; }
}
class Issue61V718b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(718,(1033.0,-84.0,136.0),270);return true; }
}
class Issue61V800a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(800,(-297.0,-28.0,0.0),90);return true; }
}
class Issue61V800b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(800,(-297.0,196.0,0.0),270);return true; }
}
class Issue61V801a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(801,(368.0,-28.0,0.0),90);return true; }
}
class Issue61V801b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(801,(368.0,196.0,0.0),270);return true; }
}
class Issue61V802a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(802,(-297.0,-196.0,0.0),90);return true; }
}
class Issue61V802b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(802,(-297.0,28.0,0.0),270);return true; }
}
class Issue61V803a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(803,(368.0,-196.0,0.0),90);return true; }
}
class Issue61V803b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(803,(368.0,28.0,0.0),270);return true; }
}
class Issue61V804a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(804,(1033.0,-28.0,0.0),90);return true; }
}
class Issue61V804b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(804,(1033.0,196.0,0.0),270);return true; }
}
class Issue61V805a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(805,(1033.0,-196.0,0.0),90);return true; }
}
class Issue61V805b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(805,(1033.0,28.0,0.0),270);return true; }
}
class Issue61V806a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(806,(-1900.0,0.0,0.0),0);return true; }
}
class Issue61V806b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(806,(-1676.0,0.0,0.0),180);return true; }
}
class Issue61V807a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(807,(1301.0,0.0,0.0),0);return true; }
}
class Issue61V807b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(807,(1525.0,0.0,0.0),180);return true; }
}
class Issue61V808a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(808,(-693.0,0.0,0.0),0);return true; }
}
class Issue61V808b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(808,(-469.0,0.0,0.0),180);return true; }
}
class Issue61V902a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(902,(256.0,368.0,136.0),0);return true; }
}
class Issue61V902b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(902,(480.0,368.0,136.0),180);return true; }
}
class Issue61V905a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(905,(256.0,-368.0,136.0),0);return true; }
}
class Issue61V905b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(905,(480.0,-368.0,136.0),180);return true; }
}
class Issue61V906a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(906,(-233.0,432.0,136.0),0);return true; }
}
class Issue61V906b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(906,(-9.0,432.0,136.0),180);return true; }
}
class Issue61V907a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(907,(745.0,432.0,136.0),0);return true; }
}
class Issue61V907b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(907,(969.0,432.0,136.0),180);return true; }
}
class Issue61V908a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(908,(-233.0,-432.0,136.0),0);return true; }
}
class Issue61V908b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(908,(-9.0,-432.0,136.0),180);return true; }
}
class Issue61V909a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(909,(745.0,-432.0,136.0),0);return true; }
}
class Issue61V909b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(909,(969.0,-432.0,136.0),180);return true; }
}
class Issue61V910a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(910,(282.0,84.0,136.0),90);return true; }
}
class Issue61V910b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(910,(282.0,308.0,136.0),270);return true; }
}
class Issue61V911a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(911,(282.0,-308.0,136.0),90);return true; }
}
class Issue61V911b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(911,(282.0,-84.0,136.0),270);return true; }
}
class Issue61V912a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(912,(-581.0,0.0,136.0),0);return true; }
}
class Issue61V912b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(912,(-357.0,0.0,136.0),180);return true; }
}
class Issue61V913a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(913,(1581.0,0.0,136.0),0);return true; }
}
class Issue61V913b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(913,(1805.0,0.0,136.0),180);return true; }
}
class Issue61V915a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(915,(939.0,0.0,264.0),0);return true; }
}
class Issue61V915b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(915,(1163.0,0.0,264.0),180);return true; }
}
class Issue61V916a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(916,(1198.0,-336.0,0.0),0);return true; }
}
class Issue61V916b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(916,(1422.0,-336.0,0.0),180);return true; }
}
class Issue61V917a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(917,(1198.0,336.0,0.0),0);return true; }
}
class Issue61V917b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(917,(1422.0,336.0,0.0),180);return true; }
}
class Issue61V918a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(918,(-76.0,-456.0,0.0),0);return true; }
}
class Issue61V918b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(918,(148.0,-456.0,0.0),180);return true; }
}
class Issue61V919a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(919,(588.0,-456.0,0.0),0);return true; }
}
class Issue61V919b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(919,(812.0,-456.0,0.0),180);return true; }
}
class Issue61V920a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(920,(-76.0,456.0,0.0),0);return true; }
}
class Issue61V920b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(920,(148.0,456.0,0.0),180);return true; }
}
class Issue61V921a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(921,(588.0,456.0,0.0),0);return true; }
}
class Issue61V921b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(921,(812.0,456.0,0.0),180);return true; }
}
class Issue61V922a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(922,(454.0,84.0,136.0),90);return true; }
}
class Issue61V922b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(922,(454.0,308.0,136.0),270);return true; }
}
class Issue61V923a : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(923,(454.0,-308.0,136.0),90);return true; }
}
class Issue61V923b : Issue61TourView
{
    override bool Use(bool pickup) { Super.Use(pickup);SetDoorView(923,(454.0,-84.0,136.0),270);return true; }
}
