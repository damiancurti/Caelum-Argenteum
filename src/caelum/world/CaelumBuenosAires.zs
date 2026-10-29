// Instalacion unica y guardable. Los actores trasladados/destruidos no se
// regeneran al volver: Cursor conserva cada posicion ya instalada.
class CaelumBuenosAiresContent : Actor
{
    int Revision, Cursor;
    Array<Actor> Services;
    static CaelumBuenosAiresContent Find()
    {return CaelumBuenosAiresContent(ThinkerIterator.Create('CaelumBuenosAiresContent').Next());}
    static bool Prepare()
    {
        if(!CaelumBuenosAiresData.IsMap(level.MapName))return true;
        // Un censo tipado al cargar; poblacion maxima: un controlador.
        let content=Find();
        if(content==null)content=CaelumBuenosAiresContent(Actor.Spawn('CaelumBuenosAiresContent',CaelumBuenosAiresData.ControllerPosition(),NO_REPLACE));
        return content!=null && content.Install();
    }
    bool Install()
    {
        if(Revision>=CaelumBuenosAiresData.REVISION)return true;
        while(Cursor<CaelumBuenosAiresData.COUNT)
        {
            let body=Actor.Spawn(CaelumBuenosAiresData.ActorClass(Cursor),CaelumBuenosAiresData.Position(Cursor),NO_REPLACE);
            if(body==null)return false;
            body.Angle=CaelumBuenosAiresData.Facing(Cursor);
            let merchant=CaelumCityMerchant(body);
            if(merchant!=null)
            {
                merchant.ShopIdentity=CaelumBuenosAiresData.Merchant(Cursor);
                merchant.Category=CaelumBuenosAiresData.Category(Cursor);
                merchant.TradesClothing=merchant.Category==CaelumShopCatalogue.CLOTHING;
                merchant.WalletCopper=CaelumCityData.MERCHANT_COPPER;merchant.Revision=1;
            }
            let sign=CaelumShopSign(body);
            if(sign!=null){sign.args[0]=CaelumBuenosAiresData.Category(Cursor);sign.RefreshCategory();}
            let station=CaelumCraftingStation(body);
            if(station!=null)station.CraftingRoomGroup=CaelumBuenosAiresData.Network(Cursor);
            let fixture=CaelumDomesticFixture(body);
            if(fixture!=null){fixture.House=CaelumBuenosAiresData.House(Cursor);fixture.Installed=true;}
            Services.Push(body);Cursor++;
        }
        Revision=CaelumBuenosAiresData.REVISION;return true;
    }
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
