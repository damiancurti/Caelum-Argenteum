class Issue61FarGround : Issue61View
{
    override bool Use(bool pickup)
    {
        Super.Use(pickup);
        Owner.SetOrigin((17455,7394,0),false);Owner.Angle=180;Owner.Pitch=35;
        Console.Printf("QA61_FAR_GROUND sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));
        return true;
    }
}
class Issue61AuthorRoof : Issue61View
{
    override bool Use(bool pickup)
    {
        Super.Use(pickup);
        Owner.SetOrigin((1209.915340112578,-12.13899400175061,264),false);
        Owner.Angle=177.2172318369685;Owner.Pitch=-28.125;
        return true;
    }
}
class Issue61AuthorRoofInside : Issue61AuthorRoof
{
    override bool Use(bool pickup)
    {
        Super.Use(pickup);Owner.SetOrigin((900,0,264),false);Owner.Angle=0;
        return true;
    }
}
