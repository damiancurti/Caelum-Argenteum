// La Caja guarda el cuerpo original, no una copia ni una nueva instancia.
class CaelumTarotRock : CaelumMovableProp
{
    CaelumSunCargo Cargo;
    CaelumHazardRockVisual Visual;
    CaelumTarotRockHeat Heat;
    int ComponentRevision;
    bool Contained;
    virtual double ExteriorVolume()
    {return 4.0/3*CaelumThermalData.CIRCLE_PI*CaelumMajorArcanaData.ROCK_RADIUS_METERS**3;}
    virtual double PhysicalMass()
    {return ExteriorVolume()*CaelumMajorArcanaData.ROCK_DENSITY;}
    virtual double HeatWatts(){return 0;}
    virtual void StopEmissions(){}
    virtual void UpdateComponents()
    {
        // La revisión evita recrear partes en cada tic; los punteros se guardan.
        if(ComponentRevision<1)
        {
            Visual=CaelumHazardRockVisual(Actor.Spawn('CaelumHazardRockVisual',Pos,NO_REPLACE));
            if(Visual!=null)Visual.master=self;
            if(HeatWatts()>0)
            {
                Heat=CaelumTarotRockHeat(Actor.Spawn('CaelumTarotRockHeat',Pos,NO_REPLACE));
                if(Heat!=null)Heat.Body=self;
            }
            ComponentRevision=1;
        }
        if(Visual!=null)Visual.bInvisible=Contained || bInvisible;
        if(Heat!=null)Heat.SetOrigin(Pos,false);
    }
    override void PostBeginPlay(){Super.PostBeginPlay();UpdateComponents();}
    override void Tick()
    {if(!Contained)Super.Tick();UpdateComponents();}
    override void OnDestroy()
    {
        StopEmissions();
        if(Visual!=null)Visual.Destroy();if(Heat!=null)Heat.Destroy();
        Super.OnDestroy();
    }
    Default
    {
        Radius 19.2;Height 38.4;Mass 2262;
        Tag "$CA_TAROT_HAZARD_ROCK";
    }
    States {Spawn:TNT1 A -1;Stop;}
}

// Emisión consultada desde el cuerpo: nunca queda activa dentro de la Caja.
class CaelumTarotHeatRock : CaelumTarotRock
{
    override double HeatWatts(){return CaelumMajorArcanaData.ROCK_WATTS;}
    Default {Tag "$CA_TAROT_HEAT_ROCK";}
}
class CaelumTarotRockHeat : CaelumThermalFireSource
{
    CaelumTarotRock Body;
    override double Watts()
    {return Body!=null && !Body.bDestroyed && !Body.Contained?Body.HeatWatts():0;}
    override vector3 EmissionCenter()
    {return Body!=null?Body.Pos+(0,0,Body.Height/2):Pos;}
    override double EmissionRadiusMeters(){return CaelumMajorArcanaData.ROCK_RADIUS_METERS;}
}

class CaelumSunCargo : Inventory
{
    int Revision,SearchIndex,RetryTics,LastSearchTic;
    bool Pending,Warned,CheckedSearch,HadSolid,HadShootable,HadInvisible,HadNoGravity;
    CaelumTarotRock Body;
    String OriginMap;
    vector3 SearchOrigin,CaptureOrigin;
    override bool TryPickup(in out Actor toucher){return false;}
    override Inventory CreateTossable(){return null;}

    static clearscope CaelumSunCargo View(CaelumPlayer user)
    {return user!=null?CaelumSunCargo(user.FindInventory('CaelumSunCargo')):null;}
    static clearscope bool Occupied(CaelumPlayer user)
    {let cargo=View(user);return cargo!=null && cargo.Body!=null && !cargo.Body.bDestroyed;}
    static clearscope bool Display(int itemType)
    {return itemType==CaelumMajorArcanaData.SUN_CARGO_DISPLAY || itemType==CaelumMajorArcanaData.SUN_HEAT_DISPLAY || itemType==CaelumMajorArcanaData.SUN_DIRTY_DISPLAY;}
    static clearscope String NameKey(int itemType)
    {return itemType==CaelumMajorArcanaData.SUN_DIRTY_DISPLAY?"CA_TAROT_DIRTY_ROCK":itemType==CaelumMajorArcanaData.SUN_HEAT_DISPLAY?"CA_TAROT_HEAT_ROCK":"CA_TAROT_HAZARD_ROCK";}
    static bool ReleaseSelection(CaelumPlayer user,Inventory entry)
    {
        let cargo=CaelumSunCargo(entry);
        if(cargo==null)return false;
        if(cargo.Owner==user)cargo.Release();
        user.RefreshFormalInventorySnapshot();return true;
    }
    static double Weight(CaelumPlayer user)
    {let cargo=View(user);return Occupied(user)?cargo.Body.PhysicalMass():0;}
    static bool Giant(CaelumPlayer user,CaelumTarotRock body)
    {
        double units=CaelumPhysicsUnits.MAP_UNITS_PER_METER;
        return user!=null && body!=null && body.ExteriorVolume()>=
            2*CaelumThermalData.CIRCLE_PI*(user.Radius/units)**2*(user.Height/units);
    }
    static bool Capture(CaelumPlayer user,CaelumTarotRock body)
    {
        if(!CaelumTarotService.ValidUser(user) || body==null || body.bDestroyed || body.Contained
            || !CaelumMajorTargets.Visible(user,body) || CaelumRacialAbilityRules.Interrupted(user)
            || CaelumRacialAbilityRules.MenuBlocked(user) || user.CraftingTaskActive || user.StaffCastPending)return false;
        let record=user.GetPersistentCharacterState(false);
        if(!CaelumTarotService.IsActive(record,19))return false;
        if(!CaelumTarotLoadout.Passive(record,17))
        {CaelumTarotService.Feedback(user,"CA_TAROT_SUN_STAR");return false;}
        if(CaelumTarotStar.Count(user)>0 || body.TarotLift!=null || CaelumTelekinesisRules.Held(body))
        {CaelumTarotService.Feedback(user,"CA_TAROT_SUN_OCCUPIED");return false;}
        if(!user.MagicBoxOwned || !user.HasNativeMagicBoxSlotAvailable() || !user.CanAddRawWeightToMagicBox(body.PhysicalMass()))
        {CaelumTarotService.Feedback(user,"CA_TAROT_SUN_CAPACITY");return false;}
        let cargo=View(user);
        if(cargo==null)
        {
            cargo=CaelumSunCargo(Actor.Spawn('CaelumSunCargo',user.Pos,NO_REPLACE));
            if(cargo!=null)cargo.AttachToOwner(user);
        }
        if(cargo==null)return false;
        body.StopEmissions();
        CaelumContaminationObject.LeavingWorld(body);
        cargo.Revision=CaelumMajorArcanaData.SUN_REVISION;cargo.Body=body;cargo.OriginMap=level.MapName;
        cargo.CaptureOrigin=body.Pos;cargo.Pending=false;cargo.Warned=false;cargo.SearchIndex=0;cargo.RetryTics=0;
        cargo.HadSolid=body.bSolid;cargo.HadShootable=body.bShootable;
        cargo.HadInvisible=body.bInvisible;cargo.HadNoGravity=body.bNoGravity;
        body.Cargo=cargo;body.Contained=true;body.bSolid=false;body.bShootable=false;
        body.bInvisible=true;body.bNoGravity=true;body.bNoInteraction=true;body.Vel=(0,0,0);
        body.UpdateComponents();
        user.RefreshCarriedInventorySummary();
        CaelumTarotService.Feedback(user,"CA_TAROT_SUN_CAPTURED");return true;
    }
    void Released(vector3 point)
    {
        let body=self.Body;self.Body=null;Pending=false;Warned=false;
        body.SetOrigin(point,false);body.FindFloorCeiling();body.ClearInterpolation();body.Vel=(0,0,0);
        body.Cargo=null;body.Contained=false;body.bNoInteraction=false;
        body.bSolid=HadSolid;body.bShootable=HadShootable;body.bInvisible=HadInvisible;body.bNoGravity=HadNoGravity;
        body.UpdateComponents();
        CaelumContaminationObject.Register(body);
        let user=CaelumPlayer(Owner);if(user!=null)user.RefreshCarriedInventorySummary();
    }
    bool Release()
    {
        if(Body==null || Body.bDestroyed){Body=null;Pending=false;return true;}
        Pending=true;
        if(OriginMap!=level.MapName)return false;
        let user=CaelumPlayer(Owner);
        if(user!=null && user.SessionIdentityPending)return false;
        if(CheckedSearch && LastSearchTic==level.time)return false;
        CheckedSearch=true;LastSearchTic=level.time;
        vector3 origin=user!=null?user.Pos:CaptureOrigin;
        if((origin-SearchOrigin).Length()>0.01){SearchOrigin=origin;SearchIndex=0;RetryTics=0;}
        if(RetryTics>0){RetryTics--;return false;}
        double step=Clamp(Body.Radius/2,4.0,16.0);
        int extent=int(Ceil(CaelumMajorArcanaData.SUN_RELEASE_MU/step)),width=2*extent+1;
        for(int work=0;work<CaelumMajorArcanaData.JUSTICE_SEARCH_BUDGET;work++)
        {
            if(SearchIndex>=width*width){SearchIndex=0;RetryTics=TICRATE;break;}
            int at=SearchIndex++;
            vector3 point=origin+(((at%width)-extent)*step,((at/width)-extent)*step,0);
            if((point-origin).Length()>CaelumMajorArcanaData.SUN_RELEASE_MU
                || !CaelumTarotJustice.Fits(Body,point))continue;
            bool clear=true;
            for(int h=0;h<3 && clear;h++)for(int edge=0;edge<9 && clear;edge++)
            {
                double angle=(edge-1)*45;
                vector3 offset=edge==0?(0,0,0):(Body.Radius*Cos(angle),Body.Radius*Sin(angle),0);
                offset.Z=0.01+(Body.Height-0.02)*h/2;
                clear=CaelumTarotJustice.Segment(Body,origin+offset,point+offset);
            }
            if(!clear)continue;
            Released(point);return true;
        }
        if(!Warned){Warned=true;CaelumTarotService.Feedback(user,"CA_TAROT_SUN_RELEASE_WAIT");}
        return false;
    }
    static void Guard(CaelumPlayer user)
    {
        let cargo=View(user);if(cargo==null || cargo.Body==null || user.SessionIdentityPending)return;
        let record=user.GetPersistentCharacterState(false);
        if(cargo.Pending || user.health<=0 || !CaelumTarotLoadout.Passive(record,17)
            || !CaelumTarotService.IsActive(record,19))cargo.Release();
    }
    static bool PrepareTravel()
    {
        bool ready=true;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {let cargo=View(CaelumPlayer(players[i].mo));if(cargo!=null && !cargo.Release())ready=false;}
        return ready;
    }
    static bool Input(CaelumPlayer user)
    {
        let body=CaelumTarotRock(CaelumMajorTargets.Aim(user));
        if(body==null || !CaelumTarotService.IsActive(user.GetPersistentCharacterState(false),19))return false;
        Capture(user,body);return true;
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        if(user!=null)Guard(user);
        else if(Release())Destroy();
    }
    override void OnDestroy()
    {
        // Si desaparece el dueño, el cuerpo conserva una salida pendiente en
        // su mapa. Nunca se destruye la roca ni se fuerza su aparición ocupada.
        if(Body!=null && !Body.bDestroyed && OriginMap==level.MapName)
        {
            let pending=CaelumSunCargo(Actor.Spawn('CaelumSunCargo',CaptureOrigin,NO_REPLACE));
            if(pending!=null)
            {
                pending.Revision=Revision;pending.Body=Body;pending.OriginMap=OriginMap;
                pending.CaptureOrigin=CaptureOrigin;pending.Pending=true;
                pending.HadSolid=HadSolid;pending.HadShootable=HadShootable;
                pending.HadInvisible=HadInvisible;pending.HadNoGravity=HadNoGravity;
                Body.Cargo=pending;Body=null;
            }
        }
        Super.OnDestroy();
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
