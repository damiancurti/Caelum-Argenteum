// Catálogo de contenido existente: enlazar no crea actores ni descubre lugares.
class CaelumAuthoredCartography : Object play
{
    static void BindSubject(Actor subject,int category)
    {
        if(subject==null)return;
        String id,nameKey;
        if(level.MapName=="MAP01")
        {
            // Los servicios siguen a sus instancias reales en guardados antiguos.
            let bed=CaelumRestBed(subject);
            let station=CaelumCraftingStation(subject);
            if(category==CaelumPoiData.BED && bed!=null && bed.TrialSlot>=101 && bed.TrialSlot<=104)
            {id=String.Format("mansion-bed-%d",bed.TrialSlot);nameKey=String.Format("CA_POI_BED_%d",bed.TrialSlot);}
            else if(category==CaelumPoiData.STATION && station!=null
                && station.CraftingRoomGroup>=1 && station.CraftingRoomGroup<=5)
            {
                id=String.Format("mansion-station-%d-%d",station.CraftingRoomGroup,station.GetCraftingStationType());
                nameKey=CaelumCartographyServiceData.StationName(station.GetCraftingStationType());
            }
            else if(category==CaelumPoiData.MERCHANT && subject is "CaelumPalomo")
            {id="mansion-palomo";nameKey="CA_POI_PALOMO";}
        }
        else if(level.MapName=="MAP02")
        {
            if(category==CaelumPoiData.GRATE && subject is "CaelumMazeBarredGate"
                && subject.args[0]>=44700 && subject.args[0]<=44723)
            {id=String.Format("maze-grate-%d",subject.args[0]);nameKey="CA_POI_MAZE_GRATE";}
            else if(category==CaelumPoiData.GRATE && subject is "CaelumMazeReturnGrate"
                && CaelumMazeLayout.IsReturnGrate(subject.args[0]))
            {id=String.Format("maze-return-%d",subject.args[0]);nameKey="CA_POI_RETURN_GRATE";}
        }
        else if(level.MapName=="MAP03")
        {
            let port=CaelumPortSiege.Get();
            if(category==CaelumPoiData.EXIT && subject is "CaelumBreakableGate" && port!=null)
                for(int i=0;i<port.Gates.Size();i++)if(port.Gates[i]==subject)
                {
                    // Las revisiones antiguas conservan sus seis accesos reales,
                    // sin aplicarles coordenadas ni nombres de otra orientación.
                    id=String.Format("port-r%d-gate-%d",port.args[0],i);
                    nameKey=CaelumCityData.Enabled()?String.Format("CA_POI_PORT_GATE_%d",i):"CA_POI_PORT_GATE_LEGACY";
                    break;
                }
            let vendor=CaelumCityMerchant(subject);
            let bed=CaelumRestBed(subject);
            let station=CaelumCraftingStation(subject);
            if(CaelumCityData.Enabled() && category==CaelumPoiData.MERCHANT && vendor!=null
                && vendor.ShopIdentity>=0 && vendor.ShopIdentity<CaelumCityData.SHOP_COUNT)
            {id=String.Format("city-shop-%d",vendor.ShopIdentity);nameKey=String.Format("CA_CITY_SHOP_%d",vendor.Category);}
            else if(CaelumCityData.Enabled() && category==CaelumPoiData.BED && bed!=null
                && bed.TrialSlot>=CaelumCityData.FURNITURE_SLOT_BASE
                && bed.TrialSlot<CaelumCityData.FURNITURE_SLOT_BASE+CaelumCityData.HOUSE_COUNT)
            {id=String.Format("city-bed-%d",bed.TrialSlot-CaelumCityData.FURNITURE_SLOT_BASE);nameKey="CA_POI_CITY_BED";}
            else if(CaelumCityData.Enabled() && category==CaelumPoiData.STATION && station!=null
                && CaelumCartographyCatalogueData.MatchesCityGeometry(level.GetChecksum()))
            {
                // El origen identifica la instancia del mapa aunque después se mueva.
                id=CaelumCartographyCatalogueData.CityStationId(station.SpawnPoint);
                nameKey=CaelumCartographyServiceData.StationName(station.GetCraftingStationType());
            }
            else if(category==CaelumPoiData.TRANSPORT && subject is "CaelumCoveredCart")
            {id="port-covered-cart";nameKey="CA_POI_COVERED_CART";}
            else if(category==CaelumPoiData.TRANSPORT && subject is "CaelumMerchantShip")
            {id="port-merchant-ship";nameKey="CA_POI_MERCHANT_SHIP";}
        }
        let travel=CaelumSewerTravelGate(subject);
        if(category==CaelumPoiData.EXIT && travel!=null && travel.Placed
            && (level.MapName=="MAP02" || level.MapName=="MAP03")
            && CaelumWorldCatalogue.IsSewerConnection(travel.ConnectionId))
        {id=String.Format("travel-%d",travel.ConnectionId);nameKey=CaelumWorldCatalogue.ConnectionNameKey(travel.ConnectionId);}
        if(id.Length()>0)CaelumPoiRegistration.Bind(subject,id,category,nameKey);
    }

    // Instantánea tomada exclusivamente en la interacción de este personaje.
    static int ObservedAccess(Actor subject)
    {
        let grate=CaelumMazeBarredGate(subject);
        if(grate!=null)return grate.Opened?CaelumPoiData.ACCESS_OPEN:CaelumPoiData.ACCESS_CLOSED;
        let back=CaelumMazeReturnGrate(subject);
        if(back!=null)return back.Opened?CaelumPoiData.ACCESS_OPEN:CaelumPoiData.ACCESS_CLOSED;
        let gate=CaelumBreakableGate(subject);
        if(gate!=null)return gate.Opened || gate.Broken?CaelumPoiData.ACCESS_OPEN:CaelumPoiData.ACCESS_CLOSED;
        return CaelumPoiData.ACCESS_UNKNOWN;
    }

    static void Update(CaelumPlayer user,CaelumPersistentCharacterState record)
    {
        bool first=record.CartographyMap!=level.MapName;
        if(first)
        {record.CartographyMap=level.MapName;record.CartographyChecksum=level.GetChecksum();}
        if(level.MapName=="MAP01" && CaelumCartographyCatalogueData.MatchesMansionGeometry(record.CartographyChecksum))
        {
            for(int i=0;i<CaelumCartographyCatalogueData.MANSION_ROOMS;i++)
                if(CaelumCartographyCatalogueData.MansionContains(i,user.Pos))
                    CaelumPoiKnowledge.Record(user,"mansion-room-"..CaelumCartographyCatalogueData.MansionId(i),
                        CaelumPoiData.ROOM,CaelumCartographyCatalogueData.MansionName(i),
                        CaelumCartographyCatalogueData.MansionPosition(i));
        }
        else if(level.MapName=="MAP03" && CaelumCityData.Enabled()
            && CaelumCartographyCatalogueData.MatchesCityGeometry(record.CartographyChecksum))
        {
            for(int i=0;i<4;i++)if(CaelumCartographyCatalogueData.TowerContains(i,user.Pos))
                CaelumPoiKnowledge.Record(user,String.Format("city-tower-%d",i),CaelumPoiData.TOWER,
                    String.Format("CA_POI_TOWER_%d",i),CaelumCartographyCatalogueData.TowerPosition(i));
            if(!first && CaelumCartographyCatalogueData.CrossesEast(record.CartographyPreviousPosition,user.Pos))
                CaelumPoiKnowledge.Record(user,"city-east-exit",CaelumPoiData.EXIT,"CA_POI_EAST_EXIT",
                    CaelumCartographyCatalogueData.EastPosition());
        }
        record.CartographyPreviousPosition=user.Pos;
    }
}
