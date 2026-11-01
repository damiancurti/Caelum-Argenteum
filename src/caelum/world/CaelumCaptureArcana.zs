// Dos objetivos persistentes, sin inventario transferible ni consultas globales.
class CaelumCaptureArcana : Object play
{
    int Revision;
    int Carrier[2],ReturnAt[2];
    bool Dropped[2];
    CaelumCaptureBase Bases[2];
    CaelumCaptureObjective Objectives[2];

    void Initialize(CaelumStandaloneMatch match)
    {
        if(Revision>0)return;Revision=1;
        for(int i=0;i<2;i++)
        {
            Carrier[i]=-1;vector3 point=CaelumStandaloneData.BasePosition(i);
            Bases[i]=CaelumCaptureBase(Actor.Spawn('CaelumCaptureBase',point,NO_REPLACE));
            Objectives[i]=CaelumCaptureObjective(Actor.Spawn('CaelumCaptureObjective',point,NO_REPLACE));
            Bases[i].Side=i;Objectives[i].Side=i;
            Bases[i].SetShade(i==0?0xff5555:0x88bbff);
            Bases[i].SetTag(i==0?"$CA_CAPTURE_RED_BASE":"$CA_CAPTURE_BLUE_BASE");
            Objectives[i].SetTag(i==0?"$CA_CAPTURE_RED_OBJECTIVE":"$CA_CAPTURE_BLUE_OBJECTIVE");
            Objectives[i].sprite=Actor.GetSpriteIndex(CaelumTarotArt.FrontSprite(CaelumStandaloneData.OBJECTIVE_CARD));
        }
    }
    clearscope bool Home(int side){return Carrier[side]<0 && !Dropped[side];}
    clearscope int Carrying(int slot)
    {for(int i=0;i<2;i++)if(Carrier[i]==slot)return i;return -1;}
    static bool Touches(CaelumPlayer user,Actor object)
    {
        return user!=null && user.health>0 && object!=null
            && user.Distance2D(object)<=user.Radius+object.Radius
            && user.Pos.Z<object.Pos.Z+object.Height && object.Pos.Z<user.Pos.Z+user.Height
            && user.CheckSight(object,SF_IGNOREVISIBILITY);
    }
    static bool Eligible(CaelumStandaloneMatch match,CaelumPlayer user)
    {return match!=null && match.Started && !match.Finished && user is 'CaelumStandalonePlayer' && match.Member(user.PlayerNumber()) && user.health>0;}
    void TouchObjective(CaelumStandaloneMatch match,CaelumPlayer user,int side)
    {
        if(side<0 || side>1 || !Eligible(match,user) || Carrier[side]>=0 || !Touches(user,Objectives[side]))return;
        int slot=user.PlayerNumber();
        if(match.Team[slot]==side)
        {if(Dropped[side])ReturnHome(side);return;}
        if(Carrying(slot)>=0)return;
        Carrier[side]=slot;Dropped[side]=false;ReturnAt[side]=0;
        Objectives[side].bSpecial=false;
        Console.Printf("%s",String.Format(StringTable.Localize('CA_CAPTURE_TAKEN',false),players[slot].GetUserName(),CaelumStandaloneMatch.TeamName(side)));
    }
    void ReturnHome(int side)
    {
        Carrier[side]=-1;Dropped[side]=false;ReturnAt[side]=0;
        Objectives[side].SetOrigin(Bases[side].Pos,false);Objectives[side].bSpecial=true;
    }
    void Drop(CaelumStandaloneMatch match,int slot,vector3 point)
    {
        int side=Carrying(slot);if(side<0)return;
        Carrier[side]=-1;Dropped[side]=true;ReturnAt[side]=level.time+CaelumStandaloneData.OBJECTIVE_RETURN_TICS;
        Objectives[side].SetOrigin(point,false);Objectives[side].bSpecial=true;
        Console.Printf("%s",String.Format(StringTable.Localize('CA_CAPTURE_DROPPED',false),CaelumStandaloneMatch.TeamName(side)));
    }
    void TouchBase(CaelumStandaloneMatch match,CaelumPlayer user,int side)
    {
        if(side<0 || side>1 || !Eligible(match,user) || match.Team[user.PlayerNumber()]!=side
            || !Home(side) || !Touches(user,Bases[side]) || Carrier[1-side]!=user.PlayerNumber())return;
        // Soltar primero el token impide una segunda puntuación en este tic.
        ReturnHome(1-side);match.Score[user.PlayerNumber()]++;
        Console.Printf("%s",String.Format(StringTable.Localize('CA_CAPTURE_SCORED',false),CaelumStandaloneMatch.TeamName(side),match.TeamScore(side)));
    }
    void Tick(CaelumStandaloneMatch match)
    {
        for(int i=0;i<2;i++)
        {
            if(Carrier[i]>=0)
            {
                int slot=Carrier[i];let body=CaelumStandalonePlayer(players[slot].mo);
                if(!playeringame[slot] || body==null || body.health<=0)
                {Drop(match,slot,body!=null?body.Pos:Objectives[i].Pos);continue;}
                Objectives[i].SetOrigin(body.Pos+(0,0,body.Height),false);
            }
            else if(Dropped[i] && level.time>=ReturnAt[i])ReturnHome(i);
        }
        // Un portador quieto puede puntuar cuando un aliado devuelve su arcano.
        for(int slot=0;slot<MAXPLAYERS;slot++)if(match.Member(slot) && Carrying(slot)>=0)
            TouchBase(match,CaelumPlayer(players[slot].mo),match.Team[slot]);
    }
}

class CaelumCaptureBase : Inventory
{
    int Side;
    override bool TryPickup(in out Actor toucher)
    {
        let match=CaelumStandaloneMatch.View();
        if(match!=null && match.Capture!=null)match.Capture.TouchBase(match,CaelumPlayer(toucher),Side);
        return false;
    }
    Default
    {
        Radius 18;Height 88;Scale 0.65;
        +NOGRAVITY +INVENTORY.UNDROPPABLE
        RenderStyle "Stencil";
    }
    States {Spawn:CTAR A -1 Bright;Stop;}
}

class CaelumCaptureObjective : Inventory
{
    int Side;
    override bool TryPickup(in out Actor toucher)
    {
        let match=CaelumStandaloneMatch.View();
        if(match!=null && match.Capture!=null)match.Capture.TouchObjective(match,CaelumPlayer(toucher),Side);
        return false;
    }
    Default {Radius 18;Height 88;Scale 0.25;+NOGRAVITY +INVENTORY.UNDROPPABLE}
    States {Spawn:CTAR A -1 Bright;Stop;}
}
