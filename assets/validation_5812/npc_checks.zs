// Native thermal scheduling remains active only in the live-clock cases.
class CA502NPCRat : CaelumGiantRat {
    bool Simulate;
    override void Tick(){if(Simulate)CaelumThermalRuntime.NPCStep(self);}
}
class CA502NPCSoldier : CaelumPortDefender {
    bool Simulate;
    override void Tick(){if(Simulate)CaelumThermalRuntime.NPCStep(self);}
}
class CA502NPCResident : CaelumRulo {override void Tick(){}}
class CA502NPCProof : Inventory {
    CA502NPCSoldier Soldier;CA502NPCRat Rat;CaelumEquipmentItem NativeItem;
    double BodyC,ArmorC,WeaponC,ShieldC,ItemC;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502NPCChecks : EventHandler
{
    CA502NPCSoldier Soldier;CA502NPCRat Rat;CaelumEquipmentItem Item;
    int Passed,Failed;bool Manual;
    String BodyReading,GearReading;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502N %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    void Prepare(CaelumPlayer u)
    {
        if(Soldier==null)Soldier=CA502NPCSoldier(Actor.Spawn('CA502NPCSoldier',u.Pos+(96,-48,0),NO_REPLACE));
        if(Rat==null)Rat=CA502NPCRat(Actor.Spawn('CA502NPCRat',u.Pos+(96,48,0),NO_REPLACE));
        Soldier.Simulate=Rat.Simulate=false;Soldier.Mass=Rat.Mass=80;
        Soldier.health=Rat.health=100000;Soldier.CombatToughness=Rat.CombatToughness=100;
        if(Item==null)
        {
            Item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',Soldier.Pos,NO_REPLACE));
            Item.ItemId=905031;Item.AcquisitionResolved=Item.PickupDataInitialized=true;Item.Amount=1;
            Item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            Item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
            Item.UnitWeight=1;Item.Tier=1;Item.Durability=1000;Item.AttachToOwner(Soldier);
        }
    }
    void Clean()
    {
        CaelumContaminationStorage.Set(Soldier,0);CaelumContaminationStorage.Set(Rat,0);
        CaelumContaminationStorage.Set(Item,0);Item.InMagicBox=false;
        for(int slot=0;slot<4;slot++)CaelumContaminationCombat.Exterior(Soldier,slot).Set(0);
        CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Set(0);
        CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Set(0);
    }
    CaelumThermalState Climate()
    {
        let t=new('CaelumThermalState');t.Initialize();t.Available=true;
        t.BodyMassKg=80;t.SurfaceArea=2;t.AirC=20;t.Humidity=50;t.Roof=true;
        for(int i=0;i<4;i++)t.Coverage[i]=0.25;return t;
    }
    void Core()
    {
        Clean();let t=Climate();let f=new('CaelumContaminationNPC');
        f.Advance(Rat,t,1,80);
        Check(Near(CaelumContaminationStorage.Value(Rat),Sqrt(31)),"bare NPC integrates total exposed area and body dose");
        CaelumContaminationStorage.Set(Rat,0);t.BodyMassKg=40;f.Advance(Rat,t,1,80);
        Check(Near(CaelumContaminationStorage.Value(Rat),Sqrt(63)),"40kg body receives double concentration dose");
        Clean();t=Climate();f.Advance(Soldier,t,1,80);
        Check(Near(CaelumContaminationCombat.Exterior(Soldier,1).Value(),Sqrt(7)),"modeled armor receives outside exposure first");
        double covered=CaelumContaminationStorage.Value(Soldier);
        Check(covered>0 && covered<Sqrt(31),"armor-to-body contact uses the shared covered-body balance");
        Check(CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Value()>0,"modeled sword exposed");
        Check(CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Value()>0,"modeled shield exposed");
        Check(Near(CaelumContaminationStorage.Value(Item),CaelumContaminationRules.AfterContact(0,80,0.16,1)),"native equipment exposed exactly once");
        let reused=f.Frame.Items[0];f.Advance(Soldier,t,1,80);
        Check(reused==f.Frame.Items[0],"unchanged NPC reuses frame rows");
        Clean();Item.InMagicBox=true;f.Advance(Soldier,t,1,80);
        Check(CaelumContaminationStorage.Value(Item)==0,"boxed native gear protected");
        Item.InMagicBox=false;f.Advance(Soldier,t,1,80);
        Check(CaelumContaminationStorage.Value(Item)>0,"unboxing exposes same item");
        Clean();CaelumContaminationStorage.Set(Rat,80);f.Advance(Rat,t,60,5);
        Check(CaelumContaminationStorage.Value(Rat)==80,"clean air never cleans body");
        t=Climate();for(int i=0;i<4;i++){t.SubmergedCoverage[i]=0.25;t.CleanWaterCoverage[i]=0.25;}
        f.Advance(Rat,t,60,80);
        Check(Near(CaelumContaminationStorage.Value(Rat),78),"potable immersion washes submerged NPC body");
        Clean();t=Climate();for(int i=0;i<4;i++){t.SubmergedCoverage[i]=0.25;t.DirtyWaterCoverage[i]=0.25;}
        f.Advance(Rat,t,1,0);
        Check(Near(CaelumContaminationStorage.Value(Rat),Sqrt(39)),"dirty immersion replaces air on submerged body");
        Clean();CaelumContaminationStorage.Set(Item,40);Soldier.RemoveInventory(Item);
        f.Advance(Soldier,Climate(),10,80);
        Check(CaelumContaminationStorage.Value(Item)==40,"dropped item no longer receives former owner's exposure");
        Item.AttachToOwner(Soldier);
        Clean();CaelumContaminationStorage.Set(Soldier,80);f.Advance(Soldier,Climate(),1,0);
        Check(CaelumContaminationCombat.Exterior(Soldier,1).Value()>0,"dirty body transfers outward to clean worn armor");
        Check(CaelumContaminationStorage.Value(Soldier)==80,"outward contact preserves source concentration");
        let resident=CA502NPCResident(Actor.Spawn('CA502NPCResident',Soldier.Pos+(64,0,0),NO_REPLACE));
        resident.EscortPrisonerId=-1;resident.StoryAnchored=true;resident.EnsureResidentTools();let nativeTool=resident.ResidentTools.Melee;
        CaelumContaminationStorage.Set(nativeTool,0);f.Advance(resident,Climate(),1,80);
        Check(Near(CaelumContaminationStorage.Value(nativeTool),CaelumContaminationRules.AfterContact(0,80,
            CaelumContaminationRules.WeaponArea(nativeTool.ItemType,nativeTool.EquipmentSize),1)),"resident's real weapon receives one dose");
        Check(resident.GetPossessedSidearm().ContaminationState==null,"native-backed sidearm creates no duplicate contamination authority");
        resident.Destroy();
        CaelumContaminationStorage.Set(Rat,0);t=Climate();t.Available=false;
        CaelumContaminationNPC.Step(Rat,t,60);
        Check(CaelumContaminationStorage.Value(Rat)==0,"unknown climate does not invent exposure");
        t.Available=true;Rat.health=0;CaelumContaminationNPC.Step(Rat,t,60);
        Check(CaelumContaminationStorage.Value(Rat)==0,"dead body is outside living NPC thermal schedule");Rat.health=100000;
    }
    void Record(CaelumPlayer u)
    {
        let p=CA502NPCProof(u.GiveInventoryType('CA502NPCProof'));
        Soldier.ChangeTid(905032);Rat.ChangeTid(905033);p.Soldier=Soldier;p.Rat=Rat;p.NativeItem=Item;
        p.BodyC=CaelumContaminationStorage.Value(Soldier);p.ItemC=CaelumContaminationStorage.Value(Item);
        p.ArmorC=CaelumContaminationCombat.Exterior(Soldier,1).Value();
        p.WeaponC=CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Value();
        p.ShieldC=CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Value();
        Check(p.BodyC>0 && p.ArmorC>0 && p.WeaponC>0 && p.ShieldC>0 && p.ItemC>0,"saved NPC and actual equipment contain exposure");
    }
    void Load(CaelumPlayer u)
    {
        let p=CA502NPCProof(u.FindInventory('CA502NPCProof'));Check(p!=null,"saved proof exists");if(p==null)return;
        let soldiers=ActorIterator.Create(905032);let rats=ActorIterator.Create(905033);
        Soldier=CA502NPCSoldier(soldiers.Next());Rat=CA502NPCRat(rats.Next());Item=null;
        Check(Soldier!=null && Rat!=null,"same hub NPC identities restored");if(Soldier==null)return;
        int matches=0;
        for(Inventory cursor=Soldier.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let gear=CaelumEquipmentItem(cursor);
            if(gear!=null && gear.ItemId==905031){Item=gear;matches++;}
        }
        Check(matches==1 && Item.Owner==Soldier,"one native item reacquired from its hub owner");
        Check(Near(CaelumContaminationStorage.Value(Soldier),p.BodyC),"body concentration persists");
        Check(Near(CaelumContaminationCombat.Exterior(Soldier,1).Value(),p.ArmorC),"armor concentration persists");
        Check(Near(CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Value(),p.WeaponC),"weapon concentration persists");
        Check(Near(CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Value(),p.ShieldC),"shield concentration persists");
        Check(Near(CaelumContaminationStorage.Value(Item),p.ItemC),"native item identity and concentration persist");
        CaelumContaminationNPC.Step(Soldier,Climate(),1);
        Check(CaelumContaminationStorage.Value(Soldier)>=p.BodyC,"rebuilt transient adapter preserves existing dirt");
        let carrier=CaelumContaminationCarrier(Soldier.FindInventory('CaelumContaminationCarrier'));
        Check(carrier!=null && carrier.bNoBlockmap && carrier.bNoSector && carrier.AttachmentRevision==1,"carrier uses migrated native inventory links");
        double value=CaelumContaminationStorage.Value(Soldier);carrier.EnsureAttachment();
        Check(CaelumContaminationStorage.Value(Soldier)==value,"attachment migration is idempotent");
    }
    void Live(CaelumPlayer u)
    {
        Clean();Soldier.Simulate=Rat.Simulate=true;Manual=true;u.Angle=0;u.Pitch=0;
        Soldier.ThermalState=null;Rat.ThermalState=null;
        Console.Printf("CA502N LIVE F1 reinicia; F2 lee sin reiniciar. La exposicion continua sola.");
    }
    void Readings()
    {
        Console.Printf("CA502N LIVE cuerpo NPC %.3f armadura %.3f espada %.3f escudo %.3f animal %.3f",
            CaelumContaminationStorage.Value(Soldier),CaelumContaminationCombat.Exterior(Soldier,1).Value(),
            CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Value(),CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Value(),CaelumContaminationStorage.Value(Rat));
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Manual || Soldier==null || Rat==null)return;let f=Font.GetFont('CaelumMono');
        Screen.Dim(0x000000,0.9,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.20));
        Screen.DrawText(f,Font.CR_GOLD,8,8,"#502 Exposicion ambiental continua de NPC",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,24,BodyReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,40,GearReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,56,"F1 reinicia | F2 informa sin reiniciar | F6 consola",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
    override void WorldTick()
    {
        if(!Manual || Soldier==null || Rat==null)return;
        BodyReading=String.Format("Cuerpo soldado: %.2f | Armadura: %.2f | Animal: %.2f",
            CaelumContaminationStorage.Value(Soldier),CaelumContaminationCombat.Exterior(Soldier,1).Value(),CaelumContaminationStorage.Value(Rat));
        GearReading=String.Format("Espada: %.2f | Escudo: %.2f | Objeto llevado: %.2f",
            CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Value(),CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Value(),CaelumContaminationStorage.Value(Item));
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || players[e.Player].mo==null)return;let u=CaelumPlayer(players[e.Player].mo);
        if(e.Name=='ca502n_prepare')Prepare(u);
        else if(e.Name=='ca502n_core')Core();
        else if(e.Name=='ca502n_save'){Clean();let f=new('CaelumContaminationNPC');f.Advance(Soldier,Climate(),10,80);Record(u);}
        else if(e.Name=='ca502n_load')Load(u);
        else if(e.Name=='ca502n_manual')Live(u);
        else if(e.Name=='ca502n_read')Readings();
        else if(e.Name=='ca502n_clock')
        {
            Readings();Check(CaelumContaminationStorage.Value(Rat)>0,"native NPC thermal clock exposes bare body");
            Check(CaelumContaminationStorage.Value(Soldier)>0,"native clock exposes covered body through equipment");
            Check(CaelumContaminationStorage.Value(Item)>0,"native clock exposes carried native item");
            Check(Soldier.ContaminationExposure!=null && Rat.ContaminationExposure!=null,"production service owns adapter");
        }
        else return;Console.Printf("CA502N RESULT passed=%d failures=%d",Passed,Failed);
    }
}
