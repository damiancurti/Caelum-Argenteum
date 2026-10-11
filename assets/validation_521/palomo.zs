class CA177Palomo : StaticEventHandler
{
    int Age;
    ui int Step, WaitTicks;
    static ui void Check(bool ok,String label){Console.Printf("CA177 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(true);
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);}
        if(Age!=100)return;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
        let p=CA177Route.Palomo(u);CA177Route.EndTalk(u);
        CaelumMainM00Loadout.Refresh(u);
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,p,null,false,0,43630);
        p.StartConversation(u,true,true);
    }
    ui bool Select(CaelumHistoryConversationMenu menu,String key)
    {
        int original=0;
        for(let reply=menu.mCurNode.Children;reply!=null;reply=reply.Next)
        {
            if(reply.Reply==key)
            {
                for(int i=0;i<menu.ReplyMap.Size();i++)if(menu.ReplyMap[i]==original)
                {menu.mSelection=i;menu.MenuEvent(Menu.MKEY_Enter,false);return true;}
                for(int i=0;i<menu.ReplyMap.Size();i++)if(menu.ReplyMap[i]==menu.MORE)
                {menu.mSelection=i;menu.MenuEvent(Menu.MKEY_Enter,false);return false;}
                Check(false,"requested Palomo action is reachable");return false;
            }
            original++;
        }
        Check(false,"requested Palomo action exists");return false;
    }
    override void UiTick()
    {
        if(Age<100 || Step>=5)return;
        let m=CaelumHistoryConversationMenu(Menu.GetCurrentMenu());if(m==null || m.mCurNode==null)return;
        WaitTicks++;if(WaitTicks<12)return;WaitTicks=0;
        if(Step==0)
        {Check(m.mCurNode.Children.Reply=="$CA_LOADOUT_WEAPON","weapons are the first plan option");if(Select(m,"$CA_LOADOUT_OPTIONAL_PLAN"))Step++;}
        else if(Step==1)
        {Check(m.mCurNode.Children.Reply=="$CA_LOADOUT_ARMOR","necklace is no longer first in optional equipment");if(Select(m,"$CA_LOADOUT_SKIP"))Step++;}
        else if(Step==2){if(Select(m,"$CA_LOADOUT_WEAPON"))Step++;}
        else if(Step==3){if(Select(m,"$CA_M01_FAMILY_3"))Step++;}
        else
        {
            Check(m.mCurNode.Children.Reply=="$CA_M01_WEAPON_OPTION_12","native ranged family opens the shotgun entry");
            let u=CaelumPlayer(m.mPlayer.mo);
            String name=CaelumMainM00StarterRules.GetName(12);
            Console.Printf("CA177 PALOMO name=%s option=%s preview=%s",name,StringTable.Localize("CA_M01_WEAPON_OPTION_12",false),u.MainM00LoadoutDescriptions[12]);
            Check(CaelumMainM00StarterRules.GetWeaponType(12)==CaelumConstants.WEAPON_TYPE_SHOTGUN,"Palomo option resolves to the existing shotgun catalogue");
            Console.Printf("CA177 PALOMO_DONE");Step=5;
        }
    }
}
