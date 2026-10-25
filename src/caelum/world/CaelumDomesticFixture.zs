// #410: instalación fija; agua compartida por vivienda. Higiene en #502.
class CaelumDomesticFixture : Actor abstract
{
    int House;
    bool Installed;
    virtual int Kind(){return 0;}
    virtual bool SuppliesWater(){return true;}
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_SetSize(CaelumDomesticFixtureData.Radius(Kind()),CaelumDomesticFixtureData.Height(Kind()));
    }
    bool CanReach(CaelumPlayer user)
    {
        return Installed && CaelumPlayerAuthority.CanMutate(user) && user.health>0 && !user.isFrozen()
            && House>=0 && House==CaelumHouseHubData.HouseForMap(level.MapName)
            && user.Distance3D(self)<=user.UseRange+Radius && user.CheckSight(self)
            && CaelumPropertyRules.ResidenceAllowed(user);
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(!SuppliesWater() || !CanReach(user) || !CaelumUseGeometry.AimedAt(user,self))return false;
        let reserve=CaelumDomesticWater.Get(House);if(reserve==null)return false;
        CaelumNotifications.Notify(user,String.Format(StringTable.Localize("CA_DOMESTIC_WATER_AVAILABLE",false),reserve.Liters));
        return true;
    }
    bool Fill(CaelumPlayer user,CaelumWaterContainer container)
    {
        if(!SuppliesWater() || !CanReach(user) || container==null || container.Owner!=user || container.InMagicBox)return false;
        let reserve=CaelumDomesticWater.Get(House);if(reserve==null)return false;
        double liters=Min(Max(0.0,container.GetCapacityLiters()-container.WaterLiters),reserve.Liters);
        if(liters<=0.000001 || !user.CanAddWeightToPersonalInventory(liters+0.001)
            || !container.AddWater(liters,CaelumWaterQuality.POTABLE))return false;
        reserve.Withdraw(liters);
        let record=user.GetPersistentCharacterState(false);
        if(container.IsPotable() && record!=null && record.MainM00WaterContainerGiven)record.MainM00WaterFilled=true;
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    static CaelumDomesticFixture SourceFor(CaelumPlayer user)
    {
        if(user==null)return null;
        let it=BlockThingsIterator.Create(user,user.UseRange+CaelumDomesticFixtureData.Radius(1));
        while(it.Next())
        {
            let source=CaelumDomesticFixture(it.thing);
            if(source!=null && source.SuppliesWater() && source.CanReach(user) && CaelumUseGeometry.AimedAt(user,source))return source;
        }
        return null;
    }
    Default {+SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE +CANPASS}
}
class CaelumDomesticSink : CaelumDomesticFixture
{
    Default {Tag "$CA_DOMESTIC_SINK";}
    States {Spawn:CDSK A -1;Stop;}
}
class CaelumDomesticBathtub : CaelumDomesticFixture
{
    override int Kind(){return 1;}
    Default {Tag "$CA_DOMESTIC_BATHTUB";}
    States {Spawn:CDBT A -1;Stop;}
}
class CaelumDomesticToilet : CaelumDomesticFixture
{
    override int Kind(){return 2;}
    override bool SuppliesWater(){return false;}
    override bool Used(Actor activator)
    {let user=CaelumPlayer(activator);return CanReach(user) && CaelumUseGeometry.AimedAt(user,self) && CaelumHygieneTask.Begin(user,self);}
    Default {Tag "$CA_DOMESTIC_TOILET";}
    States {Spawn:CDWC A -1;Stop;}
}
class CaelumBathroomInstallation : Actor
{
    int Revision;
    CaelumDomesticFixture Fixtures[CaelumDomesticFixtureData.COUNT];
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
    static bool Prepare(int house)
    {
        if(house<0 || house>=CaelumCityData.HOUSE_COUNT)return false;
        // Consulta tipada sólo al entrar/reintentar una ubicación ocupada:
        // un controlador y tres sanitarios por mapa, nunca por NPC/tic.
        let it=ThinkerIterator.Create('CaelumBathroomInstallation');
        let room=CaelumBathroomInstallation(it.Next());
        if(room==null)room=CaelumBathroomInstallation(Actor.Spawn('CaelumBathroomInstallation',CaelumCityData.HouseOrigin(house),NO_REPLACE));
        if(room==null || CaelumDomesticWater.Get(house)==null)return false;
        bool ready=true;
        for(int kind=0;kind<CaelumDomesticFixtureData.COUNT;kind++)
        {
            if(room.Fixtures[kind]!=null)continue;
            vector3 position=CaelumCityData.HouseOrigin(house)+CaelumDomesticFixtureData.Offset(kind);
            let fixture=CaelumDomesticFixture(Actor.Spawn(CaelumDomesticFixtureData.ActorClass(kind),position,NO_REPLACE));
            if(fixture==null){ready=false;continue;}
            fixture.House=house;fixture.Angle=CaelumDomesticFixtureData.Facing(kind);
            // Spawn puede aplazar PostBeginPlay: comprobar la huella definitiva.
            fixture.A_SetSize(CaelumDomesticFixtureData.Radius(kind),CaelumDomesticFixtureData.Height(kind));
            if(!fixture.TestMobjLocation() || Abs(fixture.FloorZ-position.Z)>1)
            {fixture.Destroy();ready=false;continue;}
            fixture.Installed=true;room.Fixtures[kind]=fixture;
        }
        if(ready)room.Revision=CaelumDomesticFixtureData.REVISION;
        return ready;
    }
}
