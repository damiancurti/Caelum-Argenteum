class CA211Falling : CaelumCombatActor
{
    Default { Radius 16; Height 56; Mass 80; Health 10000000; +SHOOTABLE; +SOLID; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA211Movement : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumPlayer User;
    CaelumCombatActor Body;
    void Check(String label,bool ok)
    {if(ok)Passes++;else Failures++;Console.Printf("CA211 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Energy(String label,double energy,double raw,double delta,double jump)
    {
        double ratio=delta>0 ? Max(0.0,delta-1.5*jump)/delta : 1;
        Check(label,delta>0 && Abs(energy-raw*ratio*ratio)<0.001);
        Console.Printf("CA211 TRACE native d=%.9f jump=%.9f raw=%.9f cushioned=%.9f",delta,jump,raw,energy);
    }
    override void WorldTick()
    {
        Age++;
        if(Age==40)
        {
            User=CaelumPlayer(players[0].mo);
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.bInvulnerable=true;User.CombatBlockModeActive=false;User.ShieldModel.Equipped=false;
            User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;User.ForcedSleepTics=0;
            User.SetOrigin((2048-User.Radius-3,0,0),false);User.Vel=(5,0,0);
            User.LastImpactReceivedJoules=0;User.LastImpactKind=-1;
            Console.Printf("CA211 TRACE start pos=%.3f/%.3f radius=%.3f crouch=%.3f",User.Pos.X,User.Pos.Z,User.Radius,User.player.crouchfactor);
        }
        if(Age==50)
        {
            Console.Printf("CA211 TRACE wall pos=%.3f/%.3f kind=%d blocked=%d",User.Pos.X,User.Pos.Z,User.LastImpactKind,User.ImpactWasWallBlockedLastTick);
            Check("native crouch input active",User.IsCrouching);
            Check("native wall contact detected",User.LastImpactKind==CaelumConstants.IMPACT_KIND_WALL && User.LastImpactReceivedJoules>0);
            Energy("native wall uses capacity once",User.LastImpactCushionedJoules,User.LastImpactReceivedJoules,User.LastImpactRawDeltaSpeed,User.JumpZ);
        }
        if(Age==55)
        {
            User.SetOrigin((0,0,200),false);User.Vel=(0,0,-12);
            User.LastImpactReceivedJoules=0;User.LastImpactKind=-1;
            Body=CaelumCombatActor(Actor.Spawn("CA211Falling",(0,512,200)));
            Body.bInvulnerable=true;Body.Vel=(0,0,-12);
        }
        if(Age==100)
        {
            Check("native player floor contact detected",User.LastImpactKind==CaelumConstants.IMPACT_KIND_FLOOR && User.LastImpactReceivedJoules>0);
            Energy("native player fall uses capacity once",User.LastImpactCushionedJoules,User.LastImpactReceivedJoules,User.LastImpactRawDeltaSpeed,User.JumpZ);
            Check("native ordinary NPC floor contact detected",Body.LastImpactKind==CaelumConstants.IMPACT_KIND_FLOOR && Body.LastImpactReceivedJoules>0);
            Energy("native ordinary NPC fall uses capacity once",Body.LastImpactCushionedJoules,Body.LastImpactReceivedJoules,Body.LastImpactRawDeltaSpeed,
                CaelumPhysicsUnits.JumpVelocity(Body.Mass,Body.Mass+Body.GetAttackCarriedWeight(),Body.CombatAgility));
            Console.Printf("CA211 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
