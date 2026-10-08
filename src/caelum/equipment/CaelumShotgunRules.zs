// #136: contrato de escopeta aprobado; dos cañones, un cartucho por disparo.
class CaelumShotgunRules : Object
{
    const REVISION=1;
    const CAPACITY=2;
    const PELLETS=12;
    const PELLET_DAMAGE_RATIO=0.10;
    const SHOT_DAMAGE_RATIO=PELLETS*PELLET_DAMAGE_RATIO;
    const RANGE_RATIO=0.50;

    static int MigrateDurability(int oldValue)
    {
        return int(double(oldValue)*CaelumConstants.WEAPON_CARBINE_BASE_DURABILITY
            /CaelumConstants.WEAPON_PHYSICAL_BASE_DURABILITY+0.5);
    }

    // Diferencias entre sumas redondeadas: el presupuesto completo se conserva
    // aun cuando un perdigón nominal no corresponde a un número entero de HP.
    static int PelletDamage(double total,int index)
    {
        return int(Max(0.0,total)*(index+1)/PELLETS+0.5)
            - int(Max(0.0,total)*index/PELLETS+0.5);
    }

    static play bool Fire(Actor owner,CaelumWeaponModel weapon,double total,bool critical,
        double push,double minimum,double maximum)
    {
        Array<CaelumCarbineProjectile> launched;
        for(int i=0;i<PELLETS;i++)
        {
            double spread=minimum+(maximum-minimum)*Random[CaelumShotgunSpread](0,100000)/100000.0;
            double yaw=owner.Angle+Random[CaelumShotgunYaw](-100000,100000)/100000.0*spread;
            double pitch=owner.Pitch+Random[CaelumShotgunPitch](-100000,100000)/100000.0*spread;
            let pellet=CaelumRangedRules.Fire(owner,weapon,PelletDamage(total,i),critical,push,yaw,pitch);
            if(pellet==null)
            {
                for(int j=0;j<launched.Size();j++)launched[j].Destroy();
                return false;
            }
            launched.Push(pellet);
        }
        return true;
    }
}

class CaelumShotgunPellet : CaelumCarbineProjectile
{
    // El daño cero de un presupuesto fraccionario no se convierte en un HP.
    override int DoSpecialDamage(Actor victim,int damage,Name damageType)
    {
        if(CaelumAttackPrepared && CaelumPreparedDamage==0)return 0;
        return Super.DoSpecialDamage(victim,damage,damageType);
    }
}

class CaelumShotgunAmmo : CaelumCarbineAmmo
{
    override int GetAmmoType(){return CaelumConstants.AMMUNITION_SHOTGUN;}
    override bool HandlePickup(Inventory item)
    {
        // Ammo agrupa subclases por su padre: no aceptar balas en esta pila.
        if(item.GetClass()!=GetClass())return false;
        return Super.HandlePickup(item);
    }
    override bool TryPickup(in out Actor toucher)
    {
        let user=CaelumPlayer(toucher);
        if(user==null || Owner!=null)return false;
        if(!CaelumInventoryService.AcquireDistinctAmmunition(user,GetAmmoType(),Amount))return false;
        A_StartSound("caelum/items/pickup",CHAN_ITEM);Destroy();return true;
    }
    Default
    {
        Inventory.Icon "CA_SHOTGUN_AMMO";
        Inventory.PickupMessage "$CA_AMMUNITION_SHOTGUN";
    }
    States { Spawn: CSAM A -1; Stop; }
}

// Clases nuevas: no cambian índices de estados guardados de armas anteriores.
class CaelumShotgunFrames : Actor
{
    States (Weapon,Overlay)
    {
    T1_0: SHF1 A -1; Stop;
    T1_1: SHF1 B -1; Stop;
    T1_2: SHF1 C -1; Stop;
    T1_3: SHF1 D -1; Stop;
    T1_4: SHF1 E -1; Stop;
    T1_5: SHF1 F -1; Stop;
    T1_6: SHF1 G -1; Stop;
    T2_0: SHF2 A -1; Stop;
    T2_1: SHF2 B -1; Stop;
    T2_2: SHF2 C -1; Stop;
    T2_3: SHF2 D -1; Stop;
    T2_4: SHF2 E -1; Stop;
    T2_5: SHF2 F -1; Stop;
    T2_6: SHF2 G -1; Stop;
    T3_0: SHF3 A -1; Stop;
    T3_1: SHF3 B -1; Stop;
    T3_2: SHF3 C -1; Stop;
    T3_3: SHF3 D -1; Stop;
    T3_4: SHF3 E -1; Stop;
    T3_5: SHF3 F -1; Stop;
    T3_6: SHF3 G -1; Stop;
    }
}
class CaelumShotgunHandFrames : Actor
{
    States (Weapon,Overlay)
    {
    Hands_0: SHHD A -1; Stop;
    Hands_1: SHHD B -1; Stop;
    Hands_2: SHHD C -1; Stop;
    Hands_3: SHHD D -1; Stop;
    Hands_4: SHHD E -1; Stop;
    Hands_5: SHHD F -1; Stop;
    Hands_6: SHHD G -1; Stop;
    }
}
class CaelumShotgunView : Object play
{
    static void Draw(CaelumPlayer user,int tier,double dx,double dy,double rotation)
    {
        user.A_ClearOverlays(46,47);user.A_ClearOverlays(52,53);
        int pose=user.RangedAimModeActive ? 1 : 0;
        if(user.RangedReloadActive)
        {
            bool partial=user.GetRangedMagazineCount(CaelumConstants.WEAPON_TYPE_SHOTGUN)>0;
            let ammo=user.FindNativeAmmunition(CaelumConstants.AMMUNITION_SHOTGUN);
            bool single=ammo!=null && ammo.Amount==1;
            pose=user.RangedReloadRemainingSeconds>user.RangedReloadTotalSeconds*0.5 ? (partial ? 6 : 2) : partial ? 3 : single ? 5 : 4;
        }
        State state=GetDefaultByType("CaelumShotgunFrames").FindStateByString(String.Format("T%d_%d",Clamp(tier,1,3),pose));
        CaelumFirstPersonLayers.Place(user,50,state,(160+dx,200+dy),(0.5,1.0),0.68,rotation,true);
        if(pose==1)
        {
            // Mismo guante, escala y apoyo bajo la culata que la carabina.
            user.A_ClearOverlays(51,51);
            vector2 grip=(165+dx,210+dy);
            CaelumFirstPersonLayers.Hand(user,48,6,grip,(-8,-25),0.88,rotation);
            CaelumFirstPersonLayers.Hand(user,49,5,grip,(23,-27),0.88,rotation);
            return;
        }
        user.A_ClearOverlays(48,49);
        // Las manos se sustituyen sin duplicar el arma ni alterar su animación.
        State hands=GetDefaultByType("CaelumShotgunHandFrames").FindStateByString(String.Format("Hands_%d",pose));
        CaelumFirstPersonLayers.Place(user,51,hands,(160+dx,200+dy),(0.5,1.0),0.68,rotation,true);
    }
}
