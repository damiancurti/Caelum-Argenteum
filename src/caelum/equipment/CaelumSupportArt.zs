// #479: sprites pintados; Libro y Estatuilla conservan su arte aprobado.
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
    static clearscope int Legacy(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK)return 18;
        if(type==CaelumConstants.WEAPON_TYPE_SUPPORT_STATUETTE)return 19;
        return -1;
    }
    static clearscope bool NewSprite(int type){return Index(type)>=0 && Legacy(type)<0;}
    static clearscope String Icon(int type)
    {
        if(Legacy(type)==18)return "graphics/caelum/icons/ca_book.png";
        if(Legacy(type)==19)return "graphics/caelum/icons/ca_statuette.png";
        return Index(type)<0?"":String.Format("graphics/caelum/icons/support_sprites/%s_t1.png",Key(type));
    }
    static clearscope String MaterialIcon(int material)
    {
        if(material==CaelumConstants.MATERIAL_CENSER_BASE)return Icon(CaelumConstants.WEAPON_TYPE_CENSER);
        if(material==CaelumConstants.MATERIAL_SCEPTER_BASE)return Icon(CaelumConstants.WEAPON_TYPE_SCEPTER);
        if(material==CaelumConstants.MATERIAL_ORB_BASE)return Icon(CaelumConstants.WEAPON_TYPE_ORB);
        return "";
    }
    static State Pose(int type,int tier,int phase=0)
    {
        if(Legacy(type)>=0)return GetDefaultByType("CaelumFirstPersonFrames").FindStateByString(
            String.Format("CA_FP1_%s_T%d_%s",Key(type),Clamp(tier,1,3),phase==1?"B":phase==2?"C":"A"));
        return GetDefaultByType("CaelumSupportImplementFrames").FindStateByString(String.Format("View%dT%d",type,Clamp(tier,1,3)));
    }
    static void Draw(CaelumPlayer user,int type,int tier,double dx,double dy,double rotation)
    {
        user.A_ClearOverlays(46,49);user.A_ClearOverlays(51,51);user.A_ClearOverlays(53,53);
        vector2 grip=CaelumFirstPersonLayers.Grip(type)+(dx,dy);
        CaelumFirstPersonLayers.Place(user,50,Pose(type,tier),grip,CaelumFirstPersonLayers.Grip(type),1,rotation);
        CaelumFirstPersonLayers.Hand(user,52,0,grip,(0,0),1,rotation);
    }
}
