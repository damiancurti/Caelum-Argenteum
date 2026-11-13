// #647: recipientes reales; sin modificar contenido ni reglas de producción.
class CA647WaterCamera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA647WaterEvents : EventHandler
{
    Array<CaelumWaterContainer> Drops;
    CA647WaterCamera Camera;
    int Failures;
    double Liters, Temperature, Cooling, Stamp;
    int Quality, QualityRevision, ThermalRevision;
    bool Submerged, ClockReady;

    void Check(bool okay, String label)
    {
        if (!okay) Failures++;
        Console.Printf("CA647 %s %s", okay ? "PASS" : "FAIL", label);
    }

    void Snapshot(CaelumWaterContainer item)
    {
        Liters=item.WaterLiters; Quality=item.WaterQuality;
        QualityRevision=item.WaterQualityRevision;
        Temperature=item.WaterTemperatureC; ThermalRevision=item.WaterTemperatureRevision;
        Cooling=item.CoolingSeconds; Stamp=item.TemperatureStamp;
        Submerged=item.WasSubmerged; ClockReady=item.TemperatureClockReady;
    }

    void CheckTransfer(CaelumWaterContainer item, String label)
    {
        Check(item.WaterLiters == Liters && item.WaterQuality == Quality
            && item.WaterQualityRevision == QualityRevision, label .. " exact contents/quality");
        Check(item.WaterTemperatureC == Temperature && item.WaterTemperatureRevision == ThermalRevision
            && item.CoolingSeconds == Cooling && item.TemperatureStamp == Stamp
            && item.TemperatureClockReady == ClockReady, label .. " exact thermal state");
        Check(item.WasSubmerged == Submerged, label .. " immersion state");
    }

    void Verify()
    {
        Check(Drops.Size() == 6, "six water container references retained");
        for (int index=0; index<Drops.Size(); index++)
        {
            let item=Drops[index];
            String label=String.Format("water %d",index);
            Check(item != null, label .. " saved reference");
            if (item == null) continue;
            Check(item.Owner == null && item.Amount == 1, label .. " individual world ownership");
            Check(players[0].mo.FindInventory(item.GetClass()) == null, label .. " no duplicate held container");
            Check(item.WaterLiters == item.GetCapacityLiters()/2 && item.WaterQuality == index
                && item.WaterQualityRevision == CaelumWaterQuality.REVISION, label .. " saved content/quality");
            Check(item.WaterTemperatureRevision == CaelumWaterThermalData.REVISION
                && item.WaterTemperatureC == item.WaterTemperatureC
                && item.WaterTemperatureC > -273.15, label .. " valid native thermal state");
            Check(item.GetUnitWeight() == CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT + item.WaterLiters,
                label .. " tare plus contents weight");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius == defaults.Radius && item.Height == defaults.Height
                && item.Scale == defaults.Scale, label .. " native collision and scale");
            Check(item.Icon == defaults.Icon && item.sprite == defaults.SpawnState.sprite,
                label .. " original icon and state");
            Check(abs(item.Pos.Z-item.floorz)<0.01, label .. " rests on floor");
        }
        Console.Printf("CA647 COMPLETE failures=%d",Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name == "ca647_prepare")
        {
            static const class<CaelumWaterContainer> kinds[] = { ITEM_CLASSES };
            Actor user=players[0].mo;
            for (int index=0; index<kinds.Size(); index++)
            {
                let incoming=CaelumWaterContainer(Actor.Spawn(kinds[index],(0,0,0),NO_REPLACE));
                // Valores diagnósticos, no parámetros de balance.
                incoming.WaterLiters=incoming.GetCapacityLiters()/2;
                incoming.WaterQuality=index;
                incoming.WaterQualityRevision=CaelumWaterQuality.REVISION;
                incoming.WaterTemperatureC=50;
                incoming.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;
                incoming.CoolingSeconds=0.25;
                incoming.WasSubmerged=index%2 != 0;
                incoming.StampTemperature(CaelumPlayer(user));
                Snapshot(incoming);
                Check(incoming.CallTryPickup(user),String.Format("water %d native pickup",index));
                let held=CaelumWaterContainer(user.FindInventory(kinds[index]));
                Check(held != null && held.Amount == 1,String.Format("water %d held instance",index));
                if (held == null) continue;
                CheckTransfer(held,String.Format("water %d pickup",index));
                Snapshot(held);
                let dropped=CaelumWaterContainer(held.CreateTossable(1));
                Check(dropped != null,String.Format("water %d native toss",index));
                if (dropped == null) continue;
                CheckTransfer(dropped,String.Format("water %d toss",index));
                dropped.SetOrigin(((index%3-1)*55,(index/3)*65-35,0),false);
                Drops.Push(dropped);
            }
            Camera=CA647WaterCamera(Actor.Spawn('CA647WaterCamera',(0,-180,180),NO_REPLACE));
            Camera.Angle=90; Camera.Pitch=43;
            players[0].camera=Camera; players[0].mo.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
            if (hud != null) hud.HUDFont=null;
        }
        if (e.Name == "ca647_view")
        {
            if (e.Args[0] == 4) players[0].camera=players[0].mo;
            else players[0].camera=Camera;
            players[0].mo.bInvisible=e.Args[0] != 4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
            if (hud != null)
            {
                if (e.Args[0] == 4) hud.HUDFont=Font.GetFont("CaelumMono");
                else hud.HUDFont=null;
            }
            if (e.Args[0] == 0) { Camera.SetOrigin((0,-180,180),false); Camera.Angle=90; Camera.Pitch=43; }
            if (e.Args[0] == 1) { Camera.SetOrigin((0,-180,50),false); Camera.Angle=90; Camera.Pitch=10; }
            if (e.Args[0] == 2) { Camera.SetOrigin((180,0,60),false); Camera.Angle=180; Camera.Pitch=14; }
            if (e.Args[0] == 3) { Camera.SetOrigin((0,-90,38),false); Camera.Angle=90; Camera.Pitch=24; }
            if (e.Args[0] == 5) { Camera.SetOrigin((0,-25,36),false); Camera.Angle=90; Camera.Pitch=22; }
            if (e.Args[0] == 6) { Camera.SetOrigin((55,-25,36),false); Camera.Angle=90; Camera.Pitch=22; }
            if (e.Args[0] == 7) { Camera.SetOrigin((0,180,60),false); Camera.Angle=270; Camera.Pitch=14; }
            Camera.ClearInterpolation();
        }
        if (e.Name == "ca647_verify") Verify();
        if (e.Name == "ca647_pickup")
        {
            Actor user=players[0].mo;
            for (int index=0; index<Drops.Size(); index++)
            {
                let item=Drops[index];
                class<Inventory> kind=item.GetClass();
                Snapshot(item);
                Check(item.CallTryPickup(user),String.Format("water %d repickup",index));
                let held=CaelumWaterContainer(user.FindInventory(kind));
                Check(held != null && held.Owner == user && held.Amount == 1,
                    String.Format("water %d recovered single container",index));
                if (held != null) CheckTransfer(held,String.Format("water %d repickup",index));
            }
            Console.Printf("CA647 COMPLETE failures=%d",Failures);
        }
    }
}
