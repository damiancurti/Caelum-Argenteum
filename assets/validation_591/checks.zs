// Pruebas nativas de #420; los actores y cambios de saldo son sólo del fixture.
class CA420Checks : EventHandler
{
    int Checks, Failures;
    CaelumAnchoredResident Representative, Unconfirmed;
    bool AttackSpent;

    override void WorldTick()
    {
        if (Representative != null && Representative.FactionHostilityActive
            && (Representative.CurrentCombatAnima < Representative.MaximumCombatAnima
                || Representative.CurrentCombatAir < Representative.MaximumCombatAir)) AttackSpent = true;
    }

    void Check(bool ok, String label)
    { Checks++; if (!ok) Failures++; Console.Printf("CA420 %s %s", ok ? "PASS" : "FAIL", label); }

    void Seed(CaelumPlayer user)
    {
        user.player.cheats |= CF_GODMODE;
        let record = user.GetPersistentCharacterState(true);
        record.InitializeNewFactionState();
        record.SetFactionMembership(0, true); record.SetFactionMembership(1, true);
        record.ChangeFactionReputation(0, 499); record.ChangeFactionReputation(1, -49);
        record.MarkPrisonerRewardClaimed(0);
        user.PersistCharacterState();
        Check(record.FactionMember[0] && record.FactionMember[1], "legacy multiple memberships seeded");
        Check(record.FactionReputation[0] == 499 && record.FactionReputation[1] == -49, "legacy reputations seeded");
    }

    void Migration(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        Check(record.FactionMember[0] && record.FactionMember[1], "legacy concealed memberships preserved");
        Check(record.FactionReputation[0] == 499 && record.FactionReputation[1] == -49, "migration does not alter reputation");
        CaelumFactionConsequences.Ensure(record); CaelumFactionConsequences.Ensure(record);
        Check(record.FactionMembershipEpoch[0] == 1 && record.FactionMembershipEpoch[1] == 1, "membership epochs migrate once");
        Check(record.FactionMembershipKnownEpoch[1] == 0 && record.FactionAidEvents.Size() == 0, "migration invents neither reports nor aid");
        Check(record.IsPrisonerRewardClaimed(0), "existing rescue reward remains claimed");
    }

    void Rules(CaelumPlayer user)
    {
        Check(CaelumFactionData.Rank(-1000) == 0 && CaelumFactionData.Rank(-500) == 0, "hated boundaries");
        Check(CaelumFactionData.Rank(-499) == 1 && CaelumFactionData.Rank(-250) == 1, "hostile boundaries");
        Check(CaelumFactionData.Rank(-249) == 2 && CaelumFactionData.Rank(-50) == 2, "distrusted boundaries");
        Check(CaelumFactionData.Rank(-49) == 3 && CaelumFactionData.Rank(49) == 3, "neutral boundaries");
        Check(CaelumFactionData.Rank(50) == 4 && CaelumFactionData.Rank(249) == 4, "friendly boundaries");
        Check(CaelumFactionData.Rank(250) == 5 && CaelumFactionData.Rank(499) == 5, "respected boundaries");
        Check(CaelumFactionData.Rank(500) == 6 && CaelumFactionData.Rank(1000) == 6, "revered boundaries");
        int hostile = 0, friendly = 0, neutral = 0;
        for (int i = 0; i < 6; i++) for (int j = 0; j < 6; j++)
        {
            int relation = CaelumFactionRules.GetRelation(i, j);
            if (relation == CaelumConstants.FACTION_RELATION_HOSTILE) hostile++;
            else if (relation == CaelumConstants.FACTION_RELATION_FRIENDLY) friendly++;
            else neutral++;
            Check(relation == CaelumFactionRules.GetRelation(j, i), String.Format("symmetric relation %d/%d", i, j));
        }
        Check(hostile == 4 && friendly == 6 && neutral == 26, "only two mutual enemy pairs; six own identities");
        Check(CaelumFactionRules.GetRelation(-1, 0) == CaelumConstants.FACTION_RELATION_NEUTRAL, "unknown affiliation remains neutral");
        Check(CaelumFactionRules.TradePrice(100, 3, false, -250) == 0, "hostility has no valid purchase quote");
        Check(CaelumFactionRules.TradePrice(100, 3, false, -50) == CaelumEconomyRules.GetPriceChargedByMerchant(150, 3), "distrusted purchase uses approved premium");
        Check(CaelumFactionRules.TradePrice(100, 3, false, 500) == CaelumEconomyRules.GetPriceChargedByMerchant(66, 3), "revered purchase uses approved discount");
        Check(CaelumFactionRules.TradePrice(0.7, 13, true, 500) == CaelumEconomyRules.GetPricePaidByMerchant(0.805, 13), "fractional sale rounds at whole lot boundary");
        Check(CaelumFactionData.ConfirmedPrisonerFaction(3) == -1, "Leandro has no confirmed Cult identity");

        let record = user.GetPersistentCharacterState(false);
        record.InitializeNewFactionState();
        Check(CaelumFactionConsequences.GrantAid(record, "test_aid", 0, 10), "assistance committed");
        Check(record.FactionReputation[0] == 10 && record.FactionReputation[1] == 0, "unaware enemy receives no penalty");
        Check(!CaelumFactionConsequences.GrantAid(record, "test_aid", 0, 10), "assistance receipt prevents duplicate gain");
        Check(CaelumFactionConsequences.ReportAid(record, "test_aid", 2) && record.FactionReputation[2] == 0, "neutral informed faction receives no penalty");
        Check(CaelumFactionConsequences.ReportAid(record, "test_aid", 1) && record.FactionReputation[1] == -10, "informed enemy loses exactly actual gain");
        Check(!CaelumFactionConsequences.ReportAid(record, "test_aid", 1) && record.FactionReputation[1] == -10, "repeat report cannot penalize again");
        record.ChangeFactionReputation(0, 989);
        CaelumFactionConsequences.GrantAid(record, "capped_aid", 0, 10);
        CaelumFactionConsequences.ReportAid(record, "capped_aid", 1);
        Check(record.FactionReputation[0] == 1000 && record.FactionReputation[1] == -11, "saturated gain reports only the one point actually granted");
        Check(!CaelumFactionConsequences.ReportAid(record, "missing", 1), "unknown event cannot invent assistance");
        record.SetFactionMembership(0, true); record.SetFactionMembership(1, true);
        Check(record.FactionMember[0] && record.FactionMember[1], "concealed simultaneous membership is allowed");
        Check(CaelumFactionConsequences.ReportMembership(record, 0, 1, 1), "explicit disclosure committed");
        Check(!record.FactionMember[0] && record.FactionMember[1] && record.FactionReputation[0] == 900, "only informed faction expels and subtracts 100");
        Check(!CaelumFactionConsequences.ReportMembership(record, 0, 1, 1) && record.FactionReputation[0] == 900, "same revelation cannot repeat");
        Check(record.FactionMembershipKnownEpoch[2 * 6 + 1] == 0, "unrelated faction does not learn disclosure");
        user.PersistCharacterState();
    }

    void Preserved(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        Check(record.FactionReputation[0] == 900 && record.FactionReputation[1] == -11, "saved consequences retain exact balances");
        Check(!record.FactionMember[0] && record.FactionMember[1], "saved expulsion retains other membership");
        Check(!CaelumFactionConsequences.ReportMembership(record, 0, 1, 1), "load or hub travel cannot repeat disclosure");
        Check(!CaelumFactionConsequences.ReportAid(record, "test_aid", 1), "load or hub travel cannot repeat assistance report");
        Check(record.FactionAidEvents.Size() == 2 && record.FactionMembershipKnownEpoch[13] == 0, "saved receipts and private knowledge preserved");
    }

    void Actors(CaelumPlayer user, int step)
    {
        let record = user.GetPersistentCharacterState(false);
        if (step == 0)
        {
            record.FactionReputation[0] = -250; record.FactionReputation[4] = -1000;
            Representative = CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario", (128, 0, 0)));
            Unconfirmed = CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerTarot", (-128, 0, 0)));
        }
        if (step == 1)
        {
            Check(Representative != null && Representative.bInvulnerable && Representative.FactionTarget == null, "captive keeps protection despite hostile reputation");
            Check(!Representative.CanBeFactionTarget(user), "captive cannot select faction enemy");
            Representative.EscortPrisonerPort = true; Unconfirmed.EscortPrisonerPort = true;
        }
        if (step == 2)
        {
            Check(Representative.FactionTarget == user && Representative.Target == user, "arrived representative selects visible hostile player");
            Check(!Representative.bInvulnerable && !Representative.bFriendly && Representative.FactionHostilityActive, "hostile representative fights with native vulnerable body");
            Check(AttackSpent, "hostility executes native attacks and spends their resources");
            Check(!CaelumPrisonerRescue.OpenDialogue(user, Representative), "hostile player cannot open reward dialogue");
            Check(Unconfirmed.FactionTarget == null && Unconfirmed.bInvulnerable, "unconfirmed Leandro stays protected");
            record.FactionReputation[0] = -249;
        }
        if (step == 3)
        {
            Check(Representative.FactionTarget == null && Representative.Target == null && Representative.bInvulnerable && Representative.bFriendly,
                "crossing out of hostile rank releases only faction aggression");
            Representative.Destroy(); Unconfirmed.Destroy();
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user = CaelumPlayer(players[e.Player].mo); if (user == null) return;
        if (e.Name == "ca420_seed") Seed(user);
        if (e.Name == "ca420_migrate") Migration(user);
        if (e.Name == "ca420_rules") Rules(user);
        if (e.Name == "ca420_preserved") Preserved(user);
        if (e.Name == "ca420_spawn") Actors(user, 0);
        if (e.Name == "ca420_captive") Actors(user, 1);
        if (e.Name == "ca420_hostile") Actors(user, 2);
        if (e.Name == "ca420_peace") Actors(user, 3);
        if (e.Name == "ca420_done") Console.Printf("CA420 RESULT checks=%d failures=%d", Checks, Failures);
    }
}
