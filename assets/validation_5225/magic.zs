// Native firing regression; this addon is never included in production.
class CA222Magic : StaticEventHandler
{
    int Failures;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA222 %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c222_test")return;
        let user=CaelumPlayer(players[e.Player].mo);
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
        user.CurrentLucidity=100;user.ElementalStatus=new("CaelumElementalStatus");
        user.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_STAFF;user.WeaponModel.Equipped=true;
        int staff=CaelumConstants.WEAPON_TYPE_STAFF,statue=CaelumConstants.WEAPON_TYPE_STATUETTE;
        for(int tier=1;tier<=3;tier++)
        {
            user.WeaponModel.Tier=tier;
            Check(user.WeaponModel.GetMinimumSpreadFor(staff)==2 && user.WeaponModel.GetMaximumSpreadFor(staff)==20,
                String.Format("T%d staff uses 2-20 degree base range",tier));
            Check(user.WeaponModel.GetMaximumSpreadFor(staff)==user.WeaponModel.GetMaximumSpreadFor(statue),
                String.Format("T%d staff shares statuette category",tier));
            for(int level=0;level<=100;level+=100)
            {
                user.Attributes.Insight=level;user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
                user.ReleasePendingStaffAttack(false,staff,CaelumConstants.ESSENCE_FIRE,false);
                double divisor=level==0?1:8;
                Check(Abs(user.LastStaffAccuracyPercent-100*divisor)<0.0001,
                    String.Format("T%d Insight%d retains Type-3 accuracy",tier,level));
                double yaw=Abs(user.LastStaffYawOffset),pitch=Abs(user.LastStaffPitchOffset);
                Check(yaw>=2/divisor && yaw<=20/divisor && pitch>=2/divisor && pitch<=20/divisor,
                    String.Format("T%d Insight%d actual launch uses reduced per-axis dispersion",tier,level));
                let it=ThinkerIterator.Create("CaelumPlayerMagicProjectile");Actor shot;int count=0;
                while((shot=Actor(it.Next()))!=null){if(shot.Target==user)count++;shot.Destroy();}
                Check(count==1,String.Format("T%d Insight%d casts one native staff projectile",tier,level));
            }
        }
        Check(user.WeaponModel.GetMaximumSpreadFor(CaelumConstants.WEAPON_TYPE_BOOK)==10,"book spread unchanged");
        Check(user.WeaponModel.GetMaximumSpreadFor(CaelumConstants.WEAPON_TYPE_BELL)==70,"bell spread unchanged");
        Console.Printf("CA222 DONE failures=%d",Failures);
    }
}
