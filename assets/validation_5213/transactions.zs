class CA148Transactions : StaticEventHandler
{
    int Failures;
    ui CaelumAppearanceMenu Retained;
    ui int UIFailures;
    ui void UCheck(bool ok,String label)
    {if(!ok)UIFailures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label);}
    void Check(bool ok,String label)
    { if(!ok)Failures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label); }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca148_baseline" || e.Name=="ca148_verify" || e.Name=="ca148_mutate" || e.Name=="ca148_swap")
            EventHandler.SendNetworkEvent(e.Name,e.Args[0]);
        if(e.Name=="ca148_cancel" || e.Name=="ca148_confirm")
        {
            Menu.SetMenu("CaelumAppearanceMenu");
            let menu=CaelumAppearanceMenu(Menu.GetCurrentMenu());
            if(menu==null){Console.Printf("CA148 FAIL editor did not open");return;}
            let saved=CaelumCharacterIdentity.Profile(menu.EditSubject);
            int oldTone=saved.SkinTone,oldForm=saved.BeastForm;
            menu.SkinTone=1;menu.BeastForm=0;
            UCheck(saved.SkinTone==oldTone && saved.BeastForm==oldForm,"preview edits stay in UI draft");
            menu.MenuEvent(e.Name=="ca148_cancel"?Menu.MKEY_Back:Menu.MKEY_Enter,false);
        }
        if(e.Name=="ca148_stale")EventHandler.SendNetworkEvent("ca_appearance_commit",2,3,0);
        if(e.Name=="ca148_hold")
        {
            Menu.SetMenu("CaelumAppearanceMenu");Retained=CaelumAppearanceMenu(Menu.GetCurrentMenu());
            Retained.SkinTone=2;Retained.BeastForm=3;
        }
        if(e.Name=="ca148_retained")
        {
            UCheck(!(Menu.GetCurrentMenu() is 'CaelumAppearanceMenu'),"appearance editor closed on load");
            Console.Printf("CA148 retained reference cleared=%d",Retained==null);
            if(Retained!=null)Retained.MenuEvent(Menu.MKEY_Enter,false);
        }
        if(e.Name=="ca148_replaced")
        {
            UCheck(Retained!=null && Retained.EditSubject==players[0].mo
                && Retained.EditProfile!=CaelumCharacterIdentity.Profile(Retained.EditSubject),
                "editor still targets same pawn but previous profile with equal serial");
            if(Retained!=null)Retained.MenuEvent(Menu.MKEY_Enter,false);
        }
        if(e.Name=="ca148_invalid")EventHandler.SendNetworkEvent("ca_appearance_commit",999,0,1);
        if(e.Name=="ca148_done")Console.Printf("CA148 DONE failures=%d",Failures+UIFailures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);
        let profile=CaelumCharacterIdentity.Profile(user);
        if(e.Name=="ca148_baseline")
        {
            profile.Race=CaelumConstants.RACE_BEAST_MAN;profile.Sex=CaelumConstants.SEX_FEMALE;
            profile.SkinTone=2;profile.BeastForm=3;profile.AppearanceEditSerial=0;
            user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            Console.Printf("CA148 baseline race=%d sex=%d profession=%d size=%d",profile.Race,profile.Sex,profile.GetProfession(),profile.GetSizeTier());
        }
        if(e.Name=="ca148_mutate")
        { profile.SkinTone=0;profile.BeastForm=2;user.UpdateWorldCarbineVisual(); }
        if(e.Name=="ca148_swap")
        {
            let replacement=new("CaelumCharacterProfile");replacement.CopyFrom(profile);
            user.CharacterProfile=replacement;user.GetPersistentCharacterState(false).IdentityProfile=replacement;
        }
        if(e.Name=="ca148_verify")
        {
            int expectedTone=e.Args[0]==0?2:e.Args[0]==2?0:1;
            int expectedForm=e.Args[0]==0?3:0;
            Check(profile.SkinTone==expectedTone && profile.BeastForm==expectedForm,
                String.Format("appearance expected tone=%d form=%d on %s",expectedTone,expectedForm,level.MapName));
            Check(profile.Race==CaelumConstants.RACE_BEAST_MAN && profile.Sex==CaelumConstants.SEX_FEMALE,
                "cosmetic operation preserves saved race/sex");
            Check(profile.AppearanceRevision==1,"appearance schema initialized idempotently");
            Check(user.CharacterProfile==user.GetPersistentCharacterState(false).IdentityProfile,
                "loaded/travelled pawn retains one authoritative profile");
            if(e.Args[0]==1)Check(profile.AppearanceEditSerial==1,"exactly one confirmed cosmetic commit");
            user.UpdateWorldCarbineVisual();
            Check(user.sprite==CaelumAppearance.SpriteFor(profile.Race,profile.Sex,profile.BeastForm,profile.SkinTone,
                CaelumAppearance.PoseFor(user.CurState.sprite,user.CurState.Frame),user.AppearanceHasGloves),"actual sprite agrees with saved appearance");
        }
    }
}
