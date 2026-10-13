// Isolated spawn/render diagnostic; never packaged in production.
class CA216Probe : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(u==null)return;
        if(e.Name=="c216_check")
        {
            let nodes=ThinkerIterator.Create("CaelumTutorialGoldVein");let chests=ThinkerIterator.Create("CaelumMainM00SupplyChest");
            bool ok=nodes.Next()==null && chests.Next()==null && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD,1)==2000;
            Console.Printf("CA216 %s depleted node/chest absent; exactly 2 kg retained",ok?"PASS":"FAIL");return;
        }
        if(e.Name=="c216_extract")
        {
            u.GetPersistentCharacterState(false).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
            let nodes=ThinkerIterator.Create("CaelumTutorialGoldVein");let node=CaelumTutorialGoldVein(nodes.Next());
            if(node==null){Console.Printf("CA216 FAIL missing initial node");return;}
            node.TryExtractResource(u,node.GetRequiredHarvestDamageType(),1000000,CaelumConstants.WEAPON_TYPE_PICKAXE);
            let drops=ThinkerIterator.Create("CaelumMaterialPickup");CaelumMaterialPickup drop;
            while((drop=CaelumMaterialPickup(drops.Next()))!=null)if(drop.Owner==null && drop.args[0]==CaelumConstants.MATERIAL_RAW_GOLD)
            {Actor receiver=u;drop.CallTryPickup(receiver);}
            Console.Printf("CA216 MINED units=%d",u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD,1));return;
        }
        if(e.Name!="c216_probe")return;
        let it=ThinkerIterator.Create("CaelumTutorialGoldVein");let gold=CaelumTutorialGoldVein(it.Next());
        Console.Printf("CA216 GOLD exists=%d",gold!=null);if(gold==null)return;
        Console.Printf("CA216 GOLD pos=%.2f,%.2f,%.2f floor=%.2f ceiling=%.2f alpha=%.2f units=%.2f",gold.Pos.X,gold.Pos.Y,gold.Pos.Z,gold.FloorZ,gold.CeilingZ,gold.Alpha,gold.ResourceRemainingUnits);
        u.CharacterCreationComplete=true;u.ApplyCharacterProfile();
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.bNOGRAVITY=true;
        u.SetOrigin(gold.Pos+(0,180,0),false);u.Angle=270;u.Pitch=0;
        let camera=Actor.Spawn("MapSpot",gold.Pos+(0,180,80),NO_REPLACE);camera.Angle=270;camera.Pitch=10;u.player.camera=camera;
        let all=ThinkerIterator.Create("Actor");Actor a;
        while((a=Actor(all.Next()))!=null)if(a.bSOLID && a.Pos.Z<0 && a.Pos.X>900 && a.Pos.X<2100 && a.Pos.Y>300 && a.Pos.Y<1400)
            Console.Printf("CA216 SOLID %s pos=%.1f,%.1f,%.1f radius=%.1f height=%.1f",a.GetClassName(),a.Pos.X,a.Pos.Y,a.Pos.Z,a.Radius,a.Height);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c216_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=="c216_done")Console.Printf("CA216 DONE failures=0");
    }
}
