class CA846CatalogueReference : Object
{
    static clearscope bool IsLimboMap(String mapName)
    {
        // La mansión de MAP01 pertenece al Limbo. Toda otra ubicación,
        // incluso un mapa de prueba aún sin catalogar, usa el ritmo común.
        return CaelumWorldCatalogue.LocationForMap(mapName) == CaelumWorldCatalogue.LOCATION_MANSION;
    }

}
// Reloj único: el Limbo usa escala 1:1 y el exterior conserva 20:1.
// La unidad guardada sigue siendo la anterior; no se reescriben fechas/viajes.
class CA846ReferenceClock : Inventory
{
    int CompletedDays;
    int DayTics;
    int LimboSubTics;
    // Revisión 1: tiempo local separado, sin reconstruir ni borrar el pasado.
    int LocalClockRevision;
    int LimboDays;
    int LimboDayTics;
    // Revisión 1: réplicas del reloj de campaña en los inventarios viajeros.
    // Elegir por plaza nativa, nunca por consoleplayer, mantiene todos los peers
    // iguales. Una réplica ya sincronizada prevalece sobre un personaje nuevo.
    int SharedRevision;
    int CooperativeSerial;
    CaelumCooperativeTime TimeVote;
    CaelumCooperativeTravel TravelVote;
    CaelumCooperativeQuests CampaignQuests;

    void CopyShared(CA846ReferenceClock source)
    {
        if (source == null || source == self) return;
        CompletedDays=source.CompletedDays;DayTics=source.DayTics;
        LimboSubTics=source.LimboSubTics;LocalClockRevision=source.LocalClockRevision;
        LimboDays=source.LimboDays;LimboDayTics=source.LimboDayTics;
        SharedRevision=1;
        CooperativeSerial=source.CooperativeSerial;TimeVote=source.TimeVote;TravelVote=source.TravelVote;
        CampaignQuests=source.CampaignQuests;
    }

    void EnsureLocalClock()
    {
        if (LocalClockRevision >= 1) return;
        // Conserva la hora que mostraba un guardado antiguo dentro del Limbo.
        if (CA846CatalogueReference.IsLimboMap(level.MapName))
        { LimboDays = CompletedDays; LimboDayTics = DayTics; }
        LocalClockRevision = 1;
    }

    clearscope int LocalDays()
    { return LocalClockRevision >= 1 ? LimboDays : CompletedDays; }
    clearscope int LocalTics()
    { return LocalClockRevision >= 1 ? LimboDayTics : DayTics; }

    static clearscope double SecondsPerGameHour(String mapName)
    {
        return CA846CatalogueReference.IsLimboMap(mapName) ? 3600.0
            : CaelumConstants.REAL_SECONDS_PER_GAME_HOUR;
    }

    static clearscope double MapTimeScale(String mapName)
    { return CaelumConstants.REAL_SECONDS_PER_GAME_HOUR / SecondsPerGameHour(mapName); }

    static clearscope int TicsPerHour()
    {
        return int(CaelumConstants.REAL_SECONDS_PER_GAME_HOUR * TICRATE);
    }

    static clearscope int TicsPerDay()
    {
        return TicsPerHour() * int(CaelumConstants.GAME_HOURS_PER_DAY);
    }

    static CA846ReferenceClock Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let clock = CA846ReferenceClock(user.FindInventory("CA846ReferenceClock"));
        if (clock == null && create)
            clock = CA846ReferenceClock(user.GiveInventoryType("CA846ReferenceClock"));
        return clock;
    }

    void AdvanceOneTic()
    {
        // Contadores enteros: no acumula redondeos de segundos fraccionarios.
        // Separar jornadas evita desbordar un total de tics de larga duración.
        int last = TicsPerDay() - 1;
        if (CompletedDays == 2147483647 && DayTics >= last) return;
        if (DayTics >= last) { CompletedDays++; DayTics = 0; }
        else DayTics++;
        CaelumScheduleState.Sync(CaelumPlayer(Owner));
    }

    // El viaje ya expresa su duración en unidades del reloj exterior.
    // Suma por jornadas sin un total absoluto que pueda desbordar.
    void AdvanceTics(int count)
    {
        if (count <= 0) return;
        int length = TicsPerDay();
        int days = count / length;
        int remainder = DayTics + count % length;
        if (remainder >= length) { days++; remainder -= length; }
        if (CompletedDays > 2147483647 - days)
        { CompletedDays = 2147483647; DayTics = length - 1; return; }
        CompletedDays += days; DayTics = remainder;
        CaelumScheduleState.Sync(CaelumPlayer(Owner));
    }

    void AdvanceOnMap(String mapName)
    {
        EnsureLocalClock();
        int previousDay = LimboDays;
        if (CA846CatalogueReference.IsLimboMap(mapName))
        {
            // Una fracción entera guardada evita perder tiempo al cargar o
            // alternar T. Veinte pasos del Limbo equivalen a un tic del reloj.
            LimboSubTics++;
            int divisor = int(SecondsPerGameHour(mapName) / CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
            if (LimboSubTics < divisor) return;
            LimboSubTics -= divisor;
            if (LimboDayTics >= TicsPerDay()-1)
            { if (LimboDays < 2147483647) { LimboDays++; LimboDayTics=0; } }
            else LimboDayTics++;
            // El contador heredado sigue monótono para descansos y reservas.
            // Desplazar ambos anclajes congela la fecha civil, no el reloj local.
            let calendar = CaelumCalendarState.Get(CaelumPlayer(Owner));
            if (calendar != null) calendar.ExcludeLimboTic();
        }
        AdvanceOneTic();
        if (LimboDays != previousDay) SyncLocalDay();
    }

    void SyncLocalDay()
    {
        if (!CA846CatalogueReference.IsLimboMap(level.MapName)) return;
        let it=ThinkerIterator.Create("CaelumDiningTable"); CaelumDiningTable table;
        while ((table=CaelumDiningTable(it.Next()))!=null) table.SyncLocalDay(LocalDays());
    }

    static clearscope String FormatStamp(int days, int tics, bool seconds = false)
    {
        int hour = tics / TicsPerHour();
        int minute = (tics % TicsPerHour()) * 60 / TicsPerHour();
        if (seconds)
            return String.Format("%d d %02d:%02d:%02d", days, hour, minute,
                ((tics % TicsPerHour()) * 3600 / TicsPerHour()) % 60);
        return String.Format("%d d %02d:%02d", days, hour, minute);
    }

    static void Report(CaelumPlayer user)
    {
        let clock = Get(user);
        Console.Printf("[Caelum 4.35.0j] Reloj global: registro=%d mapa=%s escala real del Limbo=%d",
            clock != null, level.MapName, CA846CatalogueReference.IsLimboMap(level.MapName));
        if (clock == null) return;
        Console.Printf("Tiempo registrado=%s jornadas=%d tics del día=%d/%d",
            FormatStamp(clock.CompletedDays, clock.DayTics, true),
            clock.CompletedDays, clock.DayTics, TicsPerDay());
        Console.Printf("Escala: 1 hora de juego = %.0f segundos de simulación; %d tics por hora.",
            SecondsPerGameHour(level.MapName), int(SecondsPerGameHour(level.MapName)*TICRATE));
        Console.Printf("Fracción del Limbo conservada=%d/20", clock.LimboSubTics);
    }

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

// Un observador estático también existe al cargar guardados anteriores.
// No conserva una copia del reloj: siempre consulta el Inventory viajero.

class CA846LocationChecks : EventHandler
{
    CaelumWorldClock Actual;
    CA846ReferenceClock Reference;
    int Revision;
    transient bool Checked;
    int Checks,Errors;
    void Check(bool valid,String message)
    {Checks++;if(!valid)Errors++;Console.Printf("CA846 CHECK %s %s",valid?"PASS":"FAIL",message);}
    void Seed(int kind)
    {
        int days=kind==4?2147483647:kind==0?0:1;
        int tics=kind>=3?CaelumWorldClock.TicsPerDay()-1:kind==2?CaelumWorldClock.TicsPerHour()-1:0;
        int divisor=int(CaelumWorldClock.SecondsPerGameHour("MAP01")/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
        int fraction=kind>=2?divisor-1:0;
        Actual.CompletedDays=Reference.CompletedDays=days;
        Actual.DayTics=Reference.DayTics=tics;
        Actual.LimboSubTics=Reference.LimboSubTics=fraction;
        Actual.LocalClockRevision=Reference.LocalClockRevision=kind==0?0:1;
        Actual.LimboDays=Reference.LimboDays=days;
        Actual.LimboDayTics=Reference.LimboDayTics=tics;
    }
    bool Same()
    {return Actual.CompletedDays==Reference.CompletedDays && Actual.DayTics==Reference.DayTics
        && Actual.LimboSubTics==Reference.LimboSubTics && Actual.LocalClockRevision==Reference.LocalClockRevision
        && Actual.LimboDays==Reference.LimboDays && Actual.LimboDayTics==Reference.LimboDayTics;}
        static double ReferenceStamp(CaelumWorldClock clock)
    {
        if(clock==null)return 0;
        double seconds=double(clock.CompletedDays)*86400.0+double(clock.DayTics)*3600.0/CaelumWorldClock.TicsPerHour();
        if(CA846CatalogueReference.IsLimboMap(level.MapName))seconds+=double(clock.LimboSubTics)/TICRATE;
        return seconds;
    }


    override void WorldTick()
    {
        if(Checked)return;Checked=true;Checks=Errors=0;
        bool fresh=Revision==0;
        Check(fresh || Revision==1,"saved_revision");
        if(fresh)
        {
            Actual=CaelumWorldClock(Actor.Spawn('CaelumWorldClock',(0,0,64),NO_REPLACE));
            Reference=CA846ReferenceClock(Actor.Spawn('CA846ReferenceClock',(0,0,64),NO_REPLACE));
            if(Actual!=null){Actual.bNoInteraction=true;Actual.bNoGravity=true;}
            if(Reference!=null){Reference.bNoInteraction=true;Reference.bNoGravity=true;}
        }
        Check(Actual!=null && Reference!=null,"original_clock_references");
        if(Actual==null || Reference==null)return;
        int divisor=int(CaelumWorldClock.SecondsPerGameHour("MAP01")/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
        Check(fresh || (Same() && Actual.CompletedDays==1 && Actual.DayTics==CaelumWorldClock.TicsPerDay()-1
            && Actual.LimboSubTics==divisor-1 && Actual.LocalClockRevision==1),"saved_fields");
        Check(Actual.Owner==null && Reference.Owner==null,"detached_test_ownership");
        Check(CaelumThermalRuntime.Stamp(null)==0 && ReferenceStamp(null)==0,"null_clock");
        String names[]={""," MAP01","CABAIRES","CAH","CAH-1","CAH000","CAH001","CAH001X","CAH002","CAH003","CAH004","CAH005","CAH006","CAH007","CAH008","CAH009","CAH010","CAH011","CAH012","CAH013","CAH014","CAH015","CAH016","CAH017","CAH018","CAH019","CAH020","CAH021","CAH022","CAH023","CAH024","CAH025","CAH026","CAH027","CAH028","CAH029","CAH030","CAH031","CAH032","CAH033","CAH034","CAH035","CAH036","CAH037","CAH038","CAH039","CAH040","CAH041","CAH042","CAH043","CAH044","CAH045","CAH046","CAH047","CAH048","CAH049","CAH050","CAH051","CAH052","CAH053","CAH054","CAH055","CAH056","CAH057","CAH058","CAH059","CAH060","CAH061","CAH062","CAH063","CAH064","CAH065","CAH066","CAH067","CAH068","CAH069","CAH070","CAH071","CAH072","CAH073","CAH074","CAH075","CAH076","CAH077","CAH078","CAH079","CAH080","CAH081","CAH082","CAH083","CAH084","CAH085","CAH086","CAH087","CAH088","CAH089","CAH090","CAH091","CAH092","CAH093","CAH094","CAH095","CAH096","CAH097","CAH098","CAH099","CAH100","CAH101","CAH102","CAH103","CAH104","CAH105","CAH106","CAH107","CAH108","CAH109","CAH110","CAH111","CAH112","CAH113","CAH114","CAH115","CAH116","CAH117","CAH118","CAH119","CAH120","CAH121","CAH122","CAH123","CAH124","CAH125","CAH126","CAH127","CAH128","CAH129","CAH130","CAH131","CAH132","CAH133","CAH134","CAH135","CAH136","CAH137","CAH138","CAH139","CAH140","CAH141","CAH142","CAH143","CAH144","CAH145","CAH146","CAH147","CAH148","CAH149","CAH150","CAH151","CAH152","CAH153","CAH154","CAH155","CAH156","CAH157","CAH158","CAH159","CAH160","CAH999","CAHUNT","CAR00","CAR01","CAR02","CAR03","CAR04","CAR05","CAR06","CAR07","CAR08","CAR09","CAR10","CAR11","CAR12","CAR13","CAR14","CAR15","CAR16","CAR17","CAR18","CAR19","CAR20","CAR21","CAR22","CAR23","CAR24","CAR25","CAR26","CAR27","CAR28","CAR29","CAR30","CAR31","CAR32","CAR33","CAR34","CAR35","CAR36","CAR37","CAR38","CAR39","CAR40","CARING","CASEWER","CAT310","CAT311","CAT317","CAT318","CAT319","CAT320","CAT410","CAT411","CAT417","CAT418","CAT419","CAT420","CAT510","CAT511","CAT517","CAT518","CAT519","CAT520","CAT610","CAT611","CAT617","CAT618","CAT619","CAT620","MAP01","MAP01 ","MAP01X","MAP02","MAP03","MAP1","TACTORS","TCOAST","THAZARD","TMAINT","TRESERV","TTAROT","ZZ0000","ZZ0001","ZZ0002","ZZ0003","ZZ0004","ZZ0005","ZZ0006","ZZ0007","ZZ0008","ZZ0009","ZZ0010","ZZ0011","ZZ0012","ZZ0013","ZZ0014","ZZ0015","ZZ0016","ZZ0017","ZZ0018","ZZ0019","ZZ0020","ZZ0021","ZZ0022","ZZ0023","ZZ0024","ZZ0025","ZZ0026","ZZ0027","ZZ0028","ZZ0029","ZZ0030","ZZ0031","ZZ0032","ZZ0033","ZZ0034","ZZ0035","ZZ0036","ZZ0037","ZZ0038","ZZ0039","ZZ0040","ZZ0041","ZZ0042","ZZ0043","ZZ0044","ZZ0045","ZZ0046","ZZ0047","ZZ0048","ZZ0049","ZZ0050","ZZ0051","ZZ0052","ZZ0053","ZZ0054","ZZ0055","ZZ0056","ZZ0057","ZZ0058","ZZ0059","ZZ0060","ZZ0061","ZZ0062","ZZ0063","cabaires","cah","cah000","cah001","cah002","cah003","cah004","cah005","cah006","cah007","cah008","cah009","cah010","cah011","cah012","cah013","cah014","cah015","cah016","cah017","cah018","cah019","cah020","cah021","cah022","cah023","cah024","cah025","cah026","cah027","cah028","cah029","cah030","cah031","cah032","cah033","cah034","cah035","cah036","cah037","cah038","cah039","cah040","cah041","cah042","cah043","cah044","cah045","cah046","cah047","cah048","cah049","cah050","cah051","cah052","cah053","cah054","cah055","cah056","cah057","cah058","cah059","cah060","cah061","cah062","cah063","cah064","cah065","cah066","cah067","cah068","cah069","cah070","cah071","cah072","cah073","cah074","cah075","cah076","cah077","cah078","cah079","cah080","cah081","cah082","cah083","cah084","cah085","cah086","cah087","cah088","cah089","cah090","cah091","cah092","cah093","cah094","cah095","cah096","cah097","cah098","cah099","cah100","cah101","cah102","cah103","cah104","cah105","cah106","cah107","cah108","cah109","cah110","cah111","cah112","cah113","cah114","cah115","cah116","cah117","cah118","cah119","cah120","cah121","cah122","cah123","cah124","cah125","cah126","cah127","cah128","cah129","cah130","cah131","cah132","cah133","cah134","cah135","cah136","cah137","cah138","cah139","cah140","cah141","cah142","cah143","cah144","cah145","cah146","cah147","cah148","cah149","cah150","cah151","cah152","cah153","cah154","cah155","cah156","cah157","cah158","cah159","cahunt","car00","car01","car02","car03","car04","car05","car06","car07","car08","car09","car10","car11","car12","car13","car14","car15","car16","car17","car18","car19","car20","car21","car22","car23","car24","car25","car26","car27","car28","car29","car30","car31","car32","car33","car34","car35","car36","car37","car38","car39","car40","caring","casewer","cat310","cat311","cat317","cat318","cat319","cat320","cat410","cat411","cat417","cat418","cat419","cat420","cat510","cat511","cat517","cat518","cat519","cat520","cat610","cat611","cat617","cat618","cat619","cat620","mAp01","map01","map02","map03","tactors","tcoast","thazard","tmaint","treserv","ttarot"};
        for(int i=0;i<names.Size();i++)
        {
            Check(CaelumWorldCatalogue.IsLimboMap(names[i])==CA846CatalogueReference.IsLimboMap(names[i]),"map_predicate");
            Check(CaelumWorldClock.SecondsPerGameHour(names[i])==CA846ReferenceClock.SecondsPerGameHour(names[i]),"time_scale");
            Check(CaelumWorldClock.MapTimeScale(names[i])==CA846ReferenceClock.MapTimeScale(names[i]),"map_scale");
        }
        String advances[]={"MAP01","map01","MAP03","CAH159","ZZ846"};
        int steps=divisor*2+1;
        for(int map=0;map<advances.Size();map++)for(int kind=0;kind<5;kind++)
        {
            Seed(kind);Check(CaelumThermalRuntime.Stamp(Actual)==ReferenceStamp(Actual),"stamp_before");
            for(int step=0;step<steps;step++)
            {Actual.AdvanceOnMap(advances[map]);Reference.AdvanceOnMap(advances[map]);Check(Same(),"native_step_boundary");}
            Check(CaelumThermalRuntime.Stamp(Actual)==ReferenceStamp(Actual),"stamp_after");
            Actual.AdvanceTics(CaelumWorldClock.TicsPerDay()+1);Reference.AdvanceTics(CaelumWorldClock.TicsPerDay()+1);
            Check(Same(),"journey_day_boundary");
        }
        Seed(3);Revision=1;
        int expected=5+names.Size()*3+advances.Size()*5*(steps+3);
        Console.Printf("CA846 FIXTURE_COMPLETE fresh=%d map=%s names=%d checks=%d expected=%d errors=%d",fresh,level.MapName,names.Size(),Checks,expected,Errors);
    }
}
