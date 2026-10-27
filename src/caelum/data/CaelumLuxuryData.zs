// #410: generado desde assets/art_source/luxury_furniture/DATA.json.
class CaelumLuxuryData : Object
{
    const LAYOUT_REVISION=1;
    const SERVING_DIAMETER=21;
    const COLLISION_CELL=48;
    const CHAIR=0;
    const BED=1;
    const TABLE=2;
    static clearscope double Width(int kind){return kind==0?22.368000000:kind==1?51.200000000:133.088000000;}
    static clearscope double Depth(int kind){return kind==0?22.368000000:kind==1?65.024000000:48.960000000;}
    static clearscope double Height(int kind){return kind==0?30.080000000:kind==1?68.288000000:23.584000000;}
    static clearscope double Surface(int kind){return kind==0?13.440000000:kind==1?14.400000000:23.584000000;}
    static clearscope double Weight(int kind){return kind==0?29.002647140:kind==1?135.091394000:192.220657200;}
    static clearscope int Wood(int kind){return kind==0?28477:kind==1?132887:191074;}
    static clearscope int Iron(int kind){return kind==0?309:kind==1?1143:1148;}
    static clearscope int Cloth(int kind){return kind==0?218:kind==1?1063:0;}
}
