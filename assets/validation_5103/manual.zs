// Laboratorio local: actores reales, controles visibles y recursos protegidos.
class CA510Lab : EventHandler
{
    int Age,Mode;
    CaelumCombatActor Observer,Leader,Receiver,Subject;
    CaelumSiegeEncounter Group;
    bool ReceiverFar;

    CaelumCombatActor Body(vector3 point,bool friendly,String label)
    {
        let body=CaelumCombatActor(Actor.Spawn(Mode==4 && !friendly ? "CaelumMandinga" : "CaelumPortDefender",point,NO_REPLACE));
        body.bFriendly=friendly;body.bInvulnerable=true;body.Angle=0;body.SetTag(label);
        body.CombatInsight=0;body.CombatEffectiveInsight=0;body.CombatAgility=0;
        return body;
    }

    void Join(CaelumCombatActor body)
    {
        let entry=new("CaelumSiegeCombatant");entry.Body=body;entry.Encounter=Group;
        body.SiegeCombatant=entry;entry.CommandLeader=body==Leader ? entry : Leader.SiegeCombatant;
    }

    void Setup(int selected)
    {
        if(Mode!=0)return;
        Mode=selected;let user=CaelumPlayer(players[0].mo);user.player.cheats|=CF_GODMODE;
        user.bShootable=Mode==1 || Mode==3;user.EffectiveStealthPercent=0;
        user.SetOrigin((600,128,0),false);user.Angle=180;user.Pitch=0;user.Vel=(0,0,0);
        Observer=Body((0,0,0),false,"Observador");
        if(Mode==2){Observer.Angle=0;user.SetOrigin((-500,0,0),false);user.Angle=0;}
        if(Mode==4)
        {
            user.SetOrigin((-500,-400,0),false);user.Angle=45;
            Group=CaelumSiegeEncounter(Actor.Spawn("CaelumSiegeEncounter",(-1800,0,0),NO_REPLACE));
            Leader=Body((0,200,0),false,"Lider");Leader.Angle=180;Join(Leader);
            Join(Observer);Observer.SetTag("Testigo");
            Receiver=Body((0,450,0),false,"Receptor");Receiver.Angle=180;Join(Receiver);
            Subject=Body((600,0,0),true,"Objetivo");Subject.Angle=0;
        }
        Console.Printf("CA510 RESULT laboratorio %d listo; F2 imprime el estado real; F1 reinicia el mapa",Mode);
    }

    void Report(CaelumCombatActor body,String label)
    {
        if(body==null)return;
        let evidence=CaelumVisualPerception.Evidence(body);let memory=evidence.GetMemory();
        Console.Printf("CA510 %s sospecha=%.1f identificado=%d recuerdos=%d pos=(%.0f,%.0f) ruido=(%.0f,%.0f) edad_ruido=%.1f",
            label,evidence.Suspicion,evidence.IdentifiedSubject!=null,memory.Records.Size(),body.Pos.X,body.Pos.Y,
            evidence.NoisePosition.X,evidence.NoisePosition.Y,evidence.HasHeardNoise ? double(level.time-evidence.NoiseTic)/TICRATE : -1);
        for(int i=0;i<memory.Records.Size();i++)
        {
            let record=memory.Records[i];
            Console.Printf("CA510 recuerdo=(%.0f,%.0f) edad=%.1f orden=%d testigo=%s",
                record.Position.X,record.Position.Y,double(level.time-record.ObservedTic)/TICRATE,
                record.OrderLeader!=null && CaelumPerceptionMemoryData.Fresh(record.OrderObservedTic),
                record.OriginalWitness==null ? 'none' : record.OriginalWitness.GetClassName());
        }
    }

    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(Age==5)
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();
            let record=user.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        }
        if(Mode==0)return;
        // El laboratorio fija la deteccion para aislar cada regla, no el combate de campana.
        user.EffectiveStealthPercent=0;
        if(Observer!=null){Observer.CombatEffectiveInsight=0;Observer.CombatAgility=0;}
        if(Leader!=null)Leader.CombatEffectiveInsight=0;
        if(Receiver!=null)Receiver.CombatEffectiveInsight=0;
        if(Subject!=null)Subject.CombatEffectiveInsight=0;
        if(Mode==1 || Mode==4)
        {
            if(Observer!=null){Observer.Speed=0;Observer.CombatBaseSpeed=0;Observer.Vel.X=0;Observer.Vel.Y=0;}
            if(Leader!=null){Leader.Speed=0;Leader.CombatBaseSpeed=0;Leader.Vel.X=0;Leader.Vel.Y=0;}
            if(Receiver!=null){Receiver.Speed=0;Receiver.CombatBaseSpeed=0;Receiver.Vel.X=0;Receiver.Vel.Y=0;}
            if(Subject!=null){Subject.Speed=0;Subject.CombatBaseSpeed=0;Subject.Vel.X=0;Subject.Vel.Y=0;}
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca510_mode"){Setup(e.Args[0]);return;}
        if(Mode==0)return;
        if(e.Name=="ca510_report"){Report(Observer,"observador");Report(Leader,"lider");Report(Receiver,"receptor");}
        if(e.Name=="ca510_noise"){CaelumNoise.Emit(user,CaelumNoiseData.MAGIC);Console.Printf("CA510 ruido anonimo emitido en (%.0f,%.0f)",user.Pos.X,user.Pos.Y);}
        if(e.Name=="ca510_hide")
        {
            if(Mode==4)
            {
                if(Receiver.VisualEvidence!=null && Receiver.VisualEvidence.Memory!=null)Receiver.VisualEvidence.Memory.ClearGoal(Receiver);
                Receiver.SetOrigin((1800,1800,0),false);Receiver.VisualEvidence=new("CaelumVisualEvidence");Receiver.VisualEvidence.Initialize();
                Receiver.target=null;Receiver.LastEnemy=null;ReceiverFar=true;
            }
            else {user.SetOrigin((-500,500,0),false);user.Vel=(0,0,0);user.Angle=user.AngleTo(Observer);}
        }
        if(e.Name=="ca510_return")
        {
            if(Mode==4){Receiver.SetOrigin((0,450,0),false);ReceiverFar=false;}
            else
            {
                vector3 point=(600,384,0);
                // Reaparecer delante, separado del NPC: el contacto fisico
                // identificaria al instante incluso despues de olvidar.
                if(Mode==3)point=Observer.Pos+(cos(Observer.Angle)*512,sin(Observer.Angle)*512,0);
                user.SetOrigin(point,false);user.Vel=(0,0,0);user.Angle=user.AngleTo(Observer);
                if(Mode==1)Observer.Angle=0;
            }
        }
        if(e.Name=="ca510_turn" && Observer!=null)
        {
            if(Observer.VisualEvidence!=null && Observer.VisualEvidence.Memory!=null)Observer.VisualEvidence.Memory.ClearGoal(Observer);
            Observer.VisualEvidence=new("CaelumVisualEvidence");Observer.VisualEvidence.Initialize();
            Observer.Angle=180;Observer.target=null;Observer.LastEnemy=null;
        }
        if(e.Name=="ca510_light" && Observer!=null)Observer.CurSector.SetLightLevel(Observer.CurSector.lightlevel==0 ? 255 : 0);
    }

    static ui void Line(int row,String text,int color=Font.CR_WHITE)
    {
        Screen.DrawText(SmallFont,color,12,10+row*12,text,DTA_VIRTUALWIDTHF,640.0,
            DTA_VIRTUALHEIGHTF,360.0,DTA_KEEPRATIO,true,DTA_SHADOW,true);
    }

    ui void BodyLine(int row,CaelumCombatActor body,String label)
    {
        if(body==null)return;
        let evidence=body.VisualEvidence;if(evidence==null)return;
        int count=evidence.Memory==null ? 0 : evidence.Memory.Records.Size();
        Line(row,String.Format("%s: alerta %.0f | identificado %d | recuerdos %d",label,evidence.Suspicion,
            evidence.IdentifiedSubject!=null,count));
        if(evidence.Memory!=null && count>0)
        {
            let record=evidence.Memory.Records[0];
            Line(row+1,String.Format("Punto %.0f, %.0f | edad %.1f s | orden %d",record.Position.X,record.Position.Y,
                double(level.time-record.ObservedTic)/TICRATE,record.OrderLeader!=null && level.time-record.OrderObservedTic<30*TICRATE));
        }
        else if(evidence.HasHeardNoise)
            Line(row+1,String.Format("Ruido %.0f, %.0f | edad %.1f s",evidence.NoisePosition.X,evidence.NoisePosition.Y,
                double(level.time-evidence.NoiseTic)/TICRATE));
    }

    override void RenderOverlay(RenderEvent e)
    {
        // El panel diagnostico debe leerse aunque la mira active la ficha del NPC.
        Screen.Dim("Black",0.95,0,0,Screen.GetWidth(),int(Screen.GetHeight()*128.0/360));
        Line(0,String.Format("V5.10 / #%d - laboratorio visual",424+Mode),Font.CR_GOLD);
        Line(1,"F1: reiniciar | F2: estado en consola | F3: ruido anonimo");
        Line(2,Mode==4 ? "F4: alejar receptor | F5: acercarlo (esperar hasta 5 s)" : "F4: ocultarse / traslado silencioso | F5: volver | F6: girar observador");
        Line(3,"F7: alternar luz | Esc: menu del juego | consola: tecla habitual");
        BodyLine(4,Observer,"Observador");BodyLine(6,Leader,"Lider");BodyLine(8,Receiver,"Receptor");
    }
}
