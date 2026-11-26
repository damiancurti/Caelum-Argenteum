    static double Value(Actor body)
    {
        CaelumContaminationState entry;
        // Las piezas medidas no pueden ser pilas, cofres remotos ni jugadores.
        if(NativeCarrierBody(body))entry=GetCarrier(body,false,null);
        else if(body is 'CaelumCombatActor')entry=Get(body);
        else
        {
            if(CaelumContaminationStack.Eligible(Inventory(body)))return CaelumContaminationStack.Value(Inventory(body));
            let remote=CaelumHouseStorageEntry.Remote(body);if(remote!=null)remote.SyncDirt();
            let user=CaelumPlayer(body);
            if(user!=null)return CaelumFoodIllness.Value(user);
            entry=Get(body);
        }
        // Contacto/recogida pueden ocurrir antes del primer tic tras cargar.
        // Cerrar primero el intervalo guardado o cargado, sin buscar otros actores.
        if(entry!=null && entry.Exposure!=null)entry.Exposure.SettleNow();
        return entry!=null && entry.Revision>=CaelumContaminationData.STATE_REVISION
            ? entry.Concentration : 0;
    }
