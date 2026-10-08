class CA135FrozenZupay : CaelumZupayColossus { override void Tick() {} }
class CA135Orientation : EventHandler
{
    CaelumCombatActor Bodies[4];int Stage;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();}
        if(level.time==60)
        {
            user.bNOTARGET=true;user.bINVULNERABLE=true;user.bNOGRAVITY=true;
            user.SetOrigin((2300,3860,30),false);user.Angle=90;user.Pitch=0;
            for(int i=0;i<4;i++)Bodies[i]=CaelumCombatActor(Actor.Spawn("CA135FrozenZupay",(2000+i*200,4490,0)));
        }
        int next=CVar.GetCVar("ca135_gallery_stage").GetInt();
        if(Bodies[0]==null || next<1)return;
        int group=(next-1)/8;double yaw=(next-1)%8*45;
        for(int i=0;i<4;i++)
        {
            Bodies[i].Angle=yaw;Bodies[i].tics=-1;
            Bodies[i].sprite=Bodies[i].GetSpriteIndex(group==0 && i==0 ? "ZUID"
                : group==2 && i==2 ? "ZURN" : group==2 && i==3 ? "ZUWK" : "ZUPY");
            Bodies[i].frame=group==0 ? (i==0 ? 0 : i+2) : group==1 ? i+12 : i<2 ? i+16 : 0;
        }
        if(Stage!=next)
        {
            Stage=next;Console.Printf("CA135 ORIENTATION group=%d yaw=%.0f",group,yaw);
            if(Stage==24)Console.Printf("CA135 COMPLETE checks=0 failures=0");
        }
    }
}
