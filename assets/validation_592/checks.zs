class CA419Checks : EventHandler
{
    int Checks, Failures, SavedRoll, SavedChance;
    CaelumAnchoredResident Representative;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name != "ca419_enter") return;
        let menu = CaelumPortConversationMenu(Menu.GetCurrentMenu());
        if (menu == null) { Console.Printf("CA419 FAIL native port menu is absent"); return; }
        menu.MenuEvent(Menu.MKEY_Enter, false);
    }
    void Check(bool ok, String label)
    { Checks++; if (!ok) Failures++; Console.Printf("CA419 %s %s", ok ? "PASS" : "FAIL", label); }

    void Seed(CaelumPlayer user)
    {
        user.player.cheats |= CF_GODMODE;
        let record = user.GetPersistentCharacterState(true);
        record.InitializeNewFactionState();
        record.SetFactionMembership(0, true); record.SetFactionMembership(1, true);
        user.Attributes.Empathy = 0;
        Representative = CaelumAnchoredResident(Actor.Spawn("CaelumPrisonerUnitario", (96, 0, 0)));
        Check(Representative != null, "native representative spawned");
    }

    void Open(CaelumPlayer user)
    {
        Representative.EscortPrisonerPort = true;
        Check(CaelumPrisonerRescue.OpenDialogue(user, Representative), "native prisoner conversation opens");
        Check(user.player.ConversationNPC == Representative && user.player.ConversationPC == user, "native conversation owns both participants");
    }

    void Close(CaelumPlayer user)
    {
        if (user.player.ConversationNPC != null) user.player.ConversationNPC.bInConversation = false;
        user.player.ConversationNPC = null; user.player.ConversationPC = null;
    }

    void Rules(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        Check(record.PortSocialRevision == 0 || record.PortSocialRevision == 1, "old record accepts additive social migration");
        CaelumPortSocial.Ensure(record); CaelumPortSocial.Ensure(record);
        Check(record.PortSocialRevision == 1 && record.FactionWitnesses.Size() == 0, "migration invents no witness knowledge");
        Check(CaelumPortSocial.Speaker(user) == Representative, "saved native speaker remains a valid action context");
        Check(CaelumPortSocial.Chance(user, 0) == 83, "neutral empathy uses existing ability curve");
        record.FactionReputation[0] = -50;
        Check(CaelumPortSocial.Chance(user, 0) == 63, "distrusted social factor applies");
        Check(CaelumMainM00SocialDialogue.GetChance(user, CaelumConstants.MAIN_M00_RESIDENT_RULO) == 83, "tutorial probability ignores the new faction modifier");
        record.FactionReputation[0] = 50;
        Check(CaelumPortSocial.Chance(user, 0) == 92, "friendly social factor applies");
        record.FactionReputation[0] = 250;
        Check(CaelumPortSocial.Chance(user, 0) == 100, "respected chance clamps at 100");
        record.FactionReputation[0] = 0;
        Check(CaelumPortSocial.Read(user), "first emotional reading succeeds as an action");
        SavedRoll = record.PortEmotionRoll[0]; SavedChance = record.PortEmotionChance[0];
        let proof = CA419Proof(Actor.Spawn("CA419Proof"));
        proof.Roll = SavedRoll; proof.Chance = SavedChance; proof.AttachToOwner(user);
        Check(SavedChance == 83 && SavedRoll >= 1 && SavedRoll <= 100 && record.PortEmotionResult[0] != 0, "first roll and chance are recorded");
        user.Attributes.Empathy = 100;
        Check(CaelumPortSocial.Read(user) && record.PortEmotionChance[0] == SavedChance && record.PortEmotionRoll[0] == SavedRoll, "better attributes cannot reroll the same situation");
        record.MarkPrisonerRewardClaimed(0);
        Check(CaelumPortSocial.Stage(record, 0) == 1 && CaelumPortSocial.Read(user) && record.PortEmotionChance[1] == 100, "preparation stage grants one distinct attempt");
        record.PortSiegeNarrativeStarted = true;
        Check(CaelumPortSocial.Stage(record, 0) == 2 && CaelumPortSocial.Read(user), "actual siege start changes the situation");
        record.PortSiegeNarrativeComplete = true;
        Check(CaelumPortSocial.Stage(record, 0) == 3 && CaelumPortSocial.Read(user), "actual victory changes the situation");
        Check(record.PortEmotionResult[1] == 2 && record.PortEmotionResult[2] == 2 && record.PortEmotionResult[3] == 2, "automatic success records each approved later stage");
        Check(record.PortEmotionResult[4] == 0, "one NPC's reading does not reveal another NPC");
        let other = CaelumPersistentCharacterState(Actor.Spawn("CaelumPersistentCharacterState"));
        CaelumPortSocial.Ensure(other);
        Check(other.PortEmotionResult[0] == 0 && other.FactionWitnesses.Size() == 0, "another character record has no private readings or declarations");
        other.Destroy();
        Check(!CaelumPortSocial.Declare(user, 4), "cannot confess a membership the character does not have");
        Check(CaelumPortSocial.Declare(user, 1), "true membership can be declared privately");
        Check(record.FactionMember[0] && record.FactionReputation[0] == 0 && record.FactionMembershipKnownEpoch[1] == 0, "declaration is not an institutional report");
        Check(CaelumPortSocial.Witness(record, 0).MembershipEpoch[1] == 1 && CaelumPortSocial.Witness(record, 1) == null, "only the addressed witness learns membership");
        CaelumFactionConsequences.GrantAid(record, "social_aid", 1, 10);
        Check(CaelumPortSocial.DeclareAid(user) && record.FactionReputation[0] == 0, "private aid declaration leaves unaware faction unchanged");
        Check(CaelumPortSocial.Report(user), "explicit report uses actual witness knowledge");
        Check(!record.FactionMember[0] && record.FactionMember[1] && record.FactionReputation[0] == -110, "report applies expulsion and actual enemy aid once");
        Check(CaelumPortSocial.Report(user) && record.FactionReputation[0] == -110, "report replay cannot repeat either sanction");
        Check(record.FactionMembershipKnownEpoch[13] == 0 && CaelumPortSocial.Witness(record, 1) == null, "other witnesses and factions stay unaware");
        user.PersistCharacterState();
    }

    void Preserved(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        let proof = CA419Proof(user.FindInventory("CA419Proof"));
        Check(proof != null && record.PortEmotionRoll[0] == proof.Roll && record.PortEmotionChance[0] == proof.Chance && record.PortEmotionResult[0] != 0, "original private roll survives save or travel");
        Check(record.PortEmotionResult[1] == 2 && record.PortEmotionResult[2] == 2 && record.PortEmotionResult[3] == 2, "stage-specific impressions remain recorded");
        Check(CaelumPortSocial.Witness(record, 0).MembershipEpoch[1] == 1 && CaelumPortSocial.Witness(record, 1) == null, "saved witness knowledge remains private");
        Check(record.FactionReputation[0] == -110 && !record.FactionMember[0] && record.FactionMember[1], "saved report consequences retain exact state");
    }

    void Interrupted(CaelumPlayer user, int step)
    {
        let record = user.GetPersistentCharacterState(false);
        if (step == 0)
        {
            Close(user); Open(user); record.FactionReputation[0] = -250;
        }
        else
        {
            Console.Printf("CA419 interrupted speaker=%s", user.player.ConversationNPC == null ? "none" : String.Format("%s", user.player.ConversationNPC.GetClassName()));
            Check(user.player.ConversationNPC != Representative && !Representative.bInConversation, "hostility interrupts the representative conversation");
            Check(!CaelumPortSocial.Read(user) && !CaelumPortSocial.Declare(user, 1) && !CaelumPortSocial.Report(user), "interrupted actions cannot mutate social state");
            Check(record.PortEmotionRoll[0] == SavedRoll, "interruption preserves previous roll");
            record.FactionReputation[0] = -110;
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user = CaelumPlayer(players[e.Player].mo); if (user == null) return;
        if (e.Name == "ca419_seed") Seed(user);
        if (e.Name == "ca419_open") Open(user);
        if (e.Name == "ca419_close") Close(user);
        if (e.Name == "ca419_rules") Rules(user);
        if (e.Name == "ca419_ui_read")
        {
            let record = user.GetPersistentCharacterState(false);
            Check(record.PortEmotionResult[0] != 0 && record.PortEmotionChance[0] == 83,
                "native menu replies invoke the authoritative emotion action");
        }
        if (e.Name == "ca419_preserved") Preserved(user);
        if (e.Name == "ca419_hostile") Interrupted(user, 0);
        if (e.Name == "ca419_interrupted") Interrupted(user, 1);
        if (e.Name == "ca419_done") Console.Printf("CA419 RESULT checks=%d failures=%d", Checks, Failures);
    }
}

class CA419Proof : Inventory
{
    int Roll, Chance;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}
