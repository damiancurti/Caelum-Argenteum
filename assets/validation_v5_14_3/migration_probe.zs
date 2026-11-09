// #444: production events, real native inventory, shared checkpoint and exact-once settlement.
class CA446TravelLedger : Inventory
{
    CaelumEquipmentItem Equipment;
    Inventory Food;
    double Copper;
    int Reputation;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA590NetworkProbe : EventHandler
{
    const PEERS=2;
    const DISCONNECT=0;
    const TRAVEL=0;
    int Phase,Checks,Failures,RestoreStamp,PendingStamp;
    bool Restored,Complete;
    ui int SentSerial,SentPhase;
    ui bool SentAny,Saved,SavedAwards;
    CaelumDiningTable Table;
    CaelumCardDuel Duel;
    CaelumEquipmentItem Equipment;
    Inventory Food,ReservedFood;
    double OriginalMoney[8];
    int OriginalReputation[8],Stakes[8];
    String SavedState;
    void Check(bool okay,String label){Checks++;if(!okay)Failures++;Console.Printf("CA446 %s %s",okay?"PASS":"FAIL",label);}
    String State()
    {
        let g=Duel.Advanced;String s=String.Format("%d/%d/%d/%d/%f/%f",g.Mano,g.Turn,g.HandNumber,g.Phase,g.Health[0],g.Health[1]);
        for(int i=0;i<PEERS;i++)
        {
            let claim=CaelumTrucazoClaims.Read(Duel.Member(i));
            s=s..String.Format("/%f/%d/%f",Duel.Member(i).GetOwnedMoneyCopperValue(),claim.Entries.Size(),claim.Copper);
            for(int j=0;j<int(g.Seats[i].Cards.Hand.Size());j++)s=s..String.Format("/%d:%d",g.Seats[i].Cards.Hand[j],int(g.Seats[i].Cards.Used[j]));
        }
        for(int i=0;i<int(g.Deck.Size());i++)s=s..String.Format("/%d",g.Deck[i]);return s;
    }
    int Row(CaelumPlayer user,Inventory item)
    {let view=CaelumTrucazoWagerView.Refresh(user);for(int i=0;i<int(view.Rows.Size());i++)if(view.Rows[i]==item)return i;return -1;}
    void Offers()
    {
        let a=Duel.Member(0);let b=Duel.Member(1);
        for(int i=0;i<PEERS;i++){let rest=CaelumRestState(Duel.Member(i).FindInventory('CaelumRestState'));rest.AutoEating=false;rest.AutoDrinking=false;}
        Equipment=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',b.Pos,NO_REPLACE));Equipment.AttachToOwner(b);
        Equipment.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Equipment.ItemType=CaelumConstants.WEAPON_TYPE_MACHETE;
        Equipment.Tier=2;Equipment.EquipmentSize=1;Equipment.Durability=345;Equipment.ItemFlags=0;Equipment.UnitWeight=1;Equipment.PickupDataInitialized=true;
        Equipment.AcquisitionResolved=true;Equipment.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        b.EnsureEquipmentItemId(Equipment);
        Food=Duel.Member(PEERS-1).GiveInventoryType('CaelumFoodRation');Food.Amount=4;CaelumFoodInventory.Reconcile(Food);
        for(int i=0;i<PEERS;i++)
        {
            let user=Duel.Member(i);let money=CaelumCurrencyItem(user.GiveInventoryType(i%2==0?'CaelumCopperCoin100':'CaelumSilverCoin'));money.Amount=10;
            user.OnNativeInventoryChanged();OriginalMoney[i]=user.GetOwnedMoneyCopperValue();OriginalReputation[i]=user.GetPersistentCharacterState(true).TrucazoReputation;
            Stakes[i]=i==3?11:7+i;Check(Duel.WagerRequest(user,CaelumTrucazoWagers.SET_COINS,Stakes[i],Duel.Serial),"native owned money offer accepted");
        }
        int stale=Duel.Serial;Duel.Lobby(a,CaelumCardDuel.CONSENT,Duel.Serial);
        Check(!Duel.WagerRequest(a,CaelumTrucazoWagers.SET_COINS,1,stale) && Duel.Accepted==1,"stale edit cannot revoke existing consent or alter stakes");
        Check(Duel.WagerRequest(b,CaelumTrucazoWagers.ADD_ITEM,Row(b,Equipment),Duel.Serial,1) && Duel.Accepted==0,"exact owned item offer clears every consent");
        Check(!CaelumTrucazoWagers.Eligible(a,Equipment),"foreign native item cannot be offered");
        Check(!CaelumTrucazoWagers.Eligible(Duel.Member(PEERS-1),Duel.Member(PEERS-1).FindInventory('CaelumTarotDeck')),"physical deck protected");
        let box=a.GiveInventoryType('CaelumMagicBox');Check(!CaelumTrucazoWagers.Eligible(a,box),"Box protected");
        Equipment.ItemFlags=CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;Check(!CaelumTrucazoWagers.Eligible(b,Equipment),"temporary quest equipment protected");Equipment.ItemFlags=0;
        let owner=Duel.Member(PEERS-1);int row=Row(owner,Food);
        Check(!Duel.WagerRequest(owner,CaelumTrucazoWagers.ADD_ITEM,row,Duel.Serial,5),"excess quantity rejected");
        Check(Duel.WagerRequest(owner,CaelumTrucazoWagers.ADD_ITEM,Row(owner,Food),Duel.Serial,2),"partial native food stack accepted");
        if(Duel.Wagers.Offers.Size()!=2){Complete=true;return;}
        if(PEERS>2)Check(Duel.Wagers.Offers[0].Recipient==0 && Duel.Wagers.Offers[1].Recipient==2,"default item recipients alternate winning seats");
        Check(Duel.WagerRequest(a,CaelumTrucazoWagers.CYCLE_RECIPIENT,0,Duel.Serial),"allocation editable before unanimous consent");
        for(int n=1;n<PEERS/2;n++)Duel.WagerRequest(a,CaelumTrucazoWagers.CYCLE_RECIPIENT,0,Duel.Serial);
        Food.Amount=3;Check(!Duel.Wagers.Reserve(),"changed stack invalidates whole reservation");Food.Amount=4;
        bool intact=Equipment.Owner==b && Food.Owner==owner && !Duel.Wagers.Reserved;
        for(int i=0;i<PEERS;i++)if(Duel.Member(i).GetOwnedMoneyCopperValue()!=OriginalMoney[i])intact=false;
        Check(intact,"failed preflight leaves all owners and balances unchanged");
        int last=Duel.Wagers.Coins[PEERS-1];Duel.Wagers.Coins[PEERS-1]=2147483647;
        Check(!Duel.Wagers.Reserve(),"insufficient last-member funds reject before any debit");Duel.Wagers.Coins[PEERS-1]=last;
        intact=true;for(int i=0;i<PEERS;i++)if(Duel.Member(i).GetOwnedMoneyCopperValue()!=OriginalMoney[i])intact=false;
        Check(intact,"insufficient funds do not partially charge earlier members");
    }
    void Reserved()
    {
        Check(Duel.Wagers.Reserved && !Duel.Wagers.Settled,"unanimous native consent reserves before dealing");
        bool exact=true;for(int i=0;i<PEERS;i++)if(Duel.Member(i).GetOwnedMoneyCopperValue()!=OriginalMoney[i]-Stakes[i])exact=false;
        Check(exact,"native denominations converted with exact change");
        Check(Equipment==Duel.Wagers.Offers[0].Claim.Item && Equipment.Owner==CaelumTrucazoClaims.Read(Duel.Member(1)).Vault && Equipment.Durability==345 && Equipment.EquipmentSize==1,"whole equipment identity size and wear survive custody");
        ReservedFood=Duel.Wagers.Offers[1].Claim.Item;
        Check(ReservedFood!=Food && ReservedFood.Amount==2 && Food.Amount==2 && CaelumFoodInventory.GetLots(ReservedFood).Units()==2 && CaelumFoodInventory.GetLots(Food).Units()==2,"native partial lot split conserves units and food batches");
        Check(!CaelumTrucazoWagers.Eligible(Duel.Member(1),Equipment),"reserved instance cannot be offered a second time");
        Duel.Release();Check(!Duel.bDestroyed && CaelumCardSeat.Session(Duel.Member(0))==Duel,"unsettled pot cannot be released");
        SavedState=State();Phase=7;Console.Printf("CA446 RESULT %s checks=%d fresh",Failures==0?"PASS":"FAIL",Checks);
    }
    void Settlement()
    {
        let a=Duel.Member(0);let claim=CaelumTrucazoClaims.Read(a);
        // Controlled capacity failure in this disposable fixture; all currency/items stay real.
        for(int i=0;i<PEERS;i+=2){Duel.Member(i).MagicBoxOwned=false;Duel.Member(i).DerivedStats.CarryCapacity=0;}
        Check(Duel.DispatchAdvanced(Duel.Member(1),CaelumTrucazoRules.FORFEIT,0,Duel.Serial),"production authority accepts deliberate forfeit");Duel.Wagers.Settle();
        Check(Duel.Finished() && Duel.Advanced.Winner==0 && Duel.Wagers.Settled,"voluntary abandonment settles entire losing team once");
        double lost=0;for(int i=1;i<PEERS;i+=2)lost+=Stakes[i];int size=PEERS/2;double share=floor(lost/size);int remainder=int(lost-share*size);
        bool exact=true,rep=true;int firstWinner=Duel.Advanced.Mano%2==0?Duel.Advanced.Mano:(Duel.Advanced.Mano+1)%PEERS;
        for(int i=0;i<PEERS;i++)
        {
            let user=Duel.Member(i);let c=CaelumTrucazoClaims.Read(user);
            double expected=i%2==0?OriginalMoney[i]+share+(remainder>0 && i==firstWinner?1:0):OriginalMoney[i]-Stakes[i];
            if(user.GetOwnedMoneyCopperValue()+c.Copper!=expected)exact=false;
            if(user.GetPersistentCharacterState(true).TrucazoReputation!=OriginalReputation[i]+(i%2==0?5:0))rep=false;
            Check(c.Reservation==null,"settled claims release profile transfer lock");
        }
        Check(exact,"winners recover own stakes and split opposing copper with mano remainder");Check(rep,"only winners receive five separate reputation points");
        Check(claim.Pending()>0 && claim.Copper>0 && Equipment.Owner==claim.Vault,"capacity failure retains actual equipment and money as claimable awards");
        double before=claim.Copper;int reputation=a.GetPersistentCharacterState(true).TrucazoReputation;
        Duel.Wagers.Settle();Check(claim.Copper==before && a.GetPersistentCharacterState(true).TrucazoReputation==reputation,"repeated settlement cannot duplicate stakes or reputation");
        Phase=8;PendingStamp=level.time;
    }
    void ClaimAwards()
    {
        let a=Duel.Member(0);
        for(int i=0;i<PEERS;i+=2)
        {
            let user=Duel.Member(i);let c=CaelumTrucazoClaims.Read(user);user.DerivedStats.CarryCapacity=100000;
            int serial=c.Serial;Check(c.Claim(user,serial),"prizes claim after freeing native capacity");
            Check(!c.Claim(user,serial) && c.Pending()==0 && c.Copper==0,"repeated claim event cannot duplicate prizes");
        }
        Check(Equipment.Owner==a && Equipment.Durability==345 && Equipment.EquipmentSize==1,"claimed equipment remains the reserved native instance");
        int foodRecipient=Duel.Wagers.Offers[1].Recipient;Check(ReservedFood.Owner==Duel.Member(foodRecipient) && ReservedFood.Amount==2,"split food goes to agreed winning recipient");
        Complete=true;Console.Printf("CA446 RESULT %s checks=%d restored",Failures==0?"PASS":"FAIL",Checks);
    }
    void TravelAwards()
    {
        for(int i=0;i<PEERS;i++)
        {
            let user=Duel.Member(i);CaelumRestState.Cancel(user);
            if(i%2==0)
            {
                let ledger=CA446TravelLedger(user.GiveInventoryType('CA446TravelLedger'));let claim=CaelumTrucazoClaims.Read(user);
                ledger.Equipment=i==0?Equipment:null;ledger.Food=ReservedFood.Owner==claim.Vault?ReservedFood:null;
                ledger.Copper=claim.Copper;ledger.Reputation=user.GetPersistentCharacterState(true).TrucazoReputation;
            }
        }
        Duel.Release();Phase=9;Level.ChangeLevel('T444',0,CHANGELEVEL_NOINTERMISSION);
    }
    void Arrived()
    {
        for(int i=0;i<PEERS;i+=2)
        {
            let user=CaelumPlayer(players[i].mo);let ledger=CA446TravelLedger(user.FindInventory('CA446TravelLedger'));let claim=CaelumTrucazoClaims.Read(user);
            Check(ledger!=null && claim!=null && claim.Vault!=null && claim.Copper==ledger.Copper,"native map travel retains pending money and owned vault");
            if(ledger==null || claim==null)return;
            Check(user.GetPersistentCharacterState(true).TrucazoReputation==ledger.Reputation,"personal reputation survives native map travel");
            if(ledger.Equipment!=null)Check(ledger.Equipment.Owner==claim.Vault && ledger.Equipment.Durability==345,"native travel preserves original equipment reference and wear");
            if(ledger.Food!=null)Check(ledger.Food.Owner==claim.Vault && CaelumFoodInventory.GetLots(ledger.Food).Units()==2,"native travel retains nested food batches");
            user.DerivedStats.CarryCapacity=100000;Check(claim.Claim(user,claim.Serial) && claim.Pending()==0 && claim.Copper==0,"pending prizes claim at destination without duplication");
        }
        Complete=true;Console.Printf("CA446 RESULT %s checks=%d travel",Failures==0?"PASS":"FAIL",Checks);
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca446_restored" && e.Player==0){Restored=true;RestoreStamp=level.time;}}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0 || Complete)return;
        if(Phase==7 && !Restored && consoleplayer==0 && !Saved){Saved=true;SavegameManager.GetManager().DoSave(0,"CA446 reserved native stakes");return;}
        if(Phase==8 && consoleplayer==0 && !SavedAwards){SavedAwards=true;SavegameManager.GetManager().DoSave(0,"CA446 pending prizes");return;}
        let user=CaelumPlayer(players[consoleplayer].mo);let link=CaelumCardSeat.Read(user);if(link==null)return;
        int serial=link.LastSerial;if(SentAny && SentSerial==serial)return;
        int op=-1,arg=0;
        if(Phase==1 && consoleplayer==0){op=CaelumCardDuel.CONSENT;arg=1;}
        else if(Phase==2 && consoleplayer==0)op=CaelumCardDuel.SELECT_GAME;
        else if(Phase==3 && consoleplayer==0){op=CaelumCardDuel.SELECT_TEAM_SIZE;arg=PEERS;}
        else if(Phase==4 && consoleplayer==0)op=CaelumCardDuel.SELECT_CONSEQUENCES;
        else if(Phase==6 && Duel!=null)
        {int next=0;while(next<PEERS && (Duel.Accepted&(1<<next))!=0)next++;if(consoleplayer==next)op=CaelumCardDuel.CONSENT;}
        if(op>=0 && SentPhase!=Phase){SentAny=true;SentSerial=serial;SentPhase=Phase;SendNetworkEvent("ca_card_table",op,arg,serial);}
    }
    override void WorldTick()
    {
        if(Complete || level.maptime<105)return;
        if(DISCONNECT!=0 && Phase==7 && !Restored && !playeringame[PEERS-1])
        {if(!Duel.Suspended)return;Check(!Duel.Wagers.Settled && !Duel.Finished() && Equipment.Owner==Duel.Wagers.Offers[0].Claim.Item.Owner,"disconnect preserves custody without automatic settlement");Complete=true;Console.Printf("CA446 RESULT %s checks=%d disconnected",Failures==0?"PASS":"FAIL",Checks);return;}
        for(int i=0;i<PEERS;i++)if(!playeringame[i] || !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let a=CaelumPlayer(players[0].mo);
        if(level.MapName=='T444'){Arrived();return;}
        if(Phase==0)
        {
            Check(CaelumDiningWorld.Place(1444,(0,512,0),3),"native large table placed");Table=CaelumDiningWorld.Find(1444);if(Table==null){Complete=true;return;}
            for(int i=0;i<PEERS;i++)
            {let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];vector3 away=chair.Pos-Table.Pos;user.SetOrigin(chair.Pos+away*(48/Max(1.0,away.Length())),false);user.Vel=(0,0,0);user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair) && CaelumCardSeat.Interact(user),"native participant sits and opens the table");}
            CaelumPlayer(players[PEERS-1].mo).GiveInventoryType('CaelumTarotDeck');Phase=1;return;
        }
        if(Phase==1 && CaelumCardSeat.Session(a)!=null){Duel=CaelumCardSeat.Session(a);Phase=2;}
        else if(Phase==2 && Duel.Game==CaelumCardDuel.GAME_TRUCAZO)Phase=3;
        else if(Phase==3 && Duel.TeamMode)Phase=4;
        else if(Phase==4 && Duel.Consequences){Offers();Phase=6;}
        else if(Phase==6 && Duel.Started)Reserved();
        else if(Phase==7 && Restored && level.time>=RestoreStamp+105)
        {Check(State()==SavedState && Duel.Wagers.Reserved && !Duel.Wagers.Settled,"common checkpoint restores exact hands deck money and escrow");Check(Equipment==Duel.Wagers.Offers[0].Claim.Item,"saved custody preserves actual item reference");Check(!Duel.Ranked && Duel.Competitive==null,"pre-ranking saved match retains its non-ranked contract");Settlement();}
        else if(Phase==8 && level.time>=Max(PendingStamp,RestoreStamp)+105){if(TRAVEL!=0)TravelAwards();else ClaimAwards();}
    }
}
