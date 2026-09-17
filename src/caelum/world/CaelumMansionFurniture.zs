// Mobiliario de MAP01. No altera geometría, inventarios, hitos ni rutas del hub.
class CaelumMansionFurniture : Object play
{
    static bool Bed(int slot,vector3 position,double facing)
    {
        if(CaelumRestFurnitureTrial.Find(slot)!=null)return true;
        let bed=CaelumRestBed(Actor.Spawn("CaelumRestBed",position,NO_REPLACE));
        if(bed==null)return false;
        if(!bed.TestMobjLocation() || Abs(bed.FloorZ-position.Z)>1){bed.Destroy();return false;}
        bed.TrialSlot=slot;bed.Angle=facing;return true;
    }

    static bool Align(int slot,vector3 tablePosition,vector3 bedPosition=(0,0,0),double facing=90)
    {
        let table=CaelumDiningWorld.Find(slot);
        let bed=CaelumRestFurnitureTrial.Find(slot);
        if(table==null || (slot<=104 && bed==null))return false;
        bool moveTable=(table.Pos-tablePosition).Length()>0.01 || Abs(table.Angle-facing)>0.01;
        bool moveBed=bed!=null && (bed.Pos-bedPosition).Length()>0.01;
        if(!moveTable && !moveBed)return CaelumDiningWorld.EnsureSeats(table);
        // Un guardado sentado se conserva. La mudanza espera a levantarse,
        // y mueve las mismas instancias con sus pertenencias y referencias.
        if(table.LayoutOccupied() || (bed!=null && bed.Occupant!=null))return false;
        vector3 oldTable=table.Pos;
        double oldAngle=table.Angle;
        vector3 oldBed=bed!=null?bed.Pos:(0,0,0);
        if(bed!=null)bed.SetOrigin(bedPosition,false);
        table.MoveLayout(tablePosition,facing);
        if(CaelumDiningWorld.EnsureSeats(table) && table.LayoutFits()
            && (bed==null || (bed.TestMobjLocation() && Abs(bed.FloorZ-bed.Pos.Z)<=1)))return true;
        if(bed!=null)bed.SetOrigin(oldBed,false);
        table.MoveLayout(oldTable,oldAngle);
        return false;
    }
    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        bool ready=true;
        // Rulo / Ronnie al norte; Caella / Argento al sur. Acceso y NPC libres.
        for(int i=0;i<4;i++)
        {
            double x=i%2==0?-384:944;
            double side=i<2?1:-1;
            vector3 tablePosition=i%2==0?(x,side*392,136):(1072,side*480,136);
            vector3 bedPosition=i%2==0?(x+176,side*472,136):(x,side*392,136);
            // Al este, el piso continúa detrás de la pared: FloorZ por sí solo
            // no detectaba la silla oculta. Ambas plazas quedan ahora adentro.
            double tableFacing=i%2==0?90:0;
            if(!CaelumDiningWorld.Place(101+i,tablePosition,1,tableFacing))ready=false;
            if(!Bed(101+i,bedPosition,side>0?90:270))ready=false;
            if(!Align(101+i,tablePosition,bedPosition,tableFacing))ready=false;
        }
        if(!CaelumDiningWorld.Place(105,(1652,0,0),2,90))ready=false;
        if(!Align(105,(1652,0,0)))ready=false;
        if(!CaelumDiningWorld.Place(106,(496,-192,264),3))ready=false;
        return ready;
    }
}
