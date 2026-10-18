// Isolated #321 UI assertions through the real console command/binding tables.
class CA321Probe : CA282Probe
{
    ui int UIPassed,UIFailed;
    ui void UIAssert(bool ok,String label)
    {if(ok)UIPassed++;else UIFailed++;Console.Printf("CA282 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c321_hidden")
            UIAssert(automapactive && !CaelumCartography.LegendExpanded(),"automap legend hidden by default");
        if(e.Name=="c321_visible")
            UIAssert(automapactive && CaelumCartography.LegendExpanded(),"native legend command expands help");
        if(e.Name=="c321_text")
        {
            String wanted=CVar.FindCVar("language").GetString()=="es"?"Leyenda [%s]":"Legend [%s]";
            UIAssert(CaelumCartography.LegendHint()==String.Format(wanted,CaelumCartography.Keys("ca_map_legend")),"hint uses configured language");
        }
        if(e.Name=="c321_rebind")
            UIAssert(CaelumCartography.Keys("ca_map_legend")~=="F9","hint reads current rebound key");
        if(e.Name=="c321_unbound")
            UIAssert(CaelumCartography.Keys("ca_map_legend")==StringTable.Localize("CA_INTRO_UNBOUND",false),"cleared binding remains unbound");
        if(e.Name=="c321_shadowed")
            UIAssert(CaelumCartography.Keys("ca_map_legend")==StringTable.Localize("CA_INTRO_UNBOUND",false),"automap command shadowing is reflected in hint");
        if(e.Name=="c321_done")Console.Printf("CA282 DONE passes=%d failures=%d",UIPassed,UIFailed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c321_manual"){Setup();Manual=true;}
    }
}
