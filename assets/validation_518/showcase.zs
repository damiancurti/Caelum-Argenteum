// Shared baseline/current visual scene. Deliberately slowed inspection models
// are separate from the full-speed trajectory assertions in checks.zs.
class CA137Showcase : StaticEventHandler
{
    int Previous,Age;
    Actor Prop;
    CaelumActorProjectile Shot;
    override void WorldLoaded(WorldEvent e){Previous=-1;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        if(level.time<70)return;
        int selection=CVar.GetCVar("ca137_view").GetInt();
        if(selection!=Previous)
        {
            if(Prop!=null)Prop.Destroy();if(Shot!=null)Shot.Destroy();
            Previous=selection;Age=0;
            u.SetOrigin((2048,4096,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            u.CurSector.SetLightLevel(224);u.health=u.CaelumMaximumHealth;u.CurrentLucidity=100;u.UpdateLucidityState();
            if(selection<5)
            {
                Class<Actor> types[]={"CaelumArrowProjectile","CaelumBoltProjectile","CaelumCarbineProjectile","CaelumShotgunPellet","CaelumJavelinProjectile"};
                Shot=CaelumActorProjectile(Actor.Spawn(types[selection],(2088,4090,50)));
                Shot.target=u;Shot.Vel=(0,0.12,0.05);Shot.Angle=90;Shot.bNOGRAVITY=true;Shot.tics=10000;
            }
            else if(selection<7)
            {
                Prop=Actor.Spawn(selection==5 ? "CaelumMandinga" : "CaelumZupayColossus",(2210,4096,0));
                Prop.Angle=90;
            }
            Console.Printf("CA137 SHOWCASE stage=%d",selection);
        }
        Age++;
        if(selection>=5 && selection<7 && Age>=3)
        {
            let npc=CaelumCombatActor(Prop);let thermal=CaelumThermalBody.Get(npc,true);
            if(thermal!=null){thermal.Exposure=-10;thermal.Severity=1;}
        }
        if(selection>=7 && selection<=12 && Age==3)
        {
            int kind=selection==7 ? -1 : selection==8 ? 0 : selection==9 ? 3 : selection==10 ? 5 : selection==11 ? 7 : -1;
            Shot=CaelumActorProjectile(Actor.Spawn("CaelumPlayerMagicProjectile",(5000,5000,64)));
            if(kind>=0)Shot.StoreCaelumElementalPayload(kind/2,kind%2==1,100,100);
            int damage=int(u.CaelumMaximumHealth*(selection==12 ? .25 : .025));
            u.DamageMobj(Shot,null,damage,'CaelumElementalDOT',DMG_NO_ARMOR|DMG_FORCED,0);
            Console.Printf("CA137 HIT kind=%d loss=%d max=%d",kind,damage,u.CaelumMaximumHealth);
        }
        if(selection>=13 && selection<=17)
        {
            if(selection==13 || selection==14 || selection==17)
                u.health=int(u.CaelumMaximumHealth*(selection==13 ? .49 : .09));
            if(selection>=15)u.CurrentLucidity=selection==15 ? 49 : 9;
            u.UpdateHealthStateEffects();u.UpdateLucidityState();
        }
        if(selection==18)
        {
            u.CurSector.SetLightLevel(160);
            if(Age==1)
            {
                Shot=CaelumActorProjectile(Actor.Spawn("CaelumJavelinProjectile",(2220,3900,60)));
                Shot.target=u;Shot.Vel=(0,15,7);Shot.Angle=90;
            }
            if(Shot!=null && Age%4==0)Console.Printf("CA137 JAVELIN age=%d pos=(%.5f,%.5f,%.5f) vel=(%.5f,%.5f,%.5f)",Age,Shot.Pos.X,Shot.Pos.Y,Shot.Pos.Z,Shot.Vel.X,Shot.Vel.Y,Shot.Vel.Z);
        }
        if(selection==19 && Age==10)Console.Printf("CA137 SHOWCASE COMPLETE");
    }
}
