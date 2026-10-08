class CA135PoseZupay : CaelumZupayColossus { override void Tick() {} }
class CA135Visual : EventHandler
{
    int Stage,SeenFrames;
    CaelumCombatActor Body;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(user!=null){user.bINVULNERABLE=true;user.player.damagecount=0;}
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==60)
        {
            user.bNOGRAVITY=true;user.SetOrigin((2048,4096,170),false);user.Angle=0;user.Pitch=30;
            for(int size=0;size<3;size++)for(int family=0;family<3;family++)
                Actor.Spawn(CaelumPotionRules.ItemClass(CaelumPotionRules.Kind(family,size)),(2200+size*110,4096+(family-1)*115,0),NO_REPLACE);
        }
        int nextStage=CVar.GetCVar("ca135_gallery_stage").GetInt();
        if(Stage!=nextStage)
        {
            if(Stage==1 || Stage==2)Console.Printf("CA135 ANIMATION stage=%d seenMask=%d failures=%d",Stage,SeenFrames,int(SeenFrames!=15));
            Stage=nextStage;SeenFrames=0;
            if(Body!=null)Body.Destroy();
            Body=CaelumCombatActor(Actor.Spawn(Stage==1 ? "CaelumMandinga" : Stage==2 ? "CaelumZupayColossus" : "CA135PoseZupay",(2300,4490,0)));
            Body.target=null;Body.Angle=0;Body.tics=-1;
            if(Stage>=3){Body.CaelumDiagnosticPassiveAI=true;Body.Angle=(Stage-3)*45;Body.SetStateLabel("IdleBreathing");Body.tics=-1;}
            user.SetOrigin((2348,4180,25),false);user.Angle=90;user.Pitch=0;
            Console.Printf("CA135 VISUAL stage=%d yaw=%.0f sprite=%d frame=%d",Stage,Body.Angle,Body.sprite,Body.frame);
            if(Stage==10)Console.Printf("CA135 COMPLETE checks=0 failures=0");
        }
        if(Body!=null && Stage<=2 && Body.ThermalState!=null)
        {Body.ThermalState.Exposure=-15;Body.ThermalState.Severity=1;if(Body.DemonBreath!=null)SeenFrames|=1<<(Body.frame&3);}
        if(Body!=null && Stage>=3){Body.Angle=(Stage-3)*45;Body.sprite=Body.GetSpriteIndex("ZUID");Body.frame=0;}
    }
}
