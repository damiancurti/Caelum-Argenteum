// Guardado auténtico con la versión anterior, sin clases nuevas del selector.
class CA282Probe : StaticEventHandler
{
    override void UiTick()
    {if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c282_seed")
        {
            let user=CaelumPlayer(players[consoleplayer].mo);
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();
            user.GrantMagicBoxFromPalomo(false);user.bInvulnerable=true;
            user.CurrentSleep=user.CurrentLucidity=100;
            for(Inventory item=user.Inv;item!=null;)
            {Inventory next=item.Inv;if(item is "CaelumConsumableItem" || item is "CaelumCarbineAmmo")item.Destroy();item=next;}
            let food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation'));food.AttachToOwner(user);food.Amount=3;
            let life=CaelumConsumableItem(Actor.Spawn('CaelumLifePotion'));life.AttachToOwner(user);life.Amount=2;life.InMagicBox=true;
            let water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenNormal'));water.AttachToOwner(user);water.WaterLiters=1.5;
            user.InvSel=life;user.InvFirst=life;user.OnNativeInventoryChanged();
            Console.Printf("CA282 legacy seed boxed-selection=%d old-water-hidden=%d",user.InvSel==life,!water.bInvBar);
        }
        if(e.Name=="c282_done")Console.Printf("CA282 DONE passes=0 failures=0");
    }
}
