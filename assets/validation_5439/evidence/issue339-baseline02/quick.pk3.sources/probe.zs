// Datos y controles aislados de QA; no cambian reglas del juego.
class CA339Probe : CA282Probe
{
    int Mode,Age,ContactTic,StartHealth;
    bool Running,Injected,Contact;
    double Jump,ContactVelocity;
    bool HasJump() { return false; }
    bool Updated() { return false; }
    void Done() { Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed); }
    void Persistence(bool expected)
    {
        User=CaelumPlayer(players[0].mo);
        Check(User.Pos.Z>User.FloorZ,"loaded actual airborne body");
        Check(HasJump()==expected,"save retains only established voluntary jump provenance");
        Check(Abs(User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL)
            -(expected ? User.GetBiologicalLandingAbsorptionSpeed() : 0))<0.000001,"loaded wall capacity agrees with provenance");
        Done();
    }
    void Controls()
    {
        User=CaelumPlayer(players[0].mo);
        Check(HasJump(),"actual native jump active for controls");
        double capacity=User.GetBiologicalLandingAbsorptionSpeed();
        Check(capacity>0 && User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL)==capacity,"voluntary wall capacity");
        Check(User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_ACTOR)==0,"moving bodies gain no voluntary jump allowance");
        Check(User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_ENVIRONMENT,true)==0,"stationary props gain no airborne allowance");
        User.LucidityPhysicalStunRemaining=5;
        Check(User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL)==0,"immobilization disables actual jumping body");
        User.LucidityPhysicalStunRemaining=0;
        User.CombatBlockModeActive=true;User.ShieldModel.Equipped=true;
        User.ShieldModel.Durability=100;User.ShieldModel.ShieldType=CaelumConstants.SHIELD_TYPE_BUCKLER;
        Check(User.GetImpactAgilityAbsorptionSpeed(CaelumConstants.IMPACT_KIND_WALL)==2*capacity,"buckler doubles capacity once");
        User.CombatBlockModeActive=false;
        
        Done();
    }
    void Start(int testMode)
    {
        Setup();Mode=testMode;Age=0;Running=true;Injected=Contact=false;
        User.bInvulnerable=false;User.CombatBlockModeActive=false;
        User.ShieldModel.Equipped=false;User.IsCrouching=false;
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;
        User.ForcedSleepTics=0;User.CurrentSleep=User.CurrentHunger=User.CurrentThirst=100;
        User.SetOrigin((1600,0,0),false);User.Vel=(0,0,0);
        User.LastImpactKind=-1;User.LastImpactReceivedJoules=0;
        StartHealth=User.health;Jump=User.JumpZ;
        Console.Printf("CA339 START mode=%d health=%d jump=%.9f",Mode,StartHealth,Jump);
    }
    void Trace(String label)
    {
        Console.Printf("CA339 TRACE %s age=%d z=%.6f vz=%.6f jump=%d ground=%d hp=%d kind=%d raw=%.9f retained=%.9f delta=%.9f capacity=%.9f final=%d",
            label,Age,User.Pos.Z,User.Vel.Z,HasJump(),User.player.onground,User.health,
            User.LastImpactKind,User.LastImpactReceivedJoules,User.LastImpactCushionedJoules,
            User.LastImpactRawDeltaSpeed,User.LastImpactBiologicalAbsorptionSpeed,User.LastImpactFinalDamage);
    }
    override void WorldTick()
    {
        if(!Running)return;
        Age++;
        if(Age<8)Trace("takeoff");
        bool ready=Mode==1 ? User.Pos.Z>User.FloorZ && User.Vel.Z<0
            : Mode==2 || Mode==3 ? Age==5
            : User.Pos.Z>User.FloorZ && User.Vel.Z>0 && Age>=3;
        if(!Injected && ready)
        {
            Check(HasJump()==(Updated() && Mode!=2 && Mode!=3),"native takeoff provenance before contact");
            if(Mode==1)Check(!(User.player.cmd.buttons & BT_JUMP),"descending after actual jump key release");
            double z=Mode==2 || Mode==3 ? 100 : User.Pos.Z;
            double vz=Mode==2 ? -2 : Mode==3 ? 4 : User.Vel.Z;
            if(Mode==5)User.LucidityPhysicalStunRemaining=5;
            ContactVelocity=Mode==4 ? 20 : 5;
            User.SetOrigin((2048-User.Radius-3,0,z),false);
            User.Vel=(ContactVelocity,0,vz);Injected=true;
            Trace("injected");
        }
        if(Injected && !Contact && User.LastImpactKind==CaelumConstants.IMPACT_KIND_WALL)
        {
            Contact=true;ContactTic=Age;Trace("wall");
            Check(User.LastImpactReceivedJoules>0,"native wall contact has assigned energy");
            double capacity=Updated() && Mode!=2 && Mode!=3 && Mode!=5 ? User.GetBiologicalLandingAbsorptionSpeed() : 0;
            double delta=User.LastImpactRawDeltaSpeed;
            double ratio=delta>0 ? Max(0.0,delta-capacity)/delta : 1;
            Check(Abs(User.LastImpactCushionedJoules-User.LastImpactReceivedJoules*ratio*ratio)<0.00001,"native residual energy follows existing formula exactly");
            Check(Abs(User.LastImpactBiologicalAbsorptionSpeed-Min(delta,capacity))<0.00001,"capacity applied once or correctly excluded");
            Check(StartHealth-User.health==User.LastImpactFinalDamage,"actual HP loss equals resolved wall damage");
            if(Mode==4)Check(User.LastImpactCushionedJoules>0,"excess impact retains damage energy");
            // Tras medir HP, aislar el aterrizaje de muerte/aturdimiento por ese golpe.
            if(User.health>0)
            {
                User.bInvulnerable=true;User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;
                User.SetOrigin((1500,0,User.Pos.Z),false);User.Vel=(0,0,User.Vel.Z);
            }
        }
        if(Contact && Age>=ContactTic+45)
        {
            Check(!HasJump(),"landing or death ends voluntary jump");
            if(User.health>0)Check(User.LastImpactKind==CaelumConstants.IMPACT_KIND_FLOOR,"subsequent native landing remains registered");
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);Running=false;
        }
        if(Age==150 && !Contact)
        {Trace("timeout");Check(false,"native contact completed");Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);Running=false;}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c339_start")Start(e.Args[0]);
        else if(e.Name=="c339_persist")
        {
            Setup();User.SetOrigin((1600,0,0),false);User.Vel=(0,0,0);Running=false;
            User.CurrentHunger=User.CurrentThirst=100;
        }
        else if(e.Name=="c339_airborne")Persistence(Updated());
        else if(e.Name=="c339_legacy")Persistence(false);
        else if(e.Name=="c339_controls")Controls();
        else if(e.Name=="c339_landed")
        {User=CaelumPlayer(players[0].mo);Check(!HasJump(),"landing or travel clears latch");Done();}
        else Super.NetworkProcess(e);
    }
}
