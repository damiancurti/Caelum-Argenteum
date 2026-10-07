// Presupuesto de recetas sin cupos, concesiones ni desbloqueos del tutorial.
class CaelumMazeMaterialBudget : CaelumMainM00StarterMaterials
{
    override void Expand(int material,int amount,int depth)
    {
        if(amount<=0)return;
        if(material<0 || material>=CaelumConstants.MATERIAL_TYPE_COUNT || depth>8){Valid=false;return;}
        int component=CaelumCraftingRules.FindComponentRecipeForOutput(material);
        if(component>=0)
        {
            Recipes[component]=true;
            int output=CaelumCraftingRules.GetComponentOutputUnits(0,2);
            int batches=int(Ceil(double(amount)/Max(1,output)));
            Expand(CaelumCraftingRules.GetComponentBaseMaterial(material,1),
                batches*CaelumCraftingRules.GetComponentInputUnits(0),depth+1);
            return;
        }
        int processing=CaelumCraftingRules.FindProcessingRecipeForOutput(material,1);
        if(processing>=0)
        {
            Recipes[processing]=true;
            int output=CaelumCraftingRules.GetProcessingOutputUnits(processing,0);
            int batches=int(Ceil(double(amount)/Max(1,output)));
            Expand(CaelumCraftingRules.GetProcessingInputOneMaterial(processing),
                batches*CaelumCraftingRules.GetProcessingInputOneUnits(processing,0),depth+1);
            int second=CaelumCraftingRules.GetProcessingInputTwoMaterial(processing);
            if(second>=0)Expand(second,batches*CaelumCraftingRules.GetProcessingInputTwoUnits(processing,0),depth+1);
            return;
        }
        Units[material]+=amount;
    }

    void AddCatalogueWeapon(int type,int essence,int size)
    {
        for(int option=0;option<CaelumMainM00StarterRules.OPTION_COUNT;option++)
        {
            if(CaelumMainM00StarterRules.GetWeaponType(option)!=type)continue;
            if(option>=16 && CaelumCraftingRules.GetUnifiedEssenceType(CaelumMainM00StarterRules.GetRecipe(option))!=essence)continue;
            AddWeapon(option,size);return;
        }
        Valid=false;
    }
}

// Contenido de MAP02. Inventarios reales y estado serializado por el hub nativo.
class CaelumMazeChest : CaelumStashChest
{
    Inventory Loot[5];
    bool MaterialAllocated;
    int MaterialSize;
    int MaterialRemaining[CaelumConstants.MATERIAL_TYPE_COUNT];

    int PreviewMaterial(int material,CaelumMazeMaterialBudget budget)
    {
        return MaterialAllocated?MaterialRemaining[material]:budget.Units[material];
    }

    CaelumMazeMaterialBudget PreviewBudget(CaelumPlayer user)
    {
        int size=MaterialAllocated?MaterialSize:CaelumEquipmentRules.ResolveAcquisitionSize(user,
            CaelumEquipmentRules.CHARACTER_DEFAULT,CaelumConstants.EQUIPMENT_SIZE_M);
        return CaelumMazeLootCatalogue.MaterialBudget(args[0],size);
    }

    void CollectMaterials(CaelumPlayer user)
    {
        let budget=PreviewBudget(user);
        if(!budget.Valid)return;
        for(int material=0;material<CaelumConstants.MATERIAL_TYPE_COUNT;material++)
        {
            int remaining=PreviewMaterial(material,budget);
            if(remaining<=0)continue;
            user.RefreshCarriedInventorySummary();
            int low=0,high=remaining;
            while(low<high)
            {
                int mid=low+(high-low+1)/2;
                if(user.CanAddWeightToPersonalInventory(mid*CaelumConstants.MATERIAL_UNIT_WEIGHT))low=mid;
                else high=mid-1;
            }
            if(low<=0)continue;
            let item=CaelumMaterialPickup(Actor.Spawn("CaelumMaterialPickup",Pos,NO_REPLACE));
            if(item==null)return;
            item.args[0]=material;item.args[1]=1;item.Amount=low;item.UpdateMaterialVisuals();
            Actor receiver=user;
            if(!item.CallTryPickup(receiver)){item.Destroy();continue;}
            if(!MaterialAllocated)
            {
                MaterialSize=CaelumEquipmentRules.ResolveAcquisitionSize(user,CaelumEquipmentRules.CHARACTER_DEFAULT,CaelumConstants.EQUIPMENT_SIZE_M);
                for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)MaterialRemaining[m]=budget.Units[m];
                MaterialAllocated=true;
            }
            MaterialRemaining[material]-=low;
        }
        int left=0;
        for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)
            if(PreviewMaterial(m,budget)>0)left++;
        if(left>0)CaelumNotifications.Notify(user,String.Format(
            StringTable.Localize("CA_CHEST_PREVIEW_CAPACITY",false),left));
    }

    bool Stocked;
    int Seeded;
    int LootRevision;
    Inventory LegacyLoot[5];
    bool LegacyLayout;
    bool LegacyStocked;
    int LegacySeeded;

    // Una partida anterior conserva sus huecos vaciados y su distribución.
    // Se retiran sólo T2/T3 aún en el cofre; no se recrea ninguna pieza.
    void MigrateLegacyLoot()
    {
        if(LootRevision>=CaelumMazeLootCatalogue.REVISION)return;
        LegacyLayout=Stocked || Seeded>0;
        LegacyStocked=Stocked;LegacySeeded=Seeded;
        if((Stocked || Seeded>0) && args[0]>=13)
        {
            for(int i=0;i<5;i++)
                if(Loot[i]!=null && Loot[i].Owner==self)
                {LegacyLoot[i]=Loot[i];Loot[i]=null;}
        }
        if(Stocked || Seeded>0)Stocked=true;
        LootRevision=CaelumMazeLootCatalogue.REVISION;
    }

    // Herramienta reversible de migración; nunca se invoca desde el juego.
    void RestoreLegacyLootForMigration()
    {
        if(!LegacyLayout)return;
        for(int i=0;i<5;i++)
            if(LegacyLoot[i]!=null && LegacyLoot[i].Owner==self && Loot[i]==null)
            {Loot[i]=LegacyLoot[i];LegacyLoot[i]=null;}
        LootRevision=0;
        Stocked=LegacyStocked;Seeded=LegacySeeded;
        LegacyLayout=false;
    }

    void EnsureLoot()
    {
        if(CaelumMazeLayout.IsCardinal())return;
        MigrateLegacyLoot();
        if(Stocked)return;
        while(Seeded<5)
        {
            int index=CaelumMazeLootCatalogue.ChestEntry(args[0],Seeded);
            if(index<0){Seeded++;continue;}
            let item=CaelumMazeLootCatalogue.Create(index,Pos);
            if(item==null)return;
            item.AttachToOwner(self);Loot[Seeded]=item;Seeded++;
        }
        Stocked=true;
    }

    override void Tick() { Super.Tick();EnsureLoot(); }

    bool CanInspect(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.health>0 && user.CharacterCreationComplete
            && !user.CreationWizardOpen && !(user.player.cheats & CF_PREDICTING)
            && CaelumUseGeometry.AimedAt(user,self) && user.CheckSight(self);
    }

    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(!CanInspect(user))return false;
        if(UseLatched && LastChestUser==user)return true;
        UseLatched=true;LastChestUser=user;
        if(!ChestOpen)
        {
            ChestOpen=true;RefreshChestVisual();A_StartSound("caelum/world/door_open",CHAN_BODY);
        }
        let preview=CaelumChestPreviewState.Get(user,true);
        if(preview!=null){preview.Chest=self;preview.Refresh();}
        return true;
    }

    void Collect(CaelumPlayer user)
    {
        // Confirmar vuelve a consultar el receptor y las existencias reales.
        if(!CanInspect(user))return;
        if(CaelumMazeLayout.IsCardinal()){CollectMaterials(user);return;}
        int taken=0,remaining=0;
        for(int i=0;i<5;i++)
        {
            let item=Loot[i];if(item==null || item.Owner!=self)continue;
            let equipment=CaelumEquipmentItem(item);
            bool unclaimed=equipment!=null && !equipment.AcquisitionResolved;
            bool oldDropped=item.bDROPPED;
            item.BecomePickup();item.bSpecial=false;
            // BecomePickup pierde el contexto del dueño. Un intento antiguo
            // fallido no debe hacerse pasar por equipo adquirido y soltado.
            if(unclaimed)item.bDROPPED=false;
            Actor receiver=user;
            if(item.CallTryPickup(receiver)){Loot[i]=null;taken++;}
            else {item.bDROPPED=oldDropped;item.AttachToOwner(self);remaining++;}
        }
        if(remaining>0)CaelumNotifications.Notify(user,
            String.Format(StringTable.Localize("CA_CHEST_PREVIEW_CAPACITY",false),remaining));
    }

    override void OnDestroy()
    {
        for(int i=0;i<5;i++) if(Loot[i]!=null && Loot[i].Owner==self)
        {
            let equipment=CaelumEquipmentItem(Loot[i]);
            bool unclaimed=equipment!=null && !equipment.AcquisitionResolved;
            Loot[i].BecomePickup();
            if(unclaimed)Loot[i].bDROPPED=false;
            Loot[i].SetOrigin(Pos+(0,0,32),false);
        }
        if(ChestVisual!=null)ChestVisual.Destroy();
        Super.OnDestroy();
    }
}

class CaelumMazeKey : CaelumWeightedKey
{
    Default
    {
        Scale 0.125;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
    States { Spawn: CKEY A -1; Stop; }
}
class CaelumMazeSluiceKey : CaelumMazeKey
{
    override int GetKeyType(){return 1;}
    Default { Tag "$CA_MAZE_KEY_1"; Inventory.PickupMessage "$CA_MAZE_KEY_1"; }
}
class CaelumMazeCryptKey : CaelumMazeKey
{
    override int GetKeyType(){return 2;}
    Default { Tag "$CA_MAZE_KEY_2"; Inventory.PickupMessage "$CA_MAZE_KEY_2"; }
}
class CaelumMazeSanctumKey : CaelumMazeKey
{
    override int GetKeyType(){return 3;}
    Default { Tag "$CA_MAZE_KEY_3"; Inventory.PickupMessage "$CA_MAZE_KEY_3"; }
}

class CaelumMazeRockPlate : CaelumPressureTrap
{
    override bool Trigger(Actor body)
    {
        if(!IsPressedBy(body))return false;
        let rock=CaelumHazardRock(ActorIterator.Create(args[0],"CaelumHazardRock").Next());
        if(rock==null || !rock.Release())return false;
        Spent=true;ActivationCount++;InterruptVictim(body);return true;
    }
    States { Spawn: CMNE A -1; Stop; }
}
class CaelumMazeTrapdoor : CaelumTrapdoor
{
    override void Tick()
    {
        // Las tapas de bloques cerrados impiden subir desde la red inferior.
        // Ni los enemigos pueden abrirlas antes de habilitar la entrada normal.
        if(CaelumMazeLayout.IsFloodedReturn())
        {
            int entrance=CaelumMazeLayout.PitEntrance(tid);
            if(entrance!=0)
            {
                let gate=CaelumMazeBarredGate(ActorIterator.Create(entrance,"CaelumMazeBarredGate").Next());
                if(gate==null || !gate.Opened)return;
            }
        }
        Super.Tick();
    }
    Default { Radius 64; }
}
class CaelumMazeFood : CaelumFoodRation { Default { Inventory.Amount 5; } }
class CaelumMazeWater : CaelumWaterRation { Default { Inventory.Amount 5; } }

class CaelumSewerMaze : Object play
{
    const CUPS_ACE = CaelumConstants.TAROT_CUPS_ACE;

    static bool BossAlive()
    {
        let bosses=ActorIterator.Create(43799,"CaelumZupayColossus");Actor boss;
        while((boss=bosses.Next())!=null)if(boss.health>0)return true;
        return false;
    }

    static bool CanLeave(CaelumPlayer user)
    {
        if(level.MapName!="MAP02")return true;
        let progress=user.GetPersistentCharacterState(false);
        if(progress==null || !progress.SewerZupayDefeated) {CaelumNotifications.Notify(user,StringTable.Localize("CA_MAZE_ZUPAY_GUARD",false));return false;}
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.HasTarotCard(CUPS_ACE))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_MAZE_CARD_GUARD",false));return false;}
        return true;
    }

    static void Report()
    {
        int chests=0,objects=0,mandingas=0,rats=0;
        let it=ThinkerIterator.Create("CaelumMazeChest");CaelumMazeChest chest;
        while((chest=CaelumMazeChest(it.Next()))!=null)
        {
            chests++;
            for(int i=0;i<5;i++)if(chest.Loot[i]!=null && chest.Loot[i].Owner==chest)objects++;
        }
        let enemies=ThinkerIterator.Create("CaelumMandinga");Actor enemy;
        while((enemy=Actor(enemies.Next()))!=null)if(enemy.health>0)mandingas++;
        let ratIt=ThinkerIterator.Create("CaelumGiantRat");Actor rat;
        while((rat=Actor(ratIt.Next()))!=null)if(rat.health>0)rats++;
        Console.Printf("[Caelum 5.1.0] Laberinto MAP02: cofres=%d objetos heredados restantes=%d Mandingas vivos=%d ratas vivas=%d Zupay vivo=%d",chests,objects,mandingas,rats,BossAlive());
        if(CaelumMazeLayout.IsCardinal())Console.Printf("Contenido inicial: 39 cofres de materiales equivalentes a 65 piezas T1, 96 Mandingas, 192 ratas, 45 trampas; drops: 96 comida, 96 agua, 240 flechas, 120 virotes, 120 balas. Carta: índice %d.",CUPS_ACE);
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            let record=user.GetPersistentCharacterState(false);
            Console.Printf("Jugador %d: llaves=%d/%d/%d 1 de Copas=%d",i,user.FindInventory("CaelumMazeSluiceKey")!=null,
                user.FindInventory("CaelumMazeCryptKey")!=null,user.FindInventory("CaelumMazeSanctumKey")!=null,
                record!=null && record.HasTarotCard(CUPS_ACE));
        }
    }
}

class CaelumCupsAceEssence : CaelumM00FoolEssence
{
    int RevealedTo; // Campo antiguo conservado; la revelación ahora pertenece al viajero.
    override int CardId() { return CaelumConstants.TAROT_CUPS_ACE; }
    override void Tick()
    {
        CaelumArcanaProgress.UpdateEssence(self);
        Super.Tick();
    }
    Default { Tag "$CA_MAZE_CUPS_ACE"; +INVISIBLE -SOLID }
    States
    {
    Spawn:
        CTAR A -1 Bright;
        Stop;
    // Registrar el frente al cargar actores evita inicializarlo por primera
    // vez desde el hilo de renderizado al cambiar sprite en SetRevealed.
    RevealedFront:
        CACU A -1 Bright;
        Stop;
    }
}

class CaelumWandsKnightEssence : CaelumM00FoolEssence
{
    override int CardId() { return CaelumConstants.TAROT_WANDS_KNIGHT; }
    override void Tick()
    {
        CaelumArcanaProgress.UpdateEssence(self);
        Super.Tick();
    }
    Default { Tag "$CA_TAROT_WANDS_KNIGHT_NAME"; +INVISIBLE -SOLID }
    States
    {
    RevealedFront:
        CAWK A -1 Bright;
        Stop;
    }
}
