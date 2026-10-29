// Indice local de cuerpos fisicos, incluidos los que no usan el blockmap.
// No decide contactos: conserva candidatos y deja la geometria al adaptador.
class CaelumContaminationGrid : Object play
{
    const CELL=128.0; // Celda nativa del blockmap, no una distancia de contacto.
    const BUCKETS=2048;
    Array<CaelumContaminationContacts> Heads;
    double LargestRadius;
    static int Hash(int x,int y){return ((x*37+y*73)&0x7fffffff)%BUCKETS;}
    void Remove(CaelumContaminationContacts row)
    {
        if(row==null || row.Grid!=self)return;
        int h=Hash(row.GridX,row.GridY);CaelumContaminationContacts previous;
        for(let at=Heads[h];at!=null;at=at.GridNext)
        {
            if(at==row)
            {if(previous==null)Heads[h]=row.GridNext;else previous.GridNext=row.GridNext;break;}
            previous=at;
        }
        row.Grid=null;row.GridNext=null;row.GridBody=null;
    }
    void Track(Actor body)
    {
        if(!CaelumContaminationContacts.Eligible(body) || CaelumDiningContamination.Owner(body)!=body)return;
        if(!body.bNoBlockmap)
        {let old=CaelumContaminationContacts.Get(body);if(old!=null && old.Grid!=null)old.Grid.Remove(old);return;}
        let row=CaelumContaminationContacts.Get(body,true);if(row==null)return;
        int x=int(Floor(body.Pos.X/CELL)),y=int(Floor(body.Pos.Y/CELL));
        LargestRadius=Max(LargestRadius,body.Radius);
        if(row.Grid==self && row.GridBody==body && row.GridX==x && row.GridY==y)return;
        if(row.Grid!=null)row.Grid.Remove(row);
        if(Heads.Size()!=BUCKETS)Heads.Resize(BUCKETS);
        row.Grid=self;row.GridBody=body;row.GridX=x;row.GridY=y;
        int h=Hash(x,y);row.GridNext=Heads[h];Heads[h]=row;
    }
    void Observe(Actor body)
    {
        Track(body);if(!CaelumContaminationContacts.Eligible(body) || Heads.Size()==0)return;
        double range=body.Radius+LargestRadius;
        int left=int(Floor((body.Pos.X-range)/CELL)),right=int(Floor((body.Pos.X+range)/CELL));
        int low=int(Floor((body.Pos.Y-range)/CELL)),high=int(Floor((body.Pos.Y+range)/CELL));
        for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
            for(let at=Heads[Hash(x,y)];at!=null;)
            {
                let next=at.GridNext;let other=at.GridBody;
                if(other==null || !CaelumContaminationContacts.Eligible(other))Remove(at);
                else if(at.GridX==x && at.GridY==y && other!=body
                    && CaelumContaminationContacts.Overlap(body,other) && body.CheckSight(other))
                    CaelumContaminationContacts.Collision(body,other);
                at=next;
            }
    }
}
