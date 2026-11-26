    static double Value(Actor body)
    {
        if(CaelumContaminationStack.Eligible(Inventory(body)))return CaelumContaminationStack.Value(Inventory(body));
        let remote=CaelumHouseStorageEntry.Remote(body);if(remote!=null)remote.SyncDirt();
        let user=CaelumPlayer(body);
        if(user!=null)return CaelumFoodIllness.Value(user);
        let entry=Get(body);
        // Contacto/recogida pueden ocurrir antes del primer tic tras cargar.
        // Cerrar primero el intervalo guardado o cargado, sin buscar otros actores.
        if(entry!=null && entry.Exposure!=null)entry.Exposure.SettleNow();
        return entry!=null && entry.Revision>=CaelumContaminationData.STATE_REVISION
            ? entry.Concentration : 0;
    }
