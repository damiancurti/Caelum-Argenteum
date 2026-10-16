// Compatible con el paquete anterior: guarda cuerpos reales, no reemplazos.
class CA254Session : EventHandler
{
    CaelumGiantRat Living,Corpse,Sleeping,Custom;
    int SavedHealth,SavedWaterDrops;
    bool Ready,Manual;
    int Zone;
    CaelumGiantRat Focus;
    vector3 SleepPosition;
    int WaterDrops()
    {
        int count=0;let it=ThinkerIterator.Create("CaelumWaterRation");Inventory item;
        while((item=Inventory(it.Next()))!=null)if(item.Owner==null)count+=item.Amount;
        return count;
    }
    int LivingRats()
    {
        int count=0;let it=ThinkerIterator.Create("CaelumGiantRat");Actor rat;
        while((rat=Actor(it.Next()))!=null)if(rat.health>0)count++;
        return count;
    }
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Advance(CaelumPlayer user)
    {
        Zone=(Zone+1)%4;Focus=null;
        for(int i=0;i<48;i++)
        {
            let rat=CaelumGiantRat(ActorIterator.Create(48000+Zone*48+i,"CaelumGiantRat").Next());
            if(rat!=null && rat.health>0){Focus=rat;break;}
        }
        if(Focus==null)return;
        vector3 position=Focus.Pos+(Cos(Focus.Angle)*96,Sin(Focus.Angle)*96,0);
        let sector=level.PointInSector(position.XY);position.Z=sector.floorplane.ZatPoint(position.XY);
        user.SetOrigin(position,false);user.Angle=user.AngleTo(Focus);user.Vel=(0,0,0);
        user.Pitch=VectorAngle(Focus.MeleeRange+user.Radius,user.player.viewheight-Focus.Height/2);
        CaelumNotifications.Notify(user,String.Format("#254 sector %d | F6 sector / F7 daño leve / F8 muerte de prueba",Zone+1));
        Console.Printf("CA254 MANUAL zone=%d rat=%d base=%.4f",Zone,Focus.tid,Focus.CombatBaseSpeed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c254_manual")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();user.bInvulnerable=true;
            Manual=true;Zone=-1;Advance(user);Console.Printf("CA254 DONE failures=0 manual prepared");
        }
        if(Manual && e.Name=="c254_next")Advance(user);
        if(Manual && (e.Name=="c254_hit" || e.Name=="c254_kill") && Focus!=null && Focus.health>0)
            Focus.DamageMobj(user,user,e.Name=="c254_hit" ? 30 : 1000000,'CaelumImpact',0,0);
        if(e.Name=="c254_seed")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();user.bInvulnerable=true;
            Living=CaelumGiantRat(ActorIterator.Create(48000,"CaelumGiantRat").Next());
            Corpse=CaelumGiantRat(ActorIterator.Create(48001,"CaelumGiantRat").Next());
            Sleeping=CaelumGiantRat(ActorIterator.Create(48002,"CaelumGiantRat").Next());
            Custom=CaelumGiantRat(ActorIterator.Create(48003,"CaelumGiantRat").Next());
            Custom.CombatBaseSpeed=7;
            SavedHealth=Living.health;Living.CurrentCombatAir=Living.MaximumCombatAir/4;
            Sleeping.SleepSavedTics=Sleeping.tics;Sleeping.ForcedSleepTics=100*TICRATE;SleepPosition=Sleeping.Pos;
            int before=WaterDrops();Corpse.DamageMobj(null,null,1000000,'CaelumImpact',DMG_FORCED,0);
            SavedWaterDrops=WaterDrops();Ready=true;
            bool ok=Corpse.health<=0 && Corpse.MazeDropReleased && SavedWaterDrops==before+1 && LivingRats()==191;
            Console.Printf("CA254 %s seed base=%.4f living=%d drops=%d",ok?"PASS":"FAIL",Living.CombatBaseSpeed,LivingRats(),SavedWaterDrops);
            Console.Printf("CA254 DONE failures=%d",ok?0:1);
        }
        if(e.Name=="c254_verify" || e.Name=="c254_verify_hub")
        {
            bool ok=Ready && Living!=null && Corpse!=null && Sleeping!=null
                && Living.CombatBaseSpeed==GetDefaultByType("CaelumGiantRat").Speed
                && Living.health==SavedHealth && LivingRats()==191 && Corpse.health<=0
                && Corpse.MazeDropReleased && WaterDrops()==SavedWaterDrops
                && Sleeping.ForcedSleepTics>0 && (Sleeping.Pos-SleepPosition).Length()<0.001
                && Custom!=null && Custom.CombatBaseSpeed==7;
            if(e.Name=="c254_verify")ok=ok && Living.CurrentCombatAir<Living.MaximumCombatAir;
            Console.Printf("CA254 %s saved bodies base=%.4f hp=%d air=%.4f/%.4f sleep=%d living=%d drops=%d",
                ok?"PASS":"FAIL",Living.CombatBaseSpeed,Living.health,Living.CurrentCombatAir,Living.MaximumCombatAir,Sleeping.ForcedSleepTics,LivingRats(),WaterDrops());
            Console.Printf("CA254 DONE failures=%d",ok?0:1);
        }
    }
}
