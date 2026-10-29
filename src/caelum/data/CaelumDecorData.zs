// #410: medidas y masas calculadas por generate_ornamental_decor.py.
class CaelumDecorData : Object
{
    const COUNT=3;
    const PICTURE_RADIUS=11.537764081;
    const PICTURE_HEIGHT=16.640000000;
    const STATUE_RADIUS=7.919595949;
    const STATUE_HEIGHT=27.200000000;
    const LARGE_PICTURE_RADIUS=34.573330762;
    const LARGE_PICTURE_HEIGHT=49.920000000;
    static clearscope double Mass(int k){return k==0?4.278195893:k==1?27.062258043:57.305191140;}
    static clearscope double Width(int k){return k==0?23.040000000:k==1?11.200000000:69.120000000;}
    static clearscope double Height(int k){return k==0?16.640000000:k==1?27.200000000:49.920000000;}
    static clearscope double Radius(int k){return k==0?11.537764081:k==1?7.919595949:34.573330762;}
    const PICTURE_DEPTH=1.28;
    static clearscope double Depth(int k){return PICTURE_DEPTH*(k==2?1.5:1);}
    static clearscope bool WallMounted(int k){return k!=1;}
    static clearscope Name ItemClass(int k){return k==0?'CaelumPaintingItem':k==1?'CaelumStatueItem':'CaelumLargePaintingItem';}
    static clearscope Name BodyClass(int k){return k==0?'CaelumLandscapePainting':k==1?'CaelumOrnamentalStatue':'CaelumLargeLandscapePainting';}
    static clearscope String NameKey(int k){return k==0?"CA_DECOR_PAINTING":k==1?"CA_DECOR_STATUE":"CA_DECOR_PAINTING_LARGE";}
    static clearscope String Icon(int k){return k==1?"sprites/caelum/ornamental/COTSA0.png":"sprites/caelum/ornamental/COTPA0.png";}
    static clearscope int Wood(int k){return k==0?4184:k==1?27063:56472;}
    static clearscope int Iron(int k){return k==0?4:k==1?0:14;}
    static clearscope int Cloth(int k){return k==0?92:k==1?0:821;}
}
