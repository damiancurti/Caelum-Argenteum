class CA440HangedLedger : Inventory
{
    int Phase,OriginalRace,Choice;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440HangedProp : CaelumMovableProp
{
    Default {Health 100;Radius 16;Height 56;Mass 10;}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440H %s %s",ok?"PASS":"FAIL",label);}
    void Clear(CaelumPlayer user)
    {
        CaelumRacialAbilityRules.Deactivate(user);
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotCooldownTics=record.TarotEffectTics=0;
        user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
    }
    void Key(CaelumPlayer user){user.CombatTarotInputReserved=false;user.ReserveTarotInput();}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440HangedLedger(user.FindInventory('CA440HangedLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            ledger=CA440HangedLedger(user.GiveInventoryType('CA440HangedLedger'));
            Clear(user);Clear(other);ledger.OriginalRace=user.CharacterProfile.Race;
            ledger.Choice=ledger.OriginalRace==CaelumConstants.RACE_BEAST_MAN?CaelumConstants.RACE_HUMAN:CaelumConstants.RACE_BEAST_MAN;
            record.TarotRaceRevision=0;record.TarotHangedRace=0;
            CaelumTarotService.EnsureRevision(record);
            Check(record.TarotHangedRace==-1 && record.TarotHangedActiveRace==-1,"legacy save does not invent a race choice");
            CaelumTarotSequence.ApplyCard(user,record,12,2100);
            Check(!record.TarotActive[12],"World handler omits Hanged Man before any choice");
            CaelumTarotService.Select(user,12);
            Check(record.TarotRaceMenuOpen && !record.TarotSelected[12],"first equip opens choice without consuming a slot");
            Check(!CaelumHangedMan.Choose(user,ledger.OriginalRace) && !record.TarotSelected[12],"own race cannot be selected");
            CaelumTarotService.Select(user,12);
            Check(CaelumHangedMan.Choose(user,-1) && record.TarotHangedRace==-1,"cancelling choice preserves unequipped state");
            CaelumTarotService.Select(user,12);ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && record.TarotSelected[12])
        {
            Check(record.TarotHangedRace==ledger.Choice && !record.TarotRaceMenuOpen,"native network choice equips the card");
            Check(user.CharacterProfile.Race==ledger.OriginalRace,"choosing a borrowed ability preserves real race");
            CaelumTarotService.Select(user,12);
            Check(record.TarotHangedRace==ledger.Choice,"unequipping retains chosen race");
            user.SetOrigin((-256,0,0),false);other.SetOrigin((-600,-600,0),false);
            let prop=CA440HangedProp(Actor.Spawn('CA440HangedProp',(0,0,0),NO_REPLACE));prop.args[0]=1;
            user.Angle=0;user.Pitch=0;
            for(int race=0;race<4;race++)
            {
                Clear(user);user.CharacterProfile.Race=(race+1)%4;user.ApplyCharacterProfile();
                user.CurrentAnima=user.DerivedStats.MaximumAnima;user.PainImmobilizationRemaining=0;
                record.TarotHangedRace=race;
                CaelumTarotService.Select(user,12,race);
                double anima=user.CurrentAnima;
                Check(CaelumTarotService.Activate(user),String.Format("race %d opens paid window",race));
                Check(Abs(user.CurrentAnima-(anima-1000))<0.01 && user.RacialAbility==null,String.Format("race %d sequence charges once before toggle",race));
                int bodyRace=user.CharacterProfile.Race;
                Key(user);let effect=user.RacialAbility;
                Check(effect!=null && effect.Race==race && effect.TarotBorrowed,String.Format("race %d uses existing native ability",race));
                if(effect!=null)
                {
                    double cost=CaelumRacialAbilityRules.TicCost(user,effect);anima=user.CurrentAnima;
                    CaelumRacialAbilityRules.Advance(user,false);
                    Check(user.RacialAbilityActive && Abs(user.CurrentAnima-(anima-cost))<0.01,String.Format("race %d retains native per-tic cost",race));
                    if(race==0)Check(CaelumHuntersInstinct.Stealth(user,10)==30,"borrowed hunter instinct changes real stealth");
                    if(race==1)
                    {
                        double air=user.CurrentAir;anima=user.CurrentAnima;
                        CaelumAirPayment.Spend(user,10);
                        Check(user.CurrentAir==air && user.CurrentAnima<anima,"borrowed breathing pays effort with Anima");
                    }
                    if(race==2)Check(CaelumSocialization.CurrentMultiplier(user)==2,"borrowed socialization uses current dialogue multiplier");
                    if(race==3)Check(CaelumTelekinesisRules.Held(prop),"borrowed telekinesis binds the real targeted prop");
                }
                Key(user);
                Check(user.RacialAbility==null && !CaelumTelekinesisRules.Held(prop),String.Format("race %d second Tarot press releases effect",race));
                Check(user.CharacterProfile.Race==bodyRace && other.RacialAbility==null,String.Format("race %d does not change bodies or another player",race));
            }
            Clear(user);user.CharacterProfile.Race=ledger.OriginalRace;user.ApplyCharacterProfile();
            user.CurrentAnima=user.DerivedStats.MaximumAnima;record.TarotHangedRace=ledger.Choice;
            CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,12,ledger.Choice);
            CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,9);
            Check(CaelumTarotService.Activate(user) && record.TarotRemaining[12]==4200,"first Hanged Man receives later Hermit duration");
            Key(user);CaelumRacialAbilityRules.Advance(user,false);
            CaelumTarotService.Advance(user,4200);
            Check(user.RacialAbility==null && !record.TarotActive[12],"expiry stops only the borrowed ability");
            Clear(user);record.TarotHangedRace=ledger.Choice;
            CaelumTarotService.Select(user,21);double paid=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user) && record.TarotHangedActiveRace==ledger.Choice
                && record.TarotActive[12] && Abs(user.CurrentAnima-(paid-1000))<0.01,"World reuses saved choice without equipping Hanged Man");
            Key(user);CaelumRacialAbilityRules.Advance(user,false);
            user.CurrentAnima=0;CaelumRacialAbilityRules.Advance(user,false);
            Check(user.RacialAbility==null,"Anima exhaustion stops borrowed ability");
            user.CurrentAnima=user.DerivedStats.MaximumAnima;Key(user);CaelumRacialAbilityRules.Advance(user,false);
            Check(user.RacialAbilityActive && user.RacialAbility.TarotBorrowed,"paid borrowed effect is ready for common save");
            ledger.Phase=2;user.PersistCharacterState();Console.Printf("CA440H RESULT capture");return;
        }
        if(ledger.Phase==2 && Reloaded)
        {
            Check(record.TarotHangedRace==ledger.Choice && record.TarotHangedActiveRace==ledger.Choice,"recovery keeps chosen and active race separately");
            Check(user.RacialAbility!=null && user.RacialAbility.TarotBorrowed && user.RacialAbilityActive,"recovery retains native borrowed effect and payment lifecycle");
            Check(user.CharacterProfile.Race==ledger.OriginalRace && !record.TarotSelected[12],"recovery preserves body and World's unequipped activation");
            int remaining=record.TarotRemaining[12];
            CaelumTarotService.Advance(user,remaining);
            Check(user.RacialAbility==null && record.TarotHangedRace==ledger.Choice,"recovered expiry releases effect without losing choice");
            ledger.Phase=3;Console.Printf("CA440H RESULT reload");
        }
    }
}
class CA440HangedInput : StaticEventHandler
{
    ui bool Sent;
    override void UiTick()
    {
        if(consoleplayer!=0 || gamestate!=GS_LEVEL || level.time<400 || Sent)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440HangedLedger(user.FindInventory('CA440HangedLedger')):null;
        if(ledger==null || ledger.Phase!=1 || user.SessionIdentityPending)return;
        Sent=true;EventHandler.SendNetworkEvent("ca_tarot_race",ledger.Choice);
    }
}
