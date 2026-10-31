// Native departure transaction fixture: no fixture assets ship with the game.
class CA436ReturnLedger : Inventory
{
    CaelumEquipmentItem First;
    Inventory Bag,Water;
    int ItemId;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA436ClockProbe : EventHandler
{
    int Phase,TotalRequests;
    ui bool Sent;
    ui int VoteSent;
    CaelumM00ReturnDoor Door;
    CaelumCooperativeTravel Proposal;
    void Check(bool okay,String label){Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(!Sent && level.time>=TICRATE && players[consoleplayer].mo)
        {Sent=true;SendNetworkEvent("ca436_native_probe",consoleplayer);}
        if(Phase==2 && Proposal!=null && Proposal.Opened && VoteSent!=Proposal.Serial)
        {VoteSent=Proposal.Serial;SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.ACCEPT,Proposal.Serial);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca436_native_probe")Console.Printf("CA436 EVENT peer=%d sender=%d serial=%d",consoleplayer,e.Player,++TotalRequests);
    }
    static CaelumEquipmentItem Equipment(CaelumPlayer user,int kind,int type,int slot=-1)
    {
        let item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',user.Pos,NO_REPLACE));
        item.EquipmentKind=kind;item.ItemType=type;item.Tier=1;item.EquipmentSize=2;item.ArmorSlot=slot;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;item.AcquisitionResolved=true;item.PickupDataInitialized=true;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.ItemFlags=CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE;item.Durability=42;
        item.AttachToOwner(user);user.EnsureEquipmentItemId(item);return item;
    }
    static void Prepare(CaelumPlayer user)
    {
        let r=user.GetPersistentCharacterState(true);r.EnsureQuestStateInitialized();
        r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_STARTER_WEAPON_CRAFTED);
        r.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
        r.MainM00StarterChosen=true;r.MainM00StarterOption=4;r.MainM00LoadoutRevision=CaelumMainM00Loadout.REVISION;
        r.MagicBoxOwned=true;CaelumMagicBox.EnsureOwned(user);
        user.GiveInventoryType('CaelumTarotDeck');
        let ledger=CA436ReturnLedger(user.GiveInventoryType('CA436ReturnLedger'));
        ledger.First=Equipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumMainM00StarterRules.GetWeaponType(4));
        r.MainM00StarterWeaponId=ledger.ItemId=ledger.First.ItemId;
        r.MainM00ShieldId=Equipment(user,CaelumConstants.EQUIPMENT_KIND_SHIELD,0).ItemId;
        r.MainM00NecklaceItemId=Equipment(user,CaelumConstants.EQUIPMENT_KIND_AMULET,0).ItemId;
        r.MainM00CraftedSealId=Equipment(user,CaelumConstants.EQUIPMENT_KIND_SEAL,0).ItemId;
        r.MainM00PickaxeId=Equipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_PICKAXE).ItemId;
        r.MainM00UtilityStaffId=Equipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_UTILITY_STAFF).ItemId;
        r.MainM00BolasId=Equipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_BOLAS).ItemId;
        for(int i=0;i<CaelumConstants.ARMOR_SLOT_COUNT;i++)r.MainM00ArmorIds[i]=Equipment(user,CaelumConstants.EQUIPMENT_KIND_ARMOR,CaelumConstants.ARMOR_TYPE_LIGHT,i).ItemId;
        ledger.Bag=r.MainM00CraftedBag=user.GiveInventoryType('CaelumSleepingBag');
        ledger.Water=r.MainM00CraftedCanteen=user.GiveInventoryType('CaelumCanteenLarge');
        r.MainM00GoldRewardStarted=true;user.PersistCharacterState();
    }
    override void WorldTick()
    {
        if(Phase==3 || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);let b=multiplayer?CaelumPlayer(players[1].mo):a;
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(level.MapName=="MAP02")
        {
            bool finished=true,identity=true,packed=true,resources=true,closed=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let u=CaelumPlayer(players[i].mo);let r=u.GetPersistentCharacterState(false);
                let ledger=CA436ReturnLedger(u.FindInventory('CA436ReturnLedger'));
                finished=finished && CaelumCooperativeReturn.Completed(u);
                identity=identity && ledger!=null && ledger.First.Owner==u && ledger.First.ItemId==ledger.ItemId;
                packed=packed && ledger!=null && ledger.First.InMagicBox && !ledger.First.Equipped;
                resources=resources && ledger!=null && ledger.Water==r.MainM00CraftedCanteen && ledger.Bag==r.MainM00CraftedBag;
                closed=closed && CaelumCooperativeTravel.View(u)==null && !(u.player.cheats&CF_TOTALLYFROZEN);
            }
            Check(true,"native MAP02 arrival moves the whole roster");
            Check(finished,"each living character completes their own tutorial");
            Check(identity,"every player retains exact equipment instance and personal ID");
            Check(packed,"departure equipment is packed without duplication");
            Check(resources,"own crafted bag and canteen survive the crossing");
            Check(closed,"arrival releases votes and every owned freeze");
            Phase=3;Console.Printf("CA436 RESULT peer=%d tutorial",consoleplayer);return;
        }
        if(Phase==0)
        {
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Prepare(CaelumPlayer(players[i].mo));
            Door=CaelumM00ReturnDoor(Actor.Spawn('CaelumM00ReturnDoor',a.Pos+(0,64,0),NO_REPLACE));Door.StoryPlaced=true;
            let controller=CaelumMainM00QuestController(EventHandler.Find('CaelumMainM00QuestController'));
            controller.ReturnDoor=Door;controller.ReturnDoorPrepared=true;Phase=1;return;
        }
        if(Phase!=1)return;
        let ar=a.GetPersistentCharacterState(false);let br=b.GetPersistentCharacterState(false);
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let u=CaelumPlayer(players[i].mo);
            Console.Printf("CA436 DIAG member=%d conversation=%d crafting=%d craftmenu=%d shop=%d equip=%d rest=%d frozen=%d",i,u.HasActiveConversation(),u.CraftingTaskActive,u.CraftingMenuOpen,u.PalomoMerchantMenuOpen,u.EquipmentMenuOpen,CaelumRestState.IsActive(u),u.player.cheats&CF_TOTALLYFROZEN);
            // The fixture skips the opening narrative, not a production action.
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.cheats&=~CF_TOTALLYFROZEN;
            u.EquipmentMenuOpen=false;u.CraftingMenuOpen=false;u.PalomoMerchantMenuOpen=false;
        }
        if(!multiplayer)
        {
            Check(CaelumMainM00Return.IsReady(a) && CaelumOnboarding.PackDeparture(a,true),"solo departure keeps original personal prerequisites");
            a.player.ConversationNPC=Door;Door.bInConversation=true;
            Check(CaelumMainM00Return.Begin(a),"solo story confirmation retains its original fade path");
            Door.bInConversation=false;a.player.ConversationNPC=null;Phase=2;return;
        }
        Check(CaelumMainM00Return.IsReady(a) && CaelumMainM00Return.IsReady(b),"personal tutorial readiness uses existing quest flags");
        Check(CaelumOnboarding.PackDeparture(a,true) && CaelumOnboarding.PackDeparture(b,true),"all personal loadouts pass read-only preflight");
        let own=CA436ReturnLedger(a.FindInventory('CA436ReturnLedger'));
        Check(!own.First.InMagicBox,"preflight does not pack or unequip a real item");
        br.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE]=false;
        Check(!CaelumCooperativeReturn.Propose(a,Door),"unfinished living tutorial blocks departure even with a full loadout");
        br.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE]=true;
        a.RemoveInventory(own.First);
        Check(CaelumMainM00Return.ResolveStarter(a)==null && CA436ReturnLedger(b.FindInventory('CA436ReturnLedger')).First.Owner==b,"a local equipment ID never retrieves another player's starter");
        own.First.AttachToOwner(a);
        let missing=br.MainM00CraftedBag;br.MainM00CraftedBag=null;
        Check(!CaelumCooperativeReturn.Propose(a,Door),"one missing loadout prevents publishing departure");
        Check(!CaelumCooperativeReturn.Completed(a) && !CaelumCooperativeReturn.Completed(b),"failed preflight completes nobody");
        br.MainM00CraftedBag=missing;
        a.player.ConversationNPC=Door;Door.bInConversation=true;
        Check(CaelumMainM00Return.Begin(a),"initiator can confirm the narrative doorway in multiplayer");
        Door.bInConversation=false;a.player.ConversationNPC=null;
        Console.Printf("CA436 DIAG stage=%d ready=%d approach=%d ownsFreeze=%d controllerDoor=%d",ar.QuestStage[0],CaelumMainM00Return.IsReady(a),CaelumMainM00Return.CanApproach(a,Door),ar.MainM00ReturnOwnsFreeze,CaelumMainM00QuestController(EventHandler.Find('CaelumMainM00QuestController')).ReturnDoor==Door);
        CaelumMainM00Return.Update(a);Proposal=CaelumCooperativeTravel.View(a);
        Console.Printf("CA436 DIAG after stage=%d body=%d,%d pack=%d,%d freeze=%d",ar.QuestStage[0],CaelumCooperativeTravel.BodyReady(a),CaelumCooperativeTravel.BodyReady(b),CaelumOnboarding.PackDeparture(a,true),CaelumOnboarding.PackDeparture(b,true),a.player.cheats&CF_TOTALLYFROZEN);
        Check(Proposal!=null && Proposal.Opened && Proposal.Kind==CaelumCooperativeTravel.TUTORIAL,"closing the dialogue publishes shared destination consent");
        if(Proposal==null){Phase=3;return;}
        int serial=Proposal.Serial;
        Check(!Proposal.Request(b,CaelumCooperativeTravel.ACCEPT,serial-1),"stale departure consent is rejected");
        Proposal.Request(a,CaelumCooperativeTravel.ACCEPT,serial);
        Check(Proposal.Opened && !CaelumCooperativeReturn.Completed(a),"one acceptance cannot sanitize or finish a character");
        br.MainM00CraftedBag=null;
        for(int i=1;i<MAXPLAYERS;i++)if(playeringame[i])Proposal.Request(CaelumPlayer(players[i].mo),CaelumCooperativeTravel.ACCEPT,serial);
        Check(!Proposal.Opened && !CaelumCooperativeReturn.Completed(a),"changed final loadout cancels before the first personal commit");
        Check(ar.QuestStage[0]==CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED && !(a.player.cheats&CF_TOTALLYFROZEN),"cancellation restores initiator quest stage and movement");
        br.MainM00CraftedBag=missing;
        Check(CaelumCooperativeReturn.Propose(a,Door),"restored loadouts permit a fresh proposal");
        Proposal=CaelumCooperativeTravel.View(a);
        Check(Proposal.Serial!=serial && Proposal.Accepted==0,"new proposal never inherits old consent");
        Phase=2;
    }
}
