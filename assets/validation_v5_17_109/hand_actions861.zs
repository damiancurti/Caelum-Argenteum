class CA861ActionsProbe : CA861HandProbe
{
    CA259Session Equipment;
    void EquipAction(int choice)
    {
        if(Equipment==null)Equipment=new('CA259Session');
        Equipment.Choice=choice;Equipment.Tier=1;Equipment.Equip(User);
        if(choice==5)
        {
            int kind=CaelumConstants.WEAPON_TYPE_CARBINE;
            let ammo=User.FindNativeAmmunition(CaelumRangedRules.AmmoType(kind));
            if(ammo==null)ammo=Inventory(User.GiveInventoryType(CaelumInventoryService.GetAmmunitionClassName(User,CaelumRangedRules.AmmoType(kind))));
            Check(ammo!=null,"native ammunition exists for the reload fixture");
            if(ammo!=null)ammo.Amount=Max(ammo.Amount,CaelumRangedRules.MagazineCapacity(kind));
            User.SetRangedMagazineCount(kind,0);
        }
        User.EquipmentMenuOpen=false;
    }
    void ObserveAction(int phase)
    {
        int kind=User.WeaponModel.WeaponType;
        if(kind==CaelumConstants.WEAPON_TYPE_CARBINE)
        {
            Check(User.RangedReloadActive==(phase==1),"carbine capture agrees with actual reload timer");
            if(phase==1)Check(User.RangedReloadRemainingSeconds>0 && User.RangedReloadRemainingSeconds<User.RangedReloadTotalSeconds,"native reload clock advances without fixture timer writes");
            if(phase==2)Check(User.GetRangedMagazineCount(kind)==CaelumRangedRules.MagazineCapacity(kind),"native reload finishes with the canonical magazine capacity");
            let left=User.player.FindPSprite(48),right=User.player.FindPSprite(49);
            Check(left!=null && left.CurState==CaelumAppearanceHands.Hand(User,6),"carbine left hand uses actual glove selection during reload");
            Check(right!=null && right.CurState==CaelumAppearanceHands.Hand(User,5),"carbine right hand uses actual glove selection during reload");
        }
        else
        {
            Check(kind==CaelumConstants.WEAPON_TYPE_STAFF,"native action fixture equips the actual staff");
            Check(User.WeaponChargeActive==(phase==1),"staff capture agrees with actual charge timer");
            if(phase==1)Check(User.WeaponChargeRemainingSeconds>0 && User.WeaponChargeRemainingSeconds<User.WeaponChargeTotalSeconds,"native charge clock advances without fixture timer writes");
            let view=User.player.FindPSprite(CaelumFirstPersonView.LAYER);
            Check(view!=null && view.CurState==CaelumAppearanceHands.Composed(User,kind,1,0,CaelumFirstPersonView.Pose(kind,1,0)),"composed staff hand uses actual glove selection during charge");
        }
        Console.Printf("CA861 ACTION tic=%d kind=%d phase=%d reload=%.6f charge=%.6f variant=%d",level.time,kind,phase,User.RangedReloadRemainingSeconds,User.WeaponChargeRemainingSeconds,CaelumAppearanceHands.Variant(User));
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=='ca861equipaction')EquipAction(e.Args[0]);
        if(e.Name=='ca861action')ObserveAction(e.Args[0]);
    }
}
