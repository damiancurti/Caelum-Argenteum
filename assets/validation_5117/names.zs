// Native UI observation fixture; production item classes and pickup collision.
class CA169Names : EventHandler
{
    int Stage;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            u.Angle=0;u.Pitch=0;
            for(int size=0;size<3;size++)
                Actor.Spawn(CaelumPotionRules.ItemClass(CaelumPotionRules.Kind(0,size)),u.Pos+(64*(size+1),0,0),NO_REPLACE);
        }
        int requested=CVar.FindCVar('ca169_stage').GetInt();
        if(requested==Stage)return;Stage=requested;
        if(Stage>=1 && Stage<=3)
        {
            if(!u.EquipmentMenuOpen)u.ToggleEquipmentMenu();
            int kind=CaelumPotionRules.Kind(0,Stage-1);
            u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_CONSUMABLE;
            u.EquipmentSelectionConsumableType=kind;
            u.RefreshEquipmentSelectionPreview();
            let item=u.FindInventory(CaelumPotionRules.ItemClass(kind));
            Console.Printf("CA169 OBSERVED kind=%d item=%s count=%d name=%s",kind,
                CaelumPotionRules.ItemClass(kind),item!=null ? item.Amount : 0,
                StringTable.Localize(CaelumDisplayNames.GetConsumableKey(kind),false));
        }
    }
}
