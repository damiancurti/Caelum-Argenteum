// #479: vistas del mismo modelo; manos y pivote compartidos del personaje.
class CaelumSupportArt : Object play
{
    static clearscope int Index(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SCEPTER)return 0;
        if(type==CaelumConstants.WEAPON_TYPE_ORB)return 1;
        int role=CaelumSupportImplementData.RoleForWeapon(type);
        return role<0?-1:role+2;
    }
    static clearscope String Key(int type)
    {
        switch(Index(type))
        {
            case 0:return "scepter";case 1:return "orb";case 2:return "book";
            case 3:return "censer";case 4:return "statuette";case 5:return "effigy";
        }
        return "";
    }
    static clearscope String Icon(int type)
    {return Index(type)<0?"":String.Format("graphics/caelum/icons/support_implements/%s_t1.png",Key(type));}
    static clearscope String MaterialIcon(int material)
    {
        if(material==CaelumConstants.MATERIAL_CENSER_BASE)return Icon(CaelumConstants.WEAPON_TYPE_CENSER);
        if(material==CaelumConstants.MATERIAL_SCEPTER_BASE)return Icon(CaelumConstants.WEAPON_TYPE_SCEPTER);
        if(material==CaelumConstants.MATERIAL_ORB_BASE)return Icon(CaelumConstants.WEAPON_TYPE_ORB);
        return "";
    }
    static State Pose(int type,int tier)
    {return GetDefaultByType("CaelumSupportImplementFrames").FindStateByString(String.Format("View%dT%d",type,Clamp(tier,1,3)));}
    static void Draw(CaelumPlayer user,int type,int tier,double dx,double dy,double rotation)
    {
        user.A_ClearOverlays(46,49);user.A_ClearOverlays(51,51);user.A_ClearOverlays(53,53);
        vector2 grip=CaelumFirstPersonLayers.Grip(type)+(dx,dy);
        CaelumFirstPersonLayers.Place(user,50,Pose(type,tier),grip,CaelumFirstPersonLayers.Grip(type),1,rotation);
        CaelumFirstPersonLayers.Hand(user,52,0,grip,(0,0),1,rotation);
    }
}
