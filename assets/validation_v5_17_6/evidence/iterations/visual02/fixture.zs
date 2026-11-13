// #656: sala aislada con los objetos nativos; no modifica las reglas de juego.
class CA656DocumentCamera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA656DocumentEvents : EventHandler
{
    Array<Inventory> Drops;
    Array<Inventory> Remainders;
    Array<double> Weights;
    CA656DocumentCamera Camera;
    int Failures;
    int DetailIndex;
    int DetailAngle;
    void Check(bool okay, String label)
    {
        if(!okay) Failures++;
        Console.Printf("CA656 %s %s",okay?"PASS":"FAIL",label);
    }
    void Metadata(Inventory item, String label)
    {
        let special=CaelumSpecialInventoryItem(item);
        if(special!=null)
        {
            Check(special.CompanionHistory!=null && special.CompanionHistory.Records.Size()==1,label.." provenance record");
            if(special.CompanionHistory!=null && special.CompanionHistory.Records.Size()==1)
            {
                let record=special.CompanionHistory.Records[0];
                Check(record.Loan && record.Refused && record.RefusedStage==2,label.." provenance markers");
            }
            Check(!special.InMagicBox && special.LimboQuestUnits==0,label.." location and quest flags");
            Check(CaelumContaminationStack.Eligible(item) && CaelumContaminationStack.Value(item)>0,label.." contamination retained");
        }
        let book=CaelumRecipeBook(item);
        if(book!=null)
            Check(book.Sheets[0] && book.Sheets[CaelumRecipeLearning.SLOT_COUNT-1],label.." recipe pages retained");
        let key=CaelumWeightedKey(item);
        if(key!=null)Check(key.GetKeyType()==CaelumConstants.KEY_SILVER,label.." native key identity");
    }
    void Verify()
    {
        Check(Drops.Size()==6 && Remainders.Size()==6,"six native inventory classes");
        for(int index=0;index<Drops.Size();index++)
        {
            let item=Drops[index];String label=String.Format("item %d",index);
            Check(item!=null,label.." saved reference");if(item==null)continue;
            let defaults=GetDefaultByType(item.GetClass());
            bool stacked=defaults.MaxAmount>1;
            Check(item.Owner==null && item.Amount==(stacked?2:1),label.." dropped quantity and ownership");
            if(stacked)Check(Remainders[index]!=null && Remainders[index].Owner==players[0].mo && Remainders[index].Amount==3,label.." held remainder");
            else Check(players[0].mo.FindInventory(item.GetClass())==null,label.." unique item left inventory");
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale,label.." native collision and scale");
            Check(item.Icon==defaults.Icon && item.sprite==defaults.SpawnState.sprite,label.." original icon and spawn state");
            Check(abs(item.Pos.Z-item.floorz)<0.01,label.." floor contact");
            let special=CaelumSpecialInventoryItem(item);
            if(special!=null)Check(abs(special.GetUnitWeight()-Weights[index])<0.000001,label.." unit weight");
            Metadata(item,label);
        }
        Console.Printf("CA656 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca656_prepare")
        {
            static const class<Inventory> kinds[]={'CaelumProcessingManual','CaelumSealedLetter','CaelumSilverKey','CaelumCleaningCloth','CaelumIronIngot','CaelumRecipeBook'};
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int index=0;index<kinds.Size();index++)
            {
                let previous=user.FindInventory(kinds[index]);if(previous!=null)previous.Destroy();
                let incoming=Inventory(Actor.Spawn(kinds[index],(0,0,0),NO_REPLACE));
                incoming.Amount=incoming.MaxAmount>1?5:1;
                let book=CaelumRecipeBook(incoming);
                if(book!=null){book.Sheets[0]=true;book.Sheets[CaelumRecipeLearning.SLOT_COUNT-1]=true;}
                Check(incoming.CallTryPickup(user),String.Format("item %d native pickup",index));
                let owned=Inventory(user.FindInventory(kinds[index]));
                Check(owned!=null,String.Format("item %d owned",index));if(owned==null)continue;
                let special=CaelumSpecialInventoryItem(owned);
                if(special!=null)
                {
                    special.CompanionHistory=new('CaelumCompanionHistory');special.CompanionHistory.Revision=1;
                    let record=new('CaelumCompanionItemRecord');record.Loan=true;record.Refused=true;record.RefusedStage=2;
                    special.CompanionHistory.Records.Push(record);
                    CaelumContaminationStack.Set(special,25);
                    special.LimboQuestUnits=1;
                    Check(special.CreateTossable(1)==null,String.Format("item %d quest drop guard",index));
                    special.LimboQuestUnits=0;
                    Weights.Push(special.GetUnitWeight());
                }
                else Weights.Push(0);
                let dropped=Inventory(owned.CreateTossable(owned.MaxAmount>1?2:1));
                Check(dropped!=null,String.Format("item %d native toss",index));if(dropped==null)continue;
                dropped.SetOrigin(((index%3-1)*55,(index/3-1)*55,0),false);
                Drops.Push(dropped);Remainders.Push(owned.MaxAmount>1?owned:null);
            }
            Camera=CA656DocumentCamera(Actor.Spawn('CA656DocumentCamera',(0,-180,180),NO_REPLACE));
            Camera.Angle=90;Camera.Pitch=43;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca656_view")
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
        if(e.Name=="ca656_detail" || e.Name=="ca656_next" || e.Name=="ca656_rotate")
        {
            if(Drops.Size()==0)return;
            if(e.Name=="ca656_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca656_next")DetailIndex=(DetailIndex+1)%Drops.Size();
            if(e.Name=="ca656_rotate")DetailAngle=DetailAngle==90?160:DetailAngle==160?270:90;
            if(DetailIndex<0 || DetailIndex>=Drops.Size())return;if(DetailAngle==0)DetailAngle=90;
            static const double extents[]={108.07017543859648,93.0,87.0,101.99999999999999,112.0,108.07017543859648};static const double heights[]={8.007017543859648,2.13125,2.44320201085718,5.980975397802475,12.727272727272727,8.007017543859648};
            let item=Drops[DetailIndex];double distance=max(9.,extents[DetailIndex]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[DetailIndex]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*0.5),false);
            Camera.Angle=angle;Camera.Pitch=26.565051;players[0].camera=Camera;Camera.ClearInterpolation();
        }
        if(e.Name=="ca656_verify")Verify();
        if(e.Name=="ca656_pickup")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int index=0;index<Drops.Size();index++)
            {
                let kind=Drops[index].GetClass();int expected=Drops[index].MaxAmount>1?5:1;
                Check(Drops[index].CallTryPickup(user),String.Format("item %d repickup",index));
                let owned=Inventory(user.FindInventory(kind));
                Check(owned!=null && owned.Amount==expected,String.Format("item %d recovered quantity",index));
                if(owned!=null)Metadata(owned,String.Format("item %d recovered",index));
            }
            Console.Printf("CA656 COMPLETE failures=%d",Failures);
        }
    }
}
