// El fixture coloca servicios reales; +use atraviesa la entrada nativa.
class CA232Hooks : StaticEventHandler
{
    Actor Service;
    int Category,Failures;
    bool BlockedCase;
    bool Interactive;
    bool ReportedUse;
    void Inspect(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);int markers=0;
        let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker mark;
        while((mark=CaelumKnownPoiMarker(it.Next()))!=null)if(!mark.bDormant)markers++;
        Console.Printf("CA232 INSPECT tic=%d category=%d service=%d facts=%d markers=%d rest=%d craft=%d merchant=%d buttons=%d pos=(%.1f %.1f %.1f) pitch=%.1f",level.time,Category,Service!=null,r.KnownPois.Size(),markers,u.HasActiveConversation(),u.CraftingMenuOpen,u.PalomoMerchantMenuOpen,u.player.cmd.buttons,u.Pos.X,u.Pos.Y,u.Pos.Z,u.Pitch);
        if(Service!=null)Console.Printf("CA232 TARGET pos=(%.1f %.1f %.1f) radius=%.1f height=%.1f aimed=%d sight=%d distance=%.1f",Service.Pos.X,Service.Pos.Y,Service.Pos.Z,Service.Radius,Service.Height,CaelumUseGeometry.AimedAt(u,Service),u.CheckSight(Service),u.Distance3D(Service));
        for(int i=0;i<r.KnownPois.Size();i++)Console.Printf("CA232 FACT %s %s category=%d",r.KnownPois[i].MapId,r.KnownPois[i].PoiId,r.KnownPois[i].Category);
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || Service==null || Category!=5)return;
        if(!(u.player.cmd.buttons&BT_USE)){ReportedUse=false;return;}
        if(ReportedUse)return;ReportedUse=true;
        let cart=CaelumTravelVehicle(Service);int aimed=0;
        for(int i=0;i<32;i++)if(cart.Parts[i]!=null && CaelumUseGeometry.AimedAt(u,cart.Parts[i]))aimed++;
        Console.Printf("CA232 TRANSPORT input=%d aimed-parts=%d can-board=%d hint=%s pos=(%.1f %.1f %.1f) angle=%.1f",u.player.cmd.buttons,aimed,cart.CanBoard(u),CaelumInteractionHint.Find(u),u.Pos.X,u.Pos.Y,u.Pos.Z,u.Angle);
    }
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA232 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c232_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);if(r==null)return;
        if(e.Name=="c232_author")Interactive=true;
        if(e.Name=="c232_inspect")Inspect(u);
        if(e.Name=="c232_release")
        {
            u.ClosePalomoMerchant();u.CloseCraftingStationSession();
            u.SetCraftingJournalState(false);CaelumJourneyPlan.Cancel(u);
        }
        if(e.Name=="c232_present")
            Check(Service!=null,String.Format("service-survives-human-wait-%d",Category));
        if(e.Name=="c232_retained")
        {
            Check(Service!=null,String.Format("service-retained-after-use-%d",Category));
            if(Category==1)Check(u.HasActiveConversation(),"bed-menu-remains-open");
            if(Category==2)Check(u.CraftingMenuOpen,"station-menu-remains-open");
            if(Category==3)Check(u.PalomoMerchantMenuOpen,"merchant-menu-remains-open");
            bool visible=false;let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker mark;
            while((mark=CaelumKnownPoiMarker(it.Next()))!=null)
                if(mark.PoiId==String.Format("hook-%d",Category) && !mark.bDormant)visible=true;
            Check(visible,String.Format("used-service-marker-retained-%d",Category));
        }
        if(e.Name=="c232_hook")
        {
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.ConversationPC=null;
            u.ClosePalomoMerchant();u.CloseCraftingStationSession();CaelumJourneyPlan.Cancel(u);
            if(Service!=null)Service.Destroy();
            Category=e.Args[0];u.Angle=(Category-1)*90;u.Pitch=0;u.Vel=(0,0,0);
            u.CurrentSleep=u.CurrentHunger=u.CurrentThirst=80;u.CombatTimeRemaining=0;
            u.MagicBoxOwned=true;r.MagicBoxOwned=true;r.MagicBoxOwnershipVersion=1;
            Vector3 pos=u.Pos+(80*Cos(u.Angle),80*Sin(u.Angle),0);
            switch(Category)
            {
            case 1:Service=Actor.Spawn("CaelumRestBed",pos,NO_REPLACE);u.Pitch=20;break;
            case 2:Service=Actor.Spawn("CaelumWorkbenchStation",pos,NO_REPLACE);break;
            case 3:Service=Actor.Spawn("CaelumCityMerchant",pos,NO_REPLACE);break;
            case 4:
                let gate=CaelumSewerTravelGate(Actor.Spawn("CaelumSewerTravelGate",pos,NO_REPLACE));
                gate.Placed=true;gate.ConnectionId=level.MapName=="MAP03"?8:10;Service=gate;break;
            case 5:
                let cart=CaelumCoveredCart(CaelumVehicleWorld.Find("CaelumCoveredCart"));
                if(cart==null){Check(false,"existing-authored-vehicle-present");return;}
                Service=cart;
                u.SetOrigin(cart.BoardingPoint,false);u.Angle=VectorAngle(cart.Pos.X-u.Pos.X,cart.Pos.Y-u.Pos.Y);
                Check(cart.CanBoard(u),"prepared-native-vehicle-can-board");break;
            }
            if(Service==null){Check(false,"service-spawn");return;}
            let binding=CaelumPoiRegistration.Bind(Service,String.Format("hook-%d",Category),Category,CaelumPoiData.CategoryKey(Category));
            Check(binding!=null,String.Format("registered-real-service-%d",Category));
            if(!Interactive)Check(CaelumPoiKnowledge.Find(r,level.MapName,String.Format("hook-%d",Category))==null,String.Format("service-unknown-before-use-%d",Category));
            Console.Printf("CA232 SERVICE category=%d user=(%.1f %.1f %.1f) actor=(%.1f %.1f %.1f)",Category,u.Pos.X,u.Pos.Y,u.Pos.Z,Service.Pos.X,Service.Pos.Y,Service.Pos.Z);
            BlockedCase=e.Args[1]!=0;
            if(BlockedCase)
            {
                if(Category==3){u.MagicBoxOwned=false;r.MagicBoxOwned=false;}
                else u.CombatTimeRemaining=10;
            }
        }
        if(e.Name=="c232_used")
        {
            Check(CaelumPoiKnowledge.Find(r,level.MapName,String.Format("hook-%d",Category))!=null,String.Format("native-use-discovers-service-%d",Category));
            if(BlockedCase)
            {
                let plan=CaelumJourneyPlan.Get(u);
                Check(!u.HasActiveConversation() && !u.PalomoMerchantMenuOpen && (plan==null || !plan.Open),"blocked-service-discovery-does-not-unlock-service");
            }
            Console.Printf("CA232 LIVE category=%d facts=%d rest=%d craft=%d merchant=%d plan=%d travel-block=%s depart=%d water=%d ground=%d combat=%.1f",Category,r.KnownPois.Size(),u.HasActiveConversation(),u.CraftingMenuOpen,u.PalomoMerchantMenuOpen,CaelumJourneyPlan.Get(u)!=null,CaelumJourneyRules.BlockReason(u),CaelumTravelService.CanDepart(u,10),u.WaterLevel,u.player.onground,u.CombatTimeRemaining);
        }
        if(e.Name=="c232_done")Console.Printf("CA232 DONE failures=%d",Failures);
    }
}
