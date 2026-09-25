// Issue #31: former MAP01 music becomes the soundtrack of the brief story
// presentation that opens a new game. MAP01 itself now uses the former MAP02
// track; the prologue awakening (fade and unknown voice) is that presentation,
// so no new lore text is invented here.
//
// The music starts once character creation is complete (the awakening is about
// to begin), not while menus or a loaded save are active. It returns to the
// map background once the opening conversation has closed or after a short
// safety timeout. Chapter-end intermissions are not wired in this class: the
// main campaign chapters are not implemented as runtime boundaries yet, and
// the existing prologue exit already owns its confirmed notice and transfer.
class CaelumStoryIntermission : StaticEventHandler
{
    bool OpeningPending;
    bool OpeningMusicStarted;
    bool OpeningConversationSeen;
    int OpeningTicks;

    override void WorldLoaded(WorldEvent e)
    {
        OpeningPending = false;
        OpeningMusicStarted = false;
        OpeningConversationSeen = false;
        OpeningTicks = 0;
        if (level.MapName == "MAP01" && !e.IsSaveGame)
        {
            OpeningPending = true;
        }
    }

    override void WorldTick()
    {
        if (!OpeningPending) { return; }
        if (consoleplayer < 0 || !playeringame[consoleplayer]) { return; }
        let user = CaelumPlayer(players[consoleplayer].mo);
        if (user == null || user.player == null) { return; }

        if (!OpeningMusicStarted)
        {
            if (!user.CharacterCreationComplete) { return; }
            S_ChangeMusic("CA_MUS01", 0, true);
            OpeningMusicStarted = true;
            OpeningTicks = 0;
        }

        OpeningTicks++;
        if (user.player.ConversationNPC != null)
        {
            OpeningConversationSeen = true;
        }

        bool presentationFinished = OpeningConversationSeen
            && user.player.ConversationNPC == null;
        bool timedOut = OpeningTicks >= 35 * 12;
        if (presentationFinished || timedOut)
        {
            S_ChangeMusic("CA_MUS02", 0, true);
            OpeningPending = false;
        }
    }
}
