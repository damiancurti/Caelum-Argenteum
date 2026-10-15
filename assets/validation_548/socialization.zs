// Escenario aislado con actores, páginas, opciones y acciones USDF reales.
class CA240Probe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumAnchoredResident Speaker;
    int Passed,Failed,LastChance,LastRoll;
    double BeforeAnima;
    bool Pin,Manual;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA240 %s %s",ok?"PASS":"FAIL",label);}
    void Stats()
    {
        User.Attributes.Eloquence=4;User.Attributes.Charisma=0;User.Attributes.Empathy=0;
        User.DerivedStats.DialogueSkillPercent=CaelumGrowthRules.Bonus(4);
        User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.AnimaRegenerationPerSecond=0;User.DerivedStats.HealthRegenerationPerSecond=0;
    }
    void Reset()
    {
        CaelumRacialAbilityRules.Deactivate(User);CaelumSocialization.Clear(User);
        if(User.player.ConversationNPC!=null)User.player.ConversationNPC.bInConversation=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        if(Speaker!=null)Speaker.Destroy();
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.CurrentAnima=1000;User.CurrentAir=1000;User.CurrentSleep=100;User.CurrentLucidity=100;
        User.health=User.CaelumMaximumHealth;User.player.health=User.health;User.player.playerstate=PST_LIVE;
        User.bInvulnerable=true;User.LucidityPhysicalStunRemaining=0;User.PainImmobilizationRemaining=0;
        User.RacialAbilityInputLatched=false;User.EquipmentMenuOpen=false;User.CombatChannelModeActive=false;
        CaelumClassAbilityRules.Cancel(User);CaelumSleepRules.Wake(User);Pin=true;Stats();
        let r=User.GetPersistentCharacterState(true);r.EnsureMainM00SocialState();
        r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED);
        r.SeenDialogueKeys.Clear();
        for(int i=0;i<CaelumConstants.MAIN_M00_RESIDENT_COUNT;i++)
        {r.MainM00SocialResult[i]=CaelumConstants.MAIN_M00_SOCIAL_UNTRIED;r.MainM00SocialAdvice[i]=false;r.MainM00SocialChance[i]=0;r.MainM00SocialRoll[i]=0;
         r.MainM00ResidentMet[i]=false;r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RULO_CONVINCED+i]=false;}
        CaelumMainM00SocialDialogue.Sync(User);BeforeAnima=User.CurrentAnima;
    }
    void Activate()
    {Check(CaelumRacialAbilityRules.Begin(User),"real Human factory admits effect");CaelumRacialAbilityRules.Advance(User);}
    void Contracts()
    {
        Reset();double labia=CaelumMainM00SocialDialogue.GetLabia(User);
        int emotion=CaelumMainM00SocialDialogue.GetChance(User,0);
        Check(Abs(labia-0.928)<1e-8,"inactive current Dialogue value");
        Check(CaelumMainM00SocialDialogue.GetChance(User,2)==83,"inactive Persuasion with existing rounding");
        Activate();Check(Abs(User.CurrentAnima-(1000-10.0/35))<1e-7,"ten Anima per second paid by shared clock");
        Check(Abs(CaelumMainM00SocialDialogue.GetLabia(User)-labia*2)<1e-8,"current Dialogue doubled across threshold");
        Check(CaelumMainM00SocialDialogue.GetChance(User,2)==100,"Persuasion doubled before current cap");
        Check(CaelumMainM00SocialDialogue.GetChance(User,0)==emotion,"Emotion unchanged");
        User.DerivedStats.DialogueSkillPercent=12;
        Check(CaelumSocialization.Dialogue(User)==24,"existing Dialogue modifiers are multiplied");
        User.RefreshPalomoDiscountOdds();Check(User.PalomoDiscountChancePercent==48,"existing Palomo Dialogue probability consumer receives the skill");
        User.DerivedStats.DialogueSkillPercent=30;User.RefreshPalomoDiscountOdds();
        Check(User.PalomoDiscountChancePercent==100 && User.PalomoDiscountAutomaticSuccess,"existing Palomo success cap retained");
        User.DerivedStats.AnimaCostReductionPercent=50;
        Check(Abs(CaelumRacialAbilityRules.TicCost(User,User.RacialAbility)-5.0/35)<1e-8,"normal cost modifier once");
        CaelumRacialAbilityRules.Deactivate(User);Stats();
        Check(Abs(CaelumMainM00SocialDialogue.GetLabia(User)-labia)<1e-8 && CaelumMainM00SocialDialogue.GetChance(User,2)==83,"ending effect restores live values without attribute mutation");
        User.CurrentAnima=0.01;Check(!CaelumRacialAbilityRules.Begin(User) && User.CurrentAnima==0.01,"unaffordable first tic spends nothing");
        Reset();Activate();User.PainImmobilizationRemaining=1;CaelumRacialAbilityRules.Guard(User);
        Check(!CaelumSocialization.Active(User),"immobilization turns effect off");
        Reset();User.CurrentAnima=0.3;Activate();double remainder=User.CurrentAnima;
        CaelumRacialAbilityRules.Advance(User);
        Check(!CaelumSocialization.Active(User) && User.CurrentAnima==remainder,"sub-second admission preserves final unpaid fraction");
    }
    void Open(int resident)
    {
        if(User.player.ConversationNPC!=null)User.player.ConversationNPC.bInConversation=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;CaelumSocialization.Clear(User);
        if(Speaker!=null)Speaker.Destroy();
        Speaker=CaelumAnchoredResident(Actor.Spawn(resident==1?"CaelumRonnie":"CaelumCaella",(96,0,0),NO_REPLACE));
        Speaker.args[0]=CaelumConstants.STORY_NPC_ANCHORED;Speaker.StoryAnchored=true;
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;
        User.GetPersistentCharacterState(true).RecordMainM00ResidentMet(resident);
        CaelumMainM00SocialDialogue.Sync(User);
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,Speaker,null,false,0,CaelumMainM00SocialDialogue.GetConversationId(resident));
        Check(Speaker.StartConversation(User,false,false),"real resident native conversation opens");BeforeAnima=User.CurrentAnima;
    }
    override void WorldTick()
    {User=CaelumPlayer(players[0].mo);if(Pin && User!=null && User.DerivedStats!=null)Stats();}
    override bool InputProcess(InputEvent e)
    {
        if(!Manual || e.Type!=InputEvent.Type_KeyDown)return false;
        if(e.KeyScan==InputEvent.Key_F6 || e.KeyScan==InputEvent.Key_F7)
        {
            let menu=Menu.GetCurrentMenu();if(menu!=null)menu.Close();
            EventHandler.SendNetworkEvent("c240_seed",e.KeyScan==InputEvent.Key_F6?1:2);return true;
        }
        if(e.KeyScan==InputEvent.Key_F8){EventHandler.SendNetworkEvent("c240_low");return true;}
        return false;
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        String info=String.Format("Socializacion %s | Anima %.1f | Labia %.3f",CaelumSocialization.Active(user)?"ON":"OFF",user.CurrentAnima,CaelumSocialization.Dialogue(user));
        Screen.DrawText(SmallFont,Font.CR_WHITE,8,8,info,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,8,20,"F apagar | F6 Ronnie | F7 Caella | F8 agotar Anima",DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        let menu=Menu.GetCurrentMenu();
        if(e.Name=="c240_manual")
        {
            if(menu!=null)menu.Close();
            EventHandler.SendNetworkEvent("c240_seed",e.Args[0]);return;
        }
        if(e.Name=="c240_close" && menu!=null){menu.MenuEvent(Menu.MKEY_Back,false);return;}
        if(e.Name=="c240_reply" && menu!=null)
        {for(int i=0;i<e.Args[0];i++)menu.MenuEvent(Menu.MKEY_Down,false);menu.MenuEvent(Menu.MKEY_Enter,false);}
        if(e.Name=="c240_stop")
        {
            let handler=CaelumDialogueHistory(StaticEventHandler.Find("CaelumDialogueHistory"));
            Array<int> keys;Bindings.GetAllKeysForCommand(keys,"+user1");
            if(handler!=null && keys.Size()>0)
            {handler.SocialKey(InputEvent.Type_KeyDown,keys[0]);handler.SocialKey(InputEvent.Type_KeyUp,keys[0]);}
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c240_setup")Reset();
        if(e.Name=="c240_seed")
        {
            Manual=true;Reset();Activate();Open(e.Args[0]);
            Console.Printf("CA240 DONE failures=0 MANUAL_SEED_ONLY");
        }
        if(e.Name=="c240_contract")Contracts();
        if(e.Name=="c240_on")Check(CaelumSocialization.Active(User),"native User1 or hub retains active Human power");
        if(e.Name=="c240_off")Check(!CaelumSocialization.Active(User),"native stop/exhaustion ends live power");
        if(e.Name=="c240_open")Open(e.Args[0]);
        if(e.Name=="c240_ronnie")
        {
            Check(Abs(CaelumMainM00SocialDialogue.GetLabia(User)-0.928*e.Args[0])<1e-8,"Ronnie uses displayed multiplier until conversation closes");
            Console.Printf("CA240 STATE map=%s anchored=%d conversation=%d health=%d recruitment=%d",level.MapName,Speaker!=null && Speaker.StoryAnchored,User.HasActiveConversation(),User.health,User.GetPersistentCharacterState(true).IsMainM00RecruitmentActive());
        }
        if(e.Name=="c240_drain")Check(User.CurrentAnima<BeforeAnima-10 && User.HasActiveConversation(),"real unpaused conversation continues paid drain");
        if(e.Name=="c240_ronnie_won")Check(User.GetPersistentCharacterState(true).IsMainM00ResidentConvinced(1),"real native Ronnie choice accepts retained boosted threshold");
        if(e.Name=="c240_caella")Check(CaelumMainM00SocialDialogue.GetChance(User,2)==e.Args[0],"Caella visible probability retains its multiplier");
        if(e.Name=="c240_low")User.CurrentAnima=0.01;
        if(e.Name=="c240_caella_won")
        {
            let r=User.GetPersistentCharacterState(true);LastChance=r.MainM00SocialChance[2];LastRoll=r.MainM00SocialRoll[2];
            Check(r.IsMainM00ResidentConvinced(2) && LastChance==100 && LastRoll==0,"real native Caella choice retains capped certainty without RNG");
        }
        if(e.Name=="c240_reroll")
        {
            let r=User.GetPersistentCharacterState(true);
            Check(!CaelumMainM00SocialDialogue.Attempt(User,2) && r.MainM00SocialChance[2]==LastChance && r.MainM00SocialRoll[2]==LastRoll,"resolved social attempt cannot reroll");
        }
        if(e.Name=="c240_loaded")
        {Pin=true;Stats();Check(User.HasActiveConversation() && User.SocialSession!=null && !CaelumSocialization.Active(User),"save resumes conversation and retained multiplier with power off");}
        if(e.Name=="c240_loaded_active")
        {
            Pin=true;Stats();Check(CaelumSocialization.Active(User) && User.CurrentAnima>900 && User.CurrentAnima<990,"saved active power retains its spent Anima");
            BeforeAnima=User.CurrentAnima;
        }
        if(e.Name=="c240_payment")Check(Abs(BeforeAnima-User.CurrentAnima-10)<0.3,"reloaded effect pays once per tic");
        if(e.Name=="c240_return")
        {Check(User.SocialSession==null && !User.RacialAbilityActive && User.RacialAbility==null,"rollback return has no residual multiplier or power");}
        if(e.Name=="c240_old")
        {Check(User.SocialSession==null && !CaelumSocialization.Active(User),"old neutral save gains no social snapshot or bonus");}
        if(e.Name=="c240_done")Console.Printf("CA240 DONE failures=%d passed=%d",Failed,Passed);
    }
}
