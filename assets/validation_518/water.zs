class CA137Water : StaticEventHandler
{
    CaelumActorProjectile Shots[9];
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        if(level.time==70)
        {
            u.SetOrigin((2048,4096,0),false);u.Angle=0;u.Pitch=0;
            for(int kind=0;kind<9;kind++)
            {
                Shots[kind]=CaelumActorProjectile(Actor.Spawn("CaelumPlayerMagicProjectile",(2220,3936+40*kind,60)));
                Shots[kind].target=u;Shots[kind].StoreCaelumElementalPayload(kind==8 ? 4 : kind/2,kind!=8 && kind%2==1,100,100);
                Shots[kind].Vel=(2,0,0);Shots[kind].ConfigureCaelumTravelDistance(500);
            }
        }
        if(level.time==76)
        {
            int submerged=0;for(int kind=0;kind<9;kind++)if(Shots[kind]!=null && Shots[kind].WaterLevel==3)submerged++;
            Console.Printf("CA137 %s actual swimmable 3D floor player_water=%d projectiles=%d",u.WaterLevel==3 && submerged==9 ? "PASS" : "FAIL",u.WaterLevel,submerged);
        }
        if(level.time==95)Console.Printf("CA137 WATER COMPLETE");
    }
}
