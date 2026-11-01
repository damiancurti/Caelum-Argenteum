// #601: estado de ronda guardado, ocho participantes y un perseguidor.
class CaelumHuntResources : Object play
{
    int Life;
    double Anima,Air,Adrenaline,Lucidity,Hunger,Thirst,Sleep;
    void Capture(CaelumPlayer p)
    {
        Life=Max(1,p.health);Anima=p.CurrentAnima;Air=p.CurrentAir;
        Adrenaline=p.CurrentAdrenaline;Lucidity=p.CurrentLucidity;
        Hunger=p.CurrentHunger;Thirst=p.CurrentThirst;Sleep=p.CurrentSleep;
    }
    void Restore(CaelumPlayer p)
    {
        p.health=Life;p.player.health=Life;p.CurrentAnima=Anima;p.CurrentAir=Air;
        p.CurrentAdrenaline=Adrenaline;p.CurrentLucidity=Lucidity;
        p.CurrentHunger=Hunger;p.CurrentThirst=Thirst;p.CurrentSleep=Sleep;
    }
}

class CaelumTarotHunt : Object play
{
    int Revision,Collected,CaptiveMask;
    bool Found[78];
    CaelumHuntEssence Essences[78];
    CaelumHuntTrap Traps[24];
    CaelumHuntPalomo Hunter;
    CaelumHuntResources Resources[MAXPLAYERS],BeforeTrap[MAXPLAYERS];
    int TrapFor[MAXPLAYERS],RescueTarget[MAXPLAYERS],RescueProgress[MAXPLAYERS];

    static clearscope CaelumTarotHunt View()
    {let m=CaelumStandaloneMatch.View();return m!=null?m.Hunt:null;}
    static clearscope bool Held(CaelumPlayer p)
    {let h=View();return p is 'CaelumStandalonePlayer' && h!=null && h.Captive(p.PlayerNumber());}
    static clearscope bool HumanHunter(CaelumPlayer p)
    {let body=CaelumStandalonePlayer(p);return body!=null && body.StandaloneHunter;}
    clearscope bool Captive(int slot){return slot>=0 && slot<MAXPLAYERS && (CaptiveMask&(1<<slot))!=0;}
    void Initialize()
    {
        if(Revision>0)return;Revision=1;
        for(int i=0;i<MAXPLAYERS;i++){TrapFor[i]=-1;RescueTarget[i]=-1;}
        for(int i=0;i<CaelumConstants.TAROT_CARD_COUNT;i++)
        {
            vector2 point=CaelumHuntData.Node(CaelumHuntData.EssenceNode(i));
            let card=CaelumHuntEssence(Actor.Spawn('CaelumHuntEssence',(point,0),NO_REPLACE));
            card.Card=i;card.sprite=Actor.GetSpriteIndex(CaelumTarotArt.FrontSprite(i));Essences[i]=card;
        }
        for(int i=0;i<24;i++)
        {
            let trap=CaelumHuntTrap(Actor.Spawn('CaelumHuntTrap',CaelumHuntData.TrapPoint(i),NO_REPLACE));
            trap.Index=i;trap.Kind=CaelumHuntData.TrapKind(i);trap.args[1]=CaelumHuntData.CRUSHER_SPEED;
            trap.args[2]=0;Traps[i]=trap;
            trap.SetTag(trap.Kind==0?"$CA_HUNT_DOOR":trap.Kind==1?"$CA_HUNT_FLOOR":"$CA_CRUSHER_TRAP");
        }
        let match=CaelumStandaloneMatch.View();
        if(match.PlayerPalomo==0)Hunter=CaelumHuntPalomo(Actor.Spawn('CaelumHuntPalomo',CaelumHuntData.HunterStart(),NO_REPLACE));
        else
        {let body=CaelumPlayer(players[match.PlayerPalomo-1].mo);body.TeleportMove(CaelumHuntData.HunterStart(),false);body.ClearInterpolation();}
    }
    void Collect(CaelumPlayer p,int card)
    {
        let m=CaelumStandaloneMatch.View();
        if(card<0 || card>=78 || Found[card] || m==null || m.Finished || !m.Seeker(p.PlayerNumber())
            || Captive(p.PlayerNumber()) || !CaelumCaptureArcana.Touches(p,Essences[card]))return;
        Found[card]=true;Collected++;m.Score[p.PlayerNumber()]++;
        Essences[card].bSpecial=false;Essences[card].bInvisible=true;
        Console.Printf("%s",String.Format(StringTable.Localize('CA_HUNT_FOUND',false),CaelumTarotArt.DisplayName(card),Collected));
    }
    void BeginTrap(int index)
    {
        let m=CaelumStandaloneMatch.View();
        for(int slot=0;slot<MAXPLAYERS;slot++)if(m.Seeker(slot) && !Captive(slot))
        {
            let p=CaelumPlayer(players[slot].mo);if(p==null || !Traps[index].Contains(p))continue;
            BeforeTrap[slot]=new('CaelumHuntResources');BeforeTrap[slot].Capture(p);TrapFor[slot]=index;
        }
    }
    void CapturePlayer(CaelumPlayer p,bool fatal=false)
    {
        let m=CaelumStandaloneMatch.View();int slot=p.PlayerNumber();
        if(m==null || m.Finished || !m.Seeker(slot) || Captive(slot))return;
        let saved=fatal?BeforeTrap[slot]:null;
        if(saved==null){saved=new('CaelumHuntResources');saved.Capture(p);}
        Resources[slot]=saved;BeforeTrap[slot]=null;TrapFor[slot]=-1;
        CaptiveMask|=1<<slot;saved.Restore(p);
        p.player.cheats|=CF_TOTALLYFROZEN;p.Vel=(0,0,0);
        PlaceCaptive(p);p.LastImpactFallingVelocityZ=0;p.ImpactGroundTrackingInitialized=false;
        Console.Printf("%s",String.Format(StringTable.Localize('CA_HUNT_CAPTURED',false),players[slot].GetUserName()));
    }
    bool PlaceCaptive(CaelumPlayer p)
    {
        for(int n=0;n<MAXPLAYERS;n++)if(p.TeleportMove(CaelumHuntData.Start((p.PlayerNumber()+n)%MAXPLAYERS),false))
        {p.ClearInterpolation();return true;}return false;
    }
    void Rescue(int slot)
    {
        if(!Captive(slot))return;
        let p=CaelumPlayer(players[slot].mo);if(p==null)return;
        Resources[slot].Restore(p);Resources[slot]=null;CaptiveMask&=~(1<<slot);
        p.player.cheats&=~CF_TOTALLYFROZEN;p.PainImmobilizationRemaining=0;
        p.LastImpactFallingVelocityZ=0;p.ImpactGroundTrackingInitialized=false;
        Console.Printf("%s",String.Format(StringTable.Localize('CA_HUNT_RESCUED',false),players[slot].GetUserName()));
    }
    void Tick(CaelumStandaloneMatch m)
    {
        // La consulta sólo recorre los ocho puestos de la sesión.
        let human=m.PlayerPalomo>0?CaelumPlayer(players[m.PlayerPalomo-1].mo):null;
        for(int slot=0;slot<MAXPLAYERS;slot++)if(m.Seeker(slot))
        {
            let p=CaelumPlayer(players[slot].mo);if(p==null)continue;
            if(human!=null && !Captive(slot) && CaelumVisualPerception.Touching(human,p))CapturePlayer(p);
            if(Captive(slot))
            {Resources[slot].Restore(p);p.player.cheats|=CF_TOTALLYFROZEN;p.Vel=(0,0,0);continue;}
            if(TrapFor[slot]>=0 && !Traps[TrapFor[slot]].Contains(p))
            {BeforeTrap[slot]=null;TrapFor[slot]=-1;}
            int nearby=-1;
            if((p.player.cmd.buttons&BT_USE)!=0)
                for(int other=0;other<MAXPLAYERS;other++)if(Captive(other))
                {
                    let victim=CaelumPlayer(players[other].mo);
                    if(victim!=null && p.Distance3D(victim)<=p.UseRange && p.CheckSight(victim))
                    {nearby=other;break;}
                }
            if(nearby<0){RescueTarget[slot]=-1;RescueProgress[slot]=0;continue;}
            if(RescueTarget[slot]!=nearby){RescueTarget[slot]=nearby;RescueProgress[slot]=0;}
            RescueProgress[slot]++;
            if(RescueProgress[slot]>=CaelumHuntData.RESCUE_TICS)
            {Rescue(nearby);RescueTarget[slot]=-1;RescueProgress[slot]=0;}
        }
        if(Collected>=CaelumConstants.TAROT_CARD_COUNT || (CaptiveMask&m.Seekers())==m.Seekers())
        {m.Finished=true;m.Winner=Collected>=CaelumConstants.TAROT_CARD_COUNT?0:-1;}
    }
}

class CaelumHuntEssence : Inventory
{
    int Card;
    override bool TryPickup(in out Actor toucher)
    {let h=CaelumTarotHunt.View();let p=CaelumPlayer(toucher);if(h!=null && p!=null)h.Collect(p,Card);return false;}
    Default {Radius 18;Height 88;Scale 0.25;+NOGRAVITY +INVENTORY.UNDROPPABLE}
    States {Spawn:CTAR A -1 Bright;Stop;}
}

// Un controlador por trampa: presión local y temporizador nativo guardado.
class CaelumHuntTrap : CaelumCrusherTrap
{
    int Index,Kind,RearmAt;
    bool Contains(Actor body)
    {return body!=null && Abs(body.Pos.X-Pos.X)<Radius+body.Radius && Abs(body.Pos.Y-Pos.Y)<Radius+body.Radius;}
    override bool IsPressedBy(Actor body)
    {return body is 'CaelumStandalonePlayer' && !CaelumTarotHunt.Held(CaelumPlayer(body)) && Super.IsPressedBy(body);}
    override bool Trigger(Actor body)
    {
        let h=CaelumTarotHunt.View();let m=CaelumStandaloneMatch.View();
        if(h==null || m.Finished || !IsPressedBy(body))return false;
        bool ok;
        h.BeginTrap(Index);
        if(Kind==2)ok=Release();
        else
        {
            int tag=CaelumHuntData.TrapSector(Index);
            ok=Kind==0?Level.ExecuteSpecial(249,body,null,false,tag,CaelumHuntData.DOOR_SPEED,CaelumHuntData.DOOR_WAIT)
                :Level.ExecuteSpecial(66,body,null,false,tag,0,CaelumHuntData.PIT_DEPTH/8);
            if(ok){Spent=true;ActivationCount++;}
        }
        if(ok){RearmAt=level.time+CaelumHuntData.REARM_TICS;InterruptVictim(body);}return ok;
    }
    override void Tick()
    {
        Super.Tick();
        if(Spent && RearmAt>0 && level.time>=RearmAt && !CurSector.PlaneMoving(Sector.ceiling) && !CurSector.PlaneMoving(Sector.floor))
        {
            if(Kind==1)Level.ExecuteSpecial(67,self,null,false,CaelumHuntData.TrapSector(Index),0,CaelumHuntData.PIT_DEPTH/8);
            Spent=false;StartedPanels=0;MovementFinished=false;RearmAt=0;Alpha=1;A_SetRenderStyle(1,STYLE_Normal);
        }
    }
}

class CaelumHuntPalomo : CaelumPalomo
{
    double Watch[MAXPLAYERS];
    int LastEvidence[MAXPLAYERS],LastSeen[MAXPLAYERS],Focus,Patrol,NextRoute,RouteGoal,RouteCursor;
    vector3 Remembered[MAXPLAYERS];
    Array<int> Route;
    override bool InteractWithCaelumPlayer(CaelumPlayer user){return false;}
    override void PostBeginPlay()
    {Super.PostBeginPlay();Focus=-1;RouteGoal=-1;NarrativeRevealInitialized=true;NarrativeRevealRequired=false;MerchantAnchored=true;WanderEnabled=false;}
    void BuildRoute(vector2 goal)
    {
        int from=CaelumHuntData.At(Pos.XY),to=CaelumHuntData.At(goal);
        if(from<0 || to<0)return;
        Route.Clear();RouteCursor=0;RouteGoal=to;NextRoute=level.time+CaelumHuntData.PATH_RETRY_TICS;
        Array<int> parent,queue;parent.Resize(CaelumHuntData.NODE_COUNT);
        for(int i=0;i<parent.Size();i++)parent[i]=-1;
        parent[from]=from;queue.Push(from);
        for(int head=0;head<queue.Size() && parent[to]<0;head++)
        {
            int node=queue[head];vector2 p=CaelumHuntData.Node(node);
            for(int d=0;d<4;d++)
            {
                vector2 step=d==0?(CaelumHuntData.CELL,0):d==1?(-CaelumHuntData.CELL,0):d==2?(0,CaelumHuntData.CELL):(0,-CaelumHuntData.CELL);
                int next=CaelumHuntData.At(p+step);
                if(next<0 || parent[next]>=0)continue;
                // El resto del suelo es estático y está indexado al generar.
                // Sólo las 24 trampas tienen planos que cambian en esta malla.
                int trap=CaelumHuntData.NodeTrap(next);
                if(trap>=0)
                {
                    let h=CaelumTarotHunt.View();let sec=h.Traps[trap].CurSector;
                    if(sec.floorplane.ZatPoint(p+step)<Pos.Z-MaxStepHeight
                        || sec.ceilingplane.ZatPoint(p+step)-sec.floorplane.ZatPoint(p+step)<Height)continue;
                }
                parent[next]=node;queue.Push(next);
            }
        }
        if(parent[to]<0)return;
        Array<int> reverse;for(int n=to;n!=from;n=parent[n])reverse.Push(n);
        for(int n=reverse.Size()-1;n>=0;n--)Route.Push(reverse[n]);
    }
    void MoveTo(vector2 point,CaelumStandaloneMatch m,CaelumTarotHunt h)
    {
        vector2 offset=point-Pos.XY;double distance=offset.Length();
        if(distance<=0){Vel.X=Vel.Y=0;return;}
        vector2 direction=offset/distance;double step=Min(Speed,distance);
        // Acercarse hasta el contacto físico sin pedir un paso que atraviese
        // al cuerpo sólido. Sólo los ocho participantes próximos intervienen.
        for(int i=0;i<MAXPLAYERS;i++)if(m.Member(i) && !h.Captive(i))
        {
            let p=players[i].mo;if(p==null || p.Pos.Z>=Pos.Z+Height || Pos.Z>=p.Pos.Z+p.Height)continue;
            vector2 relative=p.Pos.XY-Pos.XY;double along=relative dot direction;
            double side2=Max(0,(relative dot relative)-along*along),radius=Radius+p.Radius;
            if(along<=0 || side2>=radius*radius)continue;
            double contact=along-Sqrt(radius*radius-side2);
            if(contact>=0 && contact<step)step=Max(0,contact-0.001);
        }
        Angle=VectorAngle(offset.X,offset.Y);vector2 movement=direction*step;
        if(CheckMove(Pos.XY+movement,0)){Vel.X=movement.X;Vel.Y=movement.Y;}
        else {Vel.X=Vel.Y=0;Route.Clear();}
    }
    override void Tick()
    {
        WanderHome=Pos;MerchantReturningHome=false;WanderEnabled=false;
        Super.Tick();
        let m=CaelumStandaloneMatch.View();let h=CaelumTarotHunt.View();
        if(h==null || m==null || m.Finished || bDormant){Vel=(0,0,0);return;}
        int best=-1;double distance=1e30;
        for(int i=0;i<MAXPLAYERS;i++)if(m.Member(i) && !h.Captive(i))
        {
            let p=CaelumPlayer(players[i].mo);if(p==null)continue;
            if(CaelumVisualPerception.Touching(self,p)){h.CapturePlayer(p);Watch[i]=0;continue;}
            bool seen=CaelumVisualPerception.CanSee(self,p);
            if(seen)
            {
                LastEvidence[i]=level.time;
                Watch[i]=Min(Watch[i]+1,CaelumPerceptionData.IDENTIFICATION_SECONDS*TICRATE);
                if(Watch[i]>=CaelumPerceptionData.IDENTIFICATION_SECONDS*TICRATE)
                {LastSeen[i]=level.time;Remembered[i]=p.Pos;}
            }
            else if(level.time-LastEvidence[i]>=CaelumPerceptionData.SUSPICION_GRACE_SECONDS*TICRATE
                && (LastSeen[i]==0 || !CaelumPerceptionMemoryData.Fresh(LastSeen[i])))
                Watch[i]=Max(0,Watch[i]-CaelumPerceptionData.SUSPICION_DECAY_PER_SECOND
                    /CaelumPerceptionData.SUSPICION_MAXIMUM*CaelumPerceptionData.IDENTIFICATION_SECONDS);
            if(LastSeen[i]>0 && CaelumPerceptionMemoryData.Fresh(LastSeen[i]))
            {double range=(Remembered[i].XY-Pos.XY).Length();if(best<0 || i==Focus || (best!=Focus && range<distance)){best=i;distance=range;}}
        }
        Focus=best;
        vector2 goal=best>=0?Remembered[best].XY:CaelumHuntData.Node(CaelumHuntData.EssenceNode(Patrol));
        if((goal-Pos.XY).Length()<Radius && best<0){Patrol=(Patrol+1)%78;Route.Clear();RouteGoal=-1;}
        if(level.time>=NextRoute && (RouteCursor>=Route.Size() || RouteGoal!=CaelumHuntData.At(goal)))BuildRoute(goal);
        if(RouteCursor<Route.Size())
        {
            vector2 next=CaelumHuntData.Node(Route[RouteCursor]);vector2 offset=next-Pos.XY;double length=offset.Length();
            if(length<=Max(1,Speed)){RouteCursor++;}
            if(length>0)MoveTo(next,m,h);
        }
        else if(best>=0 && CaelumHuntData.At(Pos.XY)==CaelumHuntData.At(goal))MoveTo(goal,m,h);
        else Vel.X=Vel.Y=0;
        UpdateLocomotionVisual();
    }
    Default {+FRIENDLY}
    States {Spawn:PAID A 1;Goto Walk;Walk:PAWK AB 4;Loop;}
}
