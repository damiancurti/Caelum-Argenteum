class CA430CampaignChecks : EventHandler
{
    int Passes,Failures,CaptainTic;
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
    override void WorldTick()
    {
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
        if(e.Name=='ca430_clothing')Clothing();
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
