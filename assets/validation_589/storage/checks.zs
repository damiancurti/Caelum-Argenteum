class CA502SurfaceActor : Actor
{
    Default { Radius 16; Height 32; +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA502StorageChecks : CA502Checks
{
    CaelumWeaponPickup SavedWeapon;
    CA502SurfaceActor SavedSurface;

    CaelumEquipmentItem FindContaminated(CaelumPlayer u,double value)
    {
        for(Inventory item=u.Inv;item!=null;item=item.Inv)
        {
            let equipment=CaelumEquipmentItem(item);
            if(equipment!=null && Near(CaelumContaminationStorage.Value(equipment),value))return equipment;
        }
        return null;
    }
    void Storage(CaelumPlayer u)
    {
        Reset(u,1000,20);u.DerivedStats.BaseMass=80;
        let source=Actor.Spawn('CA502SurfaceActor',u.Pos+(100,0,0),NO_REPLACE);
        Check(CaelumContaminationStorage.Get(source)==null
            && Near(CaelumContaminationStorage.Value(source),0),"untracked actor begins clean without creating state on read");
        CaelumContaminationStorage.Set(source,80);
        CaelumContaminationStorage.Touch(source,u,0.01,10);
        Check(Near(CaelumFoodIllness.Value(u),20.0399600798006)
            && Near(CaelumContaminationStorage.Value(source),80),"native actor contact writes existing body resource and preserves source");
        CaelumFoodIllness.Get(u).Contamination=20;u.DerivedStats.BaseMass=40;
        CaelumContaminationStorage.Touch(u,source,0.01,10);
        Check(Near(CaelumFoodIllness.Value(u),20.0798406368178),"reversed actor ordering retains40kg double dose");
        let same=CaelumContaminationStorage.Get(source);
        same.Ensure();same.Ensure();
        Check(Near(same.Concentration,80),"actor-state migration idempotent");
        let weapon=CaelumWeaponPickup(Actor.Spawn('CaelumWeaponPickup',u.Pos+(100,32,0),NO_REPLACE));
        Check(CaelumContaminationStorage.Get(weapon)==null,"old equipment reads as clean");
        CaelumContaminationStorage.Set(weapon,12.5);
        Actor receiver=u;
        Check(weapon.CallTryPickup(receiver),"native equipment pickup succeeds");
        let owned=FindContaminated(u,12.5);
        Check(owned!=null && owned.Owner==u,"native pickup retains individual contamination");
        if(owned!=null)
        {
            owned.Equipped=false;
            owned.InMagicBox=true;CaelumContaminationStorage.Touch(owned,source,1,100);
            Check(Near(CaelumContaminationStorage.Value(owned),12.5),"Box shields contact without cleaning stored item");
            owned.InMagicBox=false;
            let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(0,48,0),NO_REPLACE));
            chest.ChestUnlocked=true;CaelumContainerSession.Open(u,chest);
            Check(CaelumInventoryService.TransferContainerItem(u,chest,owned,1,true),"native chest deposit succeeds");
            chest.ChestOpen=false;
            CaelumContaminationStorage.Touch(owned,source,1,100);
            Check(owned.Owner==chest && Near(CaelumContaminationStorage.Value(owned),12.5),"closed chest shields contact and preserves concentration");
            chest.ChestOpen=true;CaelumContaminationStorage.Touch(owned,source,0.01,10);
            Check(CaelumContaminationStorage.Value(owned)>12.5,"open chest permits explicit contact");
            double before=CaelumContaminationStorage.Value(owned);
            Check(CaelumInventoryService.TransferContainerItem(u,chest,owned,1,false)
                && Near(CaelumContaminationStorage.Value(owned),before),"native chest withdrawal retains contamination");
            let tossed=CaelumEquipmentItem(owned.CreateTossable(1));
            Check(tossed!=null && Near(CaelumContaminationStorage.Value(tossed),before),"native toss-copy preserves contamination");
            if(tossed!=null && tossed!=owned)
            {
                CaelumContaminationStorage.Set(tossed,5);
                Check(Near(CaelumContaminationStorage.Value(owned),before),"tossed copy cannot mutate source state by alias");
                tossed.Destroy();
            }
            CaelumContainerSession.Get(u).Close();chest.Destroy();owned.Destroy();
        }
        bool all=true;
        for(int kind=0;kind<CaelumConstants.WEAPON_TYPE_COUNT;kind++)
            all=all && CaelumContaminationData.WeaponAreaM(kind)>0;
        Check(all,"every supported weapon type has approved area");
        bool shields=true;
        for(int kind=0;kind<CaelumConstants.SHIELD_TYPE_COUNT;kind++)
            shields=shields && CaelumContaminationData.ShieldAreaM(kind)>0;
        Check(shields,"every supported shield type has approved exterior area");
        Check(Near(CaelumContaminationRules.WeaponArea(CaelumConstants.WEAPON_TYPE_SWORD,CaelumConstants.EQUIPMENT_SIZE_XS),0.10079368399159),"size conversion uses geometric similarity");
        Check(Near(CaelumContaminationRules.CylinderArea(16,32),4.71238898038469),"generic cylinder uses32 map units per metre");
        source.Destroy();Reset(u,1000,0);
    }
    void SeedStorage(CaelumPlayer u)
    {
        Reset(u,1000,12.5);u.DerivedStats.HealthRegenerationPerSecond=0;
        SavedWeapon=CaelumWeaponPickup(Actor.Spawn('CaelumWeaponPickup',u.Pos+(100,0,0),NO_REPLACE));
        CaelumContaminationStorage.Set(SavedWeapon,73.125);
        SavedSurface=CA502SurfaceActor(Actor.Spawn('CA502SurfaceActor',u.Pos+(100,32,0),NO_REPLACE));
        CaelumContaminationStorage.Set(SavedSurface,61.75);
        Check(SavedWeapon.ContaminationState!=null && SavedSurface.Inv!=null,"native persistence actors seeded");
    }
    void LoadedStorage(CaelumPlayer u)
    {
        Check(SavedWeapon!=null && Near(CaelumContaminationStorage.Value(SavedWeapon),73.125),"native saved weapon concentration restored");
        Check(SavedSurface!=null && Near(CaelumContaminationStorage.Value(SavedSurface),61.75),"native saved surface concentration restored");
        Check(Near(CaelumFoodIllness.Value(u),12.5),"player contamination stays in original authoritative record");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502_storage')Storage(u);
        else if(e.Name=='ca502_storage_seed')SeedStorage(u);
        else if(e.Name=='ca502_storage_load')LoadedStorage(u);
        else {Super.NetworkProcess(e);return;}
        Console.Printf("CA502 RESULT passes=%d failures=%d",Passed,Failed);
    }
}
