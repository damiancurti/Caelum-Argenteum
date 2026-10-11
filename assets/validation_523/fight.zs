// Native racial breath/burn reproduction with stationary combatants.
class CA180Fight : EventHandler
{
    int Age, BeforeHealth;
    CaelumMandinga Emitter, Victim;
    bool SawBreath, SawBurn, SawInfight, Loaded;
    static void Check(bool ok,String label){Console.Printf("CA180 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete || Loaded)return;Age++;
        let r=u.GetPersistentCharacterState(true);
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);}
        if(Age==100)
        {
            u.SetOrigin((-2180,150,0),false);u.Vel=(0,0,0);u.bInvulnerable=true;
            Emitter=CaelumMandinga(Actor.Spawn("CaelumMandinga",(-2310,150,0),NO_REPLACE));
            Victim=CaelumMandinga(Actor.Spawn("CaelumMandinga",(-2250,150,0),NO_REPLACE));
            Emitter.bStandStill=true;Victim.bStandStill=true;
            Emitter.bDontThrust=true;Victim.bDontThrust=true;
            if(CVar.FindCVar('ca180_stage').GetInt()==2)
                for(int i=0;i<500;i++)
                {let n=CaelumMandinga(Actor.Spawn("CaelumMandinga",(600+(i%20)*32,600+(i/20)*32,0),NO_REPLACE));n.CaelumDiagnosticPassiveAI=true;n.bNoInteraction=true;}
        }
        if(Age==103)
        {
            Emitter.target=u;Victim.target=u;Emitter.Angle=0;Victim.Angle=0;
            Emitter.bQuickToRetaliate=true;Victim.bQuickToRetaliate=true;
            BeforeHealth=Victim.health;
            Check(!Victim.OkayToSwitchTarget(Emitter),"native retaliation rejects an allied Mandinga");
        }
        if(Age>=104 && Age<160)
        {
            Emitter.Vel=(0,0,0);Victim.Vel=(0,0,0);
            Victim.CurrentCombatAnima=0;Victim.threshold=0;
            SawBreath=SawBreath || Emitter.DemonBreath!=null;
            SawBurn=SawBurn || (Victim.ElementalStatus.BurnRemaining>0 && Victim.ElementalStatus.BurnSource==Emitter);
            SawInfight=SawInfight || Victim.target==Emitter;
        }
        if(Age==160)
        {
            Console.Printf("CA180 BREATH observed=%d burn=%d infight=%d health=%d before=%d",SawBreath,SawBurn,SawInfight,Victim.health,BeforeHealth);
            Check(SawBreath && SawBurn,"live paid racial breath applies its native burn to the ally");
            Check(Victim.health<BeforeHealth,"accidental allied fire still deals its existing damage");
            Check(!SawInfight && Victim.target==u,"burn ticks preserve the legitimate player target");
            if(CVar.FindCVar('ca180_stage').GetInt()==2)
                Check(CaelumPopulationState.Get().HighDensity,"same behavior runs with the automatic 500-combatant policy active");
            CaelumDemonService.StopBreath(Emitter);CaelumDemonService.StopBreath(Victim);
            Emitter.CaelumDiagnosticPassiveAI=true;Victim.CaelumDiagnosticPassiveAI=true;
            Emitter.ElementalStatus.BurnRemaining=0;Victim.ElementalStatus.BurnRemaining=0;
            // Preserve the target relationship for saving instead of allowing
            // empty-Anima recovery AI or native state actions to replace it.
            Emitter.CurrentCombatAnima=Emitter.MaximumCombatAnima;
            Victim.CurrentCombatAnima=Victim.MaximumCombatAnima;
            Emitter.CurrentCombatAir=Emitter.MaximumCombatAir;
            Victim.CurrentCombatAir=Victim.MaximumCombatAir;
            Emitter.RecoveryPhase=0;Victim.RecoveryPhase=0;
            Emitter.tics=-1;Victim.tics=-1;
            // This pair models an already ongoing fight in an older save.
            Emitter.target=Victim;Victim.target=Emitter;Emitter.lastenemy=Victim;Victim.lastenemy=Emitter;
        }
        if(Age==165 && CVar.FindCVar('ca180_stage').GetInt()!=0)
        {
            Check(Emitter.target!=Victim && Victim.target!=Emitter && Victim.lastenemy!=Emitter,"existing accidental targets and remembered enemies are discarded");
            Victim.target=null;Victim.threshold=0;
            int burnDamage=Max(1,Victim.ElementalStatus.BurnDamagePerSecond);
            Console.Printf("CA180 ENEMY_CHECK damage=%d playerAllowed=%d",burnDamage,Victim.OkayToSwitchTarget(u));
            Victim.DamageMobj(null,u,burnDamage,'CaelumElementalDOT',DMG_NO_ARMOR,0);
            Check(Victim.target==u,"native player damage still provokes retaliation");
            Emitter.bFriendly=true;Victim.target=null;Victim.threshold=0;
            Victim.DamageMobj(null,Emitter,burnDamage,'CaelumElementalDOT',DMG_NO_ARMOR,0);
            Check(Victim.target==Emitter,"opposing native allegiance remains a valid enemy");
            Emitter.bFriendly=false;Emitter.ChangeTID(7001);Victim.ChangeTID(7002);
            Level.ExecuteSpecial(177,Victim,null,false,7002,7001,6);
            Victim.target=null;Victim.threshold=0;
            Check(Victim.OkayToSwitchTarget(Emitter),"explicit scripted hatred remains authoritative");
            Console.Printf("CA180 DONE");
        }
    }
}
class CA180FightObserver : StaticEventHandler
{
    int Age, Health;
    bool Loaded;
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let f=CA180Fight(EventHandler.Find("CA180Fight"));if(f==null)return;
        Loaded=true;f.Loaded=true;Health=f.Victim.health;
        CA180Fight.Check(f.Emitter.target==f.Victim && f.Victim.target==f.Emitter,"baseline save really contains mutual accidental hostility");
    }
    override void WorldTick()
    {
        if(!Loaded)return;Age++;if(Age!=3)return;
        let f=CA180Fight(EventHandler.Find("CA180Fight"));
        CA180Fight.Check(f.Emitter.target!=f.Victim && f.Victim.target!=f.Emitter,"old save clears allied fight without respawning either actor");
        CA180Fight.Check(f.Victim.health==Health,"old-save target repair does not heal the damaged actor");
        Console.Printf("CA180 DONE");
    }
}
