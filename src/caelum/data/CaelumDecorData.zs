// #410: medidas y masas calculadas por generate_ornamental_decor.py.
class CaelumDecorData : Object
{
    const COUNT=2;
    const PICTURE_RADIUS=11.537764081;
    const PICTURE_HEIGHT=16.640000000;
    const STATUE_RADIUS=7.919595949;
    const STATUE_HEIGHT=27.200000000;
    static clearscope double Mass(int k){return k==0?4.278195893:27.062258043;}
    static clearscope double Width(int k){return k==0?23.040000000:11.200000000;}
    static clearscope double Height(int k){return k==0?16.640000000:27.200000000;}
    static clearscope double Radius(int k){return k==0?11.537764081:7.919595949;}
    const PICTURE_DEPTH=1.28;
    static clearscope Name ItemClass(int k){return k==0?'CaelumPaintingItem':'CaelumStatueItem';}
    static clearscope Name BodyClass(int k){return k==0?'CaelumLandscapePainting':'CaelumOrnamentalStatue';}
    static clearscope String NameKey(int k){return k==0?"CA_DECOR_PAINTING":"CA_DECOR_STATUE";}
    static clearscope String Icon(int k){return k==0?"sprites/caelum/ornamental/COTPA0.png":"sprites/caelum/ornamental/COTSA0.png";}
    static clearscope int Wood(int k){return k==0?4184:27063;}
    static clearscope int Iron(int k){return k==0?4:0;}
    static clearscope int Cloth(int k){return k==0?92:0;}
}
