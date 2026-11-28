class DeathInspection : StaticEventHandler
{
    Actor subject, image;
    Array<Inventory> props;
    int slot, started, transitions, lastFrame, lastSprite;
    bool done;

    static clearscope String Caption(int i)
    {
        static const String captions[] = {CAPTIONS};
        return captions[i];
    }
    static clearscope Name Species(int i)
    {
        static const Name species[] = {CLASSES};
        return species[i];
    }
    override void WorldThingSpawned(WorldEvent e)
    {
        if(level.MapName=="CAIDAS" && e.Thing is "Inventory")props.Push(Inventory(e.Thing));
        if(level.MapName=="CAIDAS" && (e.Thing is "CaelumMoonDeathImage" || e.Thing is "CaelumSummonDeathImage"))
            image=e.Thing;
    }
    void Show(int i,bool focus)
    {
        if(subject!=null && !subject.bDestroyed)subject.Destroy();
        if(image!=null && !image.bDestroyed)image.Destroy();
        image=null;subject=null;
        slot=(i+TOTAL)%TOTAL;started=level.time;transitions=0;lastFrame=-1;lastSprite=-1;done=false;
        Name kind=Species(slot);
        // Las apariciones con propietario se crean al recibir la muerte real.
        if(kind!='CaelumTarotClone' && kind!='CaelumSummonedZupay' && kind!='CaelumHuntGuardian')
            subject=Actor.Spawn(kind,(0,0,0),NO_REPLACE);
        if(subject!=null)
        {
            subject.Angle=270;
            subject.bInvisible=false;
            if(subject is 'CaelumTarotAutomaton')CaelumTarotAutomaton(subject).Prepare();
        }
        let eye=players[0].mo;
        if(focus && eye!=null)
        {
            double height=slot<FAMILY_COUNT?62:subject!=null?subject.Height:84;
            if(kind=='CaelumGiantRat')height=19;
            double range=Max(46,height*1.72);
            eye.SetOrigin((range*.62,-range,0),false);eye.Angle=122;eye.Pitch=2;
            eye.ViewHeight=Max(10,height*.53);eye.player.ViewHeight=eye.ViewHeight;
        }
        Console.Printf("FALL start=%d class=%s",slot+1,kind);
    }
    void StartFall()
    {
        Name kind=Species(slot);
        if(subject==null)
        {
            subject=Actor.Spawn(kind,(0,0,0),NO_REPLACE);
            if(subject==null)return;
            subject.Angle=270;
            let clone=CaelumTarotClone(subject);
            if(clone!=null)
            {
                clone.Look=new('CaelumCharacterProfile');
                clone.Scale=CaelumAppearance.ScaleFor(clone.Look.Race,clone.Look.Sex,clone.Look.BeastForm,56);
                clone.Head=CaelumMoonHead(Actor.Spawn('CaelumMoonHead',clone.Pos,NO_REPLACE));
                if(clone.Head!=null)clone.Head.master=clone;
            }
        }
        if(slot<FAMILY_COUNT){subject.SetStateLabel("Falling");return;}
        subject.health=0;
        subject.Die(null,null,0,'None');
        if(subject!=null && !subject.bDestroyed)subject.bInvisible=false;
    }
    override void WorldTick()
    {
        if(level.MapName!="CAIDAS" || !players[0].mo)return;
        if(level.time==4)
        {
            players[0].mo.bInvulnerable=true;players[0].mo.bShootable=false;
            Show(FAMILY_COUNT,true);return;
        }
        if(level.time<5)return;
        int age=level.time-started;
        for(int i=props.Size()-1;i>=0;i--)
        {
            if(props[i]==null || props[i].bDestroyed){props.Delete(i);continue;}
            if(props[i].Owner==null)props[i].bInvisible=true;
        }
        if(subject!=null && !subject.bDestroyed && age<=12)
        {
            subject.SetOrigin((0,0,0),false);subject.Vel=(0,0,0);subject.Angle=270;
            let palomo=CaelumPalomo(subject);
            if(palomo!=null){palomo.MerchantAnchored=true;palomo.WanderEnabled=false;palomo.WanderHome=(0,0,0);}
        }
        if(age==12)StartFall();
        if(age<=12 || done)return;
        Actor view=image!=null?image:subject;
        let machine=CaelumTarotAutomaton(subject);
        if(machine!=null)view=machine.Look;
        let bull=CaelumBull(subject);
        if(bull!=null && bull.BullModel!=null)view=bull.BullModel;
        if(view!=null && !view.bDestroyed && (view.Frame!=lastFrame || view.Sprite!=lastSprite))
        {
            transitions++;lastFrame=view.Frame;lastSprite=view.Sprite;
            Console.Printf("FALL pose=%d dt=%d frame=%d",slot+1,age-12,lastFrame);
        }
        if(age>=82)
        {
            done=true;
            Console.Printf("FALL end=%d transitions=%d",slot+1,transitions);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(level.MapName!="CAIDAS")return;
        if(e.Name=="fila_siguiente")Show(slot+1,true);
        else if(e.Name=="fila_anterior")Show(slot-1,true);
        else if(e.Name=="fall_slot")Show(Clamp(e.Args[0]-1,0,TOTAL-1),true);
        else if(e.Name=="fall_repeat")Show(slot,false);
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(level.MapName!="CAIDAS")return;
        String title=String.Format("%d / %d   %s",slot+1,TOTAL,Caption(slot));
        Screen.DrawText(SmallFont,Font.CR_WHITE,320-SmallFont.StringWidth(title)/2,10,title,DTA_VirtualWidth,640,DTA_VirtualHeight,360,DTA_KeepRatio,true);
    }
}

