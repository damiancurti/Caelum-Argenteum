class CA318HouseChecks : EventHandler
{
    int Failures,Passes;
    bool Initialized;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){let menu=Menu.GetCurrentMenu();if(menu!=null)menu.Close();}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null || Initialized)return;
        Initialized=true;user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.ApplyCharacterProfile();user.bInvulnerable=true;
        let record=user.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
    }
    void Check(bool ok,String message)
    {
        if(ok)Passes++;else Failures++;
        Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",message);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let roster=CaelumHouseResidents.Get();
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=="houses_position")
        {
            let it=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal door;
            while((door=CaelumHousePortal(it.Next()))!=null)
                if(door.args[0]==e.Args[0])break;
            Check(door!=null,"physical portal exists");if(door==null)return;
            double side=door.args[1]==0?1:-1;
            user.SetOrigin(door.Pos+(side*user.UseRange/2,0,0),false);
            user.FindFloorCeiling();user.Vel=(0,0,0);user.Angle=side>0?180:0;user.Pitch=0;
            user.FolkloreInteractionUseLatched=false;
            Check(CaelumUseGeometry.AimedAt(user,door),"physical portal within aimed Use range");
        }
        if(e.Name=="houses_arrived")
        {
            int house=e.Args[0];
            Check(level.MapName==CaelumHouseHubData.MapName(house),"Use enters correct house map");
            int count=0;let it=ThinkerIterator.Create("CaelumPortDefender");while(it.Next()!=null)count++;
            Check(count==(house<120?4:3),"correct local resident population");
            Check(user.Angle==180,"interior arrival faces into house");
        }
        if(e.Name=="houses_returned")
        {
            Check(level.MapName=="MAP06","Use returns to exterior");
            vector3 point=CaelumCityData.DoorOutside(e.Args[0]);
            Check((user.Pos.XY-point.XY).Length()<1,"return uses original house doorstep");
        }
        if(e.Name=="houses_fresh")
        {
            let body=roster.CreateResident(158,CaelumCityData.DoorOutside(158));
            Check(body!=null && body.Shield==null,"fresh body has not received native PostBeginPlay");
            roster.Residents[158].ResidentMap="CAH158";
            // The source-map pose is irrelevant: this case returns to the city.
            Level.ChangeLevel("CAH159",0,CHANGELEVEL_NOINTERMISSION);
        }
        if(e.Name=="houses_fresh_checked")
        {
            let body=roster.Residents[158].Body;
            Check(body!=null && body.CombatProfileInitialized && body.Shield!=null && body.Sword!=null
                && body.Carbine!=null,"fresh traveller receives complete native initialization");
            Check(roster.Residents[158].Suspended==(level.MapName!="MAP06"),"fresh traveller activates only in its source map");
        }
        if(e.Name=="houses_defenders_begin")
        {
            let port=CaelumPortSiege.Get();
            // Isolate production defender deployment from attackers and commander AI.
            port.SiegeStarted=true;port.RosterSealed=true;port.Victory=true;port.Aftermath=true;
            roster.BeginDeployment(port);
        }
        if(e.Name=="houses_defenders_checked")
        {
            let port=CaelumPortSiege.Get();int emitted=0,active=0,unique=0;
            for(int i=0;i<roster.Residents.Size();i++)
            {
                let entry=roster.Residents[i];if(entry.Emitted)emitted++;
                if(entry.Body!=null && !entry.Suspended && entry.Body.health>0)active++;
                if(entry.Body!=null && entry.Body.HomeIdentity==i && port.Defenders[i]==entry.Body)unique++;
            }
            Console.Printf("CA318 DEPLOY emitted=%d active=%d unique=%d unresolved=%d",emitted,active,unique,roster.Unresolved);
            Check(emitted==600 && active==600 && unique==600 && roster.Unresolved==0,"600 unique residents deploy through house exits");
        }
        if(e.Name=="houses_reassign")
        {
            let port=CaelumPortSiege.Get();let body=roster.Residents[158].Body;
            let old=port.Guns[6].Operators[0];
            if(old!=null){let previous=CaelumPortDefender(old);if(previous!=null)previous.Gun=null;}
            port.Guns[6].Operators[0]=body;body.Gun=port.Guns[6];
            body.Station=body.Gun.Pos+CaelumPortData.OperatorOffset(6,0);body.Lane=2;
            body.FollowingCrewRoute=true;body.CrewRouteGun=0;body.CrewRouteStep=1;
        }
        if(e.Name=="houses_reassignment_checked")
        {
            let body=roster.Residents[158].Body;let port=CaelumPortSiege.Get();
            Check(body.Gun==port.Guns[6] && body.Gun.Operators[0]==body,"replacement retains cannon and exact crew slot");
            Check((body.Station-(body.Gun.Pos+CaelumPortData.OperatorOffset(6,0))).Length()<1,"replacement retains effective station");
        }
        if(e.Name=="houses_city")
        {
            Check(CaelumHouseHub.IsCity(),"city shell marker");
            Check(roster!=null && roster.Residents.Size()==600,"600 stable resident identities");
            let it=ThinkerIterator.Create("CaelumPortDefender");Check(it.Next()==null,"unvisited residents are absent from exterior simulation");
        }
        if(e.Name=="houses_inside")
        {
            Check(CaelumHouseHubData.HouseForMap(level.MapName)==158,"correct private interior");
            Check(level.Sectors.Size()==5,"small isolated interior geometry");
            int count=0;let it=ThinkerIterator.Create("CaelumPortDefender");while(it.Next()!=null)count++;
            Check(count==3,"three actual residents in house 158");
            if(roster==null){Check(false,"missing resident roster");return;}
            let body=roster.Residents[158].Body;
            Check(body!=null && body.Sword!=null && body.Shield!=null && body.Carbine!=null,"native resident initialization");
        }
        if(e.Name=="houses_seed")
        {
            if(roster==null || roster.Residents[158].Body==null){Check(false,"missing seeded body");return;}
            let body=roster.Residents[158].Body;
            body.health=321;body.Sword.Durability=37;body.Shield.Durability=42;
            body.Carbine.Magazine=3;body.Carbine.Weapon.Durability=29;
            let item=Inventory(Actor.Spawn("CaelumFoodRation",body.Pos,NO_REPLACE));
            if(item!=null){item.Amount=7;item.AttachToOwner(body);}
            body.ForcedSleepTics=2100;
            Check(item!=null,"finite native inventory attached");
        }
        if(e.Name=="houses_parked")
        {
            if(roster==null){Check(false,"roster travelled to city");return;}
            let entry=roster.Residents[158];
            Check(entry.Body!=null && entry.Suspended,"body retained and suspended outside its house");
            Check(entry.Body!=null && entry.Body.health==321,"parked health retained");
            let it=ThinkerIterator.Create("CaelumPortDefender");Check(it.Next()==null,"parked residents have no ordinary Tick");
        }
        if(e.Name=="houses_retained")
        {
            if(roster==null || roster.Residents[158].Body==null){Check(false,"body survives hub return");return;}
            let body=roster.Residents[158].Body;
            Check(!roster.Residents[158].Suspended,"resident reactivated in its own house");
            Check(body.health==321,"injury preserved");
            Check(body.Sword.Durability==37 && body.Shield.Durability==42,"individual equipment wear preserved");
            Check(body.Carbine.Magazine==3 && body.Carbine.Weapon.Durability==29,"carbine ammunition and wear preserved");
            let item=body.FindInventory("CaelumFoodRation");Check(item!=null && item.Amount==7,"finite inventory preserved");
            Check(body.ForcedSleepTics>0 && body.ForcedSleepTics<2100,"sleep duration continues without reset");
        }
        if(e.Name=="houses_done")Console.Printf("CA318 DONE failures=%d passes=%d",Failures,Passes);
    }
}
