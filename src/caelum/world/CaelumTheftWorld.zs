// El mapa conserva sus actores de hub y sus instancias de inventario. Esta
// autoridad no atraviesa mapas ni fabrica accesos de viviendas no observadas.
class CaelumTheftFoodHistory : Object play
{
    Inventory Item;
    double Stamp;
}
class CaelumTheftWorld : Actor
{
    String SourceMap;
    Array<CaelumTheftPlan> Plans;
    Array<CaelumTheftFoodHistory> Foods;
    int Revision,Cursor;
    bool Away;

    static CaelumTheftWorld Find()
    {let search=ThinkerIterator.Create('CaelumTheftWorld');return CaelumTheftWorld(search.Next());}
    static void Register(CaelumCombatActor body)
    {if(body!=null && body.AbsentTheft==null)body.AbsentTheft=new('CaelumTheftPlan');}
    static void Capture(CaelumPlayer user,out Array<CaelumCombatActor> thieves)
    {
        if(user==null || thieves.Size()==0)return;
        let world=Find();if(world==null)world=CaelumTheftWorld(Spawn('CaelumTheftWorld',(0,0,0),NO_REPLACE));
        if(world==null || world.Away)return;
        world.Revision=CaelumTheftData.REVISION;world.SourceMap=level.MapName;world.Plans.Clear();world.Foods.Clear();world.Cursor=0;
        double now=CaelumContaminationAbsence.Clock(user,level.MapName);if(now<0)return;
        Array<CaelumStashChest> chests;
        let search=ThinkerIterator.Create('CaelumStashChest');CaelumStashChest chest;
        while((chest=CaelumStashChest(search.Next()))!=null)
            if(chest.Cargo==null && !chest.bDestroyed)chests.Push(chest);
        let query=new('CaelumTheftAccess');bool firstQuery=true;
        for(int i=0;i<thieves.Size();i++)
        {
            let body=thieves[i];if(body==null || body.health<=0 || body.AbsentTheft==null)continue;
            query.Prepare(body,firstQuery);firstQuery=false;Array<CaelumStashChest> reachable;
            for(int j=0;j<chests.Size();j++)if(query.Reachable(chests[j]))reachable.Push(chests[j]);
            query.Close();
            body.AbsentTheft.World=world;body.AbsentTheft.Begin(body,level.MapName,now,reachable);
            if(body.AbsentTheft.Away)world.Plans.Push(body.AbsentTheft);
            for(int j=0;j<reachable.Size();j++)
                for(Inventory item=reachable[j].Inv;item!=null;item=item.Inv)world.CaptureFood(item,now);
        }
        world.Away=world.Plans.Size()>0;
    }
    void CaptureFood(Inventory item,double now)
    {
        if(!CaelumFoodInventory.IsFood(item))return;
        for(int i=0;i<Foods.Size();i++)if(Foods[i].Item==item)return;
        CaelumFoodInventory.Reconcile(item);
        let row=new('CaelumTheftFoodHistory');row.Item=item;row.Stamp=now;Foods.Push(row);
    }
    void BeforeTransfer(Inventory item,double at)
    {
        for(int i=0;i<Foods.Size();i++)
        {
            let row=Foods[i];if(row.Item!=item || at<=row.Stamp)continue;
            let clock=CaelumFoodClock.Get(item);
            if(clock!=null && clock.Climate!=null)
            {
                clock.Climate.Advance(CaelumFoodInventory.Prepare(item),at-row.Stamp);
                clock.Stamp+=at-row.Stamp;
            }
            row.Stamp=at;return;
        }
    }
    void AfterTransfer(CaelumCombatActor body,Inventory item)
    {
        let absent=body.ContaminationAbsence;
        let clock=CaelumFoodClock.Get(item);
        if(clock!=null && absent!=null && absent.Climate!=null)
        {clock.Climate=absent.Climate.Copy();clock.Climate.CivilSeconds=absent.Civil;clock.Ready=false;}
        if(absent!=null && absent.Away)
        {
            if(absent.Foods!=null)absent.Foods.Refresh(body);
            if(absent.Exposure!=null && body.ThermalState!=null)
            {
                absent.Exposure.Capture(body,body.ThermalState);
                absent.Exposure.Frame.BindFood(absent.Foods);
            }
        }
    }
    double Boundary(double end)
    {
        double next=end;
        for(int i=0;i<Plans.Size();i++)if(Plans[i].Away)next=Min(next,Plans[i].NextDue);
        return next;
    }
    bool Step(double now)
    {
        if(Cursor>=Plans.Size()){Cursor=0;return true;}
        let plan=Plans[Cursor++];if(plan.Due(now))plan.Step(now);return false;
    }
    void Finish(CaelumPlayer user,double now)
    {
        for(int i=0;i<Plans.Size();i++)
        {
            let plan=Plans[i];plan.Finish(now);
            int found=plan.Discover(user,level.MapName);
            if(found>0 && user!=null)
                user.A_Log(String.Format(StringTable.Localize("CA_ABSENT_THEFT_FOUND",false),found));
        }
        Away=false;Foods.Clear();
    }
    Default { +NOGRAVITY +NOBLOCKMAP +NOSECTOR +INVISIBLE Radius 0; Height 0; }
    States { Spawn: TNT1 A -1; Stop; }
}
