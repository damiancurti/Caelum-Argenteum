// #408: la calidad pertenece al agua del recipiente, no al jugador.
class CaelumWaterQuality : Object
{
    const REVISION = 1;
    const POTABLE = 0;
    const BIOLOGICAL = 1;
    const SALT = 2;
    const CHEMICAL = 4;
    const ALL = BIOLOGICAL | SALT | CHEMICAL;
    const UNIDENTIFIED = -1;

    static clearscope bool Valid(int quality) { return quality >= 0 && quality <= ALL; }
    static clearscope bool IsSafe(int quality) { return quality == POTABLE; }
    static clearscope Sector Model(CaelumPlayer user)
    {
        if(user==null || user.WaterLevel<3 || user.CurSector==null)return null;
        let sector=user.CurSector;
        double z=user.Pos.Z+user.Height*0.75;
        for(int i=0;i<sector.Get3DFloorCount();i++)
        {
            let volume=sector.Get3DFloor(i);
            if(volume!=null && (volume.flags&(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE))
                ==(F3DFloor.FF_EXISTS|F3DFloor.FF_SWIMMABLE)
                && z>=volume.bottom.ZatPoint(user.Pos.XY) && z<=volume.top.ZatPoint(user.Pos.XY))return volume.model;
        }
        let height=sector.GetHeightSec();
        return height!=null && z<=height.floorplane.ZatPoint(user.Pos.XY) ? height : sector;
    }
    static clearscope int Metadata(Sector source)
    {
        if(source==null)return UNIDENTIFIED;
        int quality=source.GetUDMFInt('user_ca_water_quality');
        if (!Valid(quality)) return UNIDENTIFIED;
        // Una contaminación explícita prevalece sobre la marca potable antigua.
        if (quality != POTABLE) return quality;
        return source.GetUDMFInt('user_ca_potable_water') != 0 ? POTABLE : UNIDENTIFIED;
    }
    static clearscope int Source(CaelumPlayer user)
    {
        let source=Model(user);if(source==null)return UNIDENTIFIED;
        return Volume(source,user.CurSector);
    }
    static clearscope int Volume(Sector source,Sector host)
    {
        if(source==null)return UNIDENTIFIED;
        let water=CaelumConnectedWaterMap.Get();
        int index=water!=null ? water.Index(source) : -1;
        if(index>=0)return water.Quality(index);
        // Una calidad explícita del volumen prevalece. Las piscinas anteriores
        // sin metadatos en el modelo conservan la identidad de su sector huésped.
        if(source.GetUDMFInt('user_ca_water_quality')!=0 || source.GetUDMFInt('user_ca_potable_water')!=0)return Metadata(source);
        return Metadata(host);
    }
    static clearscope String Label(int quality)
    {
        if (!Valid(quality)) return StringTable.Localize("CA_WATER_UNKNOWN", false);
        if (IsSafe(quality)) return StringTable.Localize("CA_WATER_POTABLE", false);
        String result = "";
        if (quality & BIOLOGICAL) result = StringTable.Localize("CA_WATER_BIOLOGICAL", false);
        if (quality & SALT) result = result .. (result.Length() > 0 ? " + " : "") .. StringTable.Localize("CA_WATER_SALT", false);
        if (quality & CHEMICAL) result = result .. (result.Length() > 0 ? " + " : "") .. StringTable.Localize("CA_WATER_CHEMICAL", false);
        return result;
    }
    static play double DrinkSource(CaelumPlayer user,double requested)
    {
        if(user==null || requested<=0)return 0;
        let water=CaelumConnectedWaterMap.Get();
        if(water==null)return requested;
        water.Sync(CaelumWorldClock.Get(user));
        int index=water.Index(Model(user));if(index<0)return requested;
        if(water.Quality(index)!=POTABLE || user.DerivedStats==null)return 0;
        // Reutiliza exactamente la hidratación por litro de los recipientes.
        double perLiter=CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE
            *CaelumConstants.CONSUMABLE_REGENERATION_SECONDS/Max(1.0,user.DerivedStats.BaseMass);
        return water.Withdraw(index,requested/perLiter)*perLiter;
    }
    static play void InventoryAction(CaelumPlayer user, bool empty)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || user.health <= 0 || user.isFrozen()) return;
        let item = CaelumWaterContainer(user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex));
        if (item == null || item.Owner != user || item.InMagicBox) return;
        bool changed = empty ? item.EmptyWater(user) : item.FillFromSource(user);
        CaelumNotifications.Notify(user, StringTable.Localize(changed
            ? (empty ? "CA_WATER_EMPTIED" : "CA_WATER_COLLECTED") : "CA_WATER_TRANSFER_REJECTED", false));
        user.RefreshFormalInventorySnapshot();
    }
}
