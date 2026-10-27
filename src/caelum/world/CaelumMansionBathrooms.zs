// #410: doce sanitarios fijos, con una única reserva doméstica ya existente.
// El controlador pertenece al mapa y el agua al registro viajero de la mansión.
class CaelumMansionBathrooms : Actor
{
    int Revision;
    CaelumDomesticFixture Fixtures[CaelumMansionBathroomData.COUNT];

    static CaelumMansionBathrooms Find()
    {return CaelumMansionBathrooms(ThinkerIterator.Create('CaelumMansionBathrooms').Next());}

    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        // Una consulta tipada durante instalación/migración; al quedar listo,
        // el controlador de la misión deja de llamarnos. Reintento a1Hz.
        let installation=Find();
        if(installation==null)installation=CaelumMansionBathrooms(Actor.Spawn('CaelumMansionBathrooms',(0,0,0),NO_REPLACE));
        if(installation==null)return false;
        bool ready=true;
        for(int index=0;index<CaelumMansionBathroomData.COUNT;index++)
        {
            if(installation.Fixtures[index]!=null)continue;
            int kind=CaelumMansionBathroomData.Kind(index);
            vector3 position=CaelumMansionBathroomData.Position(index);
            let fixture=CaelumDomesticFixture(Actor.Spawn(CaelumDomesticFixtureData.ActorClass(kind),position,NO_REPLACE));
            if(fixture==null){ready=false;continue;}
            fixture.House=CaelumDomesticWaterData.MANSION;
            fixture.Angle=CaelumMansionBathroomData.Facing(index);
            // PostBeginPlay puede estar diferido; validar el volumen definitivo.
            fixture.A_SetSize(CaelumDomesticFixtureData.Radius(kind),CaelumDomesticFixtureData.Height(kind),false);
            if(!fixture.TestMobjLocation() || !fixture.ClearOfActors(fixture) || Abs(fixture.FloorZ-position.Z)>1)
            {fixture.Destroy();ready=false;continue;}
            fixture.Installed=true;installation.Fixtures[index]=fixture;
        }
        if(ready)installation.Revision=CaelumMansionBathroomData.REVISION;
        return ready;
    }
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
