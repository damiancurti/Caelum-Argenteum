class CaelumCampFireSession : Inventory
{
    bool Open;
    String OriginMap;
    CaelumCampFire Fire;
    CaelumCampPot SelectedPot;
    int Selected,Maximum;
    bool CookingPage;
    int CookingRefreshTic;
    String CookingLabels[3];
    static clearscope CaelumCampFireSession Find(CaelumPlayer user)
    {return user==null?null:CaelumCampFireSession(user.FindInventory('CaelumCampFireSession'));}
    static bool Show(CaelumPlayer user,CaelumCampFire fire)
    {
        if((!CaelumCampTask.Available(user) && !(CaelumCampCooking.Owns(user,fire) && CaelumCampCooking.Attended(user,false)))
            || (fire!=null && !fire.CanManage(user)))return false;
        let session=Find(user);if(session==null)session=CaelumCampFireSession(user.GiveInventoryType('CaelumCampFireSession'));
        if(session==null)return false;
        session.Fire=fire;session.OriginMap=level.MapName;session.Open=true;
        session.CookingPage=fire!=null && CaelumCampCooking.Owns(user,fire);session.CookingRefreshTic=-1;
        session.SelectedPot=null;session.NextPot(user);
        session.Selected=CaelumCampData.FIRE_CAPACITY_G;session.Refresh(user);user.EquipmentMenuOpen=false;return true;
    }
    bool Valid(CaelumPlayer user)
    {return OriginMap==level.MapName && (CaelumCampTask.Available(user) || (CaelumCampCooking.Owns(user,Fire) && CaelumCampCooking.Attended(user,false)))
        && (Fire==null || (!Fire.bDestroyed && Fire.CanManage(user) && (Fire.Busy==null || CaelumCampCooking.Owns(user,Fire))));}
    void Refresh(CaelumPlayer user)
    {
        Maximum=Min(CaelumCampData.FIRE_CAPACITY_G,user.CountCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1));
        if(Fire!=null)Maximum=Min(Maximum,int(Floor(Max(0.0,CaelumCampData.FIRE_CAPACITY_G-Fire.Fuel.FuelGrams))));
        Selected=Clamp(Selected,0,Maximum);
        if(SelectedPot==null || SelectedPot.Owner!=user || SelectedPot.InMagicBox)NextPot(user);
        if(CookingRefreshTic<0 || level.Time-CookingRefreshTic>=TICRATE)
        {
            CookingRefreshTic=level.Time;
            for(int row=0;row<3;row++)
            {
                int recipe=CaelumMealData.FIRST_RECIPE+row+1;
                String label="";
                for(int slot=0;CaelumCookingData.InputMaterial(recipe,slot)>=0;slot++)
                {
                    int id=CaelumCookingData.InputMaterial(recipe,slot);if(id==CaelumConstants.MATERIAL_COAL)continue;
                    if(label.Length()>0)label=label.."; ";
                    label=label..String.Format("%d g %s",CaelumCookingData.InputGrams(recipe,slot),
                        StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id),false));
                }
                if(CaelumCookingData.WaterLiters(recipe)>0)label=label..String.Format(StringTable.Localize("CA_CAMP_COOK_WATER",false),CaelumCookingData.WaterLiters(recipe));
                label=label..String.Format(StringTable.Localize("CA_CAMP_COOK_RECIPE_TIME",false),CaelumCookingData.Seconds(recipe)/60,
                    CaelumCampPhysics.FuelGrams(CaelumCookingData.Seconds(recipe))/1000);
                if(!user.DirectCraftingRecipeKnown(recipe,1))label=StringTable.Localize("CA_CAMP_COOK_UNLEARNED",false).." "..label;
                CookingLabels[row]=label;
            }
        }
    }
    void NextPot(CaelumPlayer user)
    {
        CaelumCampPot first,next;bool found=SelectedPot==null;
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {
            let pot=CaelumCampPot(item);if(pot==null || pot.InMagicBox || CaelumWaterBoiling.Locked(pot))continue;
            if(first==null)first=pot;
            if(found && next==null)next=pot;
            if(pot==SelectedPot)found=true;
        }
        SelectedPot=next!=null?next:first;
    }
    void Act(CaelumPlayer user,int choice)
    {
        if(!Open || !Valid(user)){Open=false;return;}Refresh(user);
        if(choice==0){Open=false;return;}
        bool succeeded=true;
        if(choice==1)
        {
            if(Fire==null){succeeded=CaelumCampFireWork.Begin(user,null,CaelumCampFireWork.CREATE_FIRE,Selected);if(succeeded)Open=false;}
            else if(Fire.Fuel.Lit)Fire.Extinguish();
            else {succeeded=CaelumCampCooking.Owns(user,Fire)?CaelumCampCooking.Relight(user,Fire):CaelumCampFireWork.Begin(user,Fire,CaelumCampFireWork.LIGHT_FIRE);if(succeeded)Open=false;}
        }
        else if(choice==2)Selected=Max(0,Selected-1);
        else if(choice==3)Selected=Min(Maximum,Selected+1);
        else if(choice==4)Selected=Max(0,Selected-1000);
        else if(choice==5)Selected=Min(Maximum,Selected+1000);
        else if(choice==6)Selected=Maximum;
        else if(choice==7 && Fire!=null)succeeded=Fire.LoadWood(user,Selected);
        else if(choice==8 && Fire!=null){Fire.Advance();succeeded=Fire.RecoverWood(user);}
        else if(choice==9 && Fire!=null){succeeded=CaelumCampFireWork.Begin(user,Fire,CaelumCampFireWork.REMOVE_FIRE);if(succeeded)Open=false;}
        else if(choice==10 && Fire!=null)succeeded=Fire.Pot!=null?Fire.TakePot(user):Fire.MountPot(user,SelectedPot);
        else if(choice==11)NextPot(user);
        else if(choice==12 && Fire!=null)CookingPage=true;
        else if(choice>=13 && choice<=15 && Fire!=null)
        {succeeded=CaelumCampCooking.Begin(user,Fire,CaelumMealData.FIRST_RECIPE+choice-12);if(succeeded)Open=false;}
        else if(choice==16)CookingPage=false;
        else if(choice==17 && CaelumCampCooking.Owns(user,Fire))
        {user.CancelCraftingTask();CookingPage=false;}
        else if(choice==18 && CaelumCampCooking.Owns(user,Fire))
        {succeeded=CaelumCampCooking.Relight(user,Fire);if(succeeded)Open=false;}
        if(!succeeded)CaelumNotifications.Notify(user,StringTable.Localize("CA_CAMP_FIRE_FAILED",false));
        Refresh(user);
    }
    override void Tick(){Super.Tick();if(Open){let user=CaelumPlayer(Owner);if(!Valid(user))Open=false;else Refresh(user);}}
    override void PreTravelled(){Open=false;Fire=null;Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
