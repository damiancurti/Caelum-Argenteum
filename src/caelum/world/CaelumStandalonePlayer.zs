// El lanzador selecciona esta clase sólo para procesos sin guardado de campaña.
class CaelumStandalonePlayer : CaelumPlayer
{
    int StandaloneRevision,StandalonePreset;
    CaelumAnchoredResident StandaloneTemplate;
    CaelumHuntPalomo PalomoTemplate;
    bool StandaloneHunter;
    double HunterSpeed;
    int HunterHealth;
    bool StandaloneDeathRecorded,StandaloneInventoryCleared;
    void ClearMatchInventory()
    {DestroyAllInventory();StandaloneInventoryCleared=true;}
    override void DeathThink()
    {
        Super.DeathThink();
        let match=CaelumStandaloneMatch.View();
        if(player!=null && match!=null && match.RespawnAllowed(PlayerNumber()))player.playerstate=PST_REBORN;
    }
    override void Die(Actor source,Actor inflictor,int dmgflags,Name meansOfDeath)
    {
        if(StandaloneHunter){health=HunterHealth;player.health=health;return;}
        let hunt=CaelumTarotHunt.View();
        if(hunt!=null){hunt.CapturePlayer(self,true);return;}
        Super.Die(source,inflictor,dmgflags,meansOfDeath);
        let match=CaelumStandaloneMatch.View();
        if(health<=0 && match!=null)match.RecordDeath(self,source);
    }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(StandaloneHunter)return 0;
        let match=CaelumStandaloneMatch.View();
        if(match!=null && (!match.Started || match.Finished))return 0;
        if(match!=null && match.Hunt!=null && (CaelumTarotHunt.Held(self) || (source!=self && source is 'CaelumStandalonePlayer')))return 0;
        // Los peligros del laberinto conservan los recursos anteriores al golpe
        // fatal; una trampa en curso ya tiene su propia instantánea de entrada.
        int slot=PlayerNumber();bool snapshot=match!=null && match.Hunt!=null && match.Hunt.BeforeTrap[slot]==null;
        if(snapshot){match.Hunt.BeforeTrap[slot]=new('CaelumHuntResources');match.Hunt.BeforeTrap[slot].Capture(self);}
        int result=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
        if(snapshot && !match.Hunt.Captive(slot))match.Hunt.BeforeTrap[slot]=null;
        return result;
    }
    override void Tick()
    {
        // PostBeginPlay del jugador puede preceder al de actores creados allí.
        // Materializar el perfil sólo cuando ya arrancó la simulación del mapa.
        if(StandaloneRevision<1 && CaelumPlayerAuthority.CanMutate(self))
        {
            if(!CaelumStandalonePresets.Initialize(self,true))return;
            CaelumMaximumHealth=StandaloneHunter?HunterHealth:Max(1,int(DerivedStats.MaximumHealth));
            health=CaelumMaximumHealth;if(player!=null)player.health=health;
            RefillAir();RefillAnima();RefillSurvivalResources();
            UpdateWorldCarbineVisual();RefreshEquipmentSelectionPreview();
            RefreshFormalInventorySnapshot();PersistCharacterState();
        }
        Super.Tick();
        if(StandaloneHunter)ApplyCustomWorldVisual();
    }
    override void PlayerThink()
    {
        if(!StandaloneHunter){Super.PlayerThink();return;}
        // Palomo sólo controla movimiento y vista, sin arma ni acciones de PJ.
        player.cmd.buttons&=BT_SPEED|BT_STRAFE;player.cmd.upmove=0;
        CheckPitch();HandleMovement();CalcHeight();
    }
    override void MovePlayer()
    {
        if(!StandaloneHunter){Super.MovePlayer();return;}
        if((player.cheats&CF_TOTALLYFROZEN)!=0){Vel.X=Vel.Y=0;return;}
        vector2 input=(player.cmd.forwardmove,-player.cmd.sidemove);
        double size=input.Length();
        if(size<=0){Vel.X=Vel.Y=0;return;}
        input/=size;
        vector2 direction=(Cos(Angle)*input.X-Sin(Angle)*input.Y,Sin(Angle)*input.X+Cos(Angle)*input.Y);
        Vel.X=direction.X*HunterSpeed;Vel.Y=direction.Y*HunterSpeed;
    }
    override bool ApplyCustomWorldVisual()
    {
        if(StandaloneRevision<1)return false;
        if(StandaloneHunter)
        {
            bool moving=Vel.X*Vel.X+Vel.Y*Vel.Y>0.01;
            sprite=Actor.GetSpriteIndex(moving?'PAWK':'PAID');frame=moving?(level.time/4)%2:0;
            Scale=GetDefaultByType('CaelumPalomo').Scale;bNoSkin=true;crouchsprite=0;
            if(AppearanceHead!=null){AppearanceHead.Destroy();AppearanceHead=null;}
            return true;
        }
        let source=GetDefaultByType(CaelumStandaloneData.Resident(StandalonePreset));
        int pose=CaelumAppearance.PoseFor(sprite,frame);
        String label="CompanionIdle";int offset=0;
        if(pose==2 || pose==3 || pose==4 || pose==5 || pose==29 || pose==30)
        {label='CompanionWalk';offset=(level.time/4)%4;}
        else if(pose==6)label='CrouchIdle';
        else if(pose==7 || pose==8){label='CrouchWalk';offset=(level.time/6)%4;}
        else if(pose==16)label='RestSeated';
        else if(pose==17)label='RestLying';
        else if(pose>=12 && pose<=15){label='Death';offset=pose==12?0:pose==13?1:pose==14?3:5;}
        else if(pose>=9){label='ResidentToolUse';}
        let chosen=source.FindStateByString(label,true);
        if(chosen==null)return false;
        sprite=chosen.sprite;frame=chosen.Frame+offset;Scale=source.Scale;
        AppearancePose=pose;crouchsprite=(pose>=6 && pose<=8)?sprite:0;
        bNoSkin=true;
        if(AppearanceHead!=null){AppearanceHead.Destroy();AppearanceHead=null;}
        return true;
    }
}

class CaelumStandalonePresets : Object play
{
    static bool Initialize(CaelumPlayer user,bool worldReady=false)
    {
        let body=CaelumStandalonePlayer(user);if(body==null)return false;
        if(!worldReady)return true;
        let match=CaelumStandaloneMatch.View();
        if(match==null)return false;
        int slot=user.PlayerNumber();
        if(match.HunterPlayer(slot))return InitializePalomo(body);
        int preset=match!=null && match.Member(slot)?match.Preset[slot]:Clamp(user.ReadNewCharacterDraft('ca_standalone_preset',0),0,3);
        // Spawn programa PostBeginPlay para el primer tic propio del actor.
        // Conservar el único prototipo hasta entonces, sin colisión ni botín.
        let source=body.StandaloneTemplate;
        if(source==null)
        {
            source=CaelumAnchoredResident(Actor.Spawn(CaelumStandaloneData.Resident(preset),user.Pos,NO_REPLACE));
            body.StandaloneTemplate=source;
            if(source!=null){source.bSolid=false;source.bShootable=false;source.bInvisible=true;source.bFriendly=true;}
            return false;
        }
        if(!source.CombatProfileInitialized)return false;
        let shape=GetDefaultByType(source.GetClass());
        let snapshot=new('CaelumStandaloneProfile');snapshot.Revision=CaelumStandaloneData.REVISION;
        snapshot.Preset=preset;snapshot.BodyMass=shape.Mass;snapshot.BodyHeight=shape.Height;snapshot.BodyRadius=shape.Radius;
        snapshot.Base[0]=source.CombatStrength;snapshot.Base[1]=source.CombatToughness;snapshot.Base[2]=source.CombatConstitution;
        snapshot.Base[3]=source.CombatAgility;snapshot.Base[4]=source.CombatDexterity;snapshot.Base[5]=source.CombatResilience;
        snapshot.Base[6]=source.CombatCharisma;snapshot.Base[7]=source.CombatEmpathy;snapshot.Base[8]=source.CombatEloquence;
        snapshot.Base[9]=source.CombatIntelligence;snapshot.Base[10]=source.CombatPatience;snapshot.Base[11]=source.CombatInsight;
        let profile=user.CharacterProfile;profile.InitializeDefaultTestProfile();profile.Standalone=snapshot;
        profile.Race=source.GetArmorRace();profile.FirstClass=profile.SecondClass=CaelumStandaloneData.Branch(preset);
        profile.Sex=preset==3?CaelumConstants.SEX_FEMALE:CaelumConstants.SEX_MALE;
        CaelumPersonalityRules.Unpack(profile,source.GetApprovedPersonality());
        user.CharacterAllocation.ResetAllocations();
        source.StoryAnchored=true;source.EnsureResidentTools();
        let loadout=new('CaelumCompanionLoadout');loadout.Initialize(source);
        let selected=source.ResidentTools.Melee;
        for(Inventory cursor=source.Inv;cursor!=null;)
        {
            let next=cursor.Inv;let item=CaelumEquipmentItem(cursor);
            if(item!=null)
            {
                source.RemoveInventory(item);item.AttachToOwner(user);
                item.Equipped=item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR || item==selected;
            }
            cursor=next;
        }
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            user.ArmorModel.ArmorType[slot]=source.CombatArmor.ArmorType[slot];
            user.ArmorModel.Tier[slot]=source.CombatArmor.Tier[slot];
            user.ArmorModel.Size[slot]=source.CombatArmor.Size[slot];
            user.ArmorModel.Durability[slot]=source.CombatArmor.Durability[slot];
        }
        user.ShieldModel.Equipped=false;
        if(selected!=null)
        {
            user.WeaponModel.WeaponType=selected.ItemType;user.WeaponModel.Tier=selected.Tier;
            user.WeaponModel.Size=selected.EquipmentSize;user.WeaponModel.Durability=selected.Durability;
            user.WeaponModel.EssenceType=selected.EssenceType;user.WeaponModel.Equipped=true;
        }
        body.StandaloneRevision=CaelumStandaloneData.REVISION;body.StandalonePreset=preset;
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.DebugAttributesAt100=user.DebugAttributesAt75=false;
        source.Destroy();body.StandaloneTemplate=null;
        user.EnsureAllEquipmentItemIds();user.RepairActiveEquipmentItemReferences();
        user.EnsureWeaponFamilySelectors();
        if(selected==null || !CaelumInventoryService.ActivateExactEquippedWeapon(user,selected))
            user.ApplyCharacterProfile();
        Console.Printf("CA_MATCH PRESET player=%d preset=%d",user.PlayerNumber(),preset);
        return true;
    }
    static bool InitializePalomo(CaelumStandalonePlayer body)
    {
        let source=body.PalomoTemplate;
        if(source==null)
        {
            source=CaelumHuntPalomo(Actor.Spawn('CaelumHuntPalomo',body.Pos,NO_REPLACE));
            body.PalomoTemplate=source;
            if(source!=null){source.bSolid=false;source.bShootable=false;source.bInvisible=true;source.bDormant=true;}
            return false;
        }
        if(!source.CombatProfileInitialized)return false;
        let shape=GetDefaultByType('CaelumPalomo');
        let snapshot=new('CaelumStandaloneProfile');snapshot.Revision=CaelumStandaloneData.REVISION;
        snapshot.BodyMass=shape.Mass;snapshot.BodyHeight=shape.Height;snapshot.BodyRadius=shape.Radius;
        snapshot.Base[0]=source.CombatStrength;snapshot.Base[1]=source.CombatToughness;snapshot.Base[2]=source.CombatConstitution;
        snapshot.Base[3]=source.CombatAgility;snapshot.Base[4]=source.CombatDexterity;snapshot.Base[5]=source.CombatResilience;
        snapshot.Base[6]=source.CombatCharisma;snapshot.Base[7]=source.CombatEmpathy;snapshot.Base[8]=source.CombatEloquence;
        snapshot.Base[9]=source.CombatIntelligence;snapshot.Base[10]=source.CombatPatience;snapshot.Base[11]=source.CombatInsight;
        body.CharacterProfile.InitializeDefaultTestProfile();body.CharacterProfile.Standalone=snapshot;
        body.CharacterAllocation.ResetAllocations();body.WeaponModel.Equipped=false;body.ShieldModel.Equipped=false;
        body.CharacterCreationComplete=true;body.CreationWizardOpen=false;
        body.DebugAttributesAt100=body.DebugAttributesAt75=false;
        body.ApplyCharacterProfile();body.HunterSpeed=source.Speed;body.HunterHealth=source.health;
        body.StandaloneRevision=CaelumStandaloneData.REVISION;body.StandaloneHunter=true;
        body.bPickup=false;body.player.ReadyWeapon=null;body.player.PendingWeapon=null;body.SetTag("$CA_PALOMO_NAME");
        source.Destroy();body.PalomoTemplate=null;body.ApplyCustomWorldVisual();
        Console.Printf("CA_MATCH PALOMO player=%d",body.PlayerNumber());return true;
    }
}
