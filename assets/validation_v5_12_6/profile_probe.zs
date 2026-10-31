// Fixture: pertenencias distintas y un mundo de destino que debe permanecer intacto.
class CA434ProfileProbe : StaticEventHandler
{
    bool Ready,Done;
    ui bool Saved;
    void Check(bool okay,String text){Console.Printf("CA434 %s %s",okay?"PASS":"FAIL",text);}
    override void UiTick()
    {
        if(Ready && !Saved && consoleplayer==0)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA434 native profile checkpoint");}
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        let source=a.GetPersistentCharacterState(false);let destination=b.GetPersistentCharacterState(false);
        if(destination.ExternalProfileId=="profile-native-fixture")
        {
            if(destination.ProfileImportApplied!=destination.ProfileImportSerial)return;
            Check(destination.ProfileImportApplied==1,"native import reconciles once");
            Check(destination.IdentityProfile==b.CharacterProfile && destination.IdentityAllocation==b.CharacterAllocation,"identity references bind to imported record");
            Check(b.CharacterAllocation.AttributeBonus[0]==17,"personal attribute allocation retained");
            Check(destination.TarotOwned[12] && destination.KnownCraftingRecipe[17],"Tarot and learned recipe retained");
            Check(destination.PalomoMerchantStock[0]==91,"destination shop stock stays in its campaign");
            Check(!destination.HouseRestitutionConfirmed,"source property title does not travel");
            let coins=b.FindInventory('CaelumCopperCoin');
            Check(coins!=null && coins.Amount==321,"native wallet retains exact quantity");
            let water=CaelumWaterContainer(b.FindInventory('CaelumCanteenLarge'));
            Check(water!=null && Abs(water.WaterLiters-.625)<.000001,"water volume retained");
            Check(water!=null && water.WaterQuality==1 && water.WaterTemperatureRevision>0,"water quality and temperature schema retained");
            let table=CaelumDiningSetItem(b.FindInventory('CaelumSmallDiningSetItem'));
            Check(table!=null && table.Table!=null && table.Table.PackedItem==table,"packed table keeps reciprocal ownership");
            Check(table!=null && table.Table!=null && table.Table.Chairs[0]!=null && table.Table.Chairs[1]!=null,"both actual packed chairs retained");
            let food=table!=null && table.Table!=null?table.Table.Items[0]:null;
            Check(food!=null && food.Owner==table.Table && food.Amount==3,"table food retains amount and actual owner");
            Check(food!=null && CaelumFoodInventory.GetLots(food).OldestContamination()>=27,"food deterioration is not reset");
            Check(b.FindInventory('CaelumWorldClock')!=a.FindInventory('CaelumWorldClock'),"destination world controller was not copied from source");
            Check(b.player.ReadyWeapon!=null && b.player.ReadyWeapon.Owner==b,"native ready weapon has the imported owner");
            Done=true;Ready=true;Console.Printf("CA434 RESULT imported peer=%d",consoleplayer);return;
        }
        a.CharacterAllocation.AttributeBonus[0]=17;a.ApplyCharacterProfile();
        source.TarotOwned[12]=true;source.KnownCraftingRecipe[17]=true;
        source.PalomoMerchantVersion=1;source.PalomoMerchantStock[0]=23;source.HouseRestitutionConfirmed=true;
        destination.PalomoMerchantVersion=1;destination.PalomoMerchantStock[0]=91;
        let coins=a.GiveInventoryType('CaelumCopperCoin');coins.Amount=321;
        let water=CaelumWaterContainer(a.GiveInventoryType('CaelumCanteenLarge'));
        water.WaterLiters=.625;water.WaterQuality=1;water.WaterQualityRevision=1;
        water.WaterTemperatureC=42;water.WaterTemperatureRevision=1;
        let bundle=CaelumDiningSetItem(a.GiveInventoryType('CaelumSmallDiningSetItem'));
        bundle.Table=CaelumPortableDiningTable(Actor.Spawn('CaelumPortableSmallTable',(0,512,0),NO_REPLACE));
        bundle.Table.PackedItem=bundle;bundle.Table.ConfigureParts();bundle.Park();
        let food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation',(0,512,0),NO_REPLACE));
        food.Amount=3;food.AttachToOwner(bundle.Table);bundle.Table.Items[0]=food;
        let lots=CaelumFoodInventory.Prepare(food);lots.Lots[0].BaseContamination=27;
        a.PersistCharacterState();b.PersistCharacterState();
        Check(bundle.Table.Chairs[0]!=null && bundle.Table.Chairs[1]!=null,"source owns packed table and chairs");
        Check(food.Owner==bundle.Table && coins.Owner==a,"native source inventory ownership valid");
        Check(destination.PalomoMerchantStock[0]!=source.PalomoMerchantStock[0],"distinct source and destination world stock");
        let world=CaelumCooperativeQuests.Get(a);
        a.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_FOLLOWING);
        a.SetPlayerPrisonerRescueState(0,CaelumConstants.PRISONER_STATE_EXTRACTED);
        a.SetPlayerPrisonerRescueState(1,CaelumConstants.PRISONER_STATE_FOLLOWING);
        Check(world.Rescue[0]!=null && world.Rescue[0].Contains(source),"source campaign records earned reward eligibility");
        Check(!source.PrisonerRewardClaimed[0],"earned source reward remains pending for the return test");
        Check(source.LawfulIdentity!=null && destination.LawfulIdentity!=null,"both native identities initialized before registration");
        Check(source.PrisonerRescueState[1]==CaelumConstants.PRISONER_STATE_FOLLOWING,"independent personal investigation remains pending");
        // El escenario comienza por comando y abre su narración de diagnóstico.
        // Cerrarla explícitamente deja un punto válido de traslado; el control
        // de producción sigue rechazando conversaciones activas.
        for(int i=0;i<2;i++)
        {
            let user=CaelumPlayer(players[i].mo);
            let record=user.GetPersistentCharacterState(false);
            record.DemoNarrativeDelivered|=CaelumDemoNarrative.ObservedEvents(record);
            record.DemoNarrativePending=0;
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
        }
        Done=true;Ready=true;Console.Printf("CA434 RESULT prepared peer=%d",consoleplayer);
    }
}
