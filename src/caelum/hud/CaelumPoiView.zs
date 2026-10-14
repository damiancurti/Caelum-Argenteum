// Adaptador de sólo lectura: nombres e iconos proceden de hechos conocidos.
class CaelumPoiView : Object ui
{
    static CaelumKnownPoi Nearest(CaelumPlayer user,Vector2 center)
    {
        if(user==null)return null;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if(record==null)return null;
        CaelumKnownPoi nearest;double best=0;
        for(int i=0;i<record.KnownPois.Size();i++)
        {
            let fact=record.KnownPois[i];
            if(fact==null || fact.MapId!=level.MapName)continue;
            double distance=(fact.ObservedPosition.XY-center).LengthSquared();
            if(nearest==null || distance<best){nearest=fact;best=distance;}
        }
        return nearest;
    }
    static String Name(CaelumKnownPoi fact)
    {
        if(fact==null)return "";
        return StringTable.Localize(CaelumPoiData.CategoryKey(fact.Category),false)..": "..StringTable.Localize(fact.NameKey,false);
    }
    static String CenterLabel(CaelumPlayer user)
    {
        let fact=Nearest(user,level.GetAutomapPosition());
        if(fact==null)return "";
        return String.Format(StringTable.Localize("CA_POI_NEAREST",false),Name(fact));
    }
}
