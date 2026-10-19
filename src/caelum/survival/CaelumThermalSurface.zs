// Un contacto local con el soporte real, sin actores emisores ni pulsos de daño.
// El balance térmico comparte el área con aire/agua y conserva sus relojes.
class CaelumThermalSurface : Object play
{
    static int KindAt(Actor body)
    {
        if(body==null || body.CurSector==null || body.bNoClip || body.bNoGravity
            || body.health<=0 || body.WaterLevel>0 || body.Vel.Z>0
            || Abs(body.Pos.Z-body.FloorZ)>0.01)return CaelumThermalSurfaceData.NONE;
        Sector support=body.FloorSector;
        let floor=CaelumThermalMotion.Support(body);
        if(floor!=null)support=floor.model;
        if(support==null)return CaelumThermalSurfaceData.NONE;
        int kind=support.GetUDMFInt('user_ca_thermal_surface');
        return CaelumThermalSurfaceData.Valid(kind) ? kind : CaelumThermalSurfaceData.NONE;
    }

    static void Clear(CaelumThermalState thermal)
    {
        thermal.SurfaceKind=CaelumThermalSurfaceData.NONE;thermal.SurfaceC=0;
        for(int slot=0;slot<4;slot++)thermal.SurfaceCoverage[slot]=0;
    }

    static void Sample(Actor body,CaelumThermalState thermal,int priorKind=-1)
    {
        Clear(thermal);
        int kind=priorKind;
        if(kind<0)
        {
            let world=CaelumThermalWorld.Get();
            if(world==null || !world.HasThermalSurfaces)return;
            kind=KindAt(body);
        }
        if(!CaelumThermalSurfaceData.Valid(kind))return;
        // El agua que cubre los pies interrumpe el contacto seco. Nunca ocupa
        // simultáneamente esa franja con el suelo y el camino de inmersión.
        if((thermal.WaterRowMask&1)!=0)return;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        let anatomy=user!=null ? user.AnatomyProfile : npc!=null ? npc.AnatomyProfile : null;
        let coefficients=CaelumThermalCoefficients.Get(thermal);
        coefficients.PrepareCoverage(anatomy);
        thermal.SurfaceKind=kind;thermal.SurfaceC=CaelumThermalSurfaceData.Temperature(kind);
        for(int slot=0;slot<4;slot++)thermal.SurfaceCoverage[slot]=Min(
            coefficients.RowCoverage[slot],Max(0.0,thermal.Coverage[slot]-thermal.SubmergedCoverage[slot]));
    }
}
