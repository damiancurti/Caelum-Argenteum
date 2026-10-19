// Guardados reales y viaje de hub; conserva las mismas clases entre paquetes.
class CA312Witness : CA194Target
{
    int ConfirmedHealth;
}
class CA312Persist : CA194Combat
{
    bool Loaded;
    CaelumCombatActor A,B,BaseBody,Top;
    double LoadedCarry,ReleaseWork;
    int ReleaseHealth,Mode;
    override void WorldLoaded(WorldEvent e)
    {
        Loaded=e.IsSaveGame;Age=0;Mode=0;
        if(!Loaded)return;
        A=CaelumCombatActor(ActorIterator.Create(45700).Next());
        B=CaelumCombatActor(ActorIterator.Create(45701).Next());
        BaseBody=CaelumCombatActor(ActorIterator.Create(45702).Next());
        Top=CaelumCombatActor(ActorIterator.Create(45703).Next());
        Check("loaded four bodies",A!=null && B!=null && BaseBody!=null && Top!=null,1);
        if(A==null || B==null || BaseBody==null)return;
        let c=A.GetImpactContactState(B);
        Check("saved shared pressure identity",c!=null && c==B.GetImpactContactState(A),1);
        if(c!=null)
        {
            Check("saved motion work",c.PendingWorkJoules,1000);
            Check("saved pressure geometry",c.PendingGeometry!=null,1);
        }
        let p=CaelumWeightPressure(BaseBody.FindInventory("CaelumWeightPressure"));
        Check("saved static inventory",p!=null,1);
        if(p!=null)
        {
            LoadedCarry=p.DamageCarry;
            Check("saved ongoing fractional pressure",LoadedCarry>0 && p.ContactTics>1 && p.ContactTics<36,1);
            Console.Printf("CA312 RESTORED carry=%.9f count=%d energyrev=%d",LoadedCarry,p.ContactTics,p.EnergyRevision);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c312_rollback")Mode=1;
    }
    override void WorldTick()
    {
        Age++;
        if(!Loaded)
        {
            if(Age==5)
            {
                A=Fresh(200);A.SetOrigin((-512,0,32),false);A.ChangeTid(45700);
                B=Fresh(70);B.SetOrigin(A.Pos+(32,0,0),false);B.ChangeTid(45701);
                let c=A.LatchImpactContact(B);CaelumImpactEnergy.CaptureWork(c);c.PendingWorkJoules=1000;
                BaseBody=Fresh();BaseBody.SetOrigin((0,512,0),false);BaseBody.CombatStrength=0;BaseBody.ChangeTid(45702);
                Top=Fresh(1000000);Top.SetOrigin(BaseBody.Pos+(0,0,56),false);Top.ChangeTid(45703);
                Top.bNoGravity=false;Top.bOnMobj=true;Top.Vel=(0,0,0);
            }
            if(Age==12)
            {
                let p=CaelumWeightPressure(BaseBody.FindInventory("CaelumWeightPressure"));
                Check("ongoing save static carry exists",p!=null && p.DamageCarry>0,1);
                Check("ongoing save motion work exists",A.GetImpactContactState(B).PendingWorkJoules,1000);
                Console.Printf("CA194 DONE failures=%d passes=%d checkpoint",Failures,Passes);
            }
            return;
        }
        if(Age==8 && Mode!=1)
        {
            let p=CaelumWeightPressure(BaseBody.FindInventory("CaelumWeightPressure"));
            Check("loaded weight continues accumulating",p.DamageCarry>LoadedCarry,1);
            ReleaseWork=p.DamageCarry;ReleaseHealth=BaseBody.health;
            Top.Destroy();Top=null;B.Destroy();B=null;
        }
        if(Age==11)
        {
            if(Mode!=1)
            {
                A.UpdateImpactContactLatch();
                Check("loaded removed peer releases saved motion work",A.LastImpactReceivedJoules,1000);
                Check("loaded geometry and toughness retained",1000000-A.health,725);
                let p=CaelumWeightPressure(BaseBody.FindInventory("CaelumWeightPressure"));
                Check("loaded static release work",p.LastWorkJoules,ReleaseWork);
                Check("loaded static final once",ReleaseHealth-BaseBody.health,int(Max(0,ReleaseWork-80)+0.5));
                Check("loaded static carry consumed",p.DamageCarry,0);
                int hp=A.health;A.UpdateImpactContactLatch();Check("loaded removal no replay",A.health,hp);
            }
            Console.Printf("CA194 DONE failures=%d passes=%d restored mode=%d",Failures,Passes,Mode);
        }
    }
}

class CA312Travel : CA194Combat
{
    override void WorldTick() {}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);
        if(e.Name=="c312_travel_setup")
        {
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.bInvulnerable=false;
            u.CaelumMaximumHealth=u.health=u.player.health=10000000;
            u.SetOrigin((0,0,0),false);u.Vel=(0,0,0);u.bNoGravity=true;
            let peer=CaelumCombatActor(Actor.Spawn("CA312Witness",(32,0,0)));peer.ChangeTid(45710);
            peer.Mass=80;peer.CombatToughness=0;peer.health=1000000;
            peer.CombatArmor=new("CaelumArmorModel");peer.CombatArmor.InitializeDefaults();
            let c=u.LatchImpactContact(peer);CaelumImpactEnergy.CaptureWork(c);c.PendingWorkJoules=1000;
            let top=Fresh(1000000);top.ChangeTid(45711);top.SetOrigin(u.Pos+(0,0,u.Height),false);
            top.bNoGravity=false;top.bOnMobj=true;top.Vel=(0,0,0);
            let p=CaelumWeightPressure(u.GiveInventoryType("CaelumWeightPressure"));
            p.EnergyRevision=1;p.DamageCarry=1000;p.ContactTics=10;
            Console.Printf("CA312 TRAVEL READY contact=%.9f static=%.9f",c.PendingWorkJoules,p.DamageCarry);
        }
        if(e.Name=="c312_away")
        {
            Check("hub destination",level.MapName=="MAPQB",1);
            Check("traveler closes moving contacts",u.GetImpactContactCount(),0);
            let p=CaelumWeightPressure(u.FindInventory("CaelumWeightPressure"));
            Check("traveler preserves and closes static pressure",p!=null && p.LastWorkJoules>=1000 && p.DamageCarry==0 && p.ContactTics==0,1);
        }
        if(e.Name=="c312_back")
        {
            let peer=CA312Witness(ActorIterator.Create(45710).Next());
            Check("hub restores original peer",peer!=null,1);
            if(peer!=null)
            {
                Check("hub peer receives work before snapshot",peer.LastImpactReceivedJoules,1000);
                if(peer.ConfirmedHealth!=0)Check("second hub return cannot replay",peer.health,peer.ConfirmedHealth);
                peer.ConfirmedHealth=peer.health;
                peer.UpdateImpactContactLatch();
                Check("hub peer removes consumed edge",peer.GetImpactContactCount(),0);
                let top=ActorIterator.Create(45711).Next();if(top!=null)top.Destroy();
            }
            Console.Printf("CA194 DONE failures=%d passes=%d hub-return",Failures,Passes);
        }
    }
}
