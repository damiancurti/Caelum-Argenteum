// Generado por generate_map02_maze.py. Cada cofre tiene cinco objetos únicos.
class CaelumMazeLootCatalogue : Object play
{
    static Inventory Create(int index, vector3 position)
    {
        switch(index / 20)
        {
        case 0: return Create0(index,position);
        case 1: return Create1(index,position);
        case 2: return Create2(index,position);
        case 3: return Create3(index,position);
        case 4: return Create4(index,position);
        case 5: return Create5(index,position);
        case 6: return Create6(index,position);
        case 7: return Create7(index,position);
        case 8: return Create8(index,position);
        case 9: return Create9(index,position);
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
            if(item!=null) { item.args[0]=0;item.args[1]=0;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 1:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=0;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 2:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=0;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 3:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=0;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 4:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 5:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 6:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 7:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 8:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 9:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 10:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 11:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 12:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 13:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 14:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 15:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=1;item.args[3]=3;item.args[4]=0; }
            break;
        case 16:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 17:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 18:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 19:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
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
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 21:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 22:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 23:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 24:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 25:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=5;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 26:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=6;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 27:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=7;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 28:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=8;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 29:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=9;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 30:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=10;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 31:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=11;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 32:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=12;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 33:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=13;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 34:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=14;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 35:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=15;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 36:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=16;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 37:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 38:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 39:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
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
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 41:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 42:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 43:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 44:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 45:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 46:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 47:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 48:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 49:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 50:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 51:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 52:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 53:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 54:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 55:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
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
        case 65:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=0;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 66:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=0;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 67:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=0;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 68:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=0;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 69:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 70:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 71:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 72:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 73:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 74:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 75:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 76:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 77:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 78:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 79:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        }
        return item;
    }
    static Inventory Create4(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 80:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=2;item.args[3]=3;item.args[4]=0; }
            break;
        case 81:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 82:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 83:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 84:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 85:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 86:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 87:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 88:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 89:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 90:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=5;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 91:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=6;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 92:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=7;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 93:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=8;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 94:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=9;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 95:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=10;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 96:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=11;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 97:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=12;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 98:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=13;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 99:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=14;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        }
        return item;
    }
    static Inventory Create5(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 100:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=15;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 101:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=16;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 102:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 103:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 104:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 105:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 106:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 107:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 108:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 109:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 110:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 111:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 112:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 113:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 114:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 115:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 116:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 117:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 118:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 119:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        }
        return item;
    }
    static Inventory Create6(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 120:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 121:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 122:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 123:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 124:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 125:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 126:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 127:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 128:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 129:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=2;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 130:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=0;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 131:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=0;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 132:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=0;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 133:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=0;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 134:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=1;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 135:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=1;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 136:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=1;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 137:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=1;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 138:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=2;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 139:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=2;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        }
        return item;
    }
    static Inventory Create7(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 140:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=2;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 141:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=2;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 142:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 143:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 144:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 145:
            item=Inventory(Actor.Spawn("CaelumArmorPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=3;item.args[3]=3;item.args[4]=0; }
            break;
        case 146:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 147:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 148:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 149:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 150:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 151:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 152:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 153:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 154:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 155:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=5;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 156:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=6;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 157:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=7;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 158:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=8;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 159:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=9;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        }
        return item;
    }
    static Inventory Create8(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 160:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=10;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 161:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=11;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 162:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=12;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 163:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=13;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 164:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=14;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 165:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=15;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 166:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=16;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 167:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 168:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 169:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 170:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 171:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=17;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 172:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 173:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 174:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        case 175:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 176:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=18;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 177:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=1; }
            break;
        case 178:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=2; }
            break;
        case 179:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=3; }
            break;
        }
        return item;
    }
    static Inventory Create9(int index, vector3 position)
    {
        Inventory item;
        switch(index)
        {
        case 180:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=4; }
            break;
        case 181:
            item=Inventory(Actor.Spawn("CaelumWeaponPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=19;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=5; }
            break;
        case 182:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 183:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 184:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 185:
            item=Inventory(Actor.Spawn("CaelumShieldPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=3;item.args[3]=0;item.args[4]=0; }
            break;
        case 186:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 187:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 188:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 189:
            item=Inventory(Actor.Spawn("CaelumAmuletPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 190:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=0;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 191:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=1;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 192:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=2;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 193:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=3;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        case 194:
            item=Inventory(Actor.Spawn("CaelumSealPickup",position,NO_REPLACE));
            if(item!=null) { item.args[0]=4;item.args[1]=3;item.args[2]=0;item.args[3]=0;item.args[4]=0; }
            break;
        }
        return item;
    }
}
