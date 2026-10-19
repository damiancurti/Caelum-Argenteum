// Controles negativos de la única regla nueva: receptor autorizado antes de commit.
class CA310Guards : EventHandler
{
    int Spawns;
    override void WorldThingSpawned(WorldEvent e)
    {if(e.Thing is 'CaelumPlayerMagicProjectile')Spawns++;}

    void Dispatch(CaelumPlayer user,int route)
    {
        if(route==0)CaelumCombatDispatch.PerformEquippedWeaponPrimaryAttack(user);
        if(route==1)CaelumCombatDispatch.PerformEquippedWeaponSecondaryAttack(user);
        if(route==2)CaelumCombatDispatch.PerformLargeWeaponSweep(user,CaelumConstants.WEAPON_TYPE_HALBERD);
    }

    String Snapshot(CaelumPlayer user)
    {
        return String.Format("%d %d %d %.9f %.9f %.9f %.9f %.9f %d %d %d %d %d %d %d %d %d",
            user.AttackAnimationSerial,user.PhysicalAttackPending,user.StaffCastPending,
            user.CurrentAir,user.CurrentAnima,user.EquippedWeaponCooldownRemaining,
            user.StaffCastCooldownRemaining,user.AttackAnimationDurationTics,
            user.ActiveWeaponItemId,user.WeaponModel==null?-1:user.WeaponModel.Durability,
            user.CombatBlockModeActive,user.RangedAimSecondaryLatched,user.JavelinSecondaryLatched,
            user.WeaponChargeActive,user.WeaponChargedStateActive,user.RangedReloadActive,Spawns);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c310_guards")return;
        let audit=CA309Probe(EventHandler.Find("CA309Probe"));let user=audit.User;
        for(int route=0;route<3;route++)Dispatch(null,route);
        audit.Check(true,"all three null service requests return safely");
        for(int magic=0;magic<2;magic++)for(int route=0;route<3;route++)
        {
            user.PhysicalAttackPending=false;user.AttackAnimationDurationTics=0;
            user.EquippedWeaponCooldownRemaining=user.StaffCastCooldownRemaining=0;
            audit.Equip(magic?CaelumConstants.WEAPON_TYPE_STAFF:CaelumConstants.WEAPON_TYPE_HALBERD,1,0);
            if(magic)user.PerformDebugStaffAttack(false);else user.BeginPhysicalAttackCycle(false);
            audit.Check(magic?user.StaffCastPending:user.PhysicalAttackPending,"fixture owns a real pending attack");
            user.AttackAnimationStartTic=level.time-1000;user.PhysicalAttackReleaseTic=level.time-1;
            String before=Snapshot(user);
            int cheats=user.player.cheats;user.player.cheats=cheats|CF_PREDICTING;
            Dispatch(user,route);user.player.cheats=cheats;
            audit.Check(Snapshot(user)==before,"prediction cannot commit mature action or change state");
            let current=user.player.mo;user.player.mo=null;
            Dispatch(user,route);user.player.mo=current;
            audit.Check(Snapshot(user)==before,"stale pawn cannot commit mature action or change state");
            // Un actor ajeno conserva incluso referencias sintéticas sin mutarlas.
            let orphan=CaelumPlayer(Actor.Spawn("CaelumPlayer",(0,256,0),NO_REPLACE));
            orphan.WeaponModel=user.WeaponModel;
            String orphanBefore=Snapshot(orphan);Dispatch(orphan,route);
            audit.Check(Snapshot(orphan)==orphanBefore && Snapshot(user)==before,"detached actor leaves both owners untouched");
            orphan.Destroy();
            user.CancelPendingStaffCast(false);user.PhysicalAttackPending=false;user.AttackAnimationDurationTics=0;
            user.EquippedWeaponCooldownRemaining=user.StaffCastCooldownRemaining=0;
            Dispatch(user,magic?0:route);
            audit.Check(user.PhysicalAttackPending || user.StaffCastPending,"restored authority accepts the request");
        }
    }
}
