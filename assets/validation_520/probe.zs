class CA147Probe : StaticEventHandler
{
    bool Checked;
    ui bool MenusChecked;
    static void Check(bool ok,String label){Console.Printf("CA147 %s %s",ok?"PASS":"FAIL",label);}
    static ui void UCheck(bool ok,String label){Console.Printf("CA147 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {Checked=false;}
    override void WorldTick()
    {
        if(Checked)return;
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        Checked=true;let r=u.GetPersistentCharacterState(false);
        Check(r!=null && r.IdentityRevision==1,"identity revision initialized");
        Check(r.IdentityProfile==u.CharacterProfile && r.IdentityAllocation==u.CharacterAllocation,"record and body share the same identity objects");
        Check(CaelumCharacterIdentity.Profile(u)==u.CharacterProfile,"shared appearance/profile interface resolves saved character");
        let p=u.CharacterProfile;let a=u.CharacterAllocation;
        int h=u.health;double air=u.CurrentAir,anima=u.CurrentAnima,total=u.Attributes.GetTotalPrimaryLevels();
        for(int i=0;i<10;i++)CaelumCharacterIdentity.Ensure(u);
        Check(p==u.CharacterProfile && a==u.CharacterAllocation && h==u.health && air==u.CurrentAir && anima==u.CurrentAnima && total==u.Attributes.GetTotalPrimaryLevels(),"repeated migration changes no identity resources or bonuses");
        Check(!CVar.GetCVar('ca_newchar_ready',u.player).GetBool(),"loaded or created identity leaves no pending bridge");
        int race=p.Race,sex=p.Sex,profession=p.GetProfession();
        CVar.GetCVar('ca_newchar_ready',u.player).SetBool(true);
        CVar.GetCVar('ca_newchar_race',u.player).SetInt((race+1)%4);
        CVar.GetCVar('ca_newchar_sex',u.player).SetInt(1-sex);
        Check(!u.ConsumeNewCharacterDraft() && p.Race==race && p.Sex==sex && p.GetProfession()==profession,"global draft cannot overwrite a committed character");
        u.ClearNewCharacterDraftReady();
        let foreign=CaelumPersistentCharacterState(Actor.Spawn('CaelumPersistentCharacterState',u.Pos,NO_REPLACE));
        CaelumCharacterIdentity.Bind(u,foreign,true);
        Check(foreign.IdentityRevision==0 && p==u.CharacterProfile,"foreign unowned record rejected");foreign.Destroy();
        Check(CaelumPlayerAuthority.FromNetworkPlayer(-1)==null && CaelumPlayerAuthority.FromNetworkPlayer(MAXPLAYERS)==null && CaelumCharacterIdentity.Profile(null)==null,"invalid player endpoints do not fall back to local player");
        Check(u.bNoSkin,"global native skins cannot replace saved body presentation");
        Check(CaelumCharacterIdentity.VoiceSex(u)==sex && u.ResolvePlayerPainSound()==(sex==1?"caelum/player/pain_female":"caelum/player/pain_male"),"pain sound follows saved sex");
        Check(CaelumBreathing.Cue(u,CaelumThermalData.BREATHING_MODERATE)==(sex==1?"caelum/breathing/female":"caelum/breathing/male"),"breathing sound follows saved sex");
        u.A_StartSound(u.ResolvePlayerPainSound(),CHAN_VOICE);
        Check(u.IsActorPlayingSound(CHAN_VOICE,u.ResolvePlayerPainSound()),"saved voice plays on the native sound channel");
        // Exercise the inventory-only legacy path independently of native load.
        u.PersistCharacterState();r.IdentityRevision=0;r.IdentityProfile=null;r.IdentityAllocation=null;
        CaelumCharacterIdentity.Bind(u,r,false);
        bool restored=u.CharacterProfile.Race==p.Race && u.CharacterProfile.FirstClass==p.FirstClass
            && u.CharacterProfile.SecondClass==p.SecondClass && u.CharacterProfile.Sex==p.Sex && u.CharacterProfile.HeightChoice==p.HeightChoice;
        for(int i=0;i<4;i++)restored=restored && u.CharacterAllocation.LayerBonus[i]==a.LayerBonus[i];
        for(int i=0;i<12;i++)restored=restored && u.CharacterAllocation.AttributeBonus[i]==a.AttributeBonus[i];
        Check(restored && u.CharacterProfile==r.IdentityProfile && u.CharacterAllocation==r.IdentityAllocation,"inventory-only legacy record reconstructs every identity value");
        Check(h==u.health && air==u.CurrentAir && anima==u.CurrentAnima && total==u.Attributes.GetTotalPrimaryLevels(),"inventory-only migration does not recalculate or refill");
    }
    static ui int Count(Name menu,Name command)
    {
        let desc=OptionMenuDescriptor(MenuDescriptor.GetDescriptor(menu));if(desc==null)return -1;
        int count=0;
        for(int i=0;i<desc.mItems.Size();i++)
        {
            Name commandName;int parameter;[commandName,parameter]=desc.mItems[i].GetAction();
            if(commandName==command)count++;
        }
        return count;
    }
    override void UiTick()
    {
        if(MenusChecked)return;MenusChecked=true;
        let desc=OptionMenuDescriptor(MenuDescriptor.GetDescriptor('NewPlayerMenu'));
        bool clean=true;
        for(int i=0;i<desc.mItems.Size();i++)
        {
            let item=desc.mItems[i];
            if(item is 'OptionMenuItemPlayerClassItem' || item is 'OptionMenuItemPlayerSkinItem' || item is 'OptionMenuItemPlayerGenderItem' || item is 'OptionMenuItemPlayerColorItem' || item is 'OptionMenuItemPlayerColorSlider')clean=false;
        }
        UCheck(clean,"stock identity selectors removed before native option search");
        let controls=OptionMenuDescriptor(MenuDescriptor.GetDescriptor('CustomizeControls'));
        bool hidden=true;
        for(int i=0;i<controls.mItems.Size();i++)
        {
            let item=OptionMenuItem(controls.mItems[i]);
            if(item!=null && item.mLabel=="$CA_CONTROL_LEGACY_SECTION")hidden=false;
        }
        UCheck(hidden,"legacy binding import leaves no custom controls section");
        UCheck(Count('WeaponsControlMenu','+user1')==1 && Count('WeaponsControlMenu','+user2')==1 && Count('WeaponsControlMenu','+user3')==1 && Count('WeaponsControlMenu','+user4')==1,"four abilities occur once in native weapon controls");
        UCheck(Count('ActionControlsMenu','+moveup')==1 && Count('ActionControlsMenu','+movedown')==1,"flight retains native action controls");
        UCheck(Count('InventoryControlsMenu','ca_journal_toggle')==1 && Count('OtherControlsMenu','ca_time_skip')==1,"Journal and time skip use native categories");
        let creator=CaelumCharacterCreationMenu(new('CaelumCharacterCreationMenu'));
        creator.Confirmed=true;
        bool texts=true,combinations=true;
        for(int page=0;page<8;page++)
        {
            creator.Page=page;
            for(int choice=0;choice<(page==6?12:page==2?16:4);choice++)
            {
                creator.Race=choice%4;creator.FirstClass=choice/4;creator.SecondClass=choice%4;
                if(page==1)creator.FirstClass=choice;
                creator.SelectedLayer=choice%4;creator.SelectedAttribute=choice;
                if(creator.ContextKey()!="")texts=texts && creator.ContextText().IndexOf("CA_CREATE_")<0 && creator.ContextText().Length()>0;
                if(page==2)combinations=combinations && creator.CurrentChoice()!=creator.ProfessionKey(creator.SecondClass)
                    && CaelumCharacterProfile.ProfessionFor(creator.FirstClass,creator.SecondClass)==CaelumCharacterProfile.ProfessionFor(creator.SecondClass,creator.FirstClass);
            }
        }
        UCheck(texts,"race class family and twelve attribute descriptions resolve in current language");
        UCheck(combinations,"all sixteen ordered profession choices retain localized combined names");
        creator.Destroy();
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca147_settings")Menu.SetMenu("NewPlayerMenu");
        if(e.Name=="ca147_oldsettings")Menu.SetMenu("PlayerMenu");
        if(e.Name=="ca147_weapons")Menu.SetMenu("WeaponsControlMenu");
        if(e.Name=="ca147_inventory")Menu.SetMenu("InventoryControlsMenu");
        if(e.Name=="ca147_other")Menu.SetMenu("OtherControlsMenu");
        if(e.Name=="ca147_controls")Menu.SetMenu("CustomizeControls");
        if(e.Name=="ca147_actions")Menu.SetMenu("ActionControlsMenu");
    }
}
