// Escena privada: sólo comprueba la pertenencia física y el planificador existente.
class CA502SceneryChecks : CA502ObjectChecks
{
    Array<Actor> Scenery;
    bool ExpectedMembership;
    bool ManualScenery;
    Array<String> SceneryReadings;
    String LastAction;
    void Seed(bool expected)
    {
        ExpectedMembership=expected;
        for(int i=0;i<8;i++)
        {
            Class<Actor> kind='CaelumMansionSceneryShrub';
            if(i==1)kind='CaelumCaveSceneryRuby';else if(i==2)kind='CaelumCaveScenerySapphire';
            else if(i==3)kind='CaelumCaveSceneryEmerald';else if(i==4)kind='CaelumCaveSceneryTopaz';
            else if(i==5)kind='CaelumCaveSceneryOpal';else if(i==6)kind='CaelumShopSign';
            else if(i==7)kind='CaelumMansionSceneryTree';
            Scenery.Push(Actor.Spawn(kind,(-160+(i%4)*80,32+(i/4)*96,0),NO_REPLACE));
        }
    }
    void Core()
    {
        for(int i=0;i<Scenery.Size();i++)
        {
            let body=Scenery[i];bool enabled=ExpectedMembership || i==7;
            Check(body!=null && CaelumContaminationObject.Eligible(body)==enabled,String.Format("scenery%d eligibility matches physical classification",i));
            Check((Node(body)!=null)==enabled,String.Format("scenery%d native spawn scheduler",i));
            Check(body.bSolid==(i==7),String.Format("scenery%d retains original collision",i));
            if(!enabled)continue;
            let node=Node(body);CaelumContaminationObject.Register(body);
            Check(Node(body)==node,"typed registration remains idempotent");
            double radius=body.Radius/32.0,height=body.Height/32.0;
            double area=2*CaelumThermalData.CIRCLE_PI*radius*(radius+height);
            Check(Near(CaelumContaminationObject.Area(body),area),"physical cylinder area unchanged");
            node.Ready=false;node.Advance();CaelumContaminationStorage.Set(body,20);
            node.Ambient=80;node.Rain=0;node.Stamp-=10;node.Advance();
            Check(Near(CaelumContaminationStorage.Value(body),Min(80.0,Sqrt(400+2*0.1*80*area*10))),"world-time exposure applies to actual scenery");
            double once=CaelumContaminationStorage.Value(body);node.Advance();
            Check(Near(CaelumContaminationStorage.Value(body),once),"same clock does not expose twice");
            CaelumContaminationStorage.Set(body,80);node.Ambient=0;node.Rain=10;node.Stamp-=1800;node.Advance();
            Check(Near(CaelumContaminationStorage.Value(body),60),"approved half-hour rain washing applies to scenery");
        }
        let helper=Actor.Spawn('CA502ObjectHolder',(0,-64,0),NO_REPLACE);
        Check(!CaelumContaminationObject.Eligible(helper) && Node(helper)==null,"nonphysical helper remains excluded");helper.Destroy();
        Summary();
    }
    void Summary(){Console.Printf("CA502S RESULT passed=%d failed=%d",Passed,Failed);}
    void SaveSeed()
    {for(int i=0;i<Scenery.Size();i++)CaelumContaminationStorage.Set(Scenery[i],30+i);Check(true,"save seeds original scenery identities and contamination");Summary();}
    void LoadCheck(bool enabled)
    {
        Check(Scenery.Size()==8,"saved scenery references retained");
        for(int i=0;i<Scenery.Size();i++)
        {
            let body=Scenery[i];
            Check(body!=null && Near(CaelumContaminationStorage.Value(body),30+i),"save preserves contamination without retroactive exposure");
            Check((Node(body)!=null)==(enabled || i==7),"save attaches eligible scheduler exactly once");
            if(Node(body)!=null){let old=Node(body);CaelumContaminationObject.Register(body);Check(Node(body)==old,"saved registration stays idempotent");}
        }
        Summary();
    }
    void Read()
    {
        for(int i=0;i<Scenery.Size();i++)Console.Printf("CA502S object%d C=%.3f exposed=%d solid=%d",i,CaelumContaminationStorage.Value(Scenery[i]),Node(Scenery[i])!=null,Scenery[i].bSolid);
    }
    void ManualStep(int operationKey)
    {
        ManualScenery=true;
        LastAction=operationKey==1?"F1: objetos en 80":operationKey==3?"F3: desde 20, ambiente 80 durante 10 s":"F4: lluvia aislada 10 mm/h durante 30 min";
        for(int i=0;i<Scenery.Size();i++)
        {
            let body=Scenery[i],node=Node(body);if(node==null)continue;
            node.Ready=false;node.Advance();
            double expectedValue;
            if(operationKey==1){CaelumContaminationStorage.Set(body,80);expectedValue=80;}
            else if(operationKey==3)
            {
                CaelumContaminationStorage.Set(body,20);node.Ambient=80;node.Rain=0;node.Stamp-=10;
                expectedValue=Min(80.0,Sqrt(400+2*0.1*80*CaelumContaminationObject.Area(body)*10));node.Advance();
            }
            else
            {
                expectedValue=Max(0.0,CaelumContaminationStorage.Value(body)-20);
                node.Ambient=0;node.Rain=10;node.Stamp-=1800;node.Advance();
            }
            Check(Near(CaelumContaminationStorage.Value(body),expectedValue),"manual action applies expected scenery concentration");
        }
        Read();Summary();
    }
    override void WorldTick()
    {
        Super.WorldTick();if(!ManualScenery)return;
        SceneryReadings.Resize(Scenery.Size());
        for(int i=0;i<Scenery.Size();i++)
        {
            String label=i==0?"Arbusto":i==1?"Rubi":i==2?"Zafiro":i==3?"Esmeralda":i==4?"Topacio":i==5?"Opalo":i==6?"Cartel":"Arbol";
            SceneryReadings[i]=String.Format("%s: %.2f | expuesto: %s",label,CaelumContaminationStorage.Value(Scenery[i]),Node(Scenery[i])!=null?"si":"no");
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!ManualScenery)return;
        let f=Font.GetFont('CaelumMono');Screen.Dim(0x000000,0.85,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.55));
        Screen.DrawText(f,Font.CR_GOLD,8,5,"#502 - Contaminacion de decorados fisicos",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        for(int i=0;i<SceneryReadings.Size();i++)Screen.DrawText(f,Font.CR_WHITE,8,22+16*i,SceneryReadings[i],DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_GOLD,8,155,LastAction,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,172,"F1=80 | F2=consola | F3=exposicion | F4=lavado",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,188,"Prueba aislada: mide objetos, no el cuerpo del personaje.",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca502s_seed')Seed(e.Args[0]!=0);
        else if(e.Name=='ca502s_core')Core();
        else if(e.Name=='ca502s_saveseed')SaveSeed();
        else if(e.Name=='ca502s_load')LoadCheck(e.Args[0]!=0);
        else if(e.Name=='ca502s_read'){Read();Summary();}
        else if(e.Name=='ca502s_reset')ManualStep(1);
        else if(e.Name=='ca502s_expose')ManualStep(3);
        else if(e.Name=='ca502s_rain')ManualStep(4);
        else Super.NetworkProcess(e);
    }
}
class CA502SceneryMenu : CaelumLiveMenu
{
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_KeyDown)
        {
            String command="";
            if(e.KeyChar==UIEvent.Key_F1)command="ca502s_reset";
            else if(e.KeyChar==UIEvent.Key_F2)command="ca502s_read";
            else if(e.KeyChar==UIEvent.Key_F3)command="ca502s_expose";
            else if(e.KeyChar==UIEvent.Key_F4)command="ca502s_rain";
            if(command.Length()>0){EventHandler.SendNetworkEvent(command);return true;}
        }
        return Super.OnUIEvent(e);
    }
}
