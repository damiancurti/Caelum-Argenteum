// Contenido de MAP02. Inventarios reales y estado serializado por el hub nativo.
class CaelumMazeChest : CaelumStashChest
{
    Inventory Loot[5];
    bool Stocked;
    int Seeded;

    void EnsureLoot()
    {
        if(Stocked)return;
        while(Seeded<5)
        {
            let item=CaelumMazeLootCatalogue.Create(args[0]*5+Seeded,Pos);
            if(item==null)return;
            item.AttachToOwner(self);Loot[Seeded]=item;Seeded++;
        }
        Stocked=true;
    }

    override void Tick() { Super.Tick();EnsureLoot(); }

    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)
            || !CaelumUseGeometry.AimedAt(user,self) || !user.CheckSight(self))return false;
        if(UseLatched && LastChestUser==user)return true;
        UseLatched=true;LastChestUser=user;EnsureLoot();
        if(!ChestOpen)
        {
            ChestOpen=true;RefreshChestVisual();A_StartSound("caelum/world/door_open",CHAN_BODY);
            user.A_Print(StringTable.Localize("CA_MAZE_CHEST_OPEN",false));return true;
        }
        int taken=0,remaining=0;
        for(int i=0;i<5;i++)
        {
            let item=Loot[i];if(item==null || item.Owner!=self)continue;
            item.BecomePickup();item.bSpecial=false;
            Actor receiver=user;
            // La ruta nativa conserva identidad, peso, Caja y durabilidad.
            if(item.CallTryPickup(receiver)){Loot[i]=null;taken++;}
            else {item.AttachToOwner(self);remaining++;}
        }
        user.A_Print(String.Format(StringTable.Localize("CA_MAZE_CHEST_TAKEN",false),taken,remaining));
        return true;
    }

    override void OnDestroy()
    {
        for(int i=0;i<5;i++) if(Loot[i]!=null && Loot[i].Owner==self)
        {Loot[i].BecomePickup();Loot[i].SetOrigin(Pos+(0,0,32),false);}
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
class CaelumMazeTrapdoor : CaelumTrapdoor { Default { Radius 64; } }
class CaelumMazeFood : CaelumFoodRation { Default { Inventory.Amount 5; } }
class CaelumMazeWater : CaelumWaterRation { Default { Inventory.Amount 5; } }

class CaelumSewerMaze : Object play
{
    const CUPS_ACE = CaelumConstants.TAROT_MAJOR_COUNT + CaelumConstants.TAROT_MINOR_RANK_COUNT;

    static bool BossAlive()
    {
        let bosses=ActorIterator.Create(43799,"CaelumZupayColossus");Actor boss;
        while((boss=bosses.Next())!=null)if(boss.health>0)return true;
        return false;
    }

    static bool CanLeave(CaelumPlayer user)
    {
        if(level.MapName!="MAP02")return true;
        if(BossAlive()) {user.A_Print(StringTable.Localize("CA_MAZE_ZUPAY_GUARD",false));return false;}
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.HasTarotCard(CUPS_ACE))
        {user.A_Print(StringTable.Localize("CA_MAZE_CARD_GUARD",false));return false;}
        return true;
    }

    static void Report()
    {
        int chests=0,objects=0,mandingas=0;
        let it=ThinkerIterator.Create("CaelumMazeChest");CaelumMazeChest chest;
        while((chest=CaelumMazeChest(it.Next()))!=null)
        {
            chests++;
            for(int i=0;i<5;i++)if(chest.Loot[i]!=null && chest.Loot[i].Owner==chest)objects++;
        }
        let enemies=ThinkerIterator.Create("CaelumMandinga");Actor enemy;
        while((enemy=Actor(enemies.Next()))!=null)if(enemy.health>0)mandingas++;
        Console.Printf("[Caelum 4.36.0i] Laberinto MAP02: cofres=%d objetos restantes=%d Mandingas vivos=%d Zupay vivo=%d",chests,objects,mandingas,BossAlive());
        Console.Printf("Contenido inicial: 39 cofres, 195 piezas, 96 Mandingas, 45 trampas, 120 raciones de comida y 120 de agua. Carta: índice %d.",CUPS_ACE);
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

class CaelumCupsAceEssence : Actor
{
    int RevealedTo;
    override void Tick()
    {
        Super.Tick();
        // En solitario la esencia desaparece al incorporarse a la colección.
        if(!multiplayer && players[0].mo != null)
        {
            let owner = CaelumPlayer(players[0].mo);
            let record = owner != null ? owner.GetPersistentCharacterState(false) : null;
            if(record != null && record.HasTarotCard(CaelumSewerMaze.CUPS_ACE))
            { Destroy(); return; }
        }
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(!playeringame[i] || (RevealedTo & (1<<i)))continue;
            let user=CaelumPlayer(players[i].mo);
            if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete
                || user.CreationWizardOpen || user.Distance2D(self)>256 || !user.CheckSight(self))continue;
            RevealedTo|=1<<i;EventHandler.SendInterfaceEvent(i,"ca_tarot_reveal");
            user.A_Print(StringTable.Localize("CA_MAZE_CUPS_ACE",false));
        }
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)
            || !CaelumUseGeometry.AimedAt(user,self) || !user.CheckSight(self))return false;
        if(CaelumSewerMaze.BossAlive())
        {user.A_Print(StringTable.Localize("CA_MAZE_ZUPAY_GUARD",false));return true;}
        let record=user.GetPersistentCharacterState(true);if(record==null)return false;
        if(record.HasTarotCard(CaelumSewerMaze.CUPS_ACE))return true;
        record.TarotOwned[CaelumSewerMaze.CUPS_ACE]=true;
        user.ApplyCharacterProfile();user.RefreshSocialJournalSnapshot();
        user.RefreshFormalInventorySnapshot();user.PersistCharacterState();
        EventHandler.SendInterfaceEvent(user.PlayerNumber(),"ca_tarot_capture");
        user.A_Print(StringTable.Localize("CA_MAZE_CUPS_CAPTURED",false));
        // La esencia queda accesible para otros jugadores sin duplicar la colección.
        return true;
    }
    Default { Tag "$CA_MAZE_CUPS_ACE"; Radius 20; Height 48; Scale 0.65; +NOGRAVITY +FLOATBOB +SOLID }
    States { Spawn: CTAR A -1 Bright; Stop; }
}
