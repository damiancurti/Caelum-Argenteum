// #410: generado desde assets/art_source/sofas/DATA.json.
class CaelumSofaData : Object
{
    const REVISION=1;
    const SEAT_STRIDE=32.000000000;
    const SEAT_RADIUS=16.000000000;
    const SEAT_SURFACE=13.440000000;
    static clearscope double Width(int kind){return kind==1?67.872000000:60.160000000;}
    static clearscope double Depth(int kind){return kind==1?20.320000000:19.520000000;}
    static clearscope double Height(int kind){return kind==1?28.032000000:24.064000000;}
    static clearscope double Weight(int kind){return kind==1?43.881812348:35.373878880;}
    static clearscope int Wood(int kind){return kind==1?42797:34467;}
    static clearscope int Iron(int kind){return kind==1?407:407;}
    static clearscope int Cloth(int kind){return kind==1?679:502;}
    static clearscope double VisualStride(int kind){return (Width(kind)-5.120000000)/(kind==1?3:2);}
    static clearscope int Seats(int kind){return kind==1?3:2;}
    static clearscope vector3 Position(int kind){return kind==1?(280,-400,0):(280,-548,0);}
    static clearscope double Facing(int kind){return kind==1?180:180;}
}
