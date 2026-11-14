// #684: seis materiales y sus tres tiers nativos, sin cambiar reglas.
class CA684OreCamera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA684OreEvents : EventHandler
{
    Array<CaelumMaterialPickup> Drops;
    Array<CaelumMaterialPickup> Remainders;
    Array<int> MaterialKinds;
    Array<int> Tiers;
    CA684OreCamera Camera;
    int Failures;
    int DetailIndex;
    int DetailAngle;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA684 %s %s",okay?"PASS":"FAIL",label);}
    void Metadata(CaelumMaterialPickup item,int amount,String label)
    {
        Check(item.CompanionHistory!=null && item.CompanionHistory.Records.Size()==1,label.." provenance record");
        if(item.CompanionHistory!=null && item.CompanionHistory.Records.Size()==1)
        {
            let record=item.CompanionHistory.Records[0];
            Check(record.Loan && record.RefusedStage==2,label.." provenance marker");
        }
        let lots=CaelumContaminationStack.Prepare(item);
        Check(lots!=null && lots.Units()==amount,label.." surface ledger units");
        if(lots!=null)
        {
            int first=0,second=0;
            for(int i=0;i<lots.Lots.Size();i++)
            {
                if(lots.Lots[i].CreatedStamp==100)first+=lots.Lots[i].Units;
                if(lots.Lots[i].CreatedStamp==200)second+=lots.Lots[i].Units;
            }
            Check(first==(amount==2?2:amount==3?1:3) && second==(amount==2?0:2),label.." original lot boundaries");
        }
        Check(CaelumContaminationStack.Value(item)>0,label.." contamination retained");
        Check(!item.InMagicBox && item.LimboQuestUnits==0,label.." location and quest flags");
    }
    void Verify()
    {
        Check(Drops.Size()==18 && Remainders.Size()==18,"all six materials and three tiers");
        for(int index=0;index<Drops.Size();index++)
        {
            let item=Drops[index];let held=Remainders[index];String label=String.Format("ore %d",index);
            Check(item!=null && held!=null,label.." saved references");if(item==null || held==null)continue;
            Check(item.Owner==null && held.Owner==players[0].mo,label.." world and held ownership");
            Check(item.Amount==2 && held.Amount==3,label.." split quantities");
            Check(item.GetSpecialType()==MaterialKinds[index] && held.GetSpecialType()==MaterialKinds[index]
                && item.GetSpecialTier()==Tiers[index] && held.GetSpecialTier()==Tiers[index],label.." material and tier identity");
            Check(CaelumPlayer(players[0].mo).FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,MaterialKinds[index],Tiers[index])==held,label.." distinct native stack");
            Check(item.sprite==Actor.GetSpriteIndex(item.GetMaterialSpriteName()) && item.Icon==held.Icon,label.." original sprite and icon");
            let defaults=GetDefaultByType('CaelumMaterialPickup');
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale,label.." native collision and scale");
            Check(item.GetUnitWeight()==CaelumMaterialRules.UnitWeight(MaterialKinds[index]),label.." unit weight");
            Check(abs(item.Pos.Z-item.floorz)<0.01,label.." floor contact");
            Metadata(item,2,label.." dropped");Metadata(held,3,label.." held");
        }
        Console.Printf("CA684 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca684_prepare")
        {
            static const int kinds[]={61,62,63,64,65,66};
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int tier=1;tier<=3;tier++)for(int kind=0;kind<kinds.Size();kind++)
            {
                int index=Drops.Size();String label=String.Format("ore %d",index);
                let incoming=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',(0,0,0),NO_REPLACE));
                incoming.args[0]=kinds[kind];incoming.args[1]=tier;incoming.Amount=5;incoming.UpdateMaterialVisuals();
                let lots=new('CaelumFoodLots');lots.Ensure(CaelumFoodData.RATION,0,0);
                lots.Add(3,25,100);lots.Add(2,50,200);CaelumContaminationStack.SetLots(incoming,lots);
                Check(incoming.CallTryPickup(user),label.." native pickup");
                let owned=CaelumMaterialPickup(user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,kinds[kind],tier));
                Check(owned!=null && owned.Amount==5,label.." native distinct ownership");if(owned==null)continue;
                owned.CompanionHistory=new('CaelumCompanionHistory');owned.CompanionHistory.Revision=1;
                let record=new('CaelumCompanionItemRecord');record.Loan=true;record.RefusedStage=2;owned.CompanionHistory.Records.Push(record);
                owned.InMagicBox=true;Check(owned.GetCarriedWeight()==0,label.." existing boxed weight");owned.InMagicBox=false;
                owned.LimboQuestUnits=1;Check(owned.CreateTossable(2)==null,label.." quest drop guard");owned.LimboQuestUnits=0;
                let dropped=CaelumMaterialPickup(owned.CreateTossable(2));Check(dropped!=null,label.." native split");if(dropped==null)continue;
                dropped.SetOrigin(((index%6-2.5)*40,(index/6-1)*46,0),false);
                Drops.Push(dropped);Remainders.Push(owned);MaterialKinds.Push(kinds[kind]);Tiers.Push(tier);
            }
            Camera=CA684OreCamera(Actor.Spawn('CA684OreCamera',(0,-180,180),NO_REPLACE));
            Camera.Angle=90;Camera.Pitch=43;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca684_view")
        {
            if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;
            players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
            if(hud!=null){if(e.Args[0]==4)hud.HUDFont=Font.GetFont("CaelumMono");else hud.HUDFont=null;}
            if(e.Args[0]==0){Camera.SetOrigin((0,-180,180),false);Camera.Angle=90;Camera.Pitch=43;}
            if(e.Args[0]==1){Camera.SetOrigin((0,-180,50),false);Camera.Angle=90;Camera.Pitch=10;}
            if(e.Args[0]==2){Camera.SetOrigin((180,0,60),false);Camera.Angle=180;Camera.Pitch=14;}
            if(e.Args[0]==3){Camera.SetOrigin((0,-108,35),false);Camera.Angle=90;Camera.Pitch=25;}
            if(e.Args[0]==5){Camera.SetOrigin((0,-53,35),false);Camera.Angle=90;Camera.Pitch=22;}
            if(e.Args[0]==6){Camera.SetOrigin((-55,38,35),false);Camera.Angle=270;Camera.Pitch=22;}
            if(e.Args[0]==7){Camera.SetOrigin((0,180,60),false);Camera.Angle=270;Camera.Pitch=14;}
            Camera.ClearInterpolation();
        }
        if(e.Name=="ca684_detail" || e.Name=="ca684_next" || e.Name=="ca684_rotate")
        {
            if(Drops.Size()==0)return;
            if(e.Name=="ca684_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca684_next")DetailIndex=(DetailIndex+1)%6;
            if(e.Name=="ca684_rotate")DetailAngle=DetailAngle==90?160:DetailAngle==160?270:90;
            if(DetailIndex<0 || DetailIndex>=6)return;if(DetailAngle==0)DetailAngle=90;
            static const double extents[]={96.56920453808276,104.00000000000001,106.00000000000001,101.0,106.0,99.5188071884453};static const double heights[]={43.5,52.00000000000001,53.00000000000001,50.5,53.0,48.0};
            let item=Drops[DetailIndex];double distance=max(9.,extents[DetailIndex]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[DetailIndex]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*0.5),false);
            Camera.Angle=angle;Camera.Pitch=26.565051;players[0].camera=Camera;Camera.ClearInterpolation();
        }

        if(e.Name=="ca684_verify")Verify();
        if(e.Name=="ca684_pickup")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int index=0;index<Drops.Size();index++)
            {
                String label=String.Format("ore %d",index);
                Check(Drops[index].CallTryPickup(user),label.." repickup");
                let owned=CaelumMaterialPickup(user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,MaterialKinds[index],Tiers[index]));
                Check(owned==Remainders[index] && owned.Amount==5,label.." identical merged stack");
                if(owned!=null)Metadata(owned,5,label.." recovered");
            }
            Console.Printf("CA684 COMPLETE failures=%d",Failures);
        }
    }
}
