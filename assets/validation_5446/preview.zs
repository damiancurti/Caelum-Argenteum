// Ayudas privadas de inspección; no cambian blancos ni reglas de combate.
class CA334Preview : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c334_preview_door" || e.Player!=consoleplayer)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let it=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal door;
        while((door=CaelumHousePortal(it.Next()))!=null)if(door.args[0]==8)break;
        if(user==null || door==null)return;
        double side=door.args[1]==0?1:-1;
        user.SetOrigin(door.Pos+(side*user.UseRange/2,0,0),false);
        user.FindFloorCeiling();user.Vel=(0,0,0);user.Angle=side>0?180:0;user.Pitch=0;
        user.FolkloreInteractionUseLatched=false;
    }
}
