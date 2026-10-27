// #481: una consulta nativa de la mira por jugador; nunca busca todo el mapa.
// El resultado es transitorio. No modifica actores ni ejecuta Used al observar.
class CaelumTargetInfo : Object play
{
    Actor Subject;
    Line TargetLine;
    String Title;
    String Actions;
    double Distance;
    CaelumTargetTrace Sight;

    static clearscope String L(String key){return StringTable.Localize(key,false);}

    static clearscope Actor CanonicalActor(Actor object)
    {
        if(object is 'CaelumSlidingDoorBlocker' || object is 'CaelumGateBlocker')return object.master;
        let block=CaelumDiningBlock(object);if(block!=null)return block.Table;
        let seat=CaelumSofaSeat(object);if(seat!=null)return seat.Sofa;
        let campPart=CaelumCampTentPart(object);if(campPart!=null)return campPart.Structure;
        let part=CaelumVehiclePart(object);if(part!=null)return part.Vehicle;
        return object;
    }

    static clearscope bool Observable(Actor object)
    {
        if(object==null || (object is "Inventory" && Inventory(object).Owner!=null))return false;
        // Estas puertas son disparadores invisibles frente a su geometría real.
        if(object is 'CaelumHousePortal' || object is 'CaelumWaterGateSwitch')return true;
        if(object.bInvisible || object.GetRenderStyle()==STYLE_None)return false;
        return object.Height>0 && object.Radius>0;
    }

    void Refresh(CaelumPlayer user)
    {
        Subject=null;TargetLine=null;Title="";Actions="";Distance=0;
        if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete)return;
        vector3 direction=(Cos(user.Angle)*Cos(user.Pitch),Sin(user.Angle)*Cos(user.Pitch),-Sin(user.Pitch));
        vector3 origin=user.Pos+(0,0,user.ViewHeight);
        if(Sight==null)Sight=new("CaelumTargetTrace");
        bool hit=Sight.Trace(origin,level.PointInSector(origin.XY),direction,PLAYERMISSILERANGE,
            TRACE_PortalRestrict,Line.ML_BLOCKING|Line.ML_BLOCKEVERYTHING|Line.ML_BLOCKHITSCAN,false,user);
        Distance=hit?Sight.Results.Distance:PLAYERMISSILERANGE;
        Subject=hit?CanonicalActor(Sight.Results.HitActor):null;
        TargetLine=hit?Sight.Results.HitLine:null;
        FindNearbyLine(user,origin,direction);
        if(Subject!=null)Describe(user);
        else if(TargetLine!=null && TargetLine.special!=0)DescribeLine(user);
    }

    void FindNearbyLine(CaelumPlayer user,vector3 origin,vector3 direction)
    {
        // Las líneas de salida atravesables no detienen una traza visual.
        // Sólo buscamos sus segmentos en el blockmap del alcance nativo Use.
        let nearby=BlockLinesIterator.Create(user,user.UseRange);
        while(nearby.Next())
        {
            let line=nearby.CurLine;
            if(line.special==0 || (line.activation&SPAC_PlayerActivate)==0)continue;
            vector2 edge=line.v2.p-line.v1.p,offset=line.v1.p-origin.XY;
            double divisor=direction.X*edge.Y-direction.Y*edge.X;
            if(Abs(divisor)<0.000001)continue;
            double candidateDistance=(offset.X*edge.Y-offset.Y*edge.X)/divisor;
            double along=(offset.X*direction.Y-offset.Y*direction.X)/divisor;
            if(candidateDistance<0 || candidateDistance>user.UseRange || candidateDistance>Distance || along<0 || along>1)continue;
            vector3 point=origin+direction*candidateDistance;
            if(point.Z<line.frontsector.floorplane.ZatPoint(point.XY)
                || point.Z>line.frontsector.ceilingplane.ZatPoint(point.XY))continue;
            if(level.PointOnLineSide(origin.XY,line)!=0 && (line.activation&(SPAC_UseBack|SPAC_Cross|SPAC_AnyCross))==0)continue;
            Subject=null;TargetLine=line;Distance=candidateDistance;
        }
    }

    void DescribeLine(CaelumPlayer user)
    {
        bool travel=CaelumTargetPanelData.TravelSpecial(TargetLine.special);
        bool door=CaelumTargetPanelData.DoorSpecial(TargetLine.special);
        Title=L(travel?"CA_TARGET_TRANSITION":door?"CA_TARGET_DOOR":"CA_TARGET_SWITCH");
        if(Distance>user.UseRange){Actions=L("CA_TARGET_APPROACH");return;}
        if((TargetLine.activation&(SPAC_Use|SPAC_UseThrough|SPAC_UseBack))!=0)
            Actions=L(travel?"CA_TARGET_TRAVEL":door?"CA_TARGET_OPEN":"CA_TARGET_USE");
        else if((TargetLine.activation&(SPAC_Cross|SPAC_AnyCross))!=0)Actions=L("CA_TARGET_CROSS");
        else if((TargetLine.activation&SPAC_Impact)!=0)Actions=L("CA_TARGET_ATTACK");
    }

    void Describe(CaelumPlayer user)
    {
        Title=Subject.GetTag("");
        let item=CaelumSpecialInventoryItem(Subject);
        if(item!=null)Title=L(CaelumDisplayNames.GetSpecialItemKey(item.GetSpecialCategory(),item.GetSpecialType()));
        let equipment=CaelumEquipmentItem(Subject);
        if(equipment!=null)
        {
            switch(equipment.EquipmentKind)
            {
                case CaelumConstants.EQUIPMENT_KIND_WEAPON:Title=CaelumDisplayNames.FormatWeaponName(equipment.ItemType,equipment.Tier);break;
                case CaelumConstants.EQUIPMENT_KIND_ARMOR:Title=CaelumDisplayNames.FormatArmorTypeName(equipment.ItemType,equipment.Tier);break;
                case CaelumConstants.EQUIPMENT_KIND_SHIELD:Title=CaelumDisplayNames.FormatShieldName(equipment.ItemType,equipment.Tier);break;
                case CaelumConstants.EQUIPMENT_KIND_AMULET:Title=CaelumDisplayNames.FormatAmuletName(equipment.ItemType,equipment.Tier);break;
                case CaelumConstants.EQUIPMENT_KIND_SEAL:Title=CaelumDisplayNames.FormatSealName(equipment.ItemType,equipment.Tier);break;
            }
        }
        if(Title=="")Title=L(Subject is 'CaelumCombatActor'?"CA_TARGET_CHARACTER":"CA_TARGET_OBJECT");
        bool reachable=Distance<=user.UseRange;
        let chest=CaelumStashChest(Subject);
        let door=CaelumSlidingDoorLeaf(Subject);
        let house=CaelumHousePortal(Subject);
        let station=CaelumCraftingStation(Subject);
        let gate=CaelumSewerTravelGate(Subject);
        let domestic=CaelumDomesticFixture(Subject);
        if(Subject is 'CaelumReadingShelf')
        {Actions=L(reachable?"CA_STORED_READING_SHELF_HINT":"CA_TARGET_APPROACH");return;}
        if(Subject is 'CaelumReadingDesk')
        {Actions=L(reachable?"CA_STORED_READING_DESK_HINT":"CA_TARGET_APPROACH");return;}
        if(domestic is 'CaelumWaterFurniture')
        {Actions=L(!reachable || !domestic.CanReach(user)?"CA_TARGET_APPROACH":domestic is 'CaelumCistern'?"CA_CISTERN_HINT":"CA_FOUNTAIN_HINT");return;}
        if(domestic is 'CaelumDomesticToilet')
        {
            Actions=L(!reachable || !domestic.CanReach(user)?"CA_TARGET_APPROACH":CaelumHygieneTask.Active(user)?"CA_TOILET_CANCEL_HINT":"CA_TOILET_HINT");
            if(CaelumHygieneTask.Active(user))Actions=String.Format(L("CA_TOILET_PROGRESS"),user.CraftingTaskRemainingSeconds).."  |  "..Actions;
            return;
        }
        if(domestic is 'CaelumDomesticBathtub')
        {Actions=L(reachable && domestic.CanReach(user)?"CA_BATHTUB_POSE_HINT":"CA_TARGET_APPROACH");return;}
        if(domestic!=null && domestic.SuppliesWater())
        {Actions=L(reachable && domestic.CanReach(user)?"CA_DOMESTIC_WATER_HINT":"CA_TARGET_APPROACH");return;}
        if(door!=null || house!=null)Title=L(house!=null?"CA_TARGET_TRANSITION":"CA_TARGET_DOOR");
        if(house!=null && CaelumPropertyData.Offered(house.args[0]))Title=L("CA_PROPERTY_TITLE");
        if(gate!=null)Title=L(CaelumWorldCatalogue.ConnectionNameKey(gate.ConnectionId));
        if(station!=null)Title=L(CaelumCartographyServiceData.StationName(station.GetCraftingStationType()));
        if(Subject is 'CaelumFermentationStation')
            Title=String.Format(L("CA_FERMENTATION_TITLE"),Title,double(CaelumFermentationData.WORKING_CAPACITY_LITERS));
        if(Subject is 'CaelumDeployedTent')
        {Actions=L(reachable?"CA_TENT_USE_HINT":"CA_TARGET_APPROACH");return;}
        if(Subject is 'CaelumCampFire')
        {Actions=L(reachable?"CA_CAMP_FIRE_HINT":"CA_TARGET_APPROACH");return;}
        if(chest!=null)
        {
            if(reachable && chest.CanReachStorage(user))
                Actions=L(chest.IsChestLocked()?"CA_TARGET_UNLOCK":"CA_TARGET_OPEN")
                    ..(chest.CanCarryAsStorage()?"  |  "..L(chest is 'CaelumWardrobe'?"CA_TARGET_CARRY_WARDROBE":"CA_TARGET_CARRY_CHEST"):"");
            else Actions=L("CA_TARGET_APPROACH");
            return;
        }
        if(door!=null)
        {
            if(door.RuloArenaLocked)Actions=L("CA_TARGET_UNAVAILABLE");
            else Actions=L(!reachable?"CA_TARGET_APPROACH":door.args[3]>0 && !user.CheckKeys(door.args[3],false,true)?"CA_TARGET_LOCKED":"CA_TARGET_OPEN");
            return;
        }
        if(house!=null || gate!=null)
        {Actions=L(reachable?"CA_TARGET_TRAVEL":"CA_TARGET_APPROACH");return;}
        if(station!=null)
        {Actions=L(reachable && station.CanReachFrom(user)?"CA_TARGET_CRAFT":"CA_TARGET_APPROACH");return;}
        if(!reachable)return;
        Actions=CaelumInteractionHint.ForActor(user,Subject);
        if(Actions!="")return;
        if(Subject is 'CaelumCityMerchant')Actions=L("CA_TARGET_TRADE");
        else if(Subject is 'CaelumHousePortal')Actions=L("CA_TARGET_TRAVEL");
        else if(Subject is 'CaelumLandSource' && CaelumLandResourceData.IsHive(CaelumLandSource(Subject).Profile()))Actions=L("CA_TARGET_COLLECT");
        else if(Subject.HasConversation())Actions=L("CA_TARGET_TALK");
        else if(Subject is 'CaelumMovableProp')Actions=L("CA_TARGET_MOVE");
        else if(Subject is 'Inventory')Actions=L("CA_TARGET_PICKUP");
    }

    static clearscope double Attribute(Actor object,int index)
    {
        let playerUser=CaelumPlayer(object);
        if(playerUser!=null && playerUser.Attributes!=null)
        {
            let a=playerUser.Attributes;
            switch(index)
            {
                case 0:return a.Strength;case 1:return a.Toughness;case 2:return a.Constitution;
                case 3:return a.Agility;case 4:return a.Dexterity;case 5:return a.Resilience;
                case 6:return a.Charisma;case 7:return a.Empathy;case 8:return a.Eloquence;
                case 9:return a.Intelligence;case 10:return a.Patience;default:return a.Insight;
            }
        }
        let a=CaelumCombatActor(object);if(a==null)return 0;
        switch(index)
        {
            case 0:return a.CombatStrength;case 1:return a.CombatToughness;case 2:return a.CombatConstitution;
            case 3:return a.CombatAgility;case 4:return a.CombatEffectiveDexterity;case 5:return a.CombatResilience;
            case 6:return a.CombatCharisma;case 7:return a.CombatEmpathy;case 8:return a.CombatEloquence;
            case 9:return a.CombatEffectiveIntelligence;case 10:return a.CombatPatience;default:return a.CombatEffectiveInsight;
        }
    }

    static clearscope String VisibleAttribute(double value,double insight)
    {return value<insight?String.Format("%.1f",value):"¿?";}
}

// La devoluci?n Skip contin?a la misma traza: no salta paredes dentro del
// volumen de un auxiliar ni usa una segunda b?squeda global de actores.
class CaelumTargetTrace : LineTracer
{
    override ETraceStatus TraceCallback()
    {
        if(Results.HitType==TRACE_HitActor)
        {
            let object=CaelumTargetInfo.CanonicalActor(Results.HitActor);
            if(!CaelumTargetInfo.Observable(object))return TRACE_Skip;
        }
        return TRACE_Stop;
    }
}
