class CA614MatchProbe : StaticEventHandler
{
    CaelumEquipmentItem Weapon;
    bool Done;
    int ReadyTime;
    ui Array<double> FrameGaps;
    ui double PreviousFrame;
    ui bool FramesWritten;
    override void RenderOverlay(RenderEvent e)
    {
        if(level.time<105 || FramesWritten)return;
        double now=MSTimeF();if(PreviousFrame>0)FrameGaps.Push(now-PreviousFrame);PreviousFrame=now;
        if(level.time>=280)
        {for(int i=0;i<FrameGaps.Size();i++)Console.Printf("CA614 FRAME %.6f",FrameGaps[i]);FramesWritten=true;}
    }
    void Check(bool value,String description){Console.Printf("CA614 %s %s",value?"PASS":"FAIL",description);}
    void Move(CaelumPlayer p,vector3 point){p.SetOrigin(point,false);p.Vel=(0,0,0);p.Angle=90;p.Pitch=0;p.ClearInterpolation();}

    CaelumEquipmentItem Gun(CaelumPlayer user,int type)
    {
        let item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup'));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;item.ArmorSlot=-1;item.Tier=1;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.PickupDataInitialized=true;item.AcquisitionResolved=true;
        item.SupportMigrationRevision=CaelumSupportImplementData.MIGRATION_REVISION;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.AttachToOwner(user);user.EnsureEquipmentItemId(item);item.Equipped=true;
        item.Durability=user.GetEquipmentTaskMaximumDurability(item);
        user.WeaponModel.Equipped=true;user.WeaponModel.WeaponType=type;user.WeaponModel.Tier=1;user.WeaponModel.Size=item.EquipmentSize;
        user.WeaponModel.Durability=item.Durability;user.ActiveWeaponItemId=item.ItemId;
        user.RepairActiveEquipmentItemReferences();user.ApplyCharacterProfile();return item;
    }
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started || Done)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(m.Hunt!=null)m.Hunt.Hunter.bDormant=true;
        if(level.time==110)
        {
            if(level.MapName=="CARING")
            {Check(m.Powerups==null,"ring has no pickup registry");
                Move(a,(192,32,0));for(int j=1;j<4;j++)Move(CaelumPlayer(players[j].mo),(40+j*90,16,0));
                for(int i=0;i<6;i++){
                    let p=CaelumLabyrinthPowerup(Actor.Spawn('CaelumLabyrinthPowerup',(54+i*55,200,0),NO_REPLACE));
                    p.Refill();p.Kind=i;p.frame=i>=4?1:0;p.Emblem.frame=i;
                }
                Console.Printf("CA614 RESULT powerups");Done=true;return;}
            Check(m.Powerups!=null && m.Powerups.Points.Size()==CaelumPowerupData.PointCount(),"approved point count and map gating");
            for(int i=0;i<m.Powerups.Points.Size();i++)
            {let p=m.Powerups.Points[i];Check(p.Kind>=0 && p.Kind<6 && p.ReadyAt==0 && p.Emblem!=null,"saved point has a valid category and emblem");}
            Weapon=a.FindNativeEquipmentItemById(a.ActiveWeaponItemId);
            Check(Weapon!=null,"preset exposes native selected weapon");
            Weapon.Durability=1;
            Check(CaelumLabyrinthPowerups.Apply(a,2),"weapon pickup accepted");
            Check(Weapon.Durability==a.GetEquipmentTaskMaximumDurability(Weapon) && CaelumAwakening.Factor(Weapon)==1.25,"full repair and native awakening multiplier");
            CaelumLabyrinthPowerups.Apply(a,2);Check(CaelumAwakening.Factor(Weapon)==1.25,"repeated awakening does not stack");
            int old=CaelumAwakening.Wear(Weapon,2);Check(old==1,"awakening halves actual wear");
            Check(CaelumLabyrinthPowerups.Apply(a,3),"equipped armor compatible");
            Array<CaelumEquipmentItem> pieces;int tiers=0;
            for(Inventory cur=a.Inv;cur!=null;cur=cur.Inv){let item=CaelumEquipmentItem(cur);if(CaelumLabyrinthPowerups.Compatible(item,5)){pieces.Push(item);tiers+=item.Tier;}}
            CaelumLabyrinthPowerups.Apply(a,5);int next=0;for(int i=0;i<pieces.Size();i++)next+=pieces[i].Tier;
            Check(next==tiers+1,"one random equipped piece increases exactly one tier");
            for(int i=0;i<30;i++)CaelumLabyrinthPowerups.Apply(a,5);
            bool capped=true;for(int i=0;i<pieces.Size();i++)if(pieces[i].Tier!=3)capped=false;
            Check(capped,"equipment upgrade caps at T3 and continues repairing");
            a.CurrentAnima=0;Check(CaelumLabyrinthPowerups.Apply(a,1),"replenishment works with melee selected");
            Check(Abs(a.CurrentAnima-a.DerivedStats.MaximumAnima*.5)<.001,"replenishment adds half maximum Anima");
            CaelumLabyrinthPowerups.Apply(a,1);CaelumLabyrinthPowerups.Apply(a,1);
            Check(a.CurrentAnima==a.DerivedStats.MaximumAnima,"Anima never exceeds maximum");
        }
        if(level.time==115)
        {
            static const int types[]={CaelumConstants.WEAPON_TYPE_CARBINE,CaelumConstants.WEAPON_TYPE_SHOTGUN,CaelumConstants.WEAPON_TYPE_LONGBOW,CaelumConstants.WEAPON_TYPE_CROSSBOW};
            for(int i=0;i<4;i++)
            {
                let gun=Gun(a,types[i]);Name ammoClass=a.GetAmmunitionClassName(CaelumRangedRules.AmmoType(types[i]));
                let ammo=a.FindInventory(ammoClass);if(ammo!=null)ammo.Destroy();a.SetRangedMagazineCount(types[i],0);
                CaelumLabyrinthPowerups.Apply(a,1);ammo=a.FindInventory(ammoClass);
                Check(ammo!=null && ammo.Amount==CaelumRangedRules.MagazineCapacity(types[i]) && a.GetRangedMagazineCount(types[i])==ammo.Amount,"full native magazine without reserve ammunition");
                int amount=ammo.Amount;CaelumLabyrinthPowerups.Apply(a,1);
                Check(ammo.Amount==amount,"full magazine does not generate extra ammo");
                gun.Equipped=false;
            }
            Weapon.Equipped=true;a.ActiveWeaponItemId=Weapon.ItemId;
            a.WeaponModel.WeaponType=Weapon.ItemType;a.WeaponModel.Tier=Weapon.Tier;a.WeaponModel.Size=Weapon.EquipmentSize;a.WeaponModel.Durability=Weapon.Durability;
            a.RepairActiveEquipmentItemReferences();a.ApplyCharacterProfile();
        }
        if(level.time==120)
        {
            a.CurrentHunger=50;a.CurrentThirst=50;a.CurrentSleep=70;a.CurrentAir=0;a.CurrentAnima=0;
            a.health=a.CaelumMaximumHealth/2;a.player.health=a.health;
            let r=a.GetPersistentCharacterState(false);r.TarotCooldownTics=600*TICRATE;a.ClassSleepCooldownRemaining=600;
            let illness=CaelumFoodIllness.Get(a);illness.Contamination=20;illness.ToiletCapacity=10;
            let clock=CaelumWorldClock.Get(a);int day=clock.CompletedDays,tic=clock.DayTics;
            int life=b.health;double anima=b.CurrentAnima,air=b.CurrentAir,food=b.CurrentHunger;
            int own=a.health;double hunger=a.CurrentHunger,thirst=a.CurrentThirst;
            double start=MSTimeF();CaelumLabyrinthPowerups.Apply(a,0);
            Console.Printf("CA614 COST seated_ms=%.6f",MSTimeF()-start);
            Console.Printf("CA614 REST before=%d/%.3f/%.3f after=%d/%.3f/%.3f air=%.3f sleep=%.3f",own,hunger,thirst,a.health,a.CurrentHunger,a.CurrentThirst,a.CurrentAir,a.CurrentSleep);
            Check(a.health>own && a.CurrentHunger>hunger && a.CurrentThirst>thirst && a.CurrentAir>0,"seated rest restores native resources and digests supplied meals");
            Check(r.TarotCooldownTics==420*TICRATE && Abs(a.ClassSleepCooldownRemaining-420)<.001,"three real minutes advance only personal reuse");
            Check(day==clock.CompletedDays && tic==clock.DayTics,"shared world calendar does not advance");
            Check(life==b.health && anima==b.CurrentAnima && air==b.CurrentAir && food==b.CurrentHunger,"other player resources remain unchanged");
            Check(CaelumFoodIllness.Value(a)<20,"rest includes native depuration and toilet capacity");
            double sleep=a.CurrentSleep;CaelumFoodIllness.Get(a).Contamination=10;
            start=MSTimeF();CaelumLabyrinthPowerups.Apply(a,4);
            Console.Printf("CA614 COST bed_ms=%.6f",MSTimeF()-start);
            Check(a.CurrentSleep>sleep && CaelumFoodIllness.Value(a)==0,"bed recovery and full bath");
            Check(r.TarotCooldownTics==60*TICRATE && Abs(a.ClassSleepCooldownRemaining-60)<.001,"six real minutes preserve remaining cooldown instead of free reset");
            let point=m.Powerups.Points[0];point.Kind=1;point.ReadyAt=0;point.bSpecial=true;
            a.CurrentAnima=0;Move(a,point.Pos);a.Vel=(1,0,0);
        }
        if(level.time==125)
        {
            let point=m.Powerups.Points[0];
            Check(point.ReadyAt>level.time && point.bInvisible && point.Emblem.bInvisible,"native touch consumes shared point and hides shell and emblem");
            ReadyTime=point.ReadyAt;
            Move(b,point.Pos);
            Check(point.ReadyAt==ReadyTime,"second contact cannot reset the shared respawn timer");
            point.ReadyAt=level.time+3;
            Move(a,CaelumPowerupData.Point(1)+(0,-96,0));Move(b,CaelumPowerupData.Point(1)+(0,-160,0));
        }
        if(level.time==132)
        {
            let point=m.Powerups.Points[0];Check(point.ReadyAt==0 && !point.bInvisible && !point.Emblem.bInvisible,"expired saved timer rerolls and restores point");
            for(int i=0;i<6;i++)
            {
                let p=CaelumLabyrinthPowerup(Actor.Spawn('CaelumLabyrinthPowerup',a.Pos+(i*52-130,180,0),NO_REPLACE));
                p.Refill();p.Kind=i;p.frame=i>=4?1:0;p.Emblem.frame=i;
            }
            Console.Printf("CA614 RESULT powerups");Done=true;
        }
    }
}
