// El volumen exterior no se deduce del peso ni de los materiales macizos.
class CaelumTarotStar : Object play
{
    static clearscope double Cuboid(double width,double depth,double height)
    {return width*depth*height/(CaelumPhysicsUnits.MAP_UNITS_PER_METER**3);}
    static clearscope double FurnitureVolume(CaelumStorageFurnitureItem item)
    {
        if(item==null)return 0;
        let rest=CaelumRestFurnitureItem(item);int v=item.Variant();
        if(rest==null)return v==0?CaelumStarData.WARDROBE_VOLUME:CaelumStarData.CUPBOARD_VOLUME;
        if(v<2)return Cuboid(CaelumLuxuryData.Width(v),CaelumLuxuryData.Depth(v),CaelumLuxuryData.Height(v));
        if(v<4)return v==2?CaelumStarData.BASIC_CHAIR_VOLUME:CaelumStarData.BASIC_BED_VOLUME;
        if(v<6)return Cuboid(CaelumSofaData.Width(v-4),CaelumSofaData.Depth(v-4),CaelumSofaData.Height(v-4));
        if(v<8)return Cuboid(CaelumStudyData.Width(v-6),CaelumStudyData.Depth(v-6),CaelumStudyData.Height(v-6));
        if(v<12)
        {
            int k=v-CaelumRestFurnitureData.FIRST_DINING_VARIANT;
            double margin=2*(CaelumDiningSetData.SeatClearance(k)+CaelumDiningSetData.ChairRadius(k));
            return Cuboid(CaelumDiningSetData.Width(k)+margin,CaelumDiningSetData.Depth(k)+margin,CaelumDiningSetData.FullHeight(k));
        }
        int kind=v-CaelumRestFurnitureData.FIRST_DECOR_VARIANT;
        return Cuboid(CaelumDecorData.Width(kind),kind==1?CaelumDecorData.Width(kind):CaelumDecorData.Depth(kind),CaelumDecorData.Height(kind));
    }
    static clearscope bool Giant(CaelumPlayer user,Inventory item)
    {
        if(user==null)return false;
        double units=CaelumPhysicsUnits.MAP_UNITS_PER_METER;
        return FurnitureVolume(CaelumStorageFurnitureItem(item))>=
            2*CaelumThermalData.CIRCLE_PI*(user.Radius/units)**2*(user.Height/units);
    }
    static int Count(CaelumPlayer user,Inventory except=null)
    {
        if(user==null)return 0;
        int count=CaelumSunCargo.Occupied(user)?1:0;
        for(Inventory i=user.Inv;i!=null;i=i.Inv)
            if(i!=except && CaelumContainerRules.Boxed(i) && Giant(user,i))count+=i.Amount;
        return count;
    }
    static bool CanBox(CaelumPlayer user,Inventory item,int quantity=1)
    {
        if(!Giant(user,item))return true;
        return quantity==1 && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),17)
            && Count(user,item)==0;
    }
    static clearscope CaelumStarCargo View(CaelumPlayer user)
    {return user!=null?CaelumStarCargo(user.FindInventory('CaelumStarCargo')):null;}
    static bool Dropping(CaelumPlayer user)
    {let cargo=View(user);return cargo!=null && cargo.Placing;}
    static vector3 Point(CaelumPlayer user,vector3 normal)
    {let cargo=View(user);return cargo!=null && cargo.Placing?cargo.Point:normal;}
    static bool Land(CaelumPlayer user,vector3 point,double radius)
    {return Dropping(user) || CaelumCampLand.AllowsFurniture(user,point,radius);}
    static void Changed(CaelumPlayer user)
    {
        if(user==null || user.SessionIdentityPending)return;
        let cargo=View(user);
        if(cargo==null)cargo=CaelumStarCargo(user.GiveInventoryType('CaelumStarCargo'));
        if(cargo!=null && !cargo.Placing)cargo.Audit(user);
    }
    static bool PrepareTravel()
    {
        bool ready=true;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);Changed(user);let cargo=View(user);
            if(cargo!=null && cargo.Pending.Size()>0)ready=false;
        }
        return ready;
    }
}

// Sólo los objetos ya invalidados necesitan buscar una salida. La cola y la
// identidad sobreviven al guardado; ningún fallo destruye o duplica muebles.
class CaelumStarCargo : Inventory
{
    int Revision,SearchIndex,RetryTics;
    double BodyRadius,BodyHeight;
    bool Placing,Warned,PendingDrop;
    vector3 Point,SearchOrigin;
    Array<CaelumStorageFurnitureItem> Pending;

    void Audit(CaelumPlayer user)
    {
        Revision=CaelumStarData.REVISION;BodyRadius=user.Radius;BodyHeight=user.Height;
        bool allowed=CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),17);
        int occupied=CaelumSunCargo.Occupied(user)?1:0;
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {
            let furniture=CaelumStorageFurnitureItem(item);
            if(furniture==null || !furniture.InMagicBox || !CaelumTarotStar.Giant(user,item))continue;
            if(allowed && occupied==0 && item.Amount==1){occupied++;continue;}
            if(Pending.Find(furniture)>=Pending.Size())Pending.Push(furniture);
        }
        PendingDrop=Pending.Size()>0;
    }
    void ReleaseNext(CaelumPlayer user)
    {
        if(Pending.Size()==0)return;
        let item=Pending[0];
        if(item==null || item.bDestroyed || item.Owner!=user || !item.InMagicBox)
        {Pending.Delete(0);PendingDrop=Pending.Size()>0;SearchIndex=0;RetryTics=0;return;}
        if((SearchOrigin-user.Pos).Length()>0.01){SearchOrigin=user.Pos;SearchIndex=0;RetryTics=0;}
        if(RetryTics>0){RetryTics--;return;}
        let rest=CaelumRestFurnitureItem(item);
        double radius=rest!=null?CaelumRestFurnitureData.Radius(item.Variant()):CaelumStorageFurnitureData.Radius(item.Variant());
        double height=rest!=null?CaelumRestFurnitureData.Height(item.Variant()):CaelumStorageFurnitureData.Height(item.Variant());
        double step=Clamp(radius/2,4.0,16.0);
        // El borde del mueble, no su centro, debe quedar cerca: un conjunto
        // de comedor puede ser más ancho que el radio de búsqueda de una roca.
        double reach=CaelumMajorArcanaData.SUN_RELEASE_MU+radius;
        int extent=int(Ceil(reach/step)),width=2*extent+1;
        for(int work=0;work<CaelumMajorArcanaData.JUSTICE_SEARCH_BUDGET;work++)
        {
            if(SearchIndex>=width*width){SearchIndex=0;RetryTics=TICRATE;break;}
            int at=SearchIndex++;
            Point=SearchOrigin+(((at%width)-extent)*step,((at/width)-extent)*step,0);
            if((Point-SearchOrigin).Length()>reach
                || !CaelumPlacementGeometry.Fits(user,Point,radius,height,null))continue;
            bool clear=true;
            for(int h=0;h<3 && clear;h++)for(int edge=0;edge<9 && clear;edge++)
            {
                double angle=(edge-1)*45;
                vector3 offset=edge==0?(0,0,0):(radius*Cos(angle),radius*Sin(angle),0);
                offset.Z=0.01+(height-0.02)*h/2;
                clear=CaelumTarotJustice.Segment(user,SearchOrigin+offset,Point+offset);
            }
            if(!clear)continue;
            // Place conserva el cuerpo/mesa/contenido real; únicamente se omite
            // el permiso de instalar para una caída obligatoria, nunca la colisión.
            Placing=true;item.InMagicBox=false;bool released=item.Place(user);Placing=false;
            if(released)
            {Pending.Delete(0);PendingDrop=Pending.Size()>0;SearchIndex=0;RetryTics=0;Warned=false;user.OnNativeInventoryChanged();return;}
            if(item!=null && !item.bDestroyed && item.Owner==user)item.InMagicBox=true;
        }
        if(!Warned){Warned=true;CaelumTarotService.Feedback(user,"CA_TAROT_STAR_RELEASE_WAIT");}
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);if(user==null || user.SessionIdentityPending)return;
        if(Revision<CaelumStarData.REVISION || BodyRadius!=user.Radius || BodyHeight!=user.Height)Audit(user);
        ReleaseNext(user);
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
