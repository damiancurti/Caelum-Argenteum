// La instalación puede recrearse al cruzar el Limbo. Conservar sólo valores
// y su historia natural, nunca referencias a actores o Thinkers de otro mapa.
class CaelumHouseStoredFurnishing : Object play
{
    String Key;
    class<Actor> BodyType;
    int Revision,Profile,Region,Seed,Shelter;
    double Concentration,Stamp,Ambient,Rain,Area,Reference,CivilOffset;
    bool Ready,Variable,Covered;

    void Capture(Actor body,String key,double now)
    {
        self.Key=key;BodyType=body.GetClass();Revision=1;
        let record=CaelumContaminationStorage.Get(body,true);
        if(record==null)return;
        let node=record.Exposure;
        if(node!=null)
        {
            node.Settle(now);Ready=node.HistoryReady;
            Stamp=node.HistoryStamp;Area=node.HistoryArea;
            // Un sello activo termina al abandonar el mapa. El intervalo
            // anterior ya fue liquidado con su muestra efectiva.
            bool temporary=node.Revision>=4 && node.HistoryTemporaryClimate;
            Ambient=temporary?node.HistoryNaturalAmbient:node.HistoryAmbient;
            Variable=temporary?node.HistoryNaturalVariable:node.HistoryVariable;
            Rain=node.Revision>=4?node.HistoryRain:0;Covered=node.HistoryCovered;
            Profile=node.HistoryProfile;Region=node.HistoryRegion;Seed=node.HistorySeed;
            Shelter=node.HistoryShelter;Reference=node.HistoryReference;CivilOffset=node.HistoryCivilOffset;
        }
        Concentration=record.Concentration;
    }

    void Restore(Actor body,double now)
    {
        if(Revision!=1 || body==null || body.bDestroyed || body.GetClass()!=BodyType)return;
        let record=CaelumContaminationStorage.Get(body,true);if(record==null)return;
        CaelumContaminationObject.Register(body);let node=record.Exposure;
        record.Concentration=Concentration;
        if(node==null)return;
        node.Revision=4;node.Ready=false;node.HistoryReady=Ready;
        node.HistoryStamp=Stamp;node.HistoryArea=Area;node.HistoryAmbient=Ambient;node.HistoryRain=Rain;
        node.HistoryVariable=Variable;node.HistoryCovered=Covered;
        node.HistoryProfile=Profile;node.HistoryRegion=Region;node.HistorySeed=Seed;
        node.HistoryShelter=Shelter;node.HistoryReference=Reference;node.HistoryCivilOffset=CivilOffset;
        node.HistoryTemporaryClimate=false;node.HistoryNaturalVariable=Variable;node.HistoryNaturalAmbient=Ambient;
        // Reusar el integrador y la caché regional compartidos. Después se
        // toma una muestra local nueva, sin cobrar otra vez el tiempo ausente.
        node.Settle(now);node.Advance();
    }
}
