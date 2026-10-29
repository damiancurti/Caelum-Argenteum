// #410: limites aprobados el 27-10-2026; escritorio derivado de la mesa pequena.
class CaelumStoredReadingData : Object
{
    const REVISION=1;
    const SLOTS=25;
    const CAPACITY_KG=100.0;
    const DISPLAY_TYPE=4;
    const DESK_RADIUS=40;
    const DESK_HEIGHT=34;
    static vector3 DeskPosition(){return CaelumReadingFurnitureData.Position()+(0,80,0);}
}
