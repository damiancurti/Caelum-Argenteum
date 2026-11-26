// Private surface-index oracle and persistence fixture; never a gameplay handler.
class CA871IndexChecks : EventHandler
{
    const ADAPTIVE=__ADAPTIVE__;
    CaelumContaminationMap Actual;
    CA871ReferenceMap Reference;
    Array<CaelumContaminationTile> Identities;
    bool Seeded;
    int Checks,Failures,Loads,Growths;
    void Check(bool ok,String label)
    {Checks++;if(!ok){Failures++;Console.Printf("CA871 FAIL %s",label);}}
    bool Same(CaelumContaminationTile a,CaelumContaminationTile b)
    {
        return a!=null && b!=null && a.Kind==b.Kind && a.Surface==b.Surface && a.Side==b.Side && a.X==b.X && a.Y==b.Y
            && a.Concentration==b.Concentration && a.Stamp==b.Stamp && a.Reference==b.Reference
            && a.Profile==b.Profile && a.Region==b.Region && a.Seed==b.Seed && a.Shelter==b.Shelter
            && a.Covered==b.Covered && a.RockSources==b.RockSources && a.RockTouched==b.RockTouched
            && a.EffectiveReference()==b.EffectiveReference();
    }
    void Values(CaelumContaminationTile tile,int index)
    {
        tile.Concentration=(index%10001)/100.0;tile.Stamp=1000+(index%37)/8.0;tile.Reference=index%4==0?-1:index%101;
        tile.Profile=1+index%5;tile.Region=index%12;tile.Seed=index*17;tile.Shelter=index%5;
        tile.Covered=index%2==0;tile.RockSources=index%7==0?2:0;tile.RockTouched=index%11==0;
    }
    void VerifyAll(String label)
    {
        Check(Actual!=null && Reference!=null,"saved map objects exist");
        if(Actual==null || Reference==null)return;
        Check(Actual.Tiles.Size()==Reference.Tiles.Size() && Actual.Tiles.Size()==Identities.Size(),"tile and identity counts agree");
        if(Actual.Tiles.Size()!=Reference.Tiles.Size() || Actual.Tiles.Size()!=Identities.Size())return;
        int bad=0;int beforeCapacity=Actual.Buckets.Size();double firstLookupMS=0;
        for(int i=0;i<Actual.Tiles.Size();i++)
        {
            let a=Actual.Tiles[i];let b=Reference.Tiles[i];
            double started=i==0?MSTimeF():0;
            let found=Actual.Find(a.Kind,a.Surface,a.Side,a.X,a.Y);
            if(i==0)firstLookupMS=MSTimeF()-started;
            let original=Reference.Find(b.Kind,b.Surface,b.Side,b.X,b.Y);
            if(found!=a || found!=Identities[i] || original!=b || !Same(a,b))bad++;
        }
        Check(bad==0,label);
        Check(Actual.Epoch==Reference.Epoch && Actual.CivilOffset==Reference.CivilOffset
            && Actual.Map==Reference.Map && Actual.Revision==Reference.Revision,"map metadata remains exact");
        int expected=1024;
        if(ADAPTIVE)while(Actual.Tiles.Size()/expected>=4)expected*=2;
        Check(Actual.Buckets.Size()==expected,"derived capacity follows selected implementation");
        Console.Printf("CA871 VERIFY label=%s tiles=%d buckets=%d mismatches=%d",label,Actual.Tiles.Size(),Actual.Buckets.Size(),bad);
        Console.Printf("CA871 FIRST_FIND label=%s tiles=%d before=%d after=%d ms=%.6f",label,Actual.Tiles.Size(),beforeCapacity,Actual.Buckets.Size(),firstLookupMS);
    }
    void Populate()
    {
        Actual=new('CaelumContaminationMap');Reference=new('CA871ReferenceMap');Identities.Clear();
        Actual.Map="CA871";Reference.Map=Actual.Map;Actual.Revision=7;Reference.Revision=7;
        Actual.Epoch=123.25;Reference.Epoch=Actual.Epoch;Actual.CivilOffset=-300.5;Reference.CivilOffset=Actual.CivilOffset;
        int lump=Wads.CheckNumForFullName("index_keys.txt");Check(lump>=0,"retained current-map key dataset exists");if(lump<0)return;
        String data=Wads.ReadLump(lump);Array<String> lines;data.Split(lines,"\n",TOK_SKIPEMPTY);
        Check(lines.Size()==62253,"all observed tile keys are loaded");
        for(int i=0;i<lines.Size();i++)
        {
            Array<String> parts;lines[i].Split(parts," ",TOK_SKIPEMPTY);
            if(parts.Size()!=5){Check(false,"key row has five integers");return;}
            int kind=parts[0].ToInt(),surface=parts[1].ToInt(),side=parts[2].ToInt(),x=parts[3].ToInt(),y=parts[4].ToInt();
            int capacity=Actual.Buckets.Size();
            double started=MSTimeF();let a=Actual.Find(kind,surface,side,x,y,true);double lookupMS=MSTimeF()-started;
            let b=Reference.Find(kind,surface,side,x,y,true);
            Check(a!=null && b!=null && a.Stamp==Actual.Epoch && a.Reference==-1 && a.Concentration==0,"new tile defaults and lazy creation agree");
            if(a==null || b==null)return;
            Values(a,i);Values(b,i);Identities.Push(a);
            if(Actual.Buckets.Size()!=capacity)
            {
                Growths++;int bad=0;
                for(int j=0;j<Identities.Size();j++)
                {
                    let old=Identities[j];let found=Actual.Find(old.Kind,old.Surface,old.Side,old.X,old.Y);
                    if(found!=old || !Same(found,Reference.Tiles[j]))bad++;
                }
                Check(bad==0,"capacity growth retains every existing identity and value");
                Console.Printf("CA871 GROW tiles=%d before=%d after=%d ms=%.6f",Actual.Tiles.Size(),capacity,Actual.Buckets.Size(),lookupMS);
            }
        }
        Seeded=true;VerifyAll("fresh_dataset");
        Console.Printf("CA871 POPULATE growths=%d",Growths);
    }
    void MissingAndExtremeKeys()
    {
        int before=Actual.Tiles.Size();
        for(int i=0;i<12;i++)
        {
            int kind=700+i,surface=2147483647-i,side=-i,x=-2147483647+i,y=2147483647-i;
            let missing=Actual.Find(kind,surface,side,x,y);let expected=Reference.Find(kind,surface,side,x,y);
            Check(missing==null && expected==null,"absent extreme key returns null without creation");
            Check(Actual.Tiles.Size()==before+i,"noncreating lookup retains tile count");
            let a=Actual.Find(kind,surface,side,x,y,true);let b=Reference.Find(kind,surface,side,x,y,true);
            Check(Same(a,b) && a.Stamp==Actual.Epoch && a.Reference==-1,"extreme signed key creates matching defaults");
            Values(a,before+i);Values(b,before+i);Identities.Push(a);
            let again=Actual.Find(kind,surface,side,x,y,true);
            Check(again==a && Actual.Tiles.Size()==before+i+1,"repeated creation returns existing identity");
        }
        VerifyAll("negative_and_extreme_keys");
    }
    void DuplicateAndEmpty()
    {
        let testMap=new('CaelumContaminationMap');let old=new('CA871ReferenceMap');
        Check(testMap.Find(0,0,0,0,0)==null && testMap.Tiles.Size()==0,"empty map lookup creates only derived buckets");
        for(int i=0;i<2;i++)
        {
            let a=new('CaelumContaminationTile');a.Kind=2;a.Surface=-33;a.X=-17;a.Y=9;Values(a,i);
            testMap.Tiles.Push(a);old.Tiles.Push(a.Copy());
        }
        testMap.Buckets.Clear();old.Buckets.Clear();
        let a=testMap.Find(2,-33,0,-17,9);let b=old.Find(2,-33,0,-17,9);
        Check(a==testMap.Tiles[1] && b==old.Tiles[1] && Same(a,b),"rebuild preserves original duplicate-key traversal precedence");
        int before=Actual.Tiles.Size();Actual.Buckets.Clear();Actual.Index();
        Check(Actual.Tiles.Size()==before,"discarded index rebuild does not change authoritative tile count");
        VerifyAll("explicit_index_rebuild");
    }
    double TimeOriginal(int calls)
    {
        double started=MSTimeF();int count=Reference.Tiles.Size();
        for(int i=0;i<calls;i++){let key=Reference.Tiles[(i*17)%count];let found=Reference.Find(key.Kind,key.Surface,key.Side,key.X,key.Y);if(found!=key)Failures++;}
        return MSTimeF()-started;
    }
    double TimeActual(int calls)
    {
        double started=MSTimeF();int count=Actual.Tiles.Size();
        for(int i=0;i<calls;i++){let key=Actual.Tiles[(i*17)%count];let found=Actual.Find(key.Kind,key.Surface,key.Side,key.X,key.Y);if(found!=key)Failures++;}
        return MSTimeF()-started;
    }
    void Bench()
    {
        VerifyAll("before_benchmark");double originalTotal=0,candidateTotal=0;int calls=Actual.Tiles.Size();
        for(int round=0;round<8;round++)
        {
            double a,b;
            if(round%2==0){a=TimeOriginal(calls);b=TimeActual(calls);}else{b=TimeActual(calls);a=TimeOriginal(calls);}
            originalTotal+=a;candidateTotal+=b;
            Console.Printf("CA871 ROUND i=%d calls=%d original_ms=%.6f candidate_ms=%.6f",round,calls,a,b);
        }
        Console.Printf("CA871 BENCH tiles=%d calls=%d original_ms=%.6f candidate_ms=%.6f buckets=%d",calls,calls*8,originalTotal,candidateTotal,Actual.Buckets.Size());
    }
    void SmallBench()
    {
        let largeActual=Actual;let largeReference=Reference;
        for(int scene=0;scene<3;scene++)
        {
            int count=scene==0?16:scene==1?512:4096;
            Actual=new('CaelumContaminationMap');Reference=new('CA871ReferenceMap');
            for(int i=0;i<count;i++)
            {Actual.Find(i%3,i%97,i%2,i*31,-i*17,true);Reference.Find(i%3,i%97,i%2,i*31,-i*17,true);}
            Actual.Index();Reference.Index();
            double originalTotal=0,candidateTotal=0;int calls=62500;
            for(int round=0;round<8;round++)
            {
                double originalMS,candidateMS;
                if(round%2==0){originalMS=TimeOriginal(calls);candidateMS=TimeActual(calls);}
                else{candidateMS=TimeActual(calls);originalMS=TimeOriginal(calls);}
                originalTotal+=originalMS;candidateTotal+=candidateMS;
            }
            Check(Actual.Tiles.Size()==count && Reference.Tiles.Size()==count,"small-index repeated reads preserve population");
            Console.Printf("CA871 SMALL tiles=%d calls=%d original_ms=%.6f candidate_ms=%.6f buckets=%d",count,calls*8,originalTotal,candidateTotal,Actual.Buckets.Size());
        }
        Actual=largeActual;Reference=largeReference;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca871_check" && e.Name!="ca871_seed" && e.Name!="ca871_bench")return;
        Checks=0;Failures=0;Growths=0;
        if(!Seeded){Populate();if(e.Name!="ca871_seed"){MissingAndExtremeKeys();DuplicateAndEmpty();}}
        else {Loads++;VerifyAll("native_reload");}
        if(e.Name!="ca871_seed"){Bench();SmallBench();}
        VerifyAll("before_native_save");
        Console.Printf("CA871 RESULT checks=%d errors=%d loads=%d",Checks,Failures,Loads);
    }
}
