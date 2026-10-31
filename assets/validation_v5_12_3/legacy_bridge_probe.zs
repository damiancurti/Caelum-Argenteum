class CA437LegacyBridgeProbe : StaticEventHandler
{
    int Start,Phase;
    CaelumPlayer Body;
    CaelumPersistentCharacterState Record;
    int Wallet;
    bool SawUse;
    override void WorldLoaded(WorldEvent e){Start=-1;}
    void Check(bool value,String label){Console.Printf("CA437BRIDGE %s %s",value?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Start<0){Start=level.time;return;}
        if(Phase==2 || level.time<Start+70)return;
        if(Phase==0)
        {
            Check(StaticEventHandler.Find('CaelumSessionLifecycleEvents')!=null,"new static bridge registered on native reload");
            Body=CaelumPlayer(players[1].mo);Record=Body.GetPersistentCharacterState(false);Wallet=Body.GetOwnedMoneyCopperValue();
            Check(Body.health<=0 && Body.player.playerstate==PST_DEAD,"old spirit checkpoint preserves dead campaign body");
            Phase=1;
        }
        if((Body.player.cmd.buttons&BT_USE)!=0)SawUse=true;
        if(level.time<Start+245)return;
        Check(SawUse,"native dead peer presses Use after reload");
        Check(players[1].mo==Body && Body.health<=0 && Body.player.playerstate==PST_DEAD,"old session cannot respawn from Use");
        Check(Body.GetPersistentCharacterState(false)==Record && Body.GetOwnedMoneyCopperValue()==Wallet,"old body record and possessions remain unchanged");
        Phase=2;Console.Printf("CA437BRIDGE RESULT peer=%d",consoleplayer);
    }
}
