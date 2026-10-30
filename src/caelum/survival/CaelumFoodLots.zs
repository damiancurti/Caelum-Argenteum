// Metadatos de un lote: Amount sigue siendo autoridad del inventario nativo.
// El adaptador debe transferir exactamente las mismas unidades en ambos lados.
class CaelumFoodLot : Object play
{
    int Units;
    double CreatedStamp,BaseContamination,ExposureAtEntry;
    CaelumCompanionHistory CompanionHistory;
}

// Libro de lotes guardable, sin actores, búsquedas globales ni reloj propio.
// El servicio ambiental aporta intervalos de calendario ya resueltos.
class CaelumFoodLots : Object play
{
    int Revision,Kind;
    double Exposure;
    Array<CaelumFoodLot> Lots;

    // Sólo un estado sin esquema recibe la migración fresca aprobada.
    bool Ensure(int foodKind,int nativeUnits,double migrationStamp)
    {
        if(Revision!=0)return Revision==CaelumFoodData.REVISION && Kind==foodKind;
        if(foodKind<0 || foodKind>=CaelumFoodData.KIND_COUNT || nativeUnits<0)return false;
        Kind=foodKind;Exposure=0;Revision=CaelumFoodData.REVISION;
        if(nativeUnits>0)Add(nativeUnits,0,migrationStamp);
        return true;
    }

    clearscope int Units()
    {
        int total=0;
        for(int i=0;i<Lots.Size();i++)total+=Lots[i].Units;
        return total;
    }
    clearscope double Contamination(int index)
    {
        if(index<0 || index>=Lots.Size())return 0;
        let lot=Lots[index];
        return Clamp(lot.BaseContamination+Exposure-lot.ExposureAtEntry,
            0.0,CaelumFoodData.MAX_CONTAMINATION);
    }
    clearscope double OldestContamination()
    {return Contamination(0);}

    bool Add(int units,double contamination,double createdStamp,CaelumCompanionHistory history=null)
    {
        if(Revision!=CaelumFoodData.REVISION || units<=0
            || units>2147483647-Units())return false;
        contamination=Clamp(contamination,0.0,CaelumFoodData.MAX_CONTAMINATION);
        // Sólo se reúnen fragmentos del mismo momento y estado; nunca promediar
        // para rejuvenecer un lote al añadir comida fresca.
        for(int i=Lots.Size()-1;i>=0;i--)
            if(Lots[i].CreatedStamp==createdStamp && Contamination(i)==contamination && Lots[i].CompanionHistory==history)
            {Lots[i].Units+=units;return true;}
        let lot=new('CaelumFoodLot');
        lot.Units=units;lot.CreatedStamp=createdStamp;
        lot.BaseContamination=contamination;lot.ExposureAtEntry=Exposure;lot.CompanionHistory=history;
        int insert=Lots.Size();Lots.Push(lot);
        while(insert>0 && Lots[insert-1].CreatedStamp>createdStamp)
        {Lots[insert]=Lots[insert-1];insert--;}
        Lots[insert]=lot;
        return true;
    }

    void Advance(double seconds,double celsius,double humidity)
    {
        double hours=CaelumFoodData.FreshHours(Kind);
        if(Revision!=CaelumFoodData.REVISION || seconds<=0 || hours<=0 || Lots.Size()==0)return;
        Exposure+=CaelumFoodData.MAX_CONTAMINATION*seconds
            *CaelumFoodRules.EnvironmentRate(celsius,humidity)/(hours*3600.0);
    }

    // El promedio sólo describe la cantidad que se retira/ingiere, no reescribe
    // los lotes restantes. Una operación inválida no produce mutación parcial.
    bool Consume(int units,out double contamination)
    {
        contamination=0;
        if(Revision!=CaelumFoodData.REVISION || units<=0 || units>Units())return false;
        int remaining=units,emptied=0;
        for(int i=0;remaining>0;i++)
        {
            int taken=Min(remaining,Lots[i].Units);
            contamination+=Contamination(i)*double(taken)/units;
            Lots[i].Units-=taken;remaining-=taken;
            if(Lots[i].Units==0)emptied++;
        }
        // Compactar una sola vez conserva coste lineal al retirar muchos lotes.
        int left=Lots.Size()-emptied;
        for(int i=0;i<left;i++)Lots[i]=Lots[i+emptied];
        Lots.Resize(left);
        return true;
    }

    CaelumFoodLots CopyOldest(int units)
    {
        if(Revision!=CaelumFoodData.REVISION || units<=0 || units>Units())return null;
        let copy=new('CaelumFoodLots');copy.Ensure(Kind,0,0);
        int remaining=units;
        for(int i=0;remaining>0;i++)
        {
            int taken=Min(remaining,Lots[i].Units);
            copy.Add(taken,Contamination(i),Lots[i].CreatedStamp,
                Lots[i].CompanionHistory!=null?Lots[i].CompanionHistory.Copy():null);remaining-=taken;
        }
        return copy;
    }

    CaelumFoodLots Copy()
    {
        if(Units()>0)return CopyOldest(Units());
        let copy=new('CaelumFoodLots');copy.Ensure(Kind,0,0);return copy;
    }

    bool TransferTo(CaelumFoodLots destination,int units)
    {
        if(destination==null || destination==self || Revision!=CaelumFoodData.REVISION
            || destination.Revision!=CaelumFoodData.REVISION || destination.Kind!=Kind
            || units<=0 || units>Units() || units>2147483647-destination.Units())return false;
        // Completar el preflight antes de alterar cualquiera de los dos libros.
        int remaining=units;
        for(int i=0;remaining>0;i++)
        {
            int taken=Min(remaining,Lots[i].Units);
            destination.Add(taken,Contamination(i),Lots[i].CreatedStamp,
                Lots[i].CompanionHistory!=null?Lots[i].CompanionHistory.Copy():null);remaining-=taken;
        }
        double ignored;
        return Consume(units,ignored);
    }
}
