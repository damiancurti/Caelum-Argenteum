class CA479Enemy : CA479Body { Default { Tag "Enemigo de prueba"; } }
class CA479Ally : CA479Body { Default { Tag "Aliado de prueba"; } }
class CA479Manual : EventHandler
{
    CaelumEquipmentItem Pieces[6];
    CA479Body Enemy,Ally;
    int Selected,SlotMask,Passed,Failed,AttributeLevel;
    double BeforeAnima;
    bool Ready;
    void Check(bool ok,String text)
    {if(ok)Passed++;else Failed++;Console.Printf("CA479 %s %s",ok?"PASS":"FAIL",text);}
    void Configure(CaelumPlayer user)
    {
        if(user.Attributes.Charisma!=AttributeLevel || user.Attributes.Empathy!=AttributeLevel || user.Attributes.Eloquence!=0)
        {
            user.Attributes.Charisma=AttributeLevel;user.Attributes.Empathy=AttributeLevel;user.Attributes.Eloquence=0;
            user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
        }
        // Solo la escena de prueba suspende la regeneracion para medir el pago exacto.
        user.DerivedStats.AnimaRegenerationPerSecond=0;
    }
    override void WorldTick()
    {
        if(!Ready || level.MapName!="CSUP479")return;
        let user=CaelumPlayer(players[consoleplayer].mo);if(user!=null)Configure(user);
    }
    void Reset(CaelumPlayer user)
    {
        for(int n=0;n<3;n++)
        {
            Actor body=n==0?Actor(user):n==1?Actor(Enemy):Actor(Ally);
            let effect=CaelumSupportMagic.Status(body);if(effect!=null)effect.Destroy();
        }
        Enemy.CombatMaximumHealth=1000;Enemy.health=1000;
        Ally.CombatMaximumHealth=1000;Ally.health=500;
        user.health=user.CaelumMaximumHealth;user.player.health=user.health;
        user.CurrentAnima=user.DerivedStats.MaximumAnima;user.CombatTimeRemaining=0;
        Console.Printf("CA479 RESULT manual resources reset");
    }
    void Setup(CaelumPlayer user)
    {
        if(Ready)return;
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
        AttributeLevel=100;
        user.ApplyCharacterProfile();user.SetOrigin((-96,0,0),false);user.Angle=0;
        user.Pitch=VectorAngle(144,user.ViewHeight-32);
        Enemy=CA479Body(Actor.Spawn("CA479Enemy",(48,0,0),NO_REPLACE));Enemy.Live=true;
        Ally=CA479Body(Actor.Spawn("CA479Ally",(48,96,0),NO_REPLACE));Ally.Live=true;Ally.bFriendly=true;
        for(int i=0;i<6;i++)
        {
            int type=i<4?23+i:i==4?18:19;
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;
            item.Tier=1;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.EssenceType=i<4?4:0;
            item.PickupDataInitialized=true;item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
            item.UnitWeight=user.WeaponModel.GetWeightFor(type,1,item.EquipmentSize);
            item.Durability=item.PreviewMaximumDurability(user);item.Equipped=true;
            item.AttachToOwner(user);user.EnsureEquipmentItemId(item);Pieces[i]=item;
        }
        Ready=true;Configure(user);Reset(user);user.EnsureWeaponFamilySelectors();Select(user,0);
        Console.Printf("CA479 RESULT manual fixture ready: slot 0 support; slot 6 fire; F1 implement; F2 reset; F3 attributes; F4 seal");
    }
    void Select(CaelumPlayer user,int index)
    {
        Selected=index%6;
        CaelumInventoryService.ActivateExactEquippedWeapon(user,Pieces[Selected]);
        Configure(user);user.RefreshCarriedInventorySummary();user.RefreshFormalInventorySnapshot();
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        if(level.MapName!="CSUP479")return;
        let user=CaelumPlayer(players[event.Player].mo);if(user==null)return;
        if(event.Name=="ca479_manual")Setup(user);
        if(!Ready)return;
        if(event.Name=="ca479_choose")Select(user,Selected+1);
        if(event.Name=="ca479_reset")Reset(user);
        if(event.Name=="ca479_attributes")
        {
            AttributeLevel=AttributeLevel>0?0:100;Configure(user);
            Console.Printf("CA479 RESULT Charisma/Empathy %.0f",user.Attributes.Charisma);
        }
        if(event.Name=="ca479_seal")
        {
            let seal=CaelumSealResistance.Equipped(Enemy);
            if(seal!=null)seal.Destroy();
            else
            {
                seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",Enemy.Pos,NO_REPLACE));
                seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.ItemType=CaelumConstants.SEAL_QUINTESSENCE;
                seal.PickupDataInitialized=true;seal.Equipped=true;seal.AttachToOwner(Enemy);
            }
            Console.Printf("CA479 RESULT enemy curse retention %.2f",CaelumSupportMagic.CurseRetention(Enemy));
        }
        if(event.Name=="ca479_slotcheck")
        {
            let weapon=CaelumMagicSelectorWeapon(user.player.ReadyWeapon);
            int role=weapon==null?-1:CaelumSupportImplementData.RoleForWeapon(weapon.GetCaelumWeaponType());
            Check(role>=0,"native slot 0 selects support");if(role>=0)SlotMask|=1<<role;
        }
        if(event.Name=="ca479_slotsdone")
        {
            Check(SlotMask==15,"native slot 0 cycles all four implements");
            Select(user,0);Reset(user);
        }
        if(event.Name=="ca479_beforecast")
        {BeforeAnima=user.CurrentAnima;Check(!user.StaffCastPending,"native cast begins idle");}
        if(event.Name=="ca479_beforealt")
        {BeforeAnima=user.CurrentAnima;user.health=user.CaelumMaximumHealth/2;user.player.health=user.health;}
        if(event.Name=="ca479_afteralt")
        {
            let effect=CaelumSupportMagic.Status(user);
            Check(user.LastStaffCastCompleted && effect!=null && effect.Effects[2]!=null,"native Statuette secondary benefits self");
            Check(Abs(BeforeAnima-user.CurrentAnima-100)<0.01,"native Statuette secondary spends 100 Anima once");
            Check(CaelumSupportMagic.Status(Enemy)==null,"self benefit does not curse enemy");
            Console.Printf("CA479 RESULT controls passed=%d failed=%d",Passed,Failed);
        }
        if(event.Name=="ca479_aftercast")
        {
            Check(user.LastStaffCastCompleted && !user.StaffCastPending,"native primary completes support cast");
            Check(Abs(BeforeAnima-user.CurrentAnima-70)<0.01,"native Book primary spends 70 Anima once");
            Check(CaelumSupportMagic.Status(Enemy)!=null,"native primary applies enemy curse");
            Check(!user.WeaponChargeActive && !user.WeaponChargedStateActive,"support reload has no charged state");
            Console.Printf("CA479 RESULT primary controls passed=%d failed=%d anima-before=%.3f after=%.3f",Passed,Failed,BeforeAnima,user.CurrentAnima);
            Select(user,2);Reset(user);
        }
    }
}
