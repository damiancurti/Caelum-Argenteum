// Comprobaciones autoritativas por personaje: adquisición no equivale a activación.
class CA513PassiveReview : StaticEventHandler
{
    int Checked;
    void Check(bool result,String label)
    {Console.Printf("CA513REVIEW %s %s",result?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<160)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && !(Checked&(1<<i)))
        {
            let p=CaelumPlayer(players[i].mo);if(p==null)continue;
            let r=p.GetPersistentCharacterState(false);if(r==null)continue;
            Checked|=1<<i;
            Check(CaelumTarotService.SelectedCount(r)==0,"empty sequence");
            bool all=true;for(int card=0;card<22;card++)all=all && CaelumTarotLoadout.Passive(r,card);
            Check(all,"22 acquired passives unequipped");
            Check(CaelumTarotLoadout.Capacity(r)==7 && CaelumTarotLoadout.BoxBonus(r)==20,"owned capacities");
            Check(CaelumTemperance.Duration(p,10)==5,"unequipped Temperance halves duration");
            Check(!CaelumTemperance.SelectedForSequence(r) && !CaelumTarotLoadout.InSequence(r,15),"owned active gates remain closed");
            bool unique=true;
            for(int card=0;card<22;card++)for(int other=0;other<card;other++)
                unique=unique && CaelumTarotDetails.Active(card,true)!=CaelumTarotDetails.Active(other,true)
                    && CaelumTarotDetails.Active(card,true).IndexOf("CA_TAROT_MAJOR")==-1;
            Check(unique,"22 localized distinct active descriptions");
            for(int card=1;card<=7;card++)CaelumTarotService.Select(p,card);
            Check(CaelumTarotService.SelectedCount(r)==7,"seven cards without capacity cards equipped");
            Check(!CaelumTarotService.Select(p,8),"eighth card rejected");
            for(int card=1;card<=7;card++)CaelumTarotService.Select(p,card);
            Check(CaelumTarotService.Select(p,9) && CaelumTarotService.Select(p,9)
                && CaelumTarotLoadout.Capacity(r)==7,"removing Hermit retains capacity");
            CaelumTarotService.Select(p,21);
            Check(CaelumTemperance.SelectedForSequence(r) && CaelumTarotLoadout.InSequence(r,15),"World fanout includes active gates");
            CaelumTarotService.Select(p,21);
            Check(CaelumUnifiedTarot.Activate(p) && r.UnifiedTarotTics>0,"unified essence without World equipped");
            Check(CaelumTarotObjectMovement.Permitted(p),"unequipped Strength grants lifting");
            Check(CaelumTarotFalseWall.Revealed(p),"unequipped Priestess reveals walls");
            Console.Printf("CA513REVIEW COMPLETE player=%d",i);
        }
    }
}
