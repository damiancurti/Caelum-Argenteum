version "4.14.2"
// #454: el fixture habilita victoria/Caja; la fuente y captura son nativas.
class CA454ArcanaCity : CaelumPortSiege { override void Tick(){} }
class CA454ArcanaProbe : EventHandler
{
    int Failures,BeforeCount;
    CaelumM00FoolEssence Source;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA454 ARCANA %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        let record=user.GetPersistentCharacterState(true);
        if(e.Name=="ca454_arcana_prepare")
        {
            user.bInvulnerable=true;user.bNoTarget=true;
            record.MagicBoxOwned=true;user.MagicBoxOwned=true;
            CaelumMagicBox.EnsureOwned(user);CaelumTarotDeckRules.Grant(user,false);
            Check(CaelumTarotDeckRules.InOwnedBox(user),"physical deck in owned Box");
            Check(!record.HasTarotCard(CaelumConstants.TAROT_WANDS_KNIGHT),"no initial Knight");
            BeforeCount=record.CountTarotCards();CaelumPortSiege.Get().Victory=true;
            // Sin desplegar una fuerza ficticia: usar el estado narrativo ya
            // completado que la disponibilidad conserva al faltar el roster.
            record.PortSiegeNarrativeStarted=true;record.PortSiegeNarrativeComplete=true;
            record.DemoNarrativeDelivered=(1<<CaelumDemoNarrative.EVENT_COUNT)-1;record.DemoNarrativePending=0;
            user.PersistCharacterState();return;
        }
        if(e.Name=="ca454_arcana_seed")
        {
            Source=CaelumArcanaSources.Find(CaelumConstants.TAROT_WANDS_KNIGHT);
            Check(Source!=null,"native source appeared");return;
        }
        if(e.Name=="ca454_arcana_aim")
        {
            let source=CaelumArcanaSources.Find(CaelumConstants.TAROT_WANDS_KNIGHT);
            Check(source!=null && source==Source,"same source identity");if(source==null)return;
            Check(source.Pos==CaelumArcanaPlacement.PortSpot(),"source at current quay");
            Check(source.IsAvailable(user) && !record.HasTarotCard(source.CardId()),"victory offers capture without granting it");
            vector3 position=CaelumBarracasData.CurrentPortPoint((0,576,0));
            user.SetOrigin(position,false);user.FindFloorCeiling();
            user.SetOrigin((position.X,position.Y,user.FloorZ),false);
            user.Angle=CaelumBarracasData.CurrentPortAngle(90);user.Pitch=0;user.Vel=(0,0,0);user.ClearInterpolation();
            Check(user.TestMobjLocation() && CaelumMainM00FoolCapture.CanApproach(user,source),"native standing space and reach");return;
        }
        if(e.Name=="ca454_arcana_begin")
        {
            Check(user.player.ConversationNPC==Source && Source!=null && Source.bInConversation,"native Use opens source");
            Check(CaelumMainM00FoolCapture.BeginCapture(user),"capture response accepted");
            if(user.player.ConversationNPC!=null){user.player.ConversationNPC.bInConversation=false;user.player.ConversationNPC=null;}
            return;
        }
        if(e.Name=="ca454_arcana_leave")
        {user.SetOrigin(user.Pos+(256,0,0),false);return;}
        if(e.Name=="ca454_arcana_interrupted")
        {
            Check(Source!=null && Source.CaptureUser==null && Source.IsAvailable(user)
                && !record.HasTarotCard(Source.CardId()),"interrupted capture leaves same essence available");return;
        }
        if(e.Name=="ca454_arcana_result")
        {
            Check(Source!=null && record.HasTarotCard(Source.CardId()) && record.CountTarotCards()==BeforeCount+1,"exactly one acquired essence");
            Check(Source!=null && !Source.IsAvailable(user) && !CaelumMainM00FoolCapture.CommitCapture(user,Source),"repeat capture rejected");
            Console.Printf("CA454 ARCANA COMPLETE failures=%d",Failures);
        }
    }
}
