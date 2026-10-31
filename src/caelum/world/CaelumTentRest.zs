// #412: usar la carpa no exige atravesar su volumen de techo a pie.
// La entrada utiliza la postura agachada NATIVA; nunca cambia el modelo,
// FullHeight, radio, colisiones ajenas ni las reglas de seguridad del descanso.
class CaelumTentRest : Object play
{
    static bool CanRest(CaelumPlayer user,CaelumDeployedTent tent)
    {
        if(user==null || tent==null)return false;
        if(CaelumLockRules.SameTitle(tent.Title,CaelumLockRules.Character(user)))return true;
        // Las dos plazas aprobadas se comparten con la sesión cooperativa del
        // propietario presente. Compartir abrigo no concede título ni desmontaje.
        if(!multiplayer || deathmatch)return false;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let owner=CaelumPlayer(players[i].mo);
            if(owner!=null && CaelumLockRules.SameTitle(tent.Title,CaelumLockRules.Character(owner)))return true;
        }
        return false;
    }
    static void RestoreCrouch(CaelumPlayer user,double factor,int toggle)
    {
        if(user==null || user.player==null)return;
        for(int i=0;i<12 && Abs(user.player.crouchfactor-factor)>0.001;i++)
        {
            double before=user.player.crouchfactor;
            user.CrouchMove(before<factor?1:-1);
            if(user.player.crouchfactor==before)break;
        }
        user.player.crouching=toggle;
        // CrouchMove difiere Height hasta el siguiente Tick del motor.
        // Materializamos aquí esa misma altura para comprobar la entrada/salida.
        if(user.CanCrouch())user.Height=user.FullHeight*user.player.crouchfactor;
    }
    static bool Begin(CaelumPlayer user,CaelumDeployedTent tent,CaelumSleepingBag bag,int minutes)
    {
        if(user==null || tent==null || tent.bDestroyed || !tent.Ready || !tent.Reach(user)
            || !CaelumCampTask.Available(user) || bag==null || !bag.AvailableTo(user)
            || !CanRest(user,tent))return false;
        vector3 entry=user.Pos;double angle=user.Angle,factor=user.player.crouchfactor;
        int toggle=user.player.crouching;
        if(user.CanCrouch())
        {
            for(int i=0;i<12 && user.player.crouchfactor>0.5;i++)user.CrouchMove(-1);
            user.player.crouching=-1;
            user.Height=user.FullHeight*user.player.crouchfactor;
        }
        // Dos plazas derivadas de la anchura del saco, junto al eje del techo.
        // Compartir el reloj sigue sujeto a las reglas de descanso existentes.
        double offset=Max(CaelumAppearanceRegistry.BagHalfWidth(),user.Radius)+CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU;
        for(int slot=0;slot<2;slot++)
        {
            user.SetOrigin(tent.Pos+tent.LocalOffset((slot==0?offset:-offset,0,0)),false);
            user.Angle=tent.Angle+90;
            if(!tent.Covers(user) || !CaelumRestBag.HasRoom(user))continue;
            let mat=CaelumRestBag(Actor.Spawn('CaelumRestBag',user.Pos,NO_REPLACE));
            if(mat==null)continue;
            mat.Bag=bag;mat.Angle=user.Angle;mat.Tent=tent;mat.TentEntryRevision=1;
            mat.TentEntry=entry;mat.TentEntryMap=level.MapName;mat.EntryCrouch=factor;mat.EntryCrouchToggle=toggle;
            if(CaelumRestState.Begin(user,CaelumRestRules.MODE_SLEEP,minutes,mat))return true;
            mat.TentEntryRevision=0;mat.Destroy();break;
        }
        user.SetOrigin(entry,false);user.Angle=angle;RestoreCrouch(user,factor,toggle);
        CaelumNotifications.Notify(user,StringTable.Localize("CA_SLEEPING_BAG_SPACE",false));return false;
    }
    static bool ExitFits(CaelumRestBag mat,CaelumPlayer user,vector3 point)
    {
        let probe=Actor.Spawn('CaelumRestPlacementProbe',point,NO_REPLACE);if(probe==null)return false;
        probe.A_SetSize(user.Radius,user.FullHeight*mat.EntryCrouch,false);
        bool fits=probe.TestMobjLocation() && Abs(probe.FloorZ-point.Z)<=1 && probe.WaterLevel==0
            && user.CheckSight(probe,SF_IGNOREVISIBILITY);
        probe.Destroy();return fits;
    }
    static void Leave(CaelumRestBag mat,CaelumPlayer user)
    {
        if(mat.TentEntryRevision!=1)return;
        mat.TentEntryRevision=0;
        if(user==null || user.health<=0 || mat.TentEntryMap!=level.MapName)return;
        // Un desplazamiento externo no se revierte al finalizar la sesión.
        if(user.Distance2D(mat)<=4 && Abs(user.Pos.Z-mat.Pos.Z)<=4)
        {
            bool moved=false;
            if(ExitFits(mat,user,mat.TentEntry)){user.SetOrigin(mat.TentEntry,false);moved=true;}
            for(int i=0;i<8 && !moved;i++)
            {
                double direction=mat.Angle+i*45;
                double distance=mat.Radius+user.Radius+12;
                vector3 point=mat.Pos+(Cos(direction)*distance,Sin(direction)*distance,0);
                if(ExitFits(mat,user,point)){user.SetOrigin(point,false);moved=true;}
            }
        }
        RestoreCrouch(user,mat.EntryCrouch,mat.EntryCrouchToggle);
    }
}

class CaelumTentSession : Inventory
{
    bool Open;
    String OriginMap;
    CaelumDeployedTent Tent;
    static clearscope CaelumTentSession Find(CaelumPlayer user)
    {return user==null?null:CaelumTentSession(user.FindInventory('CaelumTentSession'));}
    static bool Show(CaelumPlayer user,CaelumDeployedTent tent)
    {
        if(!CaelumCampTask.Available(user) || tent==null || !tent.Ready || !tent.Reach(user))return false;
        if(!CaelumTentRest.CanRest(user,tent))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_PROPERTY_NO_RESIDENCE",false));return true;}
        let session=Find(user);if(session==null)session=CaelumTentSession(user.GiveInventoryType('CaelumTentSession'));
        if(session==null)return false;
        session.Tent=tent;session.OriginMap=level.MapName;session.Open=true;return true;
    }
    bool Valid(CaelumPlayer user)
    {return Tent!=null && !Tent.bDestroyed && Tent.Ready && OriginMap==level.MapName && Tent.Reach(user)
        && CaelumCampTask.Available(user) && CaelumTentRest.CanRest(user,Tent);}
    void Act(CaelumPlayer user,int choice)
    {
        if(!Open || !Valid(user)){Open=false;return;}
        if(choice==0){Open=false;return;}
        if(choice==2){if(CaelumCampTask.BeginPack(user,Tent))Open=false;return;}
        if(choice!=1)return;
        let bag=CaelumSleepingBag(user.FindInventory('CaelumSleepingBag'));
        if(bag==null || !bag.AvailableTo(user))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_SLEEPING_BAG_UNAVAILABLE",false));return;}
        Open=false;CaelumRestTrial.Open(user,null,bag,Tent);
    }
    override void Tick(){Super.Tick();if(Open && !Valid(CaelumPlayer(Owner)))Open=false;}
    override void PreTravelled(){Open=false;Tent=null;Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTentUI : Object ui
{
    static bool Key(int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)choice=1;
        else if(keyString~=="d")choice=2;
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || keyString~=="q")choice=0;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_camp_tent_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumTentSession.Find(user);if(session==null || !session.Open || view==null)return;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,StringTable.Localize("CA_CAMP_TENT",false));
        view.DrawParagraph(view.TextFont,Font.CR_WHITE,40,90,560,StringTable.Localize("CA_TENT_REST_TERMS",false));
    }
}
