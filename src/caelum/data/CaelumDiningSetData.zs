// #410: generado desde dining_sets/DATA.json y las sillas existentes.
class CaelumDiningSetData : Object
{
    const COUNT=4;
    static clearscope double Width(int v){return v==0?33.280000000:v==1?54.464000000:v==2?99.360000000:133.088000000;}
    static clearscope double Depth(int v){return v==0?33.280000000:v==1?28.256000000:v==2?27.040000000:48.960000000;}
    static clearscope double Height(int v){return v==0?23.680000000:v==1?22.752000000:v==2?22.368000000:23.584000000;}
    static clearscope double Mass(int v){return v==0?51.315145980:v==1?99.531929360:v==2?179.460430920:366.236540040;}
    static clearscope double TableMass(int v){return v==0?35.957011260:v==1?53.457525200:v==2?87.311622600:192.220657200;}
    static clearscope int Wood(int v){return v==0?51318:v==1?99402:v==2?179336:361936;}
    static clearscope int Iron(int v){return v==0?0:v==1?136:v==2?136:3002;}
    static clearscope int Cloth(int v){return v==0?0:v==1?0:v==2?0:1308;}
    static clearscope int Seats(int v){return v==0?2:v==1?6:v==2?12:6;}
    static clearscope int Capacity(int v){return v==0?4:v==1?18:v==2?60:18;}
    static clearscope Name ItemClass(int v){return v==0?"CaelumSmallDiningSetItem":v==1?"CaelumNormalDiningSetItem":v==2?"CaelumLargeDiningSetItem":"CaelumLuxuryDiningSetItem";}
    static clearscope Name BodyClass(int v){return v==0?"CaelumPortableSmallTable":v==1?"CaelumPortableNormalTable":v==2?"CaelumPortableLargeTable":"CaelumPortableLuxuryTable";}
    static clearscope String NameKey(int v){return v==0?"CA_DINING_SET_SMALL":v==1?"CA_DINING_SET_NORMAL":v==2?"CA_DINING_SET_LARGE":"CA_DINING_SET_LUXURY";}
    static clearscope String Icon(int v){return v==0?"sprites/caelum/rest_furniture/CDS2A0.png":v==1?"sprites/caelum/rest_furniture/CDS6A0.png":v==2?"sprites/caelum/rest_furniture/CD12A0.png":"sprites/caelum/rest_furniture/CDLXA0.png";}
    static clearscope double ChairRadius(int v){return CaelumRestFurnitureData.Radius(v==3?0:2);}
    static clearscope double FullHeight(int v){return Max(Height(v),CaelumRestFurnitureData.Height(v==3?0:2));}
    static clearscope double SeatClearance(int v){return Max(ChairRadius(v),GetDefaultByType("CaelumPlayer").Radius)+1;}
    static clearscope double SeatSpacing(int v){return GetDefaultByType("CaelumPlayer").Radius+ChairRadius(v)+1;}
    static clearscope double Radius(int v){double w=Width(v)/2+SeatClearance(v)+ChairRadius(v),d=Depth(v)/2+SeatClearance(v)+ChairRadius(v);return Sqrt(w*w+d*d);}
}
