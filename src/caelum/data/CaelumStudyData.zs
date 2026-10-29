// #410: geometria y materiales de assets/art_source/study_furniture/DATA.json.
class CaelumStudyData : Object
{
    const REVISION=1;
    const DESK_RADIUS=31.985036501;
    const DESK_HEIGHT=24.800000000;
    static clearscope double Width(int k){return k==0?57.088000000:60.000000000;}
    static clearscope double Depth(int k){return k==0?28.864000000:20.000000000;}
    static clearscope double Height(int k){return k==0?24.800000000:72.000000000;}
    static clearscope double Mass(int k){return k==0?48.313559840:175.990188800;}
    static clearscope int Wood(int k){return k==0?48294:175910;}
    static clearscope int Iron(int k){return k==0?21:81;}
    static clearscope double Radius(int k){double w=Width(k),d=Depth(k);return Sqrt(w*w+d*d)/2;}
}
