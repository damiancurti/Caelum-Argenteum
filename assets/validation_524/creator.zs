// Native MenuEvent and session-draft regression, independent of play mutation.
class CA183Creator : StaticEventHandler
{
    ui int SavedAttribute, SavedValue;
    static ui void Check(bool ok,String label){Console.Printf("CA183 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca183_creator")return;
        if(e.Args[0]==0){Menu.SetMenu("CaelumNewCharacterMenu");}
        if(e.Args[0]==3){Menu.SetMenu("CaelumNewCharacterMenu");}
        let m=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());if(m==null)return;
        if(e.Args[0]==0)
        {
            Check(m.RemainingLayerPoints()==0 && m.RemainingAttributePoints()==0,"new draft starts with editable 4/30 recommendation");
            m.MenuEvent(Menu.MKEY_Enter,false);
            Console.Printf("CA183 ACTIVITY %s",m.CurrentChoice());
        }
        if(e.Args[0]==1)
        {
            m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Enter,false);
            while(m.SecondClass!=1)m.MenuEvent(Menu.MKEY_Right,false);
            Console.Printf("CA183 PROFESSION %s",m.CurrentChoice());
            Check(m.CurrentChoice()!=m.ProfessionKey(m.SecondClass),"combined identical specialization is localized");
        }
        if(e.Args[0]==2)
        {
            for(int i=0;i<4;i++)m.MenuEvent(Menu.MKEY_Enter,false);
            Check(m.Page==CaelumConstants.CREATION_PAGE_ATTRIBUTES,"native navigation reaches attributes");
            for(int i=0;i<12;i++)if(m.AttributeBonus[i]>0){m.SelectedAttribute=i;break;}
            SavedAttribute=m.SelectedAttribute;SavedValue=m.AttributeBonus[SavedAttribute]-1;
            m.MenuEvent(Menu.MKEY_Left,false);
            Check(m.RemainingAttributePoints()==1,"recommendation can be edited manually");
            m.MenuEvent(Menu.MKEY_Back,false);m.MenuEvent(Menu.MKEY_Enter,false);
            Check(m.AttributeBonus[SavedAttribute]==SavedValue && m.RemainingAttributePoints()==1,"back/forward preserves manual edit");
            m.Close();
        }
        if(e.Args[0]==3)
        {
            Check(m.AttributeBonus[SavedAttribute]==SavedValue && m.RemainingAttributePoints()==1,"close/reopen preserves manual draft");
            m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Enter,false);
            Check(m.RemainingLayerPoints()==0 && m.RemainingAttributePoints()==0,"manual refund restores exact budgets");
            Console.Printf("CA183 CREATOR_DONE");
        }
        if(e.Args[0]==4)
        {
            m.ConfirmAndStart();Check(Menu.GetCurrentMenu()!=m,"recommended and manually edited character can start");
        }
    }
}
