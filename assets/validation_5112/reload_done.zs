class CA158ReloadDone : StaticEventHandler
{
    int Elapsed;
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);
        bool valid=u.CraftingSelectionSize==4 && !u.CraftingTaskActive && r.MainM00StarterWeaponId>0 && r.MainM00ShieldCrafted;
        Console.Printf("CA158 %s completed save keeps XL and both quest items",valid?"PASS":"FAIL");
    }
}
