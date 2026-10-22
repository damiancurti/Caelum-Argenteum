// #405: fuentes pequeñas con reserva útil independiente de la masa del modelo.
// Los perfiles, identidades y posiciones proceden del catálogo de datos.
class CaelumLandSource : CaelumTreeEnvironmentProp
{
    int PlacementId;
    int SourceRevision;

    virtual int Profile() { return -1; }
    override bool IsNaturalResource() { return Profile() >= 0; }
    override int GetResourceMaterialType() { return CaelumLandResourceData.Material(Profile()); }
    override double GetResourceCapacityUnits() { return CaelumLandResourceData.Capacity(Profile()); }
    override double GetResourceHardness() { return CaelumLandResourceData.HARDNESS; }
    override double GetResourceAbundance() { return CaelumLandResourceData.ABUNDANCE; }
    override int GetRequiredHarvestDamageType()
    {
        return CaelumLandResourceData.IsHive(Profile()) ? CaelumConstants.CATALOGUE_DAMAGE_NONE
            : CaelumConstants.CATALOGUE_DAMAGE_SLASHING;
    }

    override double TryExtractResource(Actor extractor, int damageKind, double strikePower, int weaponType)
    {
        if(CaelumLandResourceData.IsHive(Profile())) return 0;
        return Super.TryExtractResource(extractor,damageKind,strikePower,weaponType);
    }

    bool CollectHoney(CaelumPlayer user)
    {
        if(user == null || !CaelumPlayerAuthority.CanMutate(user) || user.health <= 0
            || !IsNaturalResource() || !CaelumLandResourceData.IsHive(Profile())) return false;
        EnsureResourceState(); SyncResourceClock();
        int amount = Min(CaelumLandResourceData.HONEY_PER_USE, int(Floor(ResourceRemainingUnits)));
        if(CaelumMainM00SupplyRules.IsLimited(user))
            amount=Min(amount,CaelumMainM00SupplyRules.Remaining(user,GetResourceMaterialType()));
        if(amount <= 0) return false;
        // La miel sale como material físico, igual que una planta cortada.
        // Reservar sólo después del spawn impide perder o duplicar cantidades.
        if(!SpawnExtractedMaterial(user,amount)) return false;
        ResourceRemainingUnits -= amount;
        ScheduleResourceRecovery(user);
        CaelumNotifications.Extracted(user,GetResourceMaterialType());
        return true;
    }

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if(!IsNaturalResource() || !CaelumLandResourceData.IsHive(Profile()) || user == null
            || !CaelumUseGeometry.AimedAt(user,self)) return false;
        if((user.player.cmd.buttons & BT_USE) == 0 || user.FolkloreInteractionUseLatched) return true;
        user.FolkloreInteractionUseLatched = true;
        user.FolkloreInteractionReleaseGuardTics = 0;
        CollectHoney(user);
        return true;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        SourceRevision = CaelumLandResourceData.REVISION;
    }
}

// Registro propio del mapa: una alta persistente por posición autorizada.
// No vuelve a crear una fuente retirada y no reescribe sus reservas al cargar.
class CaelumLandSourceRoster : Actor
{
    int Revision;
    Array<int> Issued;
    Default { +NOINTERACTION }
}

// El coordinador estático también existe al abrir un save anterior a #405.
// Sólo el registro y las fuentes del mapa contienen autoridad persistente.
class CaelumLandSourceEvents : StaticEventHandler
{
    bool Prepared;
    override void WorldLoaded(WorldEvent e)
    {
        Prepared = false;
    }
    override void WorldTick()
    {
        if(Prepared) return;
        Prepared = true;
        if(level.MapName != "MAP01" && level.MapName != "MAP03") return;
        // Un único censo tipado al cargar, limitado al registro de este sistema.
        let iterator = ThinkerIterator.Create("CaelumLandSourceRoster");
        let roster = CaelumLandSourceRoster(iterator.Next());
        if(roster == null) roster = CaelumLandSourceRoster(Actor.Spawn("CaelumLandSourceRoster",(0,0,0),NO_REPLACE));
        if(roster == null) return;
        for(int i=0;i<CaelumLandResourceData.PLACEMENT_COUNT;i++)
        {
            if(CaelumLandResourceData.Map(i) != level.MapName) continue;
            int id = CaelumLandResourceData.PlacementId(i);
            if(roster.Issued.Find(id) < roster.Issued.Size()) continue;
            Vector3 pos = CaelumLandResourceData.Position(i);
            let sector = level.PointInSector(pos.XY);
            if(sector == null) continue;
            pos.Z = sector.FloorPlane.ZatPoint(pos.XY);
            let source = CaelumLandSource(Actor.Spawn(CaelumLandResourceData.PlacementClass(i),pos,NO_REPLACE));
            if(source == null) continue;
            source.PlacementId = id;
            roster.Issued.Push(id);
        }
        roster.Revision = CaelumLandResourceData.REVISION;
    }
}
