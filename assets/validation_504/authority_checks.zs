// Sonda aislada de dos cuerpos nativos; no añade soporte de campaña en red.
class CA120AuthorityChecks : StaticEventHandler
{
    int Checks, Failures, RanAt, ReadyAt, ClockA, ClockB;
    bool Complete;
    void Check(bool ok,String label)
    { Checks++;if(!ok){Failures++;Console.Printf("CA120 FAIL %s",label);} }
    CaelumEquipmentItem Weapon(CaelumPlayer u,int wear)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType=CaelumConstants.WEAPON_TYPE_STANDARD_BOW;item.Tier=1;
        item.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        item.Durability=wear;item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.UnitWeight=u.WeaponModel.GetWeightFor(item.ItemType,1,item.EquipmentSize);
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;item.Amount=1;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;item.ItemId=120;
        item.AttachToOwner(u);u.EnsureEquipmentItemId(item);return item;
    }
    int Items(CaelumPlayer u)
    { int count=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)if(CaelumEquipmentItem(i)!=null)count++;return count; }
    void Run(CaelumPlayer a,CaelumPlayer b)
    {
        a.bInvulnerable=true;b.bInvulnerable=true;
        a.InitializeDirectMapCharacter();b.InitializeDirectMapCharacter();
        let ar=a.GetPersistentCharacterState(true);let br=b.GetPersistentCharacterState(true);
        Check(CaelumPlayerAuthority.FromNetworkPlayer(0)==a && CaelumPlayerAuthority.FromNetworkPlayer(1)==b,"explicit native player routing");
        Check(CaelumPlayerAuthority.FromNetworkPlayer(-1)==null && CaelumPlayerAuthority.FromNetworkPlayer(MAXPLAYERS)==null,"out-of-range event rejected before indexing");
        Check(CaelumPlayerAuthority.FromNetworkPlayer(2)==null,"inactive slot has no fallback");
        Check(ar!=br && ar.Owner==a && br.Owner==b && a.CharacterProfile!=b.CharacterProfile,"distinct native record/profile owners");
        Check(CaelumPlayerAuthority.OwnsRecord(a,ar) && !CaelumPlayerAuthority.OwnsRecord(a,br),"record identity contract");
        CaelumPlayerResources.AddAdrenaline(null,100);
        CaelumPlayerCharacter.InitializeDirectMapCharacter(null);
        CaelumPlayerPresentation.RefreshSocialJournalSnapshot(null);
        CaelumTarotService.Advance(null);
        Check(!CaelumInventoryService.GrantTarotDeck(null,false),"null inventory command rejected");
        Check(CaelumPlayerCharacter.ReadNewCharacterDraft(null,'ca_newchar_race',42)==42,"null draft query uses supplied fallback");
        Check(!CaelumTarotService.Select(null,0) && !CaelumTarotService.Activate(null),"null Tarot requests rejected");
        Check(CaelumTarotService.CountTarotCards(null)==0 && !CaelumTarotService.HasTarotCard(null,0),"null Tarot reads safe");
        let orphan=CaelumPlayer(Actor.Spawn("CaelumPlayer",a.Pos+(0,256,0),NO_REPLACE));
        Check(!CaelumPlayerAuthority.CanRead(orphan) && orphan.GetPersistentCharacterState(true)==null,"non-player pawn creates no record");
        CaelumPlayerResources.AddAdrenaline(orphan,100);
        Check(orphan.CurrentAdrenaline==0 && !CaelumTarotService.Activate(orphan),"non-player pawn rejects mutations");
        orphan.Destroy();
        Check(a.GrantMagicBoxFromPalomo(false) && b.GrantMagicBoxFromPalomo(false),"independent Boxes");
        Check(CaelumTarotDeckRules.Grant(a,false) && CaelumTarotDeckRules.Grant(b,false),"independent physical decks");
        let aw=Weapon(a,11);let bw=Weapon(b,7);aw.Equipped=true;bw.Equipped=true;
        Check(aw.ItemId==bw.ItemId && a.FindNativeEquipmentItemById(aw.ItemId)==aw && b.FindNativeEquipmentItemById(bw.ItemId)==bw,"same numeric ID resolves only within its owner");
        Check(a.ActivateExactEquippedWeapon(aw) && b.ActivateExactEquippedWeapon(bw),"each owner equips its exact item");
        Check(!a.ActivateExactEquippedWeapon(bw) && a.ActiveWeaponItemId==aw.ItemId && a.WeaponModel.Durability==11 && bw.Durability==7,"foreign activation changes neither owner");
        a.ApplyFormalInventorySelection(aw);int selected=a.EquipmentSelectionItemId;
        a.ApplyFormalInventorySelection(bw);Check(a.EquipmentSelectionItemId==selected,"foreign selection rejected");
        bool migrated=br.NativeEquipmentMigrationComplete;br.NativeEquipmentMigrationComplete=false;
        int ac=Items(a),bc=Items(b);a.MigrateLegacyEquipmentToNativeInventory(br);
        Check(!br.NativeEquipmentMigrationComplete && Items(a)==ac && Items(b)==bc,"foreign migration record rejected before writes");br.NativeEquipmentMigrationComplete=migrated;
        ar.TarotOwned[0]=true;br.TarotOwned[36]=true;
        a.RefreshSocialJournalSnapshot();b.RefreshSocialJournalSnapshot();
        int snapshot=a.TarotOwnedCountSnapshot;int revision=br.TarotPowerRevision;br.TarotPowerRevision=0;br.TarotSelected[36]=true;
        CaelumTarotService.RefreshJournalSnapshot(a,br);
        Check(a.TarotOwnedCountSnapshot==snapshot && br.TarotPowerRevision==0 && br.TarotSelected[36],"foreign Tarot projection cannot migrate another record");
        br.TarotPowerRevision=revision;br.TarotSelected[36]=false;
        Check(CaelumTarotService.Select(a,0) && CaelumTarotService.Select(b,36),"each owner selects its essence");
        Check(ar.TarotSelected[0] && !ar.TarotSelected[36] && br.TarotSelected[36] && !br.TarotSelected[0],"selected sets remain separate");
        a.CurrentAnima=3000;b.CurrentAnima=3000;
        Check(CaelumTarotService.Activate(a),"first owner activation");
        Check(b.CurrentAnima==3000 && br.TarotEffectTics==0 && !br.TarotActive[0],"activation never spends or starts the other owner");
        CaelumTarotService.Advance(a,5);
        Check(ar.TarotEffectTics==2095 && br.TarotEffectTics==0,"personal time does not touch another record");
        a.CurrentAdrenaline=0;b.CurrentAdrenaline=0;a.AddAdrenaline(12);
        Check(a.CurrentAdrenaline==12 && b.CurrentAdrenaline==0,"resource owner isolated");
        int cheats=a.player.cheats;a.player.cheats=cheats|CF_PREDICTING;
        int timer=ar.TarotEffectTics;double anima=a.CurrentAnima;
        a.AddAdrenaline(100);CaelumTarotService.Advance(a,10);
        Check(!CaelumTarotService.Select(a,0) && CaelumPlayerAuthority.FromNetworkPlayer(0)==null,"predicted requests rejected");
        Check(a.CurrentAdrenaline==12 && ar.TarotEffectTics==timer && a.CurrentAnima==anima,"prediction makes no resource/timer/selection writes");
        Check(a.FindNativeEquipmentItemById(aw.ItemId)==aw,"pure inventory lookup remains readable in prediction");
        a.player.cheats=cheats;
        let ap=CaelumCraftingBrowser.Get(a);let bp=CaelumCraftingBrowser.Get(b);
        int rows=bp.MaterialUnits.Size();
        Check(!a.AddScaledEquipmentTaskMaterial(CaelumConstants.MATERIAL_WOOD,1,100,0.5,true,bp) && int(bp.MaterialUnits.Size())==rows,"foreign crafting projection rejected");
        Check(a.AddScaledEquipmentTaskMaterial(CaelumConstants.MATERIAL_WOOD,1,100,0.5,true,ap) && ap.MaterialUnits.Size()>0 && int(bp.MaterialUnits.Size())==rows,"owned preview remains usable");
        Check(!a.BuildEquipmentTaskMaterials(bw,0.5,true,ap),"foreign repair target rejected");
        aw.Equipped=false;a.ApplyFormalInventorySelection(aw);int id=aw.ItemId;a.DropSelectedNativeInventoryItem();
        let it=ThinkerIterator.Create("CaelumEquipmentItem");CaelumEquipmentItem dropped;
        while((dropped=CaelumEquipmentItem(it.Next()))!=null)if(dropped.Owner==null && dropped.ItemId==id)break;
        Check(dropped!=null && a.FindNativeEquipmentItemById(id)==null,"native drop releases the old owner");
        if(dropped!=null)
        {
            Actor receiver=b;Check(dropped.CallTryPickup(receiver),"second native player picks up released item");
            Check(Items(b)==bc+1 && bw.ItemId==id && bw.Durability==7,"existing destination item retains identity and wear");
            bool transferred=false;
            for(Inventory i=b.Inv;i!=null;i=i.Inv)
            {let item=CaelumEquipmentItem(i);if(item!=null && item!=bw && item.Durability==11 && item.ItemId!=id && item.Owner==b)transferred=true;}
            Check(transferred,"legitimate transfer reassigns colliding ID without changing wear");
        }
        ClockA=CaelumWorldClock.Get(a,true).DayTics;ClockB=CaelumWorldClock.Get(b,true).DayTics;
        RanAt=level.time;
        Console.Printf("CA120 AUTHORITY checks=%d failures=%d players=2",Checks,Failures);
    }
    override void WorldTick()
    {
        int count=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])count++;
        if(level.time%35==0 && !Complete)Console.Printf("CA120 PARTICIPANTS count=%d tic=%d",count,level.time);
        if(count==2 && ReadyAt==0)ReadyAt=level.time;
        if(count==2 && RanAt==0 && level.time>=ReadyAt+10)Run(CaelumPlayer(players[0].mo),CaelumPlayer(players[1].mo));
        if(RanAt>0 && !Complete && level.time>=RanAt+35)
        {
            Check(CaelumWorldClock.Get(CaelumPlayer(players[0].mo)).DayTics==ClockA && CaelumWorldClock.Get(CaelumPlayer(players[1].mo)).DayTics==ClockB,"shared campaign clock remains unsupported with two participants");
            Complete=true;Console.Printf("CA120 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
