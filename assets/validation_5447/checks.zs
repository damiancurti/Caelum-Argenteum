// Controles privados: los números son casos de prueba, no reglas de juego.
class CA361Checks : EventHandler
{
    int Age,Passes,Failures;
    CaelumPortSiege Port;
    CA361Mandinga NPC;
    CaelumPortDefender Soldier;
    CaelumMandinga Other;
    CaelumPortCommander Boss;
    void Check(bool ok,String label)
    {if(ok)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);}}
    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(Age==5){user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;}
        if(Age==20)
        {
            Port=CaelumPortSiege(Actor.Spawn("CA361Port",(16000,16000,0),NO_REPLACE));
            Port.args[3]=1;
            NPC=CA361Mandinga(Actor.Spawn("CA361Mandinga",(1024,0,0),NO_REPLACE));
            Soldier=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(2048,0,0),NO_REPLACE));
            Other=CaelumMandinga(Actor.Spawn("CaelumMandinga",(3072,0,0),NO_REPLACE));
            Boss=CaelumPortCommander(Actor.Spawn("CaelumPortCommander",(4096,0,0),NO_REPLACE));
            NPC.bDormant=Soldier.bDormant=Other.bDormant=Boss.bDormant=true;
        }
        if(Age==35)Checks(user);
    }
    void Formula(CaelumCombatActor body)
    {
        NPC.UpdateCombatHealthEffects();
        double a=NPC.CombatHealthPerformanceMultiplier,b=NPC.CombatHealthPainMultiplier;
        double c=NPC.CombatAdrenalineGainMultiplier,d=NPC.EffectiveCombatEvasionChance,e=NPC.Speed;
        int state=NPC.CombatHealthState;
        NPC.ReferenceHealth();
        Check(a==NPC.CombatHealthPerformanceMultiplier && b==NPC.CombatHealthPainMultiplier
            && c==NPC.CombatAdrenalineGainMultiplier && d==NPC.EffectiveCombatEvasionChance
            && e==NPC.Speed && state==NPC.CombatHealthState,"original formula exact outputs");
    }
    void Checks(CaelumPlayer user)
    {
        Check(NPC.CombatProfileInitialized && Soldier.CombatProfileInitialized && Boss.CombatProfileInitialized,"native profiles initialized");
        Port.RegisterAttacker(NPC);Port.RegisterAttacker(Boss);Soldier.Port=Port;
        Check(!CaelumSiegeFocus.ApplyToActor(NPC),"peaceful city excluded");
        Port.SiegeStarted=true;
        Check(CaelumSiegeFocus.ApplyToActor(NPC) && CaelumSiegeFocus.ApplyToActor(Soldier) && CaelumSiegeFocus.ApplyToActor(Boss),"registered attackers defenders and boss included");
        Check(!CaelumSiegeFocus.ApplyToActor(Other),"unregistered demon excluded");
        user.CurrentAdrenaline=0;user.UpdateHealthStateEffects();user.UpdateSurvivalStates();
        Check(user.CurrentAdrenaline==0,"city player excluded from maximum");
        user.DerivedStats.MaximumAdrenaline*=2;user.UpdateHealthStateEffects();
        Check(user.CurrentAdrenaline==0,"player maximum change does not refill reserve");
        user.DerivedStats.MaximumAdrenaline/=2;
        Check(NPC.CurrentCombatAdrenaline==NPC.MaximumCombatAdrenaline && Soldier.CurrentCombatAdrenaline==Soldier.MaximumCombatAdrenaline && Boss.CurrentCombatAdrenaline==Boss.MaximumCombatAdrenaline,"individual existing maxima");
        for(int density=0;density<2;density++)
        {
            CaelumPopulationState.Get().HighDensity=density==1;
            for(int patience=0;patience<3;patience++)
            {
                NPC.CombatPatience=patience*10;
                for(int hp=1;hp<=100;hp++)
                {NPC.health=Max(1,NPC.CombatMaximumHealth*hp/100);Formula(NPC);}
            }
            NPC.CurrentCombatAdrenaline=0;NPC.UpdateCombatHealthEffects();
            Check(NPC.CurrentCombatAdrenaline==NPC.MaximumCombatAdrenaline,"focus precedes cache dependency guard");
            NPC.MaximumCombatAdrenaline*=2;NPC.UpdateCombatHealthEffects();
            Check(NPC.CurrentCombatAdrenaline==NPC.MaximumCombatAdrenaline,"changed maximum refreshes immediately");
            NPC.MaximumCombatAdrenaline/=2;
            NPC.health=Max(1,NPC.CombatMaximumHealth/10);NPC.UpdateCombatHealthEffects();
            Check(NPC.CombatHealthState==CaelumConstants.HEALTH_STATE_BADLY_WOUNDED
                && NPC.CombatHealthPerformanceMultiplier==1 && NPC.CombatHealthPainMultiplier==1,"real injury retained without penalty");
            Port.Victory=true;NPC.CurrentCombatAdrenaline=0;NPC.UpdateCombatHealthEffects();
            Check(NPC.CombatHealthPerformanceMultiplier<1 && NPC.CombatHealthPainMultiplier>1,"victory exits focus and invalidates cached outcome");
            Port.Victory=false;
        }
        NPC.SiegeCombatant.Exited=true;Check(!CaelumSiegeFocus.ApplyToActor(NPC),"exited attacker excluded");NPC.SiegeCombatant.Exited=false;
        NPC.health=0;Check(!CaelumSiegeFocus.ApplyToActor(NPC),"dead actor excluded");
        NPC.health=NPC.CombatMaximumHealth;NPC.SiegeCombatant.ConfirmedDead=true;
        Check(CaelumSiegeFocus.ApplyToActor(NPC),"living resurrected member keeps focus despite death record");
        NPC.SiegeCombatant.ConfirmedDead=false;
        Port.RegisterAttacker(Other);Other.CurrentCombatAdrenaline=0;Other.UpdateCombatHealthEffects();
        Check(Other.CurrentCombatAdrenaline==Other.MaximumCombatAdrenaline,"late reinforcement adopts focus");
        NPC.CombatTimeRemaining=1;NPC.CurrentCombatAdrenaline=0;NPC.Tick();
        Check(NPC.CombatTimeRemaining<1 && NPC.CombatTimeRemaining>0 && NPC.CurrentCombatAdrenaline==NPC.MaximumCombatAdrenaline,"actor tic keeps combat timer and maximum");
        NPC.CombatTimeRemaining=0;NPC.Tick();Check(NPC.CurrentCombatAdrenaline==NPC.MaximumCombatAdrenaline,"no idle decay during active siege");
        Port.Victory=true;double before=NPC.CurrentCombatAdrenaline;NPC.Tick();
        Check(NPC.CurrentCombatAdrenaline<before,"normal decay resumes after victory");Port.Victory=false;
        user.AdrenalineResourceInitialized=true;user.CombatTimeRemaining=1;user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline/2;
        double playerReserve=user.CurrentAdrenaline;
        CaelumPlayerResources.UpdateAdrenalineDecay(user);
        Check(user.CombatTimeRemaining<1 && user.CurrentAdrenaline==playerReserve,"player combat timer holds earned reserve without refill");
        user.CombatTimeRemaining=0;CaelumPlayerResources.UpdateAdrenalineDecay(user);
        Check(user.CurrentAdrenaline<playerReserve,"ordinary player decay during active siege");
        user.SurvivalResourcesInitialized=true;user.CurrentHunger=user.CurrentThirst=CaelumConstants.SURVIVAL_MAXIMUM/2;
        double hunger=user.CurrentHunger,thirst=user.CurrentThirst;
        CaelumPlayerResources.UpdateSurvivalResources(user);
        Check(user.CurrentHunger<hunger && user.CurrentThirst<thirst,"needs still consumed");
        user.CurrentHunger=user.CurrentThirst=0;user.CurrentSleep=CaelumConstants.SURVIVAL_MAXIMUM;
        user.health=Max(2,user.CaelumMaximumHealth/4);user.player.health=user.health;
        user.CurrentAdrenaline=0;
        user.UpdateSurvivalStates();user.UpdateHealthStateEffects();
        Check(user.HungerState==CaelumConstants.SURVIVAL_STATE_CRITICAL && user.ThirstState==CaelumConstants.SURVIVAL_STATE_CRITICAL,"critical needs retained");
        Check(user.SurvivalPerformanceMultiplier<1 && user.HealthPerformanceMultiplier<1 && user.HealthPainMultiplier>1,"player ordinary needs wounds and pain penalties during siege");
        int hp=user.health;user.SurvivalDamageAccumulator=1;CaelumPlayerResources.ApplyCriticalSurvivalDamage(user);
        Check(user.health<hp,"critical starvation dehydration damage retained");
        Port.Victory=true;user.CurrentAdrenaline=0;user.UpdateSurvivalStates();user.UpdateHealthStateEffects();
        Check(user.SurvivalPerformanceMultiplier<1 && user.HealthPerformanceMultiplier<1,"player ordinary penalties resume outside active siege");
        user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline;before=user.CurrentAdrenaline;
        CaelumPlayerResources.UpdateAdrenalineDecay(user);Check(user.CurrentAdrenaline<before,"player ordinary decay after victory");
        Port.Victory=false;Port.args[3]=0;
        Check(!CaelumSiegeFocus.ApplyToActor(NPC),"non-city encounter excluded");
        Port.args[3]=1;
        NPC.ElementalStatus=new("CaelumElementalStatus");
        NPC.ElementalStatus.FreezeRemaining=10;NPC.ElementalStatus.FreezePowerPercent=50;
        let thermal=CaelumThermalBody.Get(NPC,true);thermal.Exposure=-100;
        NPC.UpdateCombatHealthEffects();
        Check(NPC.Speed==NPC.CombatBaseSpeed*CaelumThermalEffects.Speed(NPC)*0.5 && NPC.Speed<NPC.CombatBaseSpeed,"thermal and elemental movement penalties retained");
        NPC.CombatLucidityPhysicalStunRemaining=1;NPC.Vel=(3,0,0);NPC.Tick();
        Check(NPC.Vel.X==0 && NPC.Vel.Y==0 && NPC.CombatLucidityPhysicalStunRemaining>0 && NPC.CombatLucidityPhysicalStunRemaining<1,"stun immobilization and timer retained");
        NPC.ElementalStatus.FreezeRemaining=0;thermal.Exposure=0;
        double units=CaelumDemonService.Potion(NPC,0).Amount;
        NPC.CurrentCombatAnima=NPC.MaximumCombatAnima/2;double anima=NPC.CurrentCombatAnima;
        NPC.UpdateCombatResourceRecovery(false);
        Check(NPC.CurrentCombatAnima>anima && NPC.CurrentCombatAnima<NPC.MaximumCombatAnima,"individual active resource recovery retained");
        Check(CaelumDemonService.Potion(NPC,0).Amount==units,"focus does not refill finite inventory");
        ChannelChecks(user);
        Port.Destroy();Check(!CaelumSiegeFocus.ApplyToActor(NPC),"destroyed encounter stops NPC focus");
        Console.Printf("CA282 DONE passes=%d failures=%d",Passes,Failures);
    }
    void ChannelChecks(CaelumPlayer user)
    {
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
            if(item is "CaelumEquipmentItem" && CaelumEquipmentItem(item).EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
                CaelumEquipmentItem(item).Equipped=false;
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",user.Pos,NO_REPLACE));
        seal.PickupDataInitialized=seal.AcquisitionResolved=true;
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.ItemType=CaelumConstants.SEAL_FIRE;seal.Tier=1;seal.Equipped=true;seal.AttachToOwner(user);
        user.PainImmobilizationRemaining=user.LucidityPhysicalStunRemaining=0;
        user.CombatChannelModeActive=true;user.CombatChannelSealType=seal.ItemType;user.CombatChannelSealTier=seal.Tier;
        user.CombatChannelAdrenalinePerTic=user.GetSealChannelAdrenalinePerTic(seal.Tier);
        user.CurrentAdrenaline=0;user.UpdateSealChannel();
        Check(!user.CombatChannelModeActive && user.CurrentAdrenaline==0,"active siege does not fund an exhausted seal channel");
        user.CombatChannelModeActive=true;user.CurrentAdrenaline=user.CombatChannelAdrenalinePerTic*2;
        double reserve=user.CurrentAdrenaline;user.UpdateSealChannel();
        Check(user.CombatChannelModeActive && user.CurrentAdrenaline==reserve-user.CombatChannelAdrenalinePerTic,"active siege seal spends exact ordinary cost");
        user.UpdateSealChannel();user.UpdateSealChannel();
        Check(!user.CombatChannelModeActive && user.CurrentAdrenaline==0,"seal channel exhausts finite reserve during siege");
        user.CurrentAdrenaline=0;user.bInvulnerable=false;int hp=user.health;
        user.ReceiveCaelumDamage(null,null,5,'Drowning',DMG_FORCED,0);
        Check(user.health<hp,"first incoming resolved damage retained");
        Check(user.CurrentAdrenaline==0,"incoming resolved damage does not grant forced maximum");
        user.PainImmobilizationRemaining=user.LucidityPhysicalStunRemaining=0;
        user.StopSealChannel(false,false);Port.Victory=true;
        user.CombatChannelModeActive=true;user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline;
        user.UpdateSealChannel();
        Check(user.CurrentAdrenaline<user.DerivedStats.MaximumAdrenaline,"ordinary seal cost outside siege retained");
        user.StopSealChannel(false,false);Port.Victory=false;
    }
}

class CA361Port : CaelumPortSiege
{
    override void Tick() {}
}
