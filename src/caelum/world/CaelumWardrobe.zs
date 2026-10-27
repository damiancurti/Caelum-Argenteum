// #410: conserva el dueño físico, contenidos, candado y permisos del cofre.
// El tipo visible no cambia el tamaño MEDIUM usado para sus límites.
class CaelumWardrobeClosedVisual : CaelumStashChestVisual
{States {Spawn:CWRD A -1;Stop;}}
class CaelumWardrobeOpenVisual : CaelumStashChestVisual
{States {Spawn:CWRD B -1;Stop;}}
class CaelumWardrobeLockedVisual : CaelumStashChestVisual
{States {Spawn:CWRD C -1;Stop;}}

class CaelumWardrobe : CaelumStashChest
{
    override double EmptyStorageWeight(){return CaelumWardrobeData.EMPTY_KG;}
    override double StorageVisualScale(){return 1;}
    override int StorageDisplayType(){return CaelumWardrobeData.DISPLAY_TYPE;}
    override String StorageVisualClass()
    {return IsChestLocked()?"CaelumWardrobeLockedVisual":ChestOpen?"CaelumWardrobeOpenVisual":"CaelumWardrobeClosedVisual";}
    override void PostBeginPlay()
    {
        args[4]=CaelumContainerRules.MEDIUM+1;Super.PostBeginPlay();
        A_SetSize(CaelumWardrobeData.RADIUS,CaelumWardrobeData.HEIGHT,false);
    }
    Default {Tag "$CA_FURNITURE_WARDROBE";}
}

class CaelumMansionWardrobe : Object play
{
    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        // Una consulta tipada sólo durante instalación; el controlador guarda
        // el resultado aunque el personaje transporte el mismo armario después.
        if(ThinkerIterator.Create('CaelumWardrobe').Next()!=null)return true;
        vector3 position=CaelumWardrobeData.Position();
        let body=CaelumWardrobe(Actor.Spawn('CaelumWardrobe',position,NO_REPLACE));
        if(body==null)return false;
        body.Angle=CaelumWardrobeData.FACING;
        body.A_SetSize(CaelumWardrobeData.RADIUS,CaelumWardrobeData.HEIGHT,false);
        if(!body.TestMobjLocation() || Abs(body.FloorZ-position.Z)>1 || body.WaterLevel!=0)
        {body.Destroy();return false;}
        return true;
    }
}
