// Escena desechable de aceptación #443/#445/#444/#446; no cambia la campaña del autor.
class CA590NetworkProbe : EventHandler
{
    const PEERS=2;
    const SCENE=0;
    bool Ready;
    ui int CheckpointTic,CheckpointSerial;
    ui bool CheckpointSaved;
    override void UiTick()
    {
        if(!Ready || consoleplayer!=0 || gamestate!=GS_LEVEL || level.time<CheckpointTic+350)return;
        for(int i=0;i<PEERS;i++)if(!playeringame[i] || !CaelumPlayerAuthority.CanRead(CaelumPlayer(players[i].mo)))return;
        let link=CaelumCardSeat.Read(CaelumPlayer(players[0].mo));if(link==null)return;
        int serial=link.Duel!=null?link.Duel.Serial:link.Tournament!=null?link.Tournament.Serial:link.LastSerial;
        if(CheckpointSaved && serial==CheckpointSerial)return;
        CheckpointTic=level.time;CheckpointSerial=serial;CheckpointSaved=true;
        SavegameManager.GetManager().DoSave(0,"V5.14 author common checkpoint");
    }
    override void WorldTick()
    {
        if(Ready || level.maptime<105)return;
        for(int i=0;i<PEERS;i++)if(!playeringame[i] || !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        Ready=true;
        if(!CaelumDiningWorld.Place(514,(0,512,0),3)){Console.Printf("CA514 AUTHOR FAIL table");return;}
        let table=CaelumDiningWorld.Find(514);
        for(int i=0;i<PEERS;i++)
        {
            let user=CaelumPlayer(players[i].mo);let chair=table.Chairs[i];vector3 away=chair.Pos-table.Pos;
            user.SetOrigin(chair.Pos+away*(48/Max(1.0,away.Length())),false);user.Vel=(0,0,0);
            user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
            if(!CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair) || !CaelumCardSeat.Interact(user)){Console.Printf("CA514 AUTHOR FAIL seat %d",i);return;}
            let rest=CaelumRestState(user.FindInventory('CaelumRestState'));rest.AutoEating=false;rest.AutoDrinking=false;
            let record=user.GetPersistentCharacterState(true);record.EnsureTrucazoRating();record.TrucazoRating=CaelumTrucazoData.RATING_GRANDMASTER;
            for(int c=0;c<78;c++)record.TarotOwned[c]=true;
            let choice=CaelumTrucazoChoice.Get(user);for(int c=0;c<22;c++)choice.Selected[c]=c==1 || c==9 || c==17;
            user.GiveInventoryType('CaelumTarotDeck');let money=user.GiveInventoryType('CaelumSilverCoin');money.Amount=10;
            let food=user.GiveInventoryType('CaelumFoodRation');food.Amount=4;CaelumFoodInventory.Reconcile(food);
            let equipment=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',user.Pos,NO_REPLACE));equipment.AttachToOwner(user);
            equipment.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;equipment.ItemType=CaelumConstants.WEAPON_TYPE_MACHETE;
            equipment.Tier=2;equipment.EquipmentSize=1;equipment.Durability=345;equipment.ItemFlags=0;equipment.UnitWeight=1;equipment.PickupDataInitialized=true;
            equipment.AcquisitionResolved=true;equipment.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;user.EnsureEquipmentItemId(equipment);user.OnNativeInventoryChanged();
        }
        let a=CaelumPlayer(players[0].mo);let link=CaelumCardSeat.Read(a);
        if(SCENE==4)
        {
            if(!CaelumTrucazoTournament.Create(a,PEERS,0,link.LastSerial)){Console.Printf("CA514 AUTHOR FAIL tournament");return;}
        }
        else
        {
            if(!CaelumCardDuel.Invite(a,CaelumPlayer(players[1].mo),link.LastSerial)){Console.Printf("CA514 AUTHOR FAIL invite");return;}
            let duel=link.Duel;duel.Lobby(a,CaelumCardDuel.SELECT_GAME,duel.Serial);duel.SetTeamSize(PEERS);
            duel.Lobby(a,CaelumCardDuel.SELECT_MAJORS,duel.Serial);duel.Lobby(a,CaelumCardDuel.SELECT_SENSES,duel.Serial);
            if(SCENE==2)duel.Lobby(a,CaelumCardDuel.SELECT_CONSEQUENCES,duel.Serial);
            if(SCENE==3)duel.Lobby(a,CaelumCardDuel.SELECT_RANKED,duel.Serial);
        }
        Console.Printf("CA514 AUTHOR READY scene=%d players=%d; no consent or card play automated",SCENE,PEERS);
    }
}
