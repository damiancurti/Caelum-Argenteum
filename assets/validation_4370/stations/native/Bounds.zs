class Issue61Bound0 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((-21144.0,-21144.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 0 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound1 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((-21144.0,0.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 1 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound2 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((-21144.0,21144.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 2 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound3 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((0.0,-21144.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 3 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound4 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((3840,0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 4 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound5 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((0.0,21144.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 5 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound6 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((21144.0,-21144.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 6 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound7 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((21144.0,0.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 7 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
class Issue61Bound8 : Issue61FarGround
{
    override bool Use(bool pickup) { Super.Use(pickup);Owner.SetOrigin((21144.0,21144.0,0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND 8 sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }
}
