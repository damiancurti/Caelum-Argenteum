// Se calcula en play con las mismas condiciones de alcance que Used. El HUD
// sólo lee el resultado: no llama callbacks ni abre diálogos al mirar.
class CaelumInteractionHint : Object play
{
    static String ForActor(CaelumPlayer user,Actor object)
    {
        bool aimed=CaelumUseGeometry.AimedAt(user,object);
        if(!aimed && (object is 'CaelumPressureTrap' || object is 'CaelumTrapdoor'))
        {
            vector2 offset=object.Pos.XY-user.Pos.XY;
            double distance=offset.Length();
            aimed=distance<=user.UseRange+object.Radius && Abs(user.Pos.Z-object.Pos.Z)<48
                && offset.X*Cos(user.Angle)+offset.Y*Sin(user.Angle)>=distance*0.85;
        }
        if(!aimed || !user.CheckSight(object,SF_IGNOREVISIBILITY))return "";
        if(object is 'CaelumMazeChest')return StringTable.Localize("CA_MAZE_USE_CHEST",false);
        if(object is 'CaelumCupsAceEssence')return StringTable.Localize("CA_MAZE_USE_CARD",false);
        if(object is 'CaelumSewerTravelGate')return StringTable.Localize("CA_MAZE_USE_GATE",false);
        if(object is 'CaelumMazeRockPlate')return StringTable.Localize("CA_MAZE_HINT_ROCK",false);
        let part=CaelumVehiclePart(object);
        let vehicle=part!=null?part.Vehicle:CaelumTravelVehicle(object);
        if(vehicle!=null && vehicle.CanBoard(user))
            return StringTable.Localize(vehicle is 'CaelumMerchantShip'?"CA_USE_SHIP":"CA_USE_CART",false);
        let block=CaelumDiningBlock(object);
        let table=block!=null?block.Table:CaelumDiningTable(object);
        if(table!=null && table.CanReach(user))return StringTable.Localize("CA_USE_TABLE",false);
        let seat=CaelumRestFurniture(object);
        if(seat!=null && seat.CanReach(user))
            return StringTable.Localize(seat is 'CaelumRestChair'?"CA_USE_CHAIR":"CA_USE_BED",false);
        let reset=CaelumHazardResetSwitch(object);
        if(reset!=null)return StringTable.Localize("CA_USE_TRAPS_RESET",false);
        let lever=CaelumHazardReleaseSwitch(object);
        if(lever!=null)
        {
            String key=lever.args[0]==43602?"CA_USE_ROLLING_ROCK":lever.args[0]==43603?"CA_USE_FALLING_ROCK":"CA_USE_CRUSHER";
            return StringTable.Localize(key,false)..(lever.Spent?StringTable.Localize("CA_USE_SPENT",false):"");
        }
        let plate=CaelumPressureTrap(object);
        if(plate!=null)return StringTable.Localize(plate is 'CaelumTeleportTrap'?"CA_HINT_TELEPORT":plate is 'CaelumMagicMine'?"CA_HINT_MINE":"CA_HINT_CRUSHER",false);
        if(object is 'CaelumTrapdoor')return StringTable.Localize("CA_HINT_PIT",false);
        return "";
    }

    static String Find(CaelumPlayer user)
    {
        if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete)return "";
        let preview=CaelumChestPreviewState.Get(user);
        if(preview!=null && preview.Chest!=null)return "";
        let nearby=BlockThingsIterator.Create(user,user.UseRange+128);
        double best=1000000;String result="";
        while(nearby.Next())
        {
            let object=nearby.thing;if(object==user)continue;
            String hint=ForActor(user,object);if(hint=="")continue;
            double distance=Max(0,user.Distance2D(object)-object.Radius);
            if(distance<best){best=distance;result=hint;}
        }
        return result;
    }
}
