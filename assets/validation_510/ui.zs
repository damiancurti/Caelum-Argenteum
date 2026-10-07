// UI-scope fixture opens the shipped journal page without mutating game state.
class CA130UI : StaticEventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        let journal=CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));
        if(journal!=null)journal.ThermalDetailsOpen=true;
    }
}
