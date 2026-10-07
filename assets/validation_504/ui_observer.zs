// Observa cambios tras teclas nativas; no modifica partida ni selecciona cartas.
class CA120UIObserver : StaticEventHandler
{
    bool Started;
    int Selected, TCSerial, TRSerial;
    override void WorldTick()
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(0);if(user==null)return;
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        let tc=CaelumTrucazoMatch.Get(user);let tr=CaelumTrucoMatch.Get(user);
        int selected=int(CaelumTarotService.IsSelected(record,36));
        int tcs=tc==null?-1:tc.Serial;int trs=tr==null?-1:tr.Serial;
        if(!Started || selected!=Selected || tcs!=TCSerial || trs!=TRSerial)
        {
            Console.Printf("CA120 UI owner=%d canonical=%d selected36=%d tcSerial=%d trSerial=%d",user.PlayerNumber(),CaelumPlayerAuthority.OwnsRecord(user,record),selected,tcs,trs);
            if(tc!=null)Console.Printf("CA120 UI TC trick=%d played=%d/%d",tc.Trick,tc.Played[0],tc.Played[1]);
            if(tr!=null)Console.Printf("CA120 UI TR trick=%d played=%d/%d",tr.Trick,tr.Played[0],tr.Played[1]);
            Started=true;Selected=selected;TCSerial=tcs;TRSerial=trs;
        }
    }
}
