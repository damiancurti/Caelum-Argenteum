class CA440PulseBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;Speed 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440UnlinkedPulseBody : CA440PulseBody { Default {+NOBLOCKMAP} }
class CA440PulseLedger : Inventory
{
    int Phase,Started;
    CA440PulseBody Body,FarBody,Unlinked,Hidden;
    CaelumEquipmentItem Exposed,Boxed,Stored;
    CaelumStashChest Chest;
    CaelumTarotGroundAim Snapshot;
    CaelumContaminationTile FloorTile,WallTile,UpperTile,LowerTile,SlopeTile;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440D %s %s",okay?"PASS":"FAIL",label);}
    CaelumEquipmentItem Equipment(Actor owner)
    {
        let item=CaelumEquipmentItem(Actor.Spawn('CaelumEquipmentItem',(0,0,0),NO_REPLACE));
        item.PickupDataInitialized=true;item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.Amount=1;item.AttachToOwner(owner);return item;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440PulseLedger(user.FindInventory('CA440PulseLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440PulseLedger(user.GiveInventoryType('CA440PulseLedger'));
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<78;i++){record.TarotOwned[i]=true;record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.GrantMagicBoxFromPalomo(false);
            user.SetOrigin((-90,0,0),false);other.SetOrigin((0,60,0),false);
            ledger.Body=CA440PulseBody(Actor.Spawn('CA440PulseBody',(0,0,0),NO_REPLACE));
            ledger.Body.InitializeCombatProfile(18,18,18,18,18,18,18,18,18,18,18,18);
            ledger.Body.CombatArmor=new('CaelumArmorModel');
            ledger.FarBody=CA440PulseBody(Actor.Spawn('CA440PulseBody',(700,0,0),NO_REPLACE));
            ledger.Unlinked=CA440PulseBody(Actor.Spawn('CA440UnlinkedPulseBody',(20,-60,0),NO_REPLACE));
            CaelumContaminationWorld.Get().ContactGrid().Track(ledger.Unlinked);
            ledger.Chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(60,40,0),NO_REPLACE));
            ledger.Exposed=Equipment(user);ledger.Boxed=Equipment(user);ledger.Boxed.InMagicBox=true;
            ledger.Stored=Equipment(ledger.Chest);ledger.Chest.ChestOpen=false;
            CaelumContaminationStorage.Set(ledger.Boxed,23);CaelumContaminationStorage.Set(ledger.Stored,37);
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            let record=user.GetPersistentCharacterState(false);
            vector3 ray=ledger.Body.Pos+(0,0,28)-CaelumTelekinesisRules.Eye(user);
            user.Angle=VectorAngle(ray.X,ray.Y);user.Pitch=-VectorAngle(ray.XY.Length(),ray.Z);
            ledger.Snapshot=CaelumTarotGroundAim.Capture(user);ledger.Snapshot.RangeMultiplier=1;
            CaelumTarotService.Select(user,13);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"selected Death casts through the native Tarot service");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01,"the instant pulse pays once");
            Check(!record.TarotActive[13] && record.TarotRemaining[13]==0,"Hermit does not repeat or prolong an instant pulse");
            Check(CaelumContaminationStorage.Value(user)==100 && CaelumContaminationStorage.Value(other)==100,"caster and other player in range receive contamination without faction exemptions");
            Check(CaelumContaminationStorage.Value(ledger.Body)==100 && CaelumContaminationStorage.Value(ledger.Unlinked)==100,"ordinary and unlinked combatants receive the pulse");
            Check(ledger.Body.CombatArmor.ContaminationState[0]!=null && ledger.Body.CombatArmor.ContaminationState[0].Concentration==100,"NPC model-backed armor shares the same contamination endpoint");
            Check(CaelumContaminationStorage.Value(ledger.FarBody)<1,"distant body is unchanged");
            Check(CaelumContaminationStorage.Value(ledger.Exposed)==100,"carried exposed weapon receives the pulse");
            Check(CaelumContaminationStorage.Value(ledger.Boxed)==23,"Box contents retain their old contamination");
            Check(CaelumContaminationStorage.Value(ledger.Stored)==37 && CaelumContaminationStorage.Value(ledger.Chest)==100,"closed chest shields contents while its exterior is affected");
            let sheet=CaelumContaminationSurfaces.CurrentMap(user);
            ledger.FloorTile=sheet.Find(0,ledger.Body.CurSector.Index(),0,0,0,false);
            Check(ledger.FloorTile!=null && ledger.FloorTile.Concentration==100,"the authoritative floor tile receives the pulse");
            ledger.Chest.ChestOpen=true;
            let pulse=CaelumTarotContamination.Pulse(user,(0,0,28),100,1);
            Check(CaelumContaminationStorage.Value(ledger.Stored)==100,"opening the chest exposes its real contents");
            Check(pulse.BodyCount>=4 && pulse.SurfaceCount>0,"local pulse reports affected bodies and surface cells");
            Check(!CaelumTarotContamination.Death(user,null,ledger.Snapshot),"invalid target is skipped without inventing a position");
            // El borde oriental de la habitación del fixture bloquea el pulso.
            user.SetOrigin((950,0,0),false);
            ledger.Hidden=CA440PulseBody(Actor.Spawn('CA440PulseBody',(1050,0,0),NO_REPLACE));
            CaelumContaminationStorage.Set(ledger.Hidden,11);
            pulse=CaelumTarotContamination.Pulse(user,(980,0,28),100,1);
            Check(!pulse.VisiblePoint((1050,0,28)) && CaelumContaminationStorage.Value(ledger.Hidden)==11,"native wall blocks a body beyond the room");
            bool found=false;
            for(int i=0;i<sheet.Tiles.Size();i++)if(sheet.Tiles[i].Kind==2 && sheet.Tiles[i].Concentration==100)
            {found=true;ledger.WallTile=sheet.Tiles[i];break;}
            Check(found,"reachable wall cells are stored separately from the floor");
            CaelumContaminationStorage.Set(ledger.Body,46);
            ledger.Started=level.time;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && level.time-ledger.Started>5)
        {
            Check(CaelumContaminationStorage.Value(ledger.Body)<50,"instant pulse does not continue forcing contamination on following tics");
            ledger.Chest.ChestOpen=false;CaelumContaminationStorage.Set(ledger.Stored,37);
            user.SetOrigin((-300,0,0),false);other.SetOrigin((-300,200,0),false);
            CaelumContaminationStorage.Set(user,0);CaelumContaminationStorage.Set(other,0);
            ledger.Phase=10;Level.ChangeLevel("CTP440",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==10 && level.MapName=="CTP440")
        {
            user.SetOrigin((0,0,96),false);other.SetOrigin((-200,-200,96),false);
            let upper=CaelumTarotContamination.Pulse(user,(16,16,124),100,1);
            let sheet=CaelumContaminationSurfaces.CurrentMap(user);
            ledger.UpperTile=sheet.Find(1,1,0,0,0,false);
            Check(ledger.UpperTile!=null && ledger.UpperTile.Concentration==100,"native 3D support uses its model-sector surface record");
            Check(sheet.Find(0,0,0,0,0,false)==null,"opaque 3D floor shields the lower floor from an upper pulse");
            user.SetOrigin((0,0,0),false);
            CaelumTarotContamination.Pulse(user,(16,16,28),100,1);
            ledger.LowerTile=sheet.Find(0,0,0,0,0,false);
            Check(ledger.LowerTile!=null && ledger.LowerTile.Concentration==100,"pulse below the bridge reaches the lower floor");
            CaelumTarotContamination.Pulse(user,(16,16,28),0,1);
            Check(ledger.LowerTile!=null && ledger.LowerTile.Concentration==0 && ledger.UpperTile!=null && ledger.UpperTile.Concentration==100,"lower surface reset cannot pass through the bridge to the upper record");
            user.SetOrigin((880,0,28),false);
            CaelumTarotContamination.Pulse(user,(880,0,56),100,1);
            vector2 cell=CaelumContaminationSurfaceContact.PlaneCoordinates((880,16),(.25,0));
            ledger.SlopeTile=sheet.Find(0,2,0,CaelumContaminationSurfaceContact.Cell(cell.X),0,false);
            Check(ledger.SlopeTile!=null && ledger.SlopeTile.Concentration==100,"sloped floor uses the same physical cell coordinates as contact");
            // Las referencias a actores del mapa anterior se liberan al viajar.
            // El guardado común verifica un contenedor del mapa actualmente cargado.
            ledger.Chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(200,200,96),NO_REPLACE));
            ledger.Stored=Equipment(ledger.Chest);ledger.Chest.ChestOpen=false;
            CaelumContaminationStorage.Set(ledger.Stored,37);
            CaelumContaminationStorage.Set(user,0);CaelumContaminationStorage.Set(other,0);
            ledger.Phase=3;user.PersistCharacterState();Console.Printf("CA440D RESULT capture");return;
        }
        if(ledger.Phase==3 && Reloaded)
        {
            Check(ledger.FloorTile!=null && ledger.FloorTile.Concentration==100,"recovery retains the exact contaminated floor record");
            Check(ledger.WallTile!=null && ledger.WallTile.Concentration==100,"recovery retains the exact contaminated wall record");
            Check(ledger.Boxed.InMagicBox && CaelumContaminationStorage.Value(ledger.Boxed)==23,"recovery retains shielded Box state");
            Check(!ledger.Chest.ChestOpen && CaelumContaminationStorage.Value(ledger.Stored)==37,"recovery preserves closed chest contents");
            Check(user.GetPersistentCharacterState(false).TarotCooldownTics>0 && !user.GetPersistentCharacterState(false).TarotActive[13],"recovery keeps the paid cooldown without replaying the pulse");
            Check(ledger.UpperTile!=null && ledger.UpperTile.Concentration==100 && ledger.SlopeTile!=null && ledger.SlopeTile.Concentration==100,"recovery preserves independent bridge and slope records");
            ledger.Phase=4;Console.Printf("CA440D RESULT reload");
        }
    }
}
