// #194: 1 J recibido equivale a 1 HP bruto. La restitución sólo resuelve
// velocidades; la severidad usa siempre el cierre inelástico previo al contacto.
class CaelumImpactEnergy : Object
{
    const HP_PER_JOULE = 1.0;

    // #311: reparación local e idempotente de aristas guardadas con distancia
    // cero. No recrea contactos ni repite daño o trabajo pendiente.
    static play void RepairLegacyContact(ImpactContactState contact)
    {
        if (contact==null || contact.ReleaseDistanceRevision>=1) return;
        Actor first=contact.FirstActor, second=contact.SecondActor;
        if (first==null || second==null) return;
        if (contact.ReleaseDistance<=0)
        {
            let firstPlayer=CaelumPlayer(first); let secondPlayer=CaelumPlayer(second);
            let firstNPC=CaelumCombatActor(first); let secondNPC=CaelumCombatActor(second);
            double firstHeight=firstPlayer!=null ? firstPlayer.GetImpactReferenceHeight()
                : firstNPC!=null ? firstNPC.GetImpactReferenceHeight() : Max(1.0,first.Height);
            double secondHeight=secondPlayer!=null ? secondPlayer.GetImpactReferenceHeight()
                : secondNPC!=null ? secondNPC.GetImpactReferenceHeight() : Max(1.0,second.Height);
            contact.ReleaseDistance=first.Radius+second.Radius
                +Min(firstHeight,secondHeight)*CaelumConstants.IMPACT_CONTACT_REARM_HEIGHT_FRACTION
                +CaelumConstants.IMPACT_CONTACT_RELEASE_MARGIN;
            contact.SeparatedTics=0;
        }
        contact.ReleaseDistanceRevision=1;
    }

    static double Received(double selfMass, double otherMass, double closingSpeed)
    {
        return ImpactPhysics.ReceivedEnergySI(selfMass,otherMass,
            CaelumPhysicsUnits.VelocitySI(closingSpeed))*HP_PER_JOULE;
    }

    static double Work(double impulse, double closingSpeed)
    {
        return 0.5*CaelumPhysicsUnits.VelocitySI(Max(0.0,impulse))
            *CaelumPhysicsUnits.VelocitySI(Max(0.0,closingSpeed));
    }

    static play double MassOf(Actor body)
    {
        let user=CaelumPlayer(body); let npc=CaelumCombatActor(body);
        let environment=CaelumEnvironmentProp(body);
        return user!=null ? user.GetCombatMass() : npc!=null ? npc.GetCollisionEffectiveMass()
            : environment!=null ? environment.GetEnvironmentMassKg() : Max(0.0001,body.Mass);
    }

    // Primera cara de la caja expandida que cruza la trayectoria relativa.
    // La componente tangencial no se convierte en una colisión frontal.
    static Vector3 ContactNormal(Actor source, Actor target, Vector3 velocity)
    {
        Vector3 position=source.Pos-target.Pos;
        Vector3 relative=velocity-target.Vel;
        double enter=-1.0e30, leave=1.0e30;
        Vector3 normal=(0,0,0);
        for (int axis=0;axis<3;axis++)
        {
            double origin=CaelumImpactPolygon.Component(position,axis);
            double direction=CaelumImpactPolygon.Component(relative,axis);
            double low=axis==2 ? -source.Height : -source.Radius-target.Radius;
            double high=axis==2 ? target.Height : source.Radius+target.Radius;
            if (direction==0) { if (origin<low || origin>high) return (0,0,0); continue; }
            double first=(low-origin)/direction, last=(high-origin)/direction;
            if (first>last) { double swap=first; first=last; last=swap; }
            if (first>enter)
            {
                enter=first;
                double sign=direction>0 ? 1 : -1;
                normal=axis==0 ? (sign,0,0) : axis==1 ? (0,sign,0) : (0,0,sign);
            }
            leave=Min(leave,last);
        }
        return enter<=leave ? normal : (0,0,0);
    }

    static play bool BodyLanding(Actor falling, double fallingSpeed)
    {
        if (!falling.bOnMobj) return false;
        Actor support=null;
        double bestArea=0;
        let nearby=BlockThingsIterator.Create(falling,falling.Radius);
        while (nearby.Next())
        {
            Actor candidate=nearby.thing;
            if (candidate==falling || !candidate.bSolid || candidate.bNoClip
                || (candidate.health<=0 && (candidate.bShootable || candidate.bCorpse)) || Abs(falling.Pos.Z-candidate.Pos.Z-candidate.Height)>0.5) continue;
            double width=Min(falling.Pos.X+falling.Radius,candidate.Pos.X+candidate.Radius)
                -Max(falling.Pos.X-falling.Radius,candidate.Pos.X-candidate.Radius);
            double depth=Min(falling.Pos.Y+falling.Radius,candidate.Pos.Y+candidate.Radius)
                -Max(falling.Pos.Y-falling.Radius,candidate.Pos.Y-candidate.Radius);
            if (width>0 && depth>0 && width*depth>bestArea) { support=candidate; bestArea=width*depth; }
        }
        if (support==null) return false;
        let blocker=CaelumGateBlocker(support);
        let gate=blocker!=null ? CaelumBreakableGate(blocker.master) : null;
        let environment=CaelumEnvironmentProp(support);
        bool anchored=gate!=null || (environment!=null && !environment.IsEnvironmentMovable());
        Actor contactOwner=support; if (gate!=null) contactOwner=gate;
        let user=CaelumPlayer(falling); let npc=CaelumCombatActor(falling);
        if (user==null && npc==null) return false;
        let supportNPC=CaelumCombatActor(support);
        if (supportNPC!=null && supportNPC.DisableCaelumImpactContacts) return true;
        ImpactContactState contact=user!=null ? user.GetImpactContactState(contactOwner) : npc.GetImpactContactState(contactOwner);
        if (contact!=null) { contact.RegisterCollision(level.time); return true; }
        let sourceBody=user!=null ? user.BuildImpactPhysicsBody() : npc.BuildImpactPhysicsBody();
        let targetBody=new("ImpactBody");
        sourceBody.Velocity.Z=-fallingSpeed;
        targetBody.Mass=MassOf(support);targetBody.Height=support.Height;
        targetBody.Position=support.Pos;targetBody.Velocity=support.Vel;
        targetBody.Restitution=CaelumConstants.IMPACT_RESTITUTION;targetBody.SurfaceMultiplier=1;
        let result=new("ImpactResult");
        if (anchored)
        {
            ImpactPhysics.ResolveStatic(sourceBody,(0,0,-1),result);
            result.SourceContactMinimumHeightRatio=result.SourceContactMaximumHeightRatio=0;
            result.TargetContactMinimumHeightRatio=result.TargetContactMaximumHeightRatio=1;
        }
        else ImpactPhysics.ResolveVerticalBodies(sourceBody,targetBody,result);
        if (!result.Valid) return true;
        contact=user!=null ? user.LatchImpactContact(contactOwner) : npc.LatchImpactContact(contactOwner);
        if (contact!=null) contact.BeginResolutionTick(level.time);
        let firstArea=gate!=null ? GateArea(falling,gate,(0,0,-1),0,0) : AreaFor(falling,support,0,0,(0,0,-1));
        let secondArea=AreaFor(support,falling,1,1,(0,0,1));
        double sourceMass=sourceBody.Mass, targetMass=targetBody.Mass;
        double joules=Received(sourceMass,anchored ? 0 : targetMass,result.ClosingSpeed);
        Deliver(falling,support,result.SourceDeltaSpeed,CaelumConstants.IMPACT_KIND_FLOOR,1,
            sourceMass,anchored ? 0 : targetMass,result.ClosingSpeed,result.Impulse,0,0,joules,firstArea,(0,0,-1));
        if (gate!=null) gate.ReceiveStructuralImpact(falling,falling,joules,1);
        else Deliver(support,falling,result.TargetDeltaSpeed,CaelumConstants.IMPACT_KIND_ACTOR,1,
            targetMass,sourceMass,result.ClosingSpeed,result.Impulse,1,1,joules,secondArea,(0,0,1));
        return true;
    }

    // La penetración pertenece al proyectil, nunca al arma que porta un cuerpo.
    static Actor DefenseInflictor(Actor source)
    { return source is "CaelumCannonProjectile" || source is "CaelumActorProjectile" ? source : null; }

    static play CaelumImpactArea AreaFor(Actor receiver, Actor source, double low, double high, Vector3 normal)
    {
        let user=CaelumPlayer(receiver); let npc=CaelumCombatActor(receiver);
        if (user!=null) return user.PrepareImpactArea(source,low,high,normal);
        if (npc!=null) return npc.PrepareImpactArea(source,low,high,normal);
        return null;
    }

    static play CaelumImpactArea GateArea(Actor receiver, CaelumBreakableGate gate,
        Vector3 normal, double low=0, double high=1)
    {
        let area=AreaFor(receiver,null,low,high,normal);
        if (area==null) return null;
        let user=CaelumPlayer(receiver); let npc=CaelumCombatActor(receiver);
        double x=0.5*(CaelumGateData.WIDTH*Abs(Cos(gate.Angle))+CaelumGateData.THICKNESS*Abs(Sin(gate.Angle)));
        double y=0.5*(CaelumGateData.WIDTH*Abs(Sin(gate.Angle))+CaelumGateData.THICKNESS*Abs(Cos(gate.Angle)));
        area.Build(receiver,null,user!=null ? user.AnatomyProfile : npc.AnatomyProfile,
            low,high,normal,true,gate.Pos-(x,y,0),gate.Pos+(x,y,CaelumGateData.HEIGHT));
        return area;
    }

    static play CaelumImpactArea RamArea(Actor receiver, CaelumBatteringRam ram,
        Vector3 normal, double low, double high)
    {
        let area=AreaFor(receiver,null,low,high,normal);
        if (area==null || ram.Head==null) return area;
        Vector3 lower=ram.Head.Pos-(ram.Head.Radius,ram.Head.Radius,0);
        Vector3 upper=ram.Head.Pos+(ram.Head.Radius,ram.Head.Radius,ram.Head.Height);
        for (int i=0;i<ram.FaceBlocks.Size();i++)
        {
            Actor block=ram.FaceBlocks[i]; if (block==null) continue;
            lower=(Min(lower.X,block.Pos.X-block.Radius),Min(lower.Y,block.Pos.Y-block.Radius),Min(lower.Z,block.Pos.Z));
            upper=(Max(upper.X,block.Pos.X+block.Radius),Max(upper.Y,block.Pos.Y+block.Radius),Max(upper.Z,block.Pos.Z+block.Height));
        }
        let user=CaelumPlayer(receiver); let npc=CaelumCombatActor(receiver);
        area.Build(receiver,null,user!=null ? user.AnatomyProfile : npc.AnatomyProfile,
            low,high,normal,true,lower,upper);
        return area;
    }

    static play void CaptureWork(ImpactContactState contact)
    {
        if (contact.FirstActor==null || contact.SecondActor==null) return;
        let snapshot=new("CaelumImpactWorkSnapshot");
        snapshot.FirstMass=MassOf(contact.FirstActor); snapshot.SecondMass=MassOf(contact.SecondActor);
        snapshot.Normal=ImpactPhysics.NormalizeHorizontal(contact.SecondActor.Pos-contact.FirstActor.Pos);
        snapshot.FirstArea=AreaFor(contact.FirstActor,contact.SecondActor,0,1,snapshot.Normal);
        snapshot.SecondArea=AreaFor(contact.SecondActor,contact.FirstActor,0,1,-snapshot.Normal);
        contact.PendingGeometry=snapshot;
    }

    static play double CushionWork(Actor body, Actor source, double work, double impulse, double mass)
    {
        let user=CaelumPlayer(body); let npc=CaelumCombatActor(body);
        double delta=impulse/mass;
        // ReceiveCaelumImpact reclasifica la roca de peligro como ambiente:
        // no recibe la amortiguación de caída usada por la presión corporal.
        double absorption=source is "CaelumHazardRock"
            ? (user!=null ? user.GetHazardPressureAbsorptionSpeed(delta) : 0)
            : user!=null ? user.GetBiologicalJumpAbsorptionSpeed()
            : npc!=null ? npc.GetBiologicalJumpAbsorptionSpeed() : 0;
        double retained=delta>0 ? Max(0.0,delta-absorption)/delta : 1;
        return work*retained*retained;
    }

    // Mezcla distribuciones de área normalizadas ponderadas por el trabajo
    // amortiguado de cada muestra, sin trasladar golpes viejos a la última cara.
    static CaelumImpactArea MixWorkAreas(CaelumImpactArea previous, CaelumImpactArea sample,
        double previousWork, double sampleWork)
    {
        let mixed=new("CaelumImpactArea");
        double total=previousWork+sampleWork;
        if (total<=0) return mixed;
        mixed.TotalArea=1;
        for (int i=0;i<16;i++)
            mixed.RegionArea[i]=((previous!=null && previous.TotalArea>0 ? previous.RegionArea[i]/previous.TotalArea : 0)*previousWork
                +(sample!=null && sample.TotalArea>0 ? sample.RegionArea[i]/sample.TotalArea : 0)*sampleWork)/total;
        mixed.NeutralArea=((previous!=null && previous.TotalArea>0 ? previous.NeutralArea/previous.TotalArea : 1)*previousWork
            +(sample!=null && sample.TotalArea>0 ? sample.NeutralArea/sample.TotalArea : 1)*sampleWork)/total;
        return mixed;
    }

    static play void AddWork(ImpactContactState contact, double work, double impulse)
    {
        if (contact.LastSustainedTick==level.time || work<=0) return;
        let previous=CaelumImpactWorkSnapshot(contact.PendingGeometry);
        CaptureWork(contact);
        let sample=CaelumImpactWorkSnapshot(contact.PendingGeometry);
        if (sample==null) return;
        double first=CushionWork(contact.FirstActor,contact.SecondActor,work,impulse,sample.FirstMass);
        double second=CushionWork(contact.SecondActor,contact.FirstActor,work,impulse,sample.SecondMass);
        sample.FirstArea=MixWorkAreas(previous!=null ? previous.FirstArea : null,sample.FirstArea,
            previous!=null ? previous.FirstRetainedWork : 0,first);
        sample.SecondArea=MixWorkAreas(previous!=null ? previous.SecondArea : null,sample.SecondArea,
            previous!=null ? previous.SecondRetainedWork : 0,second);
        sample.FirstRetainedWork=first+(previous!=null ? previous.FirstRetainedWork : 0);
        sample.SecondRetainedWork=second+(previous!=null ? previous.SecondRetainedWork : 0);
        sample.EnergyWeighted=true;
    }

    static play void ConsumeWork(ImpactContactState contact)
    {
        if (contact==null || contact.PendingWorkJoules<=0) return;
        let snapshot=CaelumImpactWorkSnapshot(contact.PendingGeometry);
        if (snapshot==null) { CaptureWork(contact); snapshot=CaelumImpactWorkSnapshot(contact.PendingGeometry); }
        if (snapshot==null) return;
        double work=contact.PendingWorkJoules;
        contact.PendingWorkJoules=0; contact.PendingGeometry=null;
        double reduced=snapshot.FirstMass/(1+snapshot.FirstMass/snapshot.SecondMass);
        double closing=CaelumPhysicsUnits.VelocityEngine(Sqrt(2*work/reduced));
        double impulse=reduced*closing;
        Deliver(contact.FirstActor,contact.SecondActor,impulse/snapshot.FirstMass,
            CaelumConstants.IMPACT_KIND_CRUSH,1,snapshot.FirstMass,snapshot.SecondMass,
            closing,impulse,0,1,work,snapshot.FirstArea,snapshot.Normal,false,
            snapshot.EnergyWeighted ? snapshot.FirstRetainedWork : -1);
        Deliver(contact.SecondActor,contact.FirstActor,impulse/snapshot.SecondMass,
            CaelumConstants.IMPACT_KIND_CRUSH,1,snapshot.SecondMass,snapshot.FirstMass,
            closing,impulse,0,1,work,snapshot.SecondArea,-snapshot.Normal,false,
            snapshot.EnergyWeighted ? snapshot.SecondRetainedWork : -1);
    }

    static play void Deliver(Actor receiver, Actor source, double deltaSpeed, int kind,
        double surface, double mass, double otherMass, double closing, double impulse,
        double low, double high, double joules, CaelumImpactArea area=null,
        Vector3 normal=(0,0,0), bool stationaryScenery=false, double cushionedJoules=-1)
    {
        if (receiver==null || receiver.health<=0) return;
        let user=CaelumPlayer(receiver); let npc=CaelumCombatActor(receiver);
        if (user!=null)
            user.ReceiveCaelumImpact(deltaSpeed,kind,source,surface,mass,otherMass,closing,impulse,
                low,high,stationaryScenery,joules,area,normal,cushionedJoules);
        else if (npc!=null)
            npc.ReceiveCaelumImpact(deltaSpeed,kind,source,surface,mass,otherMass,closing,impulse,
                low,high,stationaryScenery,joules,area,normal,cushionedJoules);
        else if (receiver.bShootable)
            receiver.DamageMobj(source,source,Max(0,int(joules*surface+0.5)),
                'CaelumImpact',DMG_THRUSTLESS,0);
    }

    // Ambos parches y masas se capturan antes de que daño, muerte o rotura de
    // armadura cambien el primer cuerpo. Cada receptor aplica sus defensas.
    static play void Pair(Actor first, Actor second, ImpactBody firstBody, ImpactBody secondBody,
        ImpactResult result, int kind, bool stationaryScenery=false, double work=-1)
    {
        double firstMass=firstBody.Mass, secondMass=secondBody.Mass;
        double firstSurface=firstBody.SurfaceMultiplier, secondSurface=secondBody.SurfaceMultiplier;
        double joules=work>=0 ? work : Received(firstMass,secondMass,result.ClosingSpeed);
        let firstArea=AreaFor(first,second,result.SourceContactMinimumHeightRatio,
            result.SourceContactMaximumHeightRatio,result.Normal);
        let secondArea=AreaFor(second,first,result.TargetContactMinimumHeightRatio,
            result.TargetContactMaximumHeightRatio,-result.Normal);
        // #195: dolor/muerte del primer receptor no cambia la amortiguación
        // que el segundo tenía al comenzar este mismo contacto.
        let firstNPC=CaelumCombatActor(first);let secondNPC=CaelumCombatActor(second);
        double firstRetained=firstNPC!=null ? firstNPC.RetainImpactEnergy(joules,result.SourceDeltaSpeed,kind,result.Normal) : -1;
        double secondRetained=secondNPC!=null ? secondNPC.RetainImpactEnergy(joules,result.TargetDeltaSpeed,kind,-result.Normal) : -1;
        Deliver(first,second,result.SourceDeltaSpeed,kind,secondSurface,firstMass,secondMass,
            result.ClosingSpeed,result.Impulse,result.SourceContactMinimumHeightRatio,
            result.SourceContactMaximumHeightRatio,joules,firstArea,result.Normal,stationaryScenery,firstRetained);
        Deliver(second,first,result.TargetDeltaSpeed,kind,firstSurface,secondMass,firstMass,
            result.ClosingSpeed,result.Impulse,result.TargetContactMinimumHeightRatio,
            result.TargetContactMaximumHeightRatio,joules,secondArea,-result.Normal,false,secondRetained);
    }
}

// La distribución de trabajo por región permanece al separarse y al guardar.
// La amortiguación se captura por muestra; armadura y Dureza se aplican al pulso.
class CaelumImpactWorkSnapshot : Object
{
    double FirstMass, SecondMass;
    bool EnergyWeighted;
    double FirstRetainedWork, SecondRetainedWork;
    Vector3 Normal;
    CaelumImpactArea FirstArea, SecondArea;
}
