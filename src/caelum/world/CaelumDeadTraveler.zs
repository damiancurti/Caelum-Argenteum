// Conserva el mismo cuerpo e inventario al cruzar mapas. GZDoom intenta
// resucitar al muerto antes de PreTravelled; por eso la guarda rodea ChangeLevel.
class CaelumDeadTraveler : Inventory
{
    int Revision, BodyHealth;
    bool Stored, InTransit;
    bool Hidden, SolidBody, ShootableBody, NoBlock, NoSector, NoInteraction;
    String BodyMap;
    vector3 BodyPosition;
    State BodyState;
    int BodyTics;
    double BodyHeight, BodyAngle;

    static clearscope CaelumDeadTraveler View(CaelumPlayer user)
    {return user!=null?CaelumDeadTraveler(user.FindInventory('CaelumDeadTraveler')):null;}

    static void Prepare(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health>0)return;
        let savedBody=View(user);
        if(savedBody==null)savedBody=CaelumDeadTraveler(user.GiveInventoryType('CaelumDeadTraveler'));
        if(savedBody==null)return;
        if(!savedBody.Stored)
        {
            savedBody.Revision=1;savedBody.Stored=true;savedBody.BodyMap=level.MapName;
            savedBody.BodyPosition=user.Pos;savedBody.BodyAngle=user.Angle;
            savedBody.BodyHealth=user.health;savedBody.BodyHeight=user.Height;
            savedBody.BodyState=user.CurState;savedBody.BodyTics=user.tics;
            savedBody.Hidden=user.bInvisible;savedBody.SolidBody=user.bSolid;
            savedBody.ShootableBody=user.bShootable;savedBody.NoBlock=user.bNOBLOCKMAP;
            savedBody.NoSector=user.bNOSECTOR;savedBody.NoInteraction=user.bNoInteraction;
        }
        // Sólo el portador nativo necesita salud positiva. El actor y su
        // registro siguen muertos: no se llama a Resurrect ni se crea otro.
        savedBody.InTransit=true;user.player.health=1;user.player.playerstate=PST_LIVE;
    }

    static void Arrive(CaelumPlayer user)
    {
        let savedBody=View(user);if(savedBody==null || !savedBody.InTransit)return;
        savedBody.InTransit=false;user.health=user.player.health=savedBody.BodyHealth;
        user.player.playerstate=PST_DEAD;user.Vel=(0,0,0);
        user.bCorpse=true;user.SetState(savedBody.BodyState);user.tics=savedBody.BodyTics;
        user.A_SetSize(user.Radius,savedBody.BodyHeight);
        bool home=level.MapName==savedBody.BodyMap;
        user.bInvisible=home?savedBody.Hidden:true;
        user.bSolid=home?savedBody.SolidBody:false;
        user.bShootable=home?savedBody.ShootableBody:false;
        user.bNoInteraction=home?savedBody.NoInteraction:true;
        user.A_ChangeLinkFlags(home && !savedBody.NoBlock?0:1,home && !savedBody.NoSector?0:1);
        if(home){user.SetOrigin(savedBody.BodyPosition,false);user.Angle=savedBody.BodyAngle;}
        user.FindFloorCeiling();user.ClearInterpolation();
        CaelumSpirit.Arrive(user);
        user.PersistCharacterState();
    }

    static void Restored(CaelumPlayer user)
    {let savedBody=View(user);if(savedBody!=null){savedBody.Stored=false;savedBody.InTransit=false;}}

    static void ChangeMap(String destination,int entry,int flags)
    {
        if(!LevelInfo.MapExists(destination))return;
        if(!CaelumTarotJustice.PrepareTravel())
        {CaelumJusticeTransit.Queue(destination,entry,flags);return;}
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Prepare(CaelumPlayer(players[i].mo));
        Level.ChangeLevel(destination,entry,flags);
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
