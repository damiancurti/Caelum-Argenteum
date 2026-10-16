// Prueba técnica de APIs nativas; no define balance ni reglas de Redención.
class CA250ProbeBody : CaelumMandinga { override void Tick(){} }
class CA250ProbeMemory : Inventory
{
    int Marker;
    Default {Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA250ResurrectionProbe : StaticEventHandler
{
    CaelumPlayer User;
    CA250ProbeBody Body;
    int Passed,Failed,Total;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA250 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Setup()
    {
        User=CaelumPlayer(players[0].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.bInvulnerable=true;User.SetOrigin((0,0,0),false);
        Body=CA250ProbeBody(Actor.Spawn("CA250ProbeBody",(160,0,0),NO_REPLACE));
        let memory=CA250ProbeMemory(Body.GiveInventoryType("CA250ProbeMemory"));memory.Marker=250;
    }
    void KillNPC()
    {
        Body.DamageMobj(User,User,10000000,'None',DMG_FORCED,0);
        Check(Body.health<=0 && Body.bCorpse,"native death leaves the original NPC corpse");
        Total=level.total_monsters;
    }
    void RaiseNPC()
    {
        Check(!Body.CanRaise(),"ordinary project corpse has no native Raise animation");
        let memory=CA250ProbeMemory(Body.FindInventory("CA250ProbeMemory"));
        Check(memory!=null && memory.Marker==250,"owned custom state survives native death");
        double deadHeight=Body.Height;
        Body.Revive();
        Check(Body.health>0 && !Body.bCorpse && !Body.bKilled,"direct native Revive works without Raise animation");
        Check(Body.Height==deadHeight && Body.Height<GetDefaultByType("CA250ProbeBody").Height,"native actor revival needs explicit full-height restoration");
        Check(level.total_monsters==Total+1,"native revival increments monster total");
        level.total_monsters=Total;
        let shape=GetDefaultByType(Body.GetClass());Body.A_SetSize(shape.Radius,shape.Height);
        Body.health=Body.CombatMaximumHealth;
        Body.CurrentCombatAnima=Body.MaximumCombatAnima;Body.CurrentCombatAir=Body.MaximumCombatAir;
        Body.CurrentCombatLucidity=CaelumConstants.MAXIMUM_LUCIDITY;
        Body.ElementalStatus=new("CaelumElementalStatus");Body.SetStateLabel("Spawn");
        Check(Body.TestMobjLocation() && Body.DemonDeathLootReleased,"restored body fits and retains consumed-loot latch");
        Check(CA250ProbeMemory(Body.FindInventory("CA250ProbeMemory"))==memory,"native revival preserves exact inventory identity");
        Body.Destroy();
    }
    void KillPlayer()
    {
        User.bInvulnerable=false;
        let memory=CA250ProbeMemory(User.GiveInventoryType("CA250ProbeMemory"));memory.Marker=251;
        User.DamageMobj(null,null,10000000,'None',DMG_FORCED,0);
        Check(User.health<=0 && User.player.playerstate==PST_DEAD,"native player enters actual dead state");
    }
    void RaisePlayer()
    {
        let saved=User;let profile=User.CharacterProfile;
        Check(User.player.Resurrect(),"native PlayerInfo resurrection succeeds");
        Check(players[0].mo==saved && User.CharacterProfile==profile && User.player.playerstate==PST_LIVE,"player resurrection retains pawn and character identity");
        User.health=User.player.health=User.CaelumMaximumHealth;
        User.CurrentAnima=User.DerivedStats.MaximumAnima;User.CurrentAir=User.DerivedStats.MaximumAir;
        User.CurrentLucidity=CaelumConstants.MAXIMUM_LUCIDITY;
        User.ElementalStatus=new("CaelumElementalStatus");User.bInvulnerable=true;
        let memory=CA250ProbeMemory(User.FindInventory("CA250ProbeMemory"));
        Check(memory!=null && memory.Marker==251,"player inventory survives death and resurrection");
        Check(User.TestMobjLocation() && User.Height==GetDefaultByType("CaelumPlayer").Height,"native player resurrection restores full collision height");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c250_setup")Setup();
        else if(e.Name=="c250_kill_npc")KillNPC();
        else if(e.Name=="c250_raise_npc")RaiseNPC();
        else if(e.Name=="c250_kill_player")KillPlayer();
        else if(e.Name=="c250_raise_player")RaisePlayer();
        else if(e.Name=="c250_done")Console.Printf("CA250 DONE failures=%d passed=%d",Failed,Passed);
    }
}
