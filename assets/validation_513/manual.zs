// Author-only inspection fixture. It grants a Box and test money and can move
// the player between inspection points. It never moves or duplicates soldiers.
class CA133Manual : EventHandler
{
    bool Prepared,Triggered;
    int LastVisit;
    override void OnRegister(){LastVisit=-2;}
    override void WorldTick()
    {
        if(level.MapName!="MAP06" || level.time<70)return;
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(!Prepared)
        {
            user.CreationWizardOpen=false;user.GrantMagicBoxFromPalomo(false);
            let money=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD),user.Pos));
            money.Amount=100;money.AttachToOwner(user);user.OnNativeInventoryChanged();Prepared=true;
            Console.Printf("CA133 MANUAL_READY: diagnostic Box/100 gold; ca133_visit 0=home, 1..6=shops, 7=front; ca133_attack true starts the authored date");
        }
        int visit=CVar.GetCVar("ca133_visit").GetInt();
        if(visit!=LastVisit)
        {
            user.ClosePalomoMerchant();
            if(visit==0){user.SetOrigin(CaelumCityData.DoorOutside(159),false);user.Angle=180;}
            else if(visit>=1 && visit<=6)
            {let vendor=CaelumCityMerchant.Find(visit-1);user.SetOrigin(vendor.Pos+(48,0,0),false);user.Angle=180;}
            else if(visit==7){user.SetOrigin((-14464,-13000,0),false);user.Angle=270;}
            user.Pitch=0;LastVisit=visit;
        }
        if(!Triggered && CVar.GetCVar("ca133_attack").GetBool())
        {
            let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
            Triggered=true;Console.Printf("CA133 MANUAL_DATE_SET 1889-11-15 13:00 boundary");
        }
    }
}
