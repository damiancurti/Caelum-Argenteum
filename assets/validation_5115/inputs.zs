class CA162InputTarget : CaelumMandinga
{
    override void Tick()
    {
        if(ElementalStatus!=null)ElementalStatus.Tick(self);
        CaelumThermalRuntime.NPCStep(self);
    }
}
class CA162Inputs : EventHandler
{
    int Stage,Age,Passed,Failed,StaffId;
    double Before,Seconds,Heat,Regeneration,Rate;
    CaelumCombatActor Victim;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA162 %s %s",ok?"PASS":"FAIL",label);}
    CaelumEquipmentItem Item(CaelumPlayer u,int type)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;
        item.Tier=1;item.EquipmentSize=2;item.Durability=u.WeaponModel.GetMaximumDurabilityFor(type,1,2);
        item.UnitWeight=u.WeaponModel.GetWeightFor(type,1,2);item.PickupDataInitialized=true;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;item.Equipped=true;item.AttachToOwner(u);u.EnsureEquipmentItemId(item);return item;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            let item=Item(u,21);StaffId=item.ItemId;Item(u,20);
            u.ActivateExactEquippedWeapon(item);u.EnsureWeaponFamilySelectors();u.SelectNativeWeaponConfiguration(u.WeaponModel.WeaponType,0,1);
            u.CurrentAnima=u.DerivedStats.MaximumAnima*0.6;Regeneration=u.DerivedStats.AnimaRegenerationPerSecond;
            Victim=CaelumCombatActor(Actor.Spawn("CA162InputTarget",u.Pos+(96,0,0),NO_REPLACE));
            CaelumFolkloreCombatActor(Victim).InitializeUniformFolkloreProfile(6);Victim.ElementalStatus=new("CaelumElementalStatus");
            CaelumThermalBody.Get(Victim,true);CaelumThermalBody.Refresh(Victim,Victim.ThermalState);
            Victim.CaelumDiagnosticPassiveAI=true;Victim.health=100000;Victim.tics=-1;Victim.target=null;
        }
        int requestedStage=CVar.FindCVar('ca162_stage').GetInt();
        if(requestedStage!=Stage){Stage=requestedStage;Age=0;Console.Printf("CA162 STAGE %d",Stage);}
        Age++;
        let stream=CaelumUtilityStaffStream(u.UtilityStaffStream);
        if(Stage==1 || Stage==3 || Stage==4)
        {
            if(Age==10)
            {
                Before=u.CurrentAnima;Seconds=stream!=null ? stream.TotalPaidSeconds : 0;
                Rate=CaelumUtilityStaff.CostPerSecond(u);Heat=Victim.ThermalState!=null ? Victim.ThermalState.AbsorbedContinuousJoules : 0;
            }
            if(Age==60)
            {
                Check(String.Format("native held mode %d emits",Stage),stream!=null && stream.Mode==(Stage==3 ? 2 : 1));
                double elapsed=stream!=null ? stream.TotalPaidSeconds-Seconds : 0;
                double expected=Before-Rate*elapsed+Regeneration*50.0/TICRATE;
                Console.Printf("CA162 COST stage=%d actual=%.9f expected=%.9f seconds=%.9f rate=%.9f",Stage,u.CurrentAnima,expected,elapsed,Rate);
                Check(String.Format("mode %d pays once while natural regeneration continues",Stage),elapsed>1 && Abs(u.CurrentAnima-expected)<0.001);
                if(Stage==3)Check("native ice status and cooling",Victim.ElementalStatus.FreezeRemaining>0 && Victim.ThermalState.AbsorbedContinuousJoules<Heat);
                else Check("native fire status and heating",Victim.ElementalStatus.BurnRemaining>0 && Victim.ThermalState.AbsorbedContinuousJoules>Heat);
                if(Stage==4)
                {
                    int count=0;let it=ThinkerIterator.Create("CaelumUtilityStaffStream");while(it.Next()!=null)count++;
                    Check("both buttons never create two emitters",count==1);
                }
            }
            if(Age==350 && Stage!=4)
            {
                double elapsed=stream!=null ? stream.TotalPaidSeconds-Seconds : 0;
                double expected=Before-Rate*elapsed+Regeneration*340.0/TICRATE;
                Check(String.Format("sustained mode %d has no extra drain or regeneration suppression",Stage),elapsed>9 && Abs(u.CurrentAnima-expected)<0.001);
                double delta=Victim.ThermalState.AbsorbedContinuousJoules-Heat;
                Check(String.Format("sustained mode %d keeps transferring real thermal energy",Stage),Stage==3 ? delta<0 : delta>0);
                Console.Printf("CA162 SUSTAIN stage=%d seconds=%.6f joules=%.6f temperature=%.6f",Stage,elapsed,delta,Victim.ThermalState.Exposure);
            }
        }
        if(Stage==2 && Age==5)Check("release removes source and its light",u.UtilityStaffStream==null);
        if(Stage==5)
        {
            if(Age==1){u.CurrentAnima=0;u.DerivedStats.AnimaRegenerationPerSecond=0;}
            if(Age==5)Check("resource exhaustion stops emission",u.UtilityStaffStream==null && u.LastStaffInsufficientAnima);
        }
        if(Stage==6)
        {
            if(Age==1){u.CurrentAnima=u.DerivedStats.MaximumAnima*0.6;u.DerivedStats.AnimaRegenerationPerSecond=Regeneration;}
            u.ForcedSleepTics=5;
            if(Age==6)Check("sleep interrupts held emission",u.UtilityStaffStream==null);
        }
        if(Stage==7)
        {
            u.ForcedSleepTics=0;u.EquipmentMenuOpen=true;
            if(Age==6)Check("equipment overlay interrupts held emission",u.UtilityStaffStream==null);
        }
        if(Stage==8)
        {
            if(Age==1){u.EquipmentMenuOpen=false;u.ActivateEquippedWeaponType(20);u.SelectNativeWeaponConfiguration(u.WeaponModel.WeaponType,0,1);}
            if(Age==10)Check("switching to Pickaxe stops emission",u.UtilityStaffStream==null && u.WeaponModel.WeaponType==20);
        }
        if(Stage==9)
        {
            if(Age==1){u.ActivateEquippedWeaponType(21);u.SelectNativeWeaponConfiguration(u.WeaponModel.WeaponType,0,1);}
            if(Age==60)
            {
                Check("switch back can resume native emission",stream!=null);
                u.health=0;u.Die(null,null,0,'None');
                Check("death destroys active emitter",u.UtilityStaffStream==null);
                Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
            }
        }
        if(Stage==10 && Age==1)Victim.SetOrigin((3200,3200,0),false);
        if(Stage==16 && Age==1)u.SetOrigin((3960,2048,0),false);
        if(Stage==11 && Age==1){Passed=0;Failed=0;}
        if(Stage==14 && Age==1)
        {
            u.ToggleEquipmentMenu();
            u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            u.EquipmentSelectionItemId=StaffId;u.EquipmentSelectionWeaponType=21;
            u.EquipmentSelectionTier=1;u.EquipmentSelectionSize=2;u.RefreshEquipmentSelectionPreview();
        }
        if(Stage==11 && Age==6)
        {
            let item=u.FindNativeEquipmentItemById(StaffId);int count=0;
            for(Inventory i=u.Inv;i!=null;i=i.Inv){let w=CaelumEquipmentItem(i);if(w!=null && w.ItemType==21 && w.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON)count++;}
            Check("active save reload retains exact staff identity",item!=null && item.ItemType==21 && count==1);
            Check("released loaded emission cannot strand light or resource drain",u.UtilityStaffStream==null && u.UtilityStaffRequestedMode==0);
            Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
