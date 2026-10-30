class CA430PopulationPort : CaelumPortSiege { override void Tick() {} }
class CA430CampaignChecks : EventHandler
{
    override void UiTick()
    {
        let menu=Menu.GetCurrentMenu();
        if(ConversationMenu(menu)!=null)menu.MenuEvent(Menu.MKEY_Back,false);
    }
    int Passes,Failures,CaptainTic;
    int RevivalTic,OldFirstClass,OldSecondClass;
    double RevivalCost;
    CaelumCompanionBond RevivedBond;
    CaelumCompanionSubcaptain Captain;
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA430 PASS %s",label);}else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    void Result(String label){Console.Printf("CA430 RESULT %s passes=%d failures=%d",label,Passes,Failures);}
    void Clothing()
    {
        let user=CaelumPlayer(players[0].mo);let party=CaelumCompanionParty.Get(user);
        let bond=party!=null ? party.Find(8) : null;Check(bond!=null,"clothing fixture owns a recruited body");
        if(bond==null)return;
        let body=bond.Body;let gear=bond.Loadout;let thermal=CaelumThermalBody.Get(body,true);
        CaelumThermalBody.Refresh(body,thermal);
        let armor=gear.Armor[1];Check(armor!=null && gear.Unequip(armor),"clothing test removes armor without consuming it");
        Check(gear.Clothing[1]==null && !gear.ClothingManaged[1],"recruitment does not invent initial clothing loot");
        let item=CaelumClothing.Create(user,CaelumClothingData.Initial(1),CaelumConstants.EQUIPMENT_SIZE_M);
        item.AttachToOwner(body);item.ThermalWaterKg=0.02;
        Check(gear.Toggle(item) && gear.Clothing[1]==item && item.Equipped,"native clothing equips on its own regional layer");
        Check(CaelumThermalBody.Material(body,1)==CaelumClothingData.THERMAL_FIRST+item.ItemType,
            "worn clothing supplies its actual thermal material");
        CaelumContaminationStorage.Set(item,42);
        let exposure=new("CaelumContaminationNPC");exposure.Capture(body,thermal);
        int row=exposure.Frame.Clothes[1];
        Check(row>=0 && exposure.Frame.Items[row].Item==item && exposure.Frame.Items[row].Worn
            && exposure.Frame.Items[row].Area==exposure.Frame.BodyArea[1],
            "clothing contamination uses one worn layer and the actual body area");
        let wrong=CaelumClothing.Create(user,CaelumClothingData.Initial(1),CaelumConstants.EQUIPMENT_SIZE_XS);wrong.AttachToOwner(body);
        Check(!gear.Toggle(wrong) && gear.Clothing[1]==item && item.Equipped,"an incompatible size cannot displace current clothing");
        double water=item.ThermalWaterKg;double runoff=thermal.ClothingRunoffKg;
        Check(gear.Unequip(item) && item.Owner==body && item.ThermalWaterKg==water
            && CaelumThermalBody.Material(body,1)==-1,"removing clothing retains its moisture and exposes the uncovered region");
        Check(gear.Toggle(item) && gear.Toggle(armor),"clothing and armor coexist without replacing one another");
        Check(CaelumThermalBody.Material(body,1)==CaelumThermalData.MaterialForArmor(armor.ItemType),
            "outer armor retains the shared thermal material rule");
        double before=gear.Water(thermal,1);CaelumThermalBody.SetWater(body,thermal,1,before);
        Check(Abs(gear.Water(thermal,1)-before)<0.000000001,"wetness redistribution conserves the combined water exactly");
        gear.Unequip(armor);gear.Unequip(item);
        Check(Abs(gear.Water(thermal,1)+armor.ThermalWaterKg+item.ThermalWaterKg
            +thermal.ClothingRunoffKg-runoff-water)<0.000000001,
            "packing wet pieces retains water or records physical runoff without duplication");
        Check(Abs(CaelumContaminationStorage.Value(item)-42)<0.0000001,"equip and removal preserve item contamination");
        Result("clothing and sizes");
    }
    void Jewelry()
    {
        let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo));let bond=party.Find(8);
        let body=bond.Body;let gear=bond.Loadout;
        double speed=body.CombatBaseSpeed;int strength=body.CombatStrength;int patience=body.CombatPatience;
        int hp=body.health/2;body.health=hp;double anima=body.CurrentCombatAnima/2;body.CurrentCombatAnima=anima;
        let amulet=gear.MakeItem("CaelumAmuletPickup",CaelumConstants.EQUIPMENT_KIND_AMULET,
            CaelumConstants.AMULET_RUBY,1,CaelumConstants.EQUIPMENT_SIZE_M,100,0.1,null);
        Check(gear.Toggle(amulet) && gear.Amulet==amulet,"native amulet equips without replacing armor");
        Check(body.CombatStrength==strength+CaelumEquipmentRules.AmuletFamilyBonus(amulet.ItemType,0,1)
            && body.CombatPatience==patience+CaelumEquipmentRules.AmuletFamilyBonus(amulet.ItemType,3,1),
            "amulet applies the shared family bonuses including the opposite family");
        int after=body.CombatStrength;gear.ApplyAmulet();gear.ApplyAmulet();
        Check(body.CombatStrength==after,"reconciliation cannot accumulate amulet bonuses");
        Check(body.health<=hp && body.CurrentCombatAnima<=anima,"equipping does not grant free health or Anima");
        Check(gear.Unequip(amulet) && body.CombatStrength==strength && body.CombatPatience==patience
            && Abs(body.CombatBaseSpeed-speed)<0.00000001,"removal restores authored attributes and movement exactly");
        let seal=gear.MakeItem("CaelumSealPickup",CaelumConstants.EQUIPMENT_KIND_SEAL,
            CaelumConstants.SEAL_FIRE,1,CaelumConstants.EQUIPMENT_SIZE_M,100,0.1,null);
        Check(gear.Toggle(seal) && CaelumSealResistance.ForEssence(body,CaelumConstants.ESSENCE_FIRE)==0.5,
            "native seal uses the existing elemental resistance");
        Check(gear.Unequip(seal) && CaelumSealResistance.ForEssence(body,CaelumConstants.ESSENCE_FIRE)==1,
            "removing the seal removes its resistance");
        gear.Toggle(amulet);gear.Toggle(seal);
        Result("jewelry");
    }
    override void WorldTick()
    {
        if(RevivalTic>0 && level.time>=RevivalTic)
        {
            RevivalTic=0;let user=CaelumPlayer(players[0].mo);RevivedBond.Reconcile();
            Check(RevivedBond.Body.health>0 && !RevivedBond.DeathRecorded && RevivedBond.Enlisted,
                "the existing paid pilgrimage ability revives the same companion");
            Check(Abs(user.ClassCastPaid-RevivalCost)<0.000001 && user.ClassSleepCooldownRemaining>0,
                "revival completes the existing preparation, exact Anima cost and cooldown");
            Check(RevivedBond.Body.FindInventory("CA430Token").Amount==7,
                "ability-level resurrection preserves actual companion inventory");
            Check(!CaelumClassAbilityRules.Begin(user),"revival cooldown prevents immediate recasting");
            user.CharacterProfile.FirstClass=OldFirstClass;user.CharacterProfile.SecondClass=OldSecondClass;
            Result("ability revival");
        }
        if(CaptainTic==0)return;
        let port=CaelumPortSiege.Get();if(port==null)return;
        if(Captain==null)
        {
            port.SiegeStarted=true;port.EnsureSubcaptain();port.SiegeStarted=false;Captain=port.Subcaptain;
            if(Captain!=null)CaptainTic=level.time+2;
            return;
        }
        if(level.time<CaptainTic)return;
        CaptainTic=0;port.SiegeStarted=false;
        Check(Captain.CombatStrength==20 && Captain.CombatAgility==20 && Captain.CombatInsight==20,
            "campaign-spawned subcaptain initializes the authored profile");
        let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo),true);
        Check(party.Recruit(Captain),"campaign subcaptain is recruitable without payment");
        port.SiegeStarted=true;port.EnsureSubcaptain();port.SiegeStarted=false;
        int count=0;
        for(int i=0;i<port.Defenders.Size();i++)if(port.Defenders[i] is "CaelumCompanionSubcaptain")count++;
        Check(count==1 && port.Subcaptain==Captain,"campaign controller creates one subcaptain and retains its identity");
        Result("campaign subcaptain");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=='ca430_defendercount')
        {
            Passes=Failures=0;
            let port=CA430PopulationPort(Actor.Spawn("CA430PopulationPort",user.Pos,NO_REPLACE));
            let party=CaelumCompanionParty.Get(user);let body=party.Find(0).Body;let captain=CaelumPortDefender(party.Find(8).Body);
            int before=port.LivingDefendingPopulation();
            Check(before>1,"defender admission counts the player and present companions");
            port.Defenders.Push(captain);
            Check(port.LivingDefendingPopulation()==before,"registered companion is counted once, not twice");
            bool friendly=body.bFriendly;body.bFriendly=false;
            Check(port.LivingDefendingPopulation()==before-1,"hostile companion does not occupy a defending place");body.bFriendly=friendly;
            int hp=body.health;body.health=0;
            Check(port.LivingDefendingPopulation()==before-1,"dead companion frees its military place immediately");body.health=hp;
            body.Companion.Parked=true;
            Check(port.LivingDefendingPopulation()==before-1,"off-map companion is not a present defender");body.Companion.Parked=false;
            Check(port.LivingDefendingPopulation()==before,"repeated admission census preserves the real population");
            port.Destroy();Result("defender admission");
        }
        if(e.Name=='ca430_protection')
        {
            Passes=Failures=0;
            let party=CaelumCompanionParty.Get(user);
            for(int i=0;i<4;i++)
            {
                let bond=party.Find(i);let body=CaelumAnchoredResident(bond.Body);
                int before=body.health;body.DamageMobj(user,user,1000000,'None',0,0);
                Check(body.IsProtectedStoryResident() && body.health>0 && body.bBuddha && !bond.DeathRecorded,
                    String.Format("mansion companion %d retains narrative protection",i));
                int mode=body.RuloPartyMode;body.RuloPartyMode=1;
                Check(!CaelumCompanions.Controlled(body),String.Format("resident %d yields companion control to the existing trial",i));
                body.RuloPartyMode=mode;party.SetOrder(bond,CaelumCompanionData.FOLLOW);
            }
            Result("mansion protection");
        }
        if(e.Name=='ca430_campaignprotection')
        {
            Passes=Failures=0;
            let party=CaelumCompanionParty.Get(user);
            for(int i=0;i<4;i++)
            {
                let bond=party.Find(i);let body=CaelumAnchoredResident(bond.Body);
                Check(!bond.Parked && !body.IsProtectedStoryResident() && !body.bInvulnerable && !body.bBuddha,
                    String.Format("campaign resident %d has no mansion immortality",i));
            }
            let bond=party.Find(0);bond.Body.DamageMobj(user,user,1000000,'None',DMG_NO_ARMOR,0);
            Check(bond.Body.health<=0 && bond.DeathRecorded && bond.Enlisted,"campaign damage creates persistent companion death");
            Result("campaign protection");
        }
        if(e.Name=='ca430_clothing')Clothing();
        if(e.Name=='ca430_abilityrevival')
        {
            let party=CaelumCompanionParty.Get(user);RevivedBond=party.Find(8);
            RevivedBond.Body.SetOrigin(user.Pos+(80,0,0),false);
            RevivedBond.Body.bBuddha=false;RevivedBond.Body.bInvulnerable=false;
            RevivedBond.Body.DamageMobj(user,user,1000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(RevivedBond.Body.health<=0 && RevivedBond.DeathRecorded,"ability test starts with an actual dead companion");
            OldFirstClass=user.CharacterProfile.FirstClass;OldSecondClass=user.CharacterProfile.SecondClass;
            user.CharacterProfile.FirstClass=CaelumConstants.CLASS_EXPLORER;user.CharacterProfile.SecondClass=CaelumConstants.CLASS_PRIEST;
            user.CurrentAnima=0;user.ClassSleepCooldownRemaining=0;
            Check(!CaelumClassAbilityRules.Begin(user),"resurrection cannot begin without its authored Anima cost");
            RevivalCost=CaelumClassAbilityRules.Cost(user);user.CurrentAnima=RevivalCost+1;
            Console.Printf("CA430 CAST health=%d created=%d profession=%d immobile=%d channel=%d active=%d equipment=%d wizard=%d rest=%d craft=%d conversation=%d merchant=%d view=%d anima=%.2f cost=%.2f",user.health,user.CharacterCreationComplete,user.CharacterProfile.GetProfession(),user.IsPhysicallyImmobilized(),user.CombatChannelModeActive,user.ClassCastActive,user.EquipmentMenuOpen,user.CreationWizardOpen,CaelumRestState.IsActive(user),user.CraftingMenuOpen,user.HasActiveConversation(),user.PalomoMerchantMenuOpen,CaelumClassCastView.Active(user),user.CurrentAnima,RevivalCost);
            Check(CaelumClassAbilityRules.Begin(user),"the existing pilgrim ability starts normally");
            RevivalTic=level.time+CaelumClassCastLayout.SECONDS*TICRATE+15;
        }
        if(e.Name=='ca430_jewelry')Jewelry();
        if(e.Name=='ca430_jewelryreload')
        {
            let party=CaelumCompanionParty.Get(user);let body=party.Find(8).Body;let gear=body.Companion.Loadout;
            int before=body.CombatStrength;gear.ApplyAmulet();
            Check(gear.Amulet!=null && gear.Amulet.Owner==body && gear.Seal!=null && gear.Seal.Owner==body,
                "loaded jewelry retains native ownership and selected slots");
            Check(before==body.CombatStrength && before==20+CaelumEquipmentRules.AmuletFamilyBonus(gear.Amulet.ItemType,0,1),
                "loading retains exactly one amulet bonus");
            Result("jewelry reload");
        }
        if(e.Name=='ca430_campaigncaptain')
        {
            let port=CaelumPortSiege.Get();Check(port!=null,"MAP03 owns its actual siege controller");
            if(port==null){Result("missing controller");return;}
            // Only exercise the authored spawn gate, without deploying another army.
            Check(!port.SiegeStarted && port.Subcaptain==null,"peaceful campaign has no premature subcaptain");
            CaptainTic=level.time;
        }
        if(e.Name=='ca430_campaignprisoners')
        {
            let party=CaelumCompanionParty.Get(user,true);
            for(int i=0;i<4;i++)
            {
                let it=ActorIterator.Create(CaelumConstants.PRISONER_TID_BASE+i);
                let body=CaelumAnchoredResident(it.Next());
                Check(body!=null,String.Format("authored sewer prisoner %d exists",i));if(body==null)continue;
                Check(!CaelumCompanions.CanRecruit(user,body),String.Format("captive prisoner %d cannot join",i));
                body.ReleaseEscortPrisoner(user);
                Check(party.Recruit(body) && party.Find(i+4).Body==body,
                    String.Format("freed prisoner %d joins as the same authored body",i));
            }
            Check(party.Occupied()==5,"four freed prisoners occupy four companion places");
            Result("campaign prisoners");
        }
        if(e.Name=='ca430_campaignarrival')
        {
            let party=CaelumCompanionParty.Get(user);let port=CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
            Check(party!=null && port!=null,"travel preserves the roster and destination registry");
            if(party==null || port==null){Result("missing arrival");return;}
            for(int i=0;i<4;i++)
            {
                let bond=party.Find(i+4);let body=bond!=null ? CaelumAnchoredResident(bond.Body) : null;
                Check(body!=null && !bond.Parked && body.EscortPrisonerPort
                    && user.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_EXTRACTED,
                    String.Format("prisoner %d arrives and finishes extraction without replacing its body",i));
                Check(body!=null && port.PortPeople[i]==body,String.Format("destination testimony registry owns prisoner %d",i));
                bool claimed=user.IsPlayerPrisonerRewardClaimed(i);
                bool first=user.ClaimPrisonerPortReward(i,CaelumPrisonerRescue.FactionFor(i));
                Check(first!=claimed && user.IsPlayerPrisonerRewardClaimed(i)
                    && !user.ClaimPrisonerPortReward(i,CaelumPrisonerRescue.FactionFor(i)),
                    String.Format("prisoner %d reward remains idempotent after travel or reload",i));
            }
            Check(port.PortSurvivors()==15,"all four actual survivors remain available to the investigation");
            Result("campaign arrival");
        }
    }
}
