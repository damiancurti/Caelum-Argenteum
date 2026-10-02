// Generado por generate_map02_maze.py. 65 piezas T1, sin duplicados.
class CaelumMazeLootCatalogue : Object play
{
    const REVISION = 1;
    const ENTRY_COUNT = 65;
    const CHEST_COUNT = 39;

    static int ChestEntry(int chest, int slot)
    {
        int index=chest+slot*CHEST_COUNT;
        return chest>=0 && chest<CHEST_COUNT && slot>=0 && index<ENTRY_COUNT?index:-1;
    }

    static Inventory Create(int index, vector3 position)
    {
        if(index<0 || index>=ENTRY_COUNT)return null;
        switch(index / 20)
        {
        case 0: return Create0(index,position);
        case 1: return Create1(index,position);
        case 2: return Create2(index,position);
        case 3: return Create3(index,position);
        }
        return null;
    }
    static Inventory Create0(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 0:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=0;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 1:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=0;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 2:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=0;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 3:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=0;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 4:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 5:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 6:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 7:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 8:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 9:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 10:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 11:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 12:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 13:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 14:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 15:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=1;item.args[3]=0;item.args[4]=0;CaelumArmorPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 16:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 17:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 18:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=2;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 19:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=3;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        }
        return item;
    }
    static Inventory Create1(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 20:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=4;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 21:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=5;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 22:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 23:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 24:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 25:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=5;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 26:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=6;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 27:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=7;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 28:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=8;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 29:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=9;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 30:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=10;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 31:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=11;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 32:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=12;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 33:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=13;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 34:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=14;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 35:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=15;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 36:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=16;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 37:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 38:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=2;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 39:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=3;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        }
        return item;
    }
    static Inventory Create2(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 40:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=4;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 41:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=5;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 42:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 43:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=2;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 44:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=3;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 45:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=4;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 46:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=5;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 47:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=1;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 48:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=2;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 49:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=3;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 50:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=4;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 51:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=5;CaelumWeaponPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 52:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0;CaelumShieldPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 53:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0;CaelumShieldPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 54:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0;CaelumShieldPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 55:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0;CaelumShieldPickup(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT; }
            break;
        case 56:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 57:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 58:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 59:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        }
        return item;
    }
    static Inventory Create3(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 60:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 61:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 62:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 63:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 64:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=1;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        }
        return item;
    }
    static CaelumMazeMaterialBudget MaterialBudget(int chest,int size)
    {
        let budget=new("CaelumMazeMaterialBudget");budget.Valid=true;budget.Efficiency=2;
        for(int slot=0;slot<2;slot++)AddMaterialEntry(budget,ChestEntry(chest,slot),size);
        return budget;
    }
    static void AddMaterialEntry(CaelumMazeMaterialBudget budget,int index,int size)
    {
        switch(index)
        {
        case 0: budget.AddArmor(0,size,0); break;
        case 1: budget.AddArmor(0,size,1); break;
        case 2: budget.AddArmor(0,size,2); break;
        case 3: budget.AddArmor(0,size,3); break;
        case 4: budget.AddArmor(1,size,0); break;
        case 5: budget.AddArmor(1,size,1); break;
        case 6: budget.AddArmor(1,size,2); break;
        case 7: budget.AddArmor(1,size,3); break;
        case 8: budget.AddArmor(2,size,0); break;
        case 9: budget.AddArmor(2,size,1); break;
        case 10: budget.AddArmor(2,size,2); break;
        case 11: budget.AddArmor(2,size,3); break;
        case 12: budget.AddArmor(3,size,0); break;
        case 13: budget.AddArmor(3,size,1); break;
        case 14: budget.AddArmor(3,size,2); break;
        case 15: budget.AddArmor(3,size,3); break;
        case 16: budget.AddCatalogueWeapon(0,0,size); break;
        case 17: budget.AddCatalogueWeapon(1,0,size); break;
        case 18: budget.AddCatalogueWeapon(1,1,size); break;
        case 19: budget.AddCatalogueWeapon(1,2,size); break;
        case 20: budget.AddCatalogueWeapon(1,3,size); break;
        case 21: budget.AddCatalogueWeapon(1,4,size); break;
        case 22: budget.AddCatalogueWeapon(2,0,size); break;
        case 23: budget.AddCatalogueWeapon(3,0,size); break;
        case 24: budget.AddCatalogueWeapon(4,0,size); break;
        case 25: budget.AddCatalogueWeapon(5,0,size); break;
        case 26: budget.AddCatalogueWeapon(6,0,size); break;
        case 27: budget.AddCatalogueWeapon(7,0,size); break;
        case 28: budget.AddCatalogueWeapon(8,0,size); break;
        case 29: budget.AddCatalogueWeapon(9,0,size); break;
        case 30: budget.AddCatalogueWeapon(10,0,size); break;
        case 31: budget.AddCatalogueWeapon(11,0,size); break;
        case 32: budget.AddCatalogueWeapon(12,0,size); break;
        case 33: budget.AddCatalogueWeapon(13,0,size); break;
        case 34: budget.AddCatalogueWeapon(14,0,size); break;
        case 35: budget.AddCatalogueWeapon(15,0,size); break;
        case 36: budget.AddCatalogueWeapon(16,0,size); break;
        case 37: budget.AddCatalogueWeapon(17,0,size); break;
        case 38: budget.AddCatalogueWeapon(17,1,size); break;
        case 39: budget.AddCatalogueWeapon(17,2,size); break;
        case 40: budget.AddCatalogueWeapon(17,3,size); break;
        case 41: budget.AddCatalogueWeapon(17,4,size); break;
        case 42: budget.AddCatalogueWeapon(18,0,size); break;
        case 43: budget.AddCatalogueWeapon(18,1,size); break;
        case 44: budget.AddCatalogueWeapon(18,2,size); break;
        case 45: budget.AddCatalogueWeapon(18,3,size); break;
        case 46: budget.AddCatalogueWeapon(18,4,size); break;
        case 47: budget.AddCatalogueWeapon(19,0,size); break;
        case 48: budget.AddCatalogueWeapon(19,1,size); break;
        case 49: budget.AddCatalogueWeapon(19,2,size); break;
        case 50: budget.AddCatalogueWeapon(19,3,size); break;
        case 51: budget.AddCatalogueWeapon(19,4,size); break;
        case 52: budget.AddShield(0,size); break;
        case 53: budget.AddShield(1,size); break;
        case 54: budget.AddShield(2,size); break;
        case 55: budget.AddShield(3,size); break;
        case 56: budget.AddAmulet(0); break;
        case 57: budget.AddAmulet(1); break;
        case 58: budget.AddAmulet(2); break;
        case 59: budget.AddAmulet(3); break;
        case 60: budget.AddSeal(0); break;
        case 61: budget.AddSeal(1); break;
        case 62: budget.AddSeal(2); break;
        case 63: budget.AddSeal(3); break;
        case 64: budget.AddSeal(4); break;
        }
    }
}
