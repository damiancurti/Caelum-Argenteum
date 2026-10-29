// Galeria aislada: la introduccion de MAP01 no tapa la revision visual.
class CA410StudyGallery : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca410study_view')return;
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        user.GetPersistentCharacterState(true).ProfileCommitted=true;user.CurrentSleep=50;
        Actor body=Actor.Spawn(e.Args[0]==0?'CaelumPortableReadingDesk':'CaelumPortableReadingShelf',(0,0,0),NO_REPLACE);
        if(body==null){Console.Printf("CA410RF FAIL study view actor");return;}
        body.Angle=e.Args[0]==0?0:180;
        user.SetOrigin((120,-120,0),false);user.FindFloorCeiling();user.Angle=135;user.Pitch=e.Args[0]==0?15:0;user.Vel=(0,0,0);
        Console.Printf("CA410RF PASS native study view actor");
        if(TexMan.CheckForTexture(CaelumRestFurnitureData.Icon(6+e.Args[0]),TexMan.Type_Any).IsValid())Console.Printf("CA410RF PASS native study view texture");
        else Console.Printf("CA410RF FAIL native study view texture");
        Console.Printf("CA410RF RESULT isolated visual scene ready");
    }
}
