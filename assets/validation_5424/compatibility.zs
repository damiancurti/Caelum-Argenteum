// Congelar sólo el escenario: la migración real sigue siendo autoritativa.
class CA284LegacyMandinga : CaelumMandinga { override void Tick(){EnsureCombatPersonality();} }
class CA284LegacyZupay : CaelumZupayColossus { override void Tick(){EnsureCombatPersonality();} }
class CA284LegacyShot : CaelumActorExplosiveElementalProjectile
{ override void Tick(){CaelumElementalVFX.Projectile(self);} }
class CA284Compat : EventHandler
{
    CaelumPlayer User;
    CA284LegacyMandinga Mandinga;
    CA284LegacyZupay Zupay;
    CA284LegacyShot Shot;
    int Passed,Failed;
    double SavedAir,SavedAnima;
    void Check(bool ok,String text)
    {if(ok)Passed++;else Failed++;Console.Printf("CA284 %s %s",ok?"PASS":"FAIL",text);}
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        Mandinga=CA284LegacyMandinga(Actor.Spawn("CA284LegacyMandinga",(128,0,0),NO_REPLACE));
        Zupay=CA284LegacyZupay(Actor.Spawn("CA284LegacyZupay",(400,0,0),NO_REPLACE));
        Shot=CA284LegacyShot(Actor.Spawn("CA284LegacyShot",(256,0,128),NO_REPLACE));
        Shot.Target=Zupay;Shot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_EARTH,true,100,100);
    }
    void Seed()
    {
        Mandinga.health=451;Zupay.health=22011;
        SavedAir=Mandinga.MaximumCombatAir*0.3;SavedAnima=Mandinga.MaximumCombatAnima*0.4;
        Mandinga.CurrentCombatAir=SavedAir;Mandinga.CurrentCombatAnima=SavedAnima;
        Mandinga.ElementalStatus.BurnRemaining=2.25;
        Mandinga.bFriendly=true;Mandinga.FriendPlayer=1;
        CaelumDemonService.Potion(Mandinga,0).Amount=2;
        Shot.CaelumLifetimeTicks=17;Shot.CaelumTravelledDistance=72;Shot.Vel=(7,0,-1);
        Check(Mandinga.CombatStrength==6 && Mandinga.health==451,"seed preserves six-point wounded Mandinga");
        Check(Mandinga.CombatPersonalityRevision==1 && Zupay.CombatPersonalityRevision==1,"seed uses original personality revision");
    }
    void Verify()
    {
        Check(Mandinga!=null && Zupay!=null && Shot!=null,"saved native identities retained");
        Check(Mandinga.health==451 && Zupay.health==22011 && Mandinga.CurrentCombatAir==SavedAir
            && Mandinga.CurrentCombatAnima==SavedAnima,"wounds Air and Anima unchanged");
        Check(Mandinga.ElementalStatus.BurnRemaining==2.25 && Mandinga.bFriendly
            && Mandinga.FriendPlayer==1 && CaelumDemonService.Potion(Mandinga,0).Amount==2,
            "saved status allegiance and finite supply preserved");
        Check(Shot.Pos==(256,0,128) && Shot.Vel==(7,0,-1) && Shot.CaelumLifetimeTicks==17
            && Shot.CaelumTravelledDistance==72 && Shot.Target==Zupay,
            "saved projectile physics lifetime travel and owner preserved");
        // CURRENT_CHECK
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent event)
    {
        if(event.Name=="c284_setup")Setup();
        if(event.Name=="c284_seed")Seed();
        if(event.Name=="c284_verify")Verify();
        if(event.Name=="c284_done")Console.Printf("CA284 DONE failures=%d passes=%d",Failed,Passed);
    }
}
