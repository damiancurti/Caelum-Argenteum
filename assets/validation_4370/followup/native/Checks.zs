class Issue61Body : Actor
{
    Default { Radius 16; Height 56; +SOLID; +NOGRAVITY; +DROPOFF; +CANPASS; MaxStepHeight 24; }
    States { Spawn: TNT1 A -1; Stop; }
}
class Issue61TerrainChecks : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let p=Spawn("Issue61Body",(0,0,1000));p.bThruActors=true;
        let stats=new("CaelumDerivedStats");
        for(int tier=1;tier<=7;tier+=3)
        {
            double factor=stats.GetHeightMetersForTier(tier)/1.8;p.A_SetSize(16*factor,56*factor);
            int checked=0,failed=0;
            for(int i=2372;i<level.Lines.Size();i++)
            {
                let line=level.Lines[i];
                if(line.backsector==null)continue;
                vector2 delta=line.v2.p-line.v1.p;
                vector2 normal=(delta.Y,-delta.X)/delta.Length();
                vector2 mid=(line.v1.p+line.v2.p)*.5;
                for(int dir=-1;dir<=1;dir+=2)
                {
                    vector2 start=mid+normal*32*dir;
                    double floor=level.PointInSector(start).floorplane.ZatPoint(start);
                    p.SetOrigin((start.X,start.Y,floor),false);
                    bool ok=true;
                    for(int distance=30;distance>=-32;distance-=2)
                    {
                        vector2 point=mid+normal*distance*dir;
                        if(!p.TryMove(point,true)){ok=false;break;}
                        p.SetOrigin((p.Pos.X,p.Pos.Y,p.FloorZ),false);
                    }
                    checked++;
                    if(!ok){failed++;if(failed<8)Console.Printf("QA61_EDGE_FAIL line=%d tier=%d side=%d at=%.2f %.2f %.2f",i,tier,dir,p.Pos.X,p.Pos.Y,p.Pos.Z);}
                }
            }
            Console.Printf("QA61_TERRAIN %s tier=%d crossings=%d failures=%d",failed==0?"PASS":"FAIL",tier,checked,failed);
        }
        p.Destroy();Console.Printf("QA61_TERRAIN_DONE");return true;
    }
}
class Issue61Resources : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let it=ThinkerIterator.Create("CaelumTreeEnvironmentProp");CaelumTreeEnvironmentProp plant;
        int bushes=0,trees=0;double fiber=0;bool garden=true;
        while((plant=CaelumTreeEnvironmentProp(it.Next()))!=null)
        {
            if(plant.Pos.Z<0)continue;
            if(plant is 'CaelumFiberBush'){bushes++;fiber+=plant.GetResourceCapacityUnits();}
            else trees++;
            garden= garden && plant.Pos.Z==0 && plant.Pos.X>=-1260 && plant.Pos.X<=-720 && abs(plant.Pos.Y)<=430;
        }
        Console.Printf("QA61_RESOURCES %s trees=%d bushes=%d fiber=%.0f",garden && bushes==20 && trees==4 && fiber==200000?"PASS":"FAIL",trees,bushes,fiber);
        int scenery=0;bool grounded=true,decorative=true,dry=true;int poolPlants=0;
        let all=ThinkerIterator.Create("Actor");Actor a;
        while((a=Actor(all.Next()))!=null)
        {
            bool isScenery=(a is 'CaelumMansionSceneryTree') || (a is 'CaelumMansionSceneryShrub');
            if((isScenery || (a is 'CaelumTreeEnvironmentProp')) && a.Pos.X>=2200 && a.Pos.X<=3480 && abs(a.Pos.Y)<=720)poolPlants++;
            if(!isScenery)continue;
            scenery++;double floor=a.CurSector.floorplane.ZatPoint(a.Pos.XY);
            grounded=grounded && abs(a.Pos.Z-floor)<0.1;
            decorative=decorative && !a.bShootable && !(a is 'CaelumTreeEnvironmentProp');
            dry=dry && a.Pos.Z>=0 && a.WaterLevel==0;
            if(abs(a.Pos.Z-floor)>=0.1)Console.Printf("QA61_SCENERY_Z %s %.3f %.3f",a.GetClassName(),a.Pos.Z,floor);
        }
        Console.Printf("QA61_SCENERY %s count=%d grounded=%d decorative=%d",scenery==40 && grounded && decorative?"PASS":"FAIL",scenery,grounded,decorative);
        Console.Printf("QA61_POOL %s plants_in_pool=%d all_scenery_dry=%d",poolPlants==0 && dry?"PASS":"FAIL",poolPlants,dry);
        return true;
    }
}
class Issue61Palomo : Issue61View
{
    override bool Use(bool pickup)
    {
        Super.Use(pickup);
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(true);
        r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD]=true;
        r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_PALOMO_MET]=true;
        Owner.SetOrigin((-1050,100,0),false);Owner.Angle=0;Owner.Pitch=0;
        return true;
    }
}
class Issue61PalomoResult : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let it=ThinkerIterator.Create("CaelumPalomo");CaelumPalomo p;
        while((p=CaelumPalomo(it.Next()))!=null)Console.Printf("QA61_PALOMO %s waypoint=%d pos=%.1f %.1f %.1f",p.DepartureDone?"PASS":"FAIL",p.DepartureWaypoint,p.Pos.X,p.Pos.Y,p.Pos.Z);
        return true;
    }
}
class Issue61Walk : Issue61View
{
    override bool Use(bool pickup)
    {
        Super.Use(pickup);
        Owner.bNoClip=false;Owner.bNoGravity=false;
        double floor=level.PointInSector((0,1024)).floorplane.ZatPoint((0,1024));
        Owner.SetOrigin((0,1024,floor),false);Owner.Angle=90;Owner.Pitch=0;
        Console.Printf("QA61_WALK_START floor=%.4f",floor);
        return true;
    }
}
class Issue61WalkResult : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        bool ok=!Owner.bNoClip && !Owner.bNoGravity && Owner.Pos.Y>2500;
        Console.Printf("QA61_WALK %s end=%.1f %.1f %.1f floor=%.1f noclip=%d nogravity=%d",ok?"PASS":"FAIL",Owner.Pos.X,Owner.Pos.Y,Owner.Pos.Z,Owner.FloorZ,Owner.bNoClip,Owner.bNoGravity);
        return true;
    }
}
