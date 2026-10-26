// Isolated fixtures keep native defense/damage but suppress autonomous AI.
class CA502CombatRat : CaelumGiantRat { override void Tick(){} }
class CA502CombatSoldier : CaelumPortDefender { override void Tick(){} }
class CA502CombatProof : Inventory
{
    CaelumCombatActor Enemy;
    CaelumEquipmentItem Weapon;
    double WeaponC,BodyC,ArmorC,ShieldC;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502CombatChecks : EventHandler
{
    int Passed,Failed;
    CaelumCombatActor Enemy;
    CaelumEquipmentItem Weapon;
    bool Manual;
    int ManualMode;
    String ManualTitle,ManualBefore,ManualAfter;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502M %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    CaelumEquipmentItem Gear(CaelumPlayer u,int id,int kind,int type,int slot=0)
    {
        let item=u.FindNativeEquipmentItemById(id);
        if(item==null){item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos,NO_REPLACE));
            item.ItemId=id;item.AcquisitionResolved=true;item.PickupDataInitialized=true;item.Amount=1;
            item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
            item.Tier=1;item.UnitWeight=1;item.Durability=1000;item.AttachToOwner(u);}
        item.InMagicBox=false;item.Equipped=true;CaelumContaminationStorage.Set(item,0);return item;
    }
    void Reset(CaelumPlayer u)
    {
        CaelumCleaningTask.Cancel(u);CaelumRestState.Cancel(u);CaelumTimeAdvanceState.Halt(u);
        u.CancelCraftingTask();u.EquipmentMenuOpen=u.CraftingMenuOpen=false;
        u.bInvulnerable=false;u.Attributes.Toughness=100;u.ApplyCharacterProfile();
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;u.EffectiveEvasionChance=0;
        u.CombatBlockModeActive=u.DebugShieldBlocking=false;
        u.PainImmobilizationRemaining=0;u.RestNonPeriodicPainRemaining=0;u.CurrentSleep=u.CurrentHunger=u.CurrentThirst=100;
        let record=u.GetPersistentCharacterState(true);
        for(int slot=0;slot<4;slot++){u.EquippedArmorItemId[slot]=0;record.EquippedClothingItemId[slot]=0;}
        u.EquippedShieldItemId=0;u.DerivedStats.BaseMass=80;CaelumContaminationStorage.Set(u,0);
        Weapon=Gear(u,905021,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD);
        u.ActiveWeaponItemId=Weapon.ItemId;
        u.WeaponModel.WeaponType=Weapon.ItemType;u.WeaponModel.Tier=1;u.WeaponModel.Size=CaelumConstants.EQUIPMENT_SIZE_M;
        u.WeaponModel.Durability=1000;u.WeaponModel.Equipped=true;
        if(Enemy==null)Enemy=CaelumCombatActor(Actor.Spawn('CA502CombatRat',u.Pos+(48,0,0),NO_REPLACE));
        Enemy.EnsureCombatPersonality();Enemy.health=100000;Enemy.Mass=80;Enemy.EffectiveCombatEvasionChance=0;Enemy.CombatToughness=100;
        Enemy.SetOrigin((u.Pos.X+48,u.Pos.Y,u.Pos.Z+u.Height*0.60-Enemy.Height/2),false);
        Enemy.bFriendly=false;u.Angle=0;u.Pitch=0;u.LastShieldBlockedAttack=false;u.LastMeleeHit=false;
        CaelumContaminationStorage.Set(Enemy,0);
    }
    void Strike(CaelumPlayer u){Enemy.DamageMobj(u,u,1,'CaelumMeleeTest',DMG_THRUSTLESS,0);}
    void Bite(CaelumPlayer u){u.DamageMobj(Enemy,Enemy,1,'Melee',DMG_THRUSTLESS,0);}
    void Core(CaelumPlayer u)
    {
        Reset(u);CaelumContaminationStorage.Set(Weapon,80);Strike(u);
        Check(Near(CaelumContaminationStorage.Value(Enemy),0.8),"dirty sword transmits exactly ten seconds to bare target");
        Check(Near(CaelumContaminationStorage.Value(Weapon),80),"dirty source retains concentration");
        CaelumContaminationStorage.Set(Weapon,0);CaelumContaminationStorage.Set(Enemy,80);Strike(u);
        Check(Near(CaelumContaminationStorage.Value(Weapon),0.8),"clean sword acquires dirt from target");
        Check(Near(CaelumContaminationStorage.Value(u),0),"weapon contact does not directly contaminate wielder");
        Reset(u);CaelumContaminationStorage.Set(Enemy,80);Bite(u);
        Check(Near(CaelumContaminationStorage.Value(u),0.8),"natural melee transmits to bare player at80kg");
        CaelumContaminationStorage.Set(u,20);Bite(u);
        Check(Near(CaelumContaminationStorage.Value(u),Sqrt(401.6)),"contact ratio updates during ten-second dose");
        u.DerivedStats.BaseMass=40;CaelumContaminationStorage.Set(u,20);Bite(u);
        Check(Near(CaelumContaminationStorage.Value(u),Sqrt(403.2)),"body mass scales receiving dose");
        Reset(u);CaelumContaminationStorage.Set(u,80);Bite(u);
        Check(Near(CaelumContaminationStorage.Value(Enemy),0.8),"natural attacker acquires victim contamination");
        Reset(u);CaelumContaminationStorage.Set(Weapon,80);Enemy.EffectiveCombatEvasionChance=100;Strike(u);
        Check(Enemy.LastCombatEvasionSucceeded && Near(CaelumContaminationStorage.Value(Enemy),0),"NPC evasion prevents transfer");
        u.EffectiveEvasionChance=100;CaelumContaminationStorage.Set(Enemy,80);Bite(u);
        Check(u.LastEvasionSucceeded && Near(CaelumContaminationStorage.Value(u),0),"player evasion prevents transfer");
        Reset(u);CaelumContaminationStorage.Set(Enemy,80);
        u.DamageMobj(Enemy,Enemy,1,'Hitscan',DMG_THRUSTLESS,0);
        u.DamageMobj(Enemy,Enemy,1,'Fire',DMG_THRUSTLESS,0);
        u.DamageMobj(Enemy,Enemy,1,'CaelumDiseaseDOT',DMG_THRUSTLESS,0);
        Check(Near(CaelumContaminationStorage.Value(u),0),"bullet magic and illness are not contact attacks");
        Reset(u);CaelumContaminationStorage.Set(Enemy,80);Enemy.target=u;Enemy.MeleeRange=128;
        Enemy.DeliverContactMelee(1);
        Check(Near(CaelumContaminationStorage.Value(u),0.8) && !Enemy.ContaminationMeleeActive,"actual native None melee transfers and clears its context");
        CaelumContaminationStorage.Set(u,0);u.DamageMobj(Enemy,Enemy,1,'None',DMG_THRUSTLESS,0);
        Check(Near(CaelumContaminationStorage.Value(u),0),"unmarked generic damage cannot inherit melee contact");
        Reset(u);CaelumContaminationStorage.Set(Weapon,80);Weapon.InMagicBox=true;Strike(u);
        Check(Near(CaelumContaminationStorage.Value(Enemy),0),"boxed weapon cannot transmit via stale selected id");
        Reset(u);CaelumContaminationStorage.Set(Enemy,80);
        let cloth=Gear(u,905022,CaelumConstants.EQUIPMENT_KIND_CLOTHING,0,CaelumConstants.ARMOR_SLOT_BODY);
        u.GetPersistentCharacterState(true).EquippedClothingItemId[CaelumConstants.ARMOR_SLOT_BODY]=cloth.ItemId;Bite(u);
        Check(Near(CaelumContaminationStorage.Value(cloth),0.8) && Near(CaelumContaminationStorage.Value(u),0),"clothing receives contact before skin");
        let armor=Gear(u,905023,CaelumConstants.EQUIPMENT_KIND_ARMOR,CaelumConstants.ARMOR_TYPE_HEAVY,CaelumConstants.ARMOR_SLOT_BODY);
        u.EquippedArmorItemId[CaelumConstants.ARMOR_SLOT_BODY]=armor.ItemId;CaelumContaminationStorage.Set(cloth,0);Bite(u);
        Check(Near(CaelumContaminationStorage.Value(armor),0.8) && Near(CaelumContaminationStorage.Value(cloth),0),"armor receives contact before clothing");
        Reset(u);CaelumContaminationStorage.Set(Enemy,80);
        let shield=Gear(u,905024,CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_KITE);
        u.EquippedShieldItemId=shield.ItemId;u.ShieldModel.Equipped=true;u.ShieldModel.ShieldType=shield.ItemType;u.ShieldModel.Durability=1000;
        u.CombatBlockModeActive=u.DebugShieldBlocking=true;Bite(u);
        Check(u.LastShieldBlockedAttack && Near(CaelumContaminationStorage.Value(shield),0.8) && Near(CaelumContaminationStorage.Value(u),0),"real shield block receives contact without skin transfer");
        Reset(u);CaelumContaminationStorage.Set(Enemy,80);
        let hands=Gear(u,905025,CaelumConstants.EQUIPMENT_KIND_ARMOR,CaelumConstants.ARMOR_TYPE_HEAVY,CaelumConstants.ARMOR_SLOT_HANDS);
        u.EquippedArmorItemId[CaelumConstants.ARMOR_SLOT_HANDS]=hands.ItemId;
        Enemy.DamageMobj(u,u,1,'Melee',DMG_THRUSTLESS,0);
        Check(Near(CaelumContaminationStorage.Value(hands),0.8) && Near(CaelumContaminationStorage.Value(Weapon),0),"unarmed punch uses hands rather than selected sword");
        Reset(u);CaelumContaminationStorage.Set(Weapon,80);CaelumContaminationStorage.Set(Enemy,80);Strike(u);
        Check(Near(CaelumContaminationStorage.Value(Enemy),80) && Near(CaelumContaminationStorage.Value(Weapon),80),"equal contamination does not exchange");
    }
    void Trace(CaelumPlayer u)
    {
        Reset(u);Enemy.A_SetSize(24,64);Enemy.SetOrigin(u.Pos+(48,0,0),false);
        u.Pitch=-VectorAngle(48,Enemy.Height/2-u.ViewHeight);u.CurrentAir=u.DerivedStats.MaximumAir;
        CaelumContaminationStorage.Set(Weapon,80);u.PerformDebugSwordAttack(false);
        Check(u.LastMeleeHit,"native sword trace reaches real target");
        Check(Near(CaelumContaminationStorage.Value(Enemy),0.8),"native sword trace transfers once through receiver defense");
        CaelumContaminationStorage.Set(Enemy,0);u.Angle=180;u.PerformDebugSwordAttack(false);
        Check(!u.LastMeleeHit && Near(CaelumContaminationStorage.Value(Enemy),0),"native swing miss has no contamination");
    }
    void Models(CaelumPlayer u)
    {
        Reset(u);let soldier=CaelumPortDefender(Enemy);Enemy.Angle=0;
        CaelumContaminationStorage.Set(Weapon,80);Strike(u);
        let armor=CaelumContaminationCombat.Exterior(Enemy,CaelumConstants.ARMOR_SLOT_BODY);
        Check(Near(armor.Value(),0.8) && Near(CaelumContaminationStorage.Value(Enemy),0),"NPC modeled armor stores receiving dirt separately");
        Enemy.Angle=180;Strike(u);let shield=CaelumContaminationCombat.ShieldPoint(soldier.Shield);
        Check(Near(shield.Value(),0.8) && Near(armor.Value(),0.8),"NPC native shield decision routes contact once");
        Check(Enemy.ContaminationBlocker==null,"per-hit blocker reference cleared");
        let sword=CaelumContaminationCombat.WeaponPoint(soldier.Sword);sword.Set(80);Bite(u);
        Check(Near(CaelumContaminationStorage.Value(u),0.8) && Near(sword.Value(),80),"NPC modeled sword uses same transmission rule");
        let copy=Weapon.CreateTossable(1);
        Check(copy!=null && Near(CaelumContaminationStorage.Value(copy),80),"native dropped equipment preserves contamination");
        if(copy!=null){Weapon=CaelumEquipmentItem(copy);if(Weapon.Owner==null)Weapon.AttachToOwner(u);}
        let proof=CA502CombatProof(u.FindInventory('CA502CombatProof'));
        if(proof==null)proof=CA502CombatProof(u.GiveInventoryType('CA502CombatProof'));
        Enemy.ChangeTid(905029);proof.Enemy=Enemy;proof.Weapon=Weapon;proof.WeaponC=CaelumContaminationStorage.Value(Weapon);
        proof.BodyC=CaelumContaminationStorage.Value(Enemy);proof.ArmorC=armor.Value();proof.ShieldC=shield.Value();
    }
    void Load(CaelumPlayer u)
    {
        let proof=CA502CombatProof(u.FindInventory('CA502CombatProof'));
        if(proof!=null && proof.Enemy==null){let it=ActorIterator.Create(905029);proof.Enemy=CaelumCombatActor(it.Next());}
        Check(proof!=null && proof.Enemy!=null && proof.Weapon!=null,"saved native identities preserved");if(proof==null || proof.Enemy==null || proof.Weapon==null)return;
        Check(Near(CaelumContaminationStorage.Value(proof.Weapon),proof.WeaponC),"equipment saved concentration preserved");
        Check(Near(CaelumContaminationStorage.Value(proof.Enemy),proof.BodyC),"body saved concentration preserved");
        Check(Near(CaelumContaminationCombat.Exterior(proof.Enemy,CaelumConstants.ARMOR_SLOT_BODY).Value(),proof.ArmorC),"modeled armor survives save");
        let soldier=CaelumPortDefender(proof.Enemy);
        Check(Near(CaelumContaminationCombat.ShieldPoint(soldier.Shield).Value(),proof.ShieldC),"modeled shield survives save");
        Check(Near(CaelumContaminationCombat.WeaponPoint(soldier.Sword).Value(),80),"modeled weapon survives save");
    }
    void Legacy(CaelumPlayer u)
    {
        let proof=CA502CombatProof(u.FindInventory('CA502CombatProof'));
        Check(proof!=null && proof.Enemy!=null && proof.Weapon!=null,"previous runtime save loads original identities");
        if(proof==null || proof.Enemy==null || proof.Weapon==null)return;
        let soldier=CaelumPortDefender(proof.Enemy);
        Check(Near(CaelumContaminationStorage.Value(proof.Weapon),34) && Near(CaelumContaminationStorage.Value(soldier),26),"previous body and native weapon contamination preserved");
        Check(soldier.Shield.ContaminationState==null && soldier.Sword.ContaminationState==null && soldier.CombatArmor.ContaminationState[1]==null,"previous models have no retroactive contamination");
        let shield=CaelumContaminationCombat.ShieldPoint(soldier.Shield);
        Check(Near(shield.Value(),0) && Near(CaelumContaminationCombat.Exterior(soldier,1).Value(),0),"old model states initialize clean");
        shield.Set(12);Check(Near(CaelumContaminationCombat.ShieldPoint(soldier.Shield).Value(),12),"repeated model initialization preserves recorded dirt");
    }
    void Scenario(CaelumPlayer u,int mode)
    {
        Reset(u);Manual=true;ManualMode=mode;u.ActivateExactEquippedWeapon(Weapon);
        Enemy.A_SetSize(24,64);Enemy.SetOrigin(u.Pos+(48,0,0),false);
        u.Pitch=-VectorAngle(48,Enemy.Height/2-u.ViewHeight);
        ManualTitle=mode==0?"Espada sucia -> objetivo limpio":mode==1?"Objetivo sucio -> espada limpia":mode==2?"Mordida -> piel descubierta":mode==3?"Golpe dirigido -> escudo":"Esquiva -> sin contacto";
        ManualBefore="F2 prepara las concentraciones y ejecuta un impacto real.";ManualAfter="";
    }
    void ManualHit(CaelumPlayer u)
    {
        Scenario(u,ManualMode);u.CurrentAir=u.DerivedStats.MaximumAir;u.EffectiveEvasionChance=0;u.DerivedStats.BaseMass=80;
        CaelumContaminationStorage.Set(Weapon,ManualMode==0 || ManualMode==4?80:0);
        CaelumContaminationStorage.Set(Enemy,ManualMode==0 || ManualMode==4?0:80);
        CaelumEquipmentItem shield;
        if(ManualMode==3)
        {
            shield=Gear(u,905024,CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_KITE);
            u.EquippedShieldItemId=shield.ItemId;u.ShieldModel.Equipped=true;u.ShieldModel.ShieldType=shield.ItemType;u.ShieldModel.Durability=1000;
            u.CombatBlockModeActive=u.DebugShieldBlocking=true;
        }
        if(ManualMode==4)Enemy.EffectiveCombatEvasionChance=100;
        if(ManualMode==2 || ManualMode==3){Enemy.target=u;Enemy.Angle=180;Enemy.MeleeRange=128;if(ManualMode==2)Enemy.DeliverContactMelee(1);else Enemy.A_CustomMeleeAttack(1,"","",'Melee');}
        else u.PerformDebugSwordAttack(false);
        ManualBefore=String.Format("Espada %.4f | Objetivo %.4f | Tu cuerpo %.4f | Escudo %.4f",
            CaelumContaminationStorage.Value(Weapon),CaelumContaminationStorage.Value(Enemy),CaelumContaminationStorage.Value(u),CaelumContaminationStorage.Value(shield));
        ManualAfter=String.Format("Ultimo golpe: traza=%d | esquiva=%d | bloqueo=%d",u.LastMeleeHit,Enemy.LastCombatEvasionSucceeded,u.LastShieldBlockedAttack);
        bool correct=ManualMode==0?Near(CaelumContaminationStorage.Value(Enemy),0.8):ManualMode==1?Near(CaelumContaminationStorage.Value(Weapon),0.8):ManualMode==2?Near(CaelumContaminationStorage.Value(u),0.8):ManualMode==3?Near(CaelumContaminationStorage.Value(shield),0.8) && Near(CaelumContaminationStorage.Value(u),0):Enemy.LastCombatEvasionSucceeded && Near(CaelumContaminationStorage.Value(Enemy),0);
        Check(correct,"manual native attack: "..ManualTitle);
        Console.Printf("CA502M LIVE %s; %s; %s",ManualTitle,ManualBefore,ManualAfter);
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Manual)return;
        let font=Font.GetFont("CaelumMono");
        Screen.Dim(0x000000,0.9,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.23));
        Screen.DrawText(font,Font.CR_GOLD,8,8,ManualTitle,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,24,ManualBefore,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,40,ManualAfter,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,56,"F1 espada | F3 inverso | F4 mordida | F5 escudo | F7 esquiva",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,70,"F2: preparar y golpear. Datos del ultimo impacto; luego sigue el ambiente.",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || players[e.Player].mo==null)return;let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502m_manual')Scenario(u,0);else if(e.Name=='ca502m_reverse')Scenario(u,1);else if(e.Name=='ca502m_bite')Scenario(u,2);else if(e.Name=='ca502m_shield')Scenario(u,3);else if(e.Name=='ca502m_evade')Scenario(u,4);else if(e.Name=='ca502m_hit')ManualHit(u);
        else if(e.Name=='ca502m_prepare')Reset(u);
        else if(e.Name=='ca502m_prepare_models'){Reset(u);Enemy.Destroy();Enemy=CaelumCombatActor(Actor.Spawn('CA502CombatSoldier',u.Pos+(64,0,0),NO_REPLACE));}
        else if(e.Name=='ca502m_legacy')Legacy(u);else if(e.Name=='ca502m_core')Core(u);else if(e.Name=='ca502m_trace')Trace(u);else if(e.Name=='ca502m_models')Models(u);else if(e.Name=='ca502m_load')Load(u);
        else return;Console.Printf("CA502M RESULT passed=%d failures=%d",Passed,Failed);
    }
}
