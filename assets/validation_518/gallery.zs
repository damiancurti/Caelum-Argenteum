// Identical before/after flight controls; visual fixtures never ship in src.
class CA137Gallery : StaticEventHandler
{
    int Previous,Mode,Age;
    CaelumActorProjectile Shot;
    CaelumCombatActor Bodies[4];
    override void WorldLoaded(WorldEvent e){Previous=-1;Mode=-1;Age=0;}
    void Clear()
    {
        if(Shot!=null)Shot.Destroy();
        for(int i=0;i<4;i++)if(Bodies[i]!=null)Bodies[i].Destroy();
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        if(level.time<70)return;
        int desiredView=CVar.GetCVar("ca137_view").GetInt(),desiredMode=CVar.GetCVar("ca137_mode").GetInt();
        if(desiredView!=Previous || desiredMode!=Mode)
        {
            Clear();Previous=desiredView;Mode=desiredMode;Age=0;
            u.SetOrigin((2048,4096,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            if(Mode==4){u.SetOrigin((1820,4096,100),false);u.Pitch=15;u.bNOGRAVITY=true;}
            u.CurSector.SetLightLevel(Mode==2 || desiredView>=27 ? 224 : 64);
            if(Mode==0)
            {
                int kind=desiredView%9,angle=(desiredView/9)%3;
                Shot=CaelumActorProjectile(Actor.Spawn("CaelumPlayerMagicProjectile",(2270,4016,58)));
                Shot.target=u;Shot.StoreCaelumElementalPayload(kind==8 ? 4 : kind/2,kind!=8 && kind%2==1,100,100);
                Shot.StoreCaelumAttackResult(1,true,false,true,1);Shot.ConfigureCaelumTravelDistance(500);
                if(angle==0){Shot.Vel=(0,20,0);Shot.Angle=90;}
                if(angle==1){Shot.SetOrigin((2180,4096,58),false);Shot.Vel=(20,0,0);Shot.Angle=0;}
                if(angle==2){Shot.SetOrigin((2430,4096,90),false);Shot.Vel=(-20,0,0);Shot.Angle=180;}
                Console.Printf("CA137 GALLERY flight=%d kind=%d viewpoint=%d",desiredView,kind,angle);
            }
            else
            {
                for(int i=0;i<4;i++)
                {
                    Class<Actor> kinds[]={"CaelumGiantRat","CaelumBull","CaelumZupayColossus","CaelumMandinga"};
                    Class<Actor> selected="CaelumMandinga";
                    if(Mode==4)selected=kinds[i];
                    Bodies[i]=CaelumCombatActor(Actor.Spawn(selected,(2220,3958+92*i,0)));
                    Bodies[i].bDORMANT=true;Bodies[i].target=null;
                }
            }
        }
        Age++;
        if(Mode>0 && Age==3)
        {
            for(int i=0;i<4;i++)
            {
                let st=Bodies[i].ElementalStatus;
                if(st==null){st=new("CaelumElementalStatus");Bodies[i].ElementalStatus=st;}
                if(i==0 || i==3)st.BurnRemaining=20;
                if(i==1 || i==3)st.PoisonRemaining=20;
                if(i==2 || i==3)st.FreezeRemaining=20;
                if(i==3)st.LightningStunRemaining=20;
                st.UpdateVisualEffects(Bodies[i]);
            }
        }
        if(Mode>0 && Age>3)
            for(int i=0;i<4;i++)
            {
                if(Bodies[i]!=null)Bodies[i].SetOrigin((2220+10*Sin(Age*3),3958+92*i,0),false);
                else if(Age==4)Console.Printf("CA137 BODY_REMOVED index=%d",i);
            }
        if(Mode==4 && Age==30)Console.Printf("CA137 GALLERY COMPLETE");
    }
}
