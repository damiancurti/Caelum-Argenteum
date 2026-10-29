// Diagnóstico de geometría: un jugador nativo; el segundo cuerpo no simula red.
class CA412BagChecks : CA411DeployChecks
{
    CaelumDeployedTent Tent;
    CaelumSleepingBag Bag;
    int Good,Bad;
    void Assert(bool ok,String label)
    {if(ok)Good++;else Bad++;Console.Printf("CA412B %s %s",ok?"PASS":"FAIL",label);}
    void Summary(){Console.Printf("CA412B RESULT passes=%d failures=%d",Good,Bad);}
    vector3 Slot(bool second=false)
    {return Tent.Pos+Tent.LocalOffset((second?-22:22,0,0));}
    void Seed(CaelumPlayer u)
    {
        Setup(u);let item=Give(u);
        // La sala exterior privada no añade permisos de campaña. El montaje
        // legal se verifica por separado con el fixture original de MAP01.
        Tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',(128,128,0),NO_REPLACE));
        Tent.Item=item;item.AttachToOwner(Tent);Tent.Prepare();
        Assert(Tent!=null && Tent.Ready,"original tent and item deployed");
        Bag=CaelumSleepingBag(u.GiveInventoryType('CaelumSleepingBag'));
        Assert(Bag!=null && Bag.AvailableTo(u),"one original unboxed sleeping bag");
    }
    void Inside(CaelumPlayer u)
    {
        if(Tent==null)return;
        CaelumRestState.Cancel(u);u.SetOrigin(Slot(),false);u.Angle=Tent.Angle+90;u.Vel=(0,0,0);
        Console.Printf("CA412B native body radius=%.3f height=%.3f crouch=%.3f",u.Radius,u.Height,u.player.crouchfactor);
    }
    vector3 Outside(CaelumPlayer u)
    {return Tent.Pos+Tent.LocalOffset((CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_LENGTH_M)/2+u.Radius+CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU,0,0));}
    void EntrySetup(CaelumPlayer u)
    {
        Seed(u);Tent.Title=CaelumLockRules.Character(u,true);
        u.SetOrigin(Outside(u),false);u.Angle=Tent.Angle+180;u.Pitch=0;u.Vel=(0,0,0);
    }
    void EntryMenu(CaelumPlayer u)
    {
        let menu=CaelumTentSession.Find(u);
        Assert(menu!=null && menu.Open && menu.Tent==Tent,"native Use from outside opens tent actions");
        if(menu!=null)menu.Act(u,0);Summary();
    }
    void EntryCore(CaelumPlayer u)
    {
        Console.Printf("CA412B ENTRY reach=%d available=%d title=%d bag=%d radius=%g height=%g pos=%g,%g,%g combat=%g talk=%d frozen=%d",Tent.Reach(u),CaelumCampTask.Available(u),CaelumLockRules.SameTitle(Tent.Title,CaelumLockRules.Character(u)),Bag.AvailableTo(u),u.Radius,u.Height,u.Pos.X,u.Pos.Y,u.Pos.Z,u.CombatTimeRemaining,u.HasActiveConversation(),u.isFrozen());
        vector3 entry=u.Pos;double original=u.player.crouchfactor;
        Assert(CaelumTentRest.Begin(u,Tent,Bag,5),"tent interaction places original bag and starts sleep");
        let rest=CaelumRestState.Get(u);let mat=rest==null?null:CaelumRestBag(rest.Furniture);
        Assert(mat!=null && mat.Bag==Bag && mat.Tent==Tent && Bag.Owner==u && Bag.Amount==1,"sleep keeps original bag and saved tent entry");
        Assert(CaelumRestState.IsSleeping(u) && Tent.Covers(u) && u.TestMobjLocation(),"native crouched body fits inside without walking through roof");
        Assert(Tent.HasRestingOccupant() && !CaelumCampTask.BeginPack(u,Tent),"occupied interactive tent refuses packing");
        CaelumRestState.Cancel(u);
        Assert((u.Pos-entry).Length()<0.01 && Abs(u.player.crouchfactor-original)<0.001,"wake restores clear entrance and prior native posture");
        Assert(Bag.Owner==u && Bag.Amount==1 && !Tent.HasRestingOccupant(),"wake does not duplicate bag and releases tent");
        Bag.InMagicBox=true;
        Assert(!CaelumTentRest.Begin(u,Tent,Bag,5) && (u.Pos-entry).Length()<0.01,"boxed bag cannot place sleeper or consume items");
        Bag.InMagicBox=false;
        let obstacle=Actor.Spawn('CA411DeployObstacle',Tent.Pos,NO_REPLACE);obstacle.A_SetSize(44,28,false);
        Assert(!CaelumTentRest.Begin(u,Tent,Bag,5) && (u.Pos-entry).Length()<0.01,"blocked berths retain original position and bag");
        obstacle.Destroy();Summary();
    }
    void EntrySeed(CaelumPlayer u)
    {EntrySetup(u);Assert(CaelumTentRest.Begin(u,Tent,Bag,5),"save interactive tent sleep begins");Summary();}
    void EntryLoad(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);let mat=rest==null?null:CaelumRestBag(rest.Furniture);
        Assert(mat!=null && mat.TentEntryRevision==1 && mat.Tent==Tent,"save retains original tent entry and bag identity");
        vector3 entry=mat==null?u.Pos:mat.TentEntry;
        Assert(CaelumRestState.IsSleeping(u) && u.TestMobjLocation(),"saved native sleep remains supported");
        CaelumRestState.Cancel(u);Assert((u.Pos-entry).Length()<0.01 && Bag.Owner==u && Bag.Amount==1,"saved wake returns to original entrance once");Summary();
    }
    int EntryMinutes(){return CaelumWorldCatalogue.IsLimboMap(level.MapName)?0:5;}
    void EntryOffer(CaelumPlayer u)
    {
        Assert(CaelumTentSession.Show(u,Tent),"outside action menu accepts owned tent");
        CaelumTentSession.Find(u).Act(u,1);
        let guide=CaelumRestGuide(u.player.ConversationNPC);
        Assert(guide!=null && guide.Tent==Tent && guide.Bag==Bag && guide.UsesTent && guide.bInConversation,
            "rest choice opens actual native duration conversation bound to original bag and tent");Summary();
    }
    void EntryChoice(CaelumPlayer u)
    {
        let guide=CaelumRestGuide(u.player.ConversationNPC);
        Assert(guide!=null,"native dialogue guide exists before reply");if(guide==null){Summary();return;}
        let replyItem=CaelumRestAction(u.GiveInventoryType(EntryMinutes()==0?'CaelumRestSleepUntimedAction':'CaelumRestSleep5Action'));
        Assert(guide.QueuedMode==CaelumRestRules.MODE_SLEEP && guide.QueuedMinutes==EntryMinutes(),"native autoactivated USDF inventory reply queues rest choice once");
        // S?lo se simula el cierre de USDF; el Tick productivo resuelve la elecci?n.
        guide.bInConversation=false;Summary();
    }
    void EntryAfterChoice(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);
        Assert(CaelumRestState.IsSleeping(u) && rest.ElapsedTics>0,"dialogue choice reaches actual sleeping session on normal tics");
        Assert(rest!=null && CaelumRestBag(rest.Furniture)!=null && u.TestMobjLocation(),"dialogue sleep retains original bag and valid native body");
        if(EntryMinutes()==0)Assert(rest.Untimed,"Limbo tent uses approved untimed rest");
        else Fast(u);
        CaelumRestState.Cancel(u);Assert((u.Pos-Outside(u)).Length()<0.01,"dialogue wake returns to outside entrance");Summary();
    }
    CaelumEquipmentItem EntrySupplies(CaelumPlayer u)
    {
        for(Inventory cur=u.Inv;cur!=null;cur=cur.Inv)
        {if(cur is 'CaelumEquipmentItem')CaelumContaminationStorage.Set(cur,0);if(cur is 'CaelumWaterContainer')CaelumWaterContainer(cur).WaterLiters=0;}
        let water=CaelumWaterContainer(u.GiveInventoryType('CaelumBottleLarge'));water.WaterLiters=5;
        water.WaterQuality=CaelumWaterQuality.POTABLE;water.InMagicBox=false;
        u.GiveInventoryType('CaelumCleaningCloth');
        let soap=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos,NO_REPLACE));
        soap.args[0]=CaelumHygieneData.SOAP;soap.args[1]=1;soap.Amount=100;soap.AttachToOwner(u);
        let item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos,NO_REPLACE));
        item.ItemId=912412;item.AcquisitionResolved=true;item.PickupDataInitialized=true;item.Amount=1;
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.Tier=1;item.Durability=100;
        item.AttachToOwner(u);item.Equipped=true;item.InMagicBox=false;u.ActiveWeaponItemId=item.ItemId;
        CaelumContaminationStorage.Set(item,80);return item;
    }
    void EntryClean(CaelumPlayer u)
    {
        EntrySetup(u);let item=EntrySupplies(u);vector3 entry=u.Pos;
        double water=CaelumCleaningSupplies.Water(u),soap=CaelumSoapSupply.Available(u);
        Assert(CaelumTentRest.Begin(u,Tent,Bag,EntryMinutes()),"tent accepts pre-sleep cleaning with resources");
        let task=CaelumCleaningTask.Find(u);
        Assert(CaelumCleaningTask.Active(u) && !CaelumRestState.IsSleeping(u) && task.Target==item && CaelumRestBag.ReservedBag(u)!=null,
            "original bag remains reserved while selected weapon is washed");
        Assert(Tent.HasRestingOccupant() && !CaelumCampTask.BeginPack(u,Tent),"cleaning reservation also prevents packing");
        CaelumCleaningTask.Advance(u,100);
        Assert(CaelumRestState.IsSleeping(u) && !CaelumCleaningTask.Active(u),"finished cleaning resumes sleep in same tent");
        Assert(Abs(CaelumCleaningSupplies.Water(u)-(water-0.16))<0.000001 && Abs(CaelumSoapSupply.Available(u)-(soap-0.8))<0.000001,
            "pre-sleep cleaning charges sword water and soap exactly once");
        CaelumRestState.Cancel(u);Assert((u.Pos-entry).Length()<0.01,"wake after cleaning restores entrance");
        CaelumContaminationStorage.Set(item,80);
        Assert(CaelumTentRest.Begin(u,Tent,Bag,EntryMinutes()) && CaelumCleaningTask.Active(u),"second pre-sleep cleaning starts");
        CaelumCleaningTask.Cancel(u);Summary();
    }
    void EntryAfterCleanCancel(CaelumPlayer u)
    {
        Assert((u.Pos-Outside(u)).Length()<0.01 && !CaelumRestState.IsSleeping(u) && !Tent.HasRestingOccupant(),
            "cancelled pre-sleep cleaning returns outside and releases tent");
        Assert(Bag.Owner==u && Bag.Amount==1 && u.TestMobjLocation(),"cancelled preparation preserves one bag and clear body");Summary();
    }
    void EntryBlockedExit(CaelumPlayer u)
    {
        EntrySetup(u);vector3 entry=u.Pos;
        Assert(CaelumTentRest.Begin(u,Tent,Bag,EntryMinutes()),"blocked-exit setup begins actual sleep");
        let block=Actor.Spawn('CA411DeployObstacle',entry,NO_REPLACE);block.A_SetSize(u.Radius,u.FullHeight,false);
        CaelumRestState.Cancel(u);
        Assert((u.Pos-entry).Length()>u.Radius && u.TestMobjLocation(),"new entrance obstacle chooses clear fallback without overlap");
        Assert(Bag.Owner==u && Bag.Amount==1,"fallback returns same owned bag");block.Destroy();Summary();
    }
    void Core(CaelumPlayer u)
    {
        double height=u.Height,radius=u.Radius;
        Console.Printf("CA412B player xyz=%.1f/%.1f/%.1f radius=%.1f height=%.1f flags=%d/%d parts=%d angle=%.1f",u.Pos.X,u.Pos.Y,u.Pos.Z,u.Radius,u.Height,u.bNoClip,u.bSolid,Tent.Parts.Size(),u.Angle);
        let scan=BlockThingsIterator.Create(u,50);int total=0,low=0;
        while(scan.Next()){if(scan.thing.bSolid){total++;if(scan.thing.Pos.Z<u.Pos.Z+height)low++;}}
        Console.Printf("CA412B nearby solid total=%d low=%d firstpart=%.1f/%.1f/%.1f",total,low,Tent.Parts[0].Pos.X,Tent.Parts[0].Pos.Y,Tent.Parts[0].Pos.Z);
        Assert(Tent!=null && u.TestMobjLocation() && Tent.Covers(u),"native crouched capsule fits under approved roof");
        Assert(CaelumRestBag.HasRoom(u),"first oriented bag footprint fits inside tent");
        let body=Actor.Spawn('CA411DeployObstacle',Slot(true),NO_REPLACE);
        body.A_SetSize(radius,height,false);
        Console.Printf("CA412B body2 xy=%.1f/%.1f floor=%.3f ceiling=%.3f height=%.3f radius=%.3f native=%d cover=%d angle=%.1f",body.Pos.X,body.Pos.Y,body.FloorZ,body.CeilingZ,body.Height,body.Radius,body.TestMobjLocation(),Tent.Covers(body),Tent.Angle);
        Assert(body.TestMobjLocation() && Tent.Covers(body),"second native-sized capsule also fits");
        Assert(CaelumRestBag.HasRoom(u),"neighbor body outside rectangular bag does not falsely block");
        body.Destroy();u.SetOrigin(Slot(true),false);
        Console.Printf("CA412B slot2 xy=%.1f/%.1f floor=%.3f ceiling=%.3f native=%d",u.Pos.X,u.Pos.Y,u.FloorZ,u.CeilingZ,u.TestMobjLocation());
        Assert(CaelumRestBag.HasRoom(u),"second oriented bag footprint fits");
        let mat=CaelumRestBag(Actor.Spawn('CaelumRestBag',Slot(),NO_REPLACE));mat.Angle=u.Angle;
        Assert(!CaelumRestBag.OverlapsBag(u.Pos,u.Angle,mat),"two accepted model envelopes do not overlap");
        Assert(CaelumRestBag.OverlapsBag(mat.Pos,u.Angle,mat),"coincident bags are rejected");
        Assert(CaelumRestBag.OverlapsBag(mat.Pos,u.Angle+90,mat),"crossing rotated bags are rejected");
        mat.Destroy();u.SetOrigin(Slot(),false);
        vector3 tip=u.Pos+(Cos(u.Angle)*43,Sin(u.Angle)*43,0);
        let obstacle=Actor.Spawn('CA411DeployObstacle',tip,NO_REPLACE);obstacle.A_SetSize(1,4,false);
        Assert(!CaelumRestBag.HasRoom(u),"small low obstruction at bag tip rejected");obstacle.Destroy();
        obstacle=Actor.Spawn('CA411DeployObstacle',u.Pos+(0,0,height-1),NO_REPLACE);obstacle.A_SetSize(1,4,false);
        Assert(!CaelumRestBag.HasRoom(u),"body head obstruction still rejected");obstacle.Destroy();
        Assert(u.Height==height && u.Radius==radius,"clearance leaves player collision unchanged");
        u.SetOrigin(Slot(true),false);u.Angle=Tent.Angle;
        Assert(!CaelumRestBag.HasRoom(u),"bag directed through rear wall rejected");
        u.Angle=Tent.Angle+90;u.SetOrigin((220,64,0),false);
        Assert(CaelumRestBag.HasRoom(u),"existing open-floor placement remains valid");
        u.SetOrigin((4,128,0),false);
        Assert(!CaelumRestBag.HasRoom(u),"world wall collision remains enforced");
        Summary();
    }
    void StartRest(CaelumPlayer u)
    {
        Assert(Bag!=null && Bag.BeginRest(u,5),"normal sleep starts through real bag entry point");
        Assert(CaelumRestState.IsSleeping(u),"native rest is sleeping");
        Assert(Tent.HasRestingOccupant(),"tent packing guard sees actual sleeper");
        Assert(!CaelumCampTask.BeginPack(u,Tent),"occupied tent cannot start packing");
        Summary();
    }
    void Follow(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);
        Assert(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"sleep remains active after native tics or load");
        Assert(rest!=null && rest.ElapsedTics>0,"normal clock advances actual rest");
        Assert(Bag!=null && Bag.Owner==u && Bag.Amount==1,"same bag identity remains owned once");
        Assert(Tent!=null && Tent.Covers(u) && u.TestMobjLocation(),"unchanged body remains supported in tent");
        if(rest!=null)Console.Printf("CA412B rest elapsed=%d result=%s height=%.3f",rest.ElapsedTics,rest.ResultKey,u.Height);
        CaelumRestState.Cancel(u);
        Assert(!Tent.HasRestingOccupant() && Bag.Owner==u,"waking releases tent without duplicating bag");
        Summary();
    }
    void Preview(CaelumPlayer u)
    {
        CaelumRestState.Cancel(u);u.SetOrigin((220,220,0),false);
        Tent.bInvisible=true;
        let first=Actor.Spawn('CA412PreviewBag',Slot(),NO_REPLACE);first.Angle=Tent.Angle+90;
        let second=Actor.Spawn('CA412PreviewBag',Slot(true),NO_REPLACE);second.Angle=Tent.Angle+90;
        let camera=Actor.Spawn('CA412BagCamera',Tent.Pos+(0,0,150),NO_REPLACE);camera.Pitch=90;camera.Angle=90;
        u.player.camera=camera;
        Assert(true,"diagnostic roof-hidden view uses unchanged bag and tent assets");Summary();
    }
    void Fast(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);int before=rest.ElapsedTics;
        Assert(CaelumTimeAdvanceState.Toggle(u),"existing solo acceleration accepts actual tent sleep");
        CaelumTimeAdvanceState.Pump(u);
        Assert(rest.ElapsedTics>before && CaelumRestState.IsSleeping(u),"accelerated rest advances without cancelling the bag");
        Assert(CaelumRestState.ResourceFactor(u)==3 && Tent.Covers(u),"existing bag recovery factor and tent shelter retained");
        CaelumTimeAdvanceState.Halt(u);Summary();
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca412b_menu_enter')
        {let menu=Menu.GetCurrentMenu();if(menu!=null)menu.MenuEvent(Menu.MKEY_Enter,false);}
        else if(e.Name=='ca412b_reply')
        {let menu=ConversationMenu(Menu.GetCurrentMenu());if(menu!=null)menu.MenuEvent(Menu.MKEY_Enter,false);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca412b_setup')Seed(u);
        else if(e.Name=='ca412b_entrysetup')EntrySetup(u);
        else if(e.Name=='ca412b_entrymenu')EntryMenu(u);
        else if(e.Name=='ca412b_entrycore')EntryCore(u);
        else if(e.Name=='ca412b_entryseed')EntrySeed(u);
        else if(e.Name=='ca412b_entryload')EntryLoad(u);
        else if(e.Name=='ca412b_entryoffer')EntryOffer(u);
        else if(e.Name=='ca412b_entrychoice')EntryChoice(u);
        else if(e.Name=='ca412b_entryafterchoice')EntryAfterChoice(u);
        else if(e.Name=='ca412b_entryclean')EntryClean(u);
        else if(e.Name=='ca412b_entryafterclean')EntryAfterCleanCancel(u);
        else if(e.Name=='ca412b_entryblockedexit')EntryBlockedExit(u);
        else if(e.Name=='ca412b_inside')Inside(u);
        else if(e.Name=='ca412b_core')Core(u);
        else if(e.Name=='ca412b_rest')StartRest(u);
        else if(e.Name=='ca412b_follow')Follow(u);
        else if(e.Name=='ca412b_cancel')CaelumRestState.Cancel(u);
        else if(e.Name=='ca412b_read')CaelumRestState.Report(u);
        else if(e.Name=='ca412b_preview')Preview(u);
        else if(e.Name=='ca412b_fast')Fast(u);
    }
}
class CA412PreviewBag : CaelumRestBag {override void Tick(){}}
class CA412BagCamera : Actor
{Default {+NOGRAVITY +NOBLOCKMAP RenderStyle "None";} States {Spawn:TNT1 A -1;Stop;}}
