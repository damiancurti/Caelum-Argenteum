// Native frame inspection plus actual uninterrupted Death sequences.
class CA137DeathFrame : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA137Deathframes : StaticEventHandler
{
    int Previous;
    int SeenFrames;
    Actor FrameBody;
    CaelumCombatActor Body;
    override void WorldLoaded(WorldEvent e){Previous=-1;SeenFrames=0;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        if(level.time<70)return;
        int selection=CVar.GetCVar("ca137_view").GetInt();
        if(selection!=Previous)
        {
            if(FrameBody!=null)FrameBody.Destroy();if(Body!=null)Body.Destroy();
            Previous=selection;
            u.SetOrigin((2048,4096,0),false);u.Vel=(0,0,0);u.Angle=0;u.Pitch=8;
            u.CurSector.SetLightLevel(224);
            if(selection<16)
            {
                FrameBody=Actor.Spawn("CA137DeathFrame",(2170,4096,0));
                FrameBody.sprite=Actor.GetSpriteIndex(selection<8 ? "DOMI" : "RATG");
                FrameBody.frame=selection<8 ? 18+selection : 5+selection-8;
                // Rat is enlarged only for this inspection, never in production.
                FrameBody.Scale=(.409091,.409091);
                SeenFrames |= 1 << selection;
                Console.Printf("CA137 DEATH_FRAME kind=%s index=%d",selection<8 ? "Domingo" : "Rat",selection%8);
            }
            else if(selection<18)
            {
                Class<Actor> type=selection==16 ? "CaelumPortDefender" : "CaelumGiantRat";
                Body=CaelumCombatActor(Actor.Spawn(type,(2170,4096,0)));
            }
            else if(selection==18)
            {
                if(SeenFrames==65535)Console.Printf("CA137 DEATH INSPECTION COMPLETE frames=16");
                else Console.Printf("CA137 FAIL incomplete death frame inspection mask=%d",SeenFrames);
            }
        }
        if(selection>=16 && selection<18 && Body!=null && Body.health>0)
        {
            // State timing, actions and final corpse frame are the production path.
            Body.health=0;Body.SetStateLabel("Death");
        }
    }
}
