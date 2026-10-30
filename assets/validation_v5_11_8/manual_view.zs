// Reuse the established handoff behavior: dismiss only the initial tutorial
// conversation so it cannot cover the short native movement demonstration.
class CA586ManualView : EventHandler
{
    override void UiTick()
    {
        if(level.time>100)return;
        let menu=Menu.GetCurrentMenu();
        if(ConversationMenu(menu)!=null)menu.MenuEvent(Menu.MKEY_Back,false);
    }
}
