class CA842ShelterReference : Object play
{
    static bool Roof(Actor body)
    {
        if(CaelumThermalWorld.UnderRoof(body))return true;
        FLineTraceData hit;
        double z=body.Pos.Z+body.Height*0.75;
        bool found=body.LineTrace(0,65536,-90,TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,
            z,body.Pos.X,body.Pos.Y,hit);
        return found && hit.HitType!=FLineTraceData.TRACE_HasHitSky;
    }

    static bool SameWall(Line a,Line b)
    {
        if(a==b)return true;
        vector2 da=a.delta,db=b.delta,offset=b.v1.p-a.v1.p;
        double length=Max(0.001,da.Length());
        return Abs(da.X*db.Y-da.Y*db.X)<=0.001*length*Max(0.001,db.Length())
            && Abs(da.X*offset.Y-da.Y*offset.X)<=0.01*length;
    }

    static bool Connected(Line a,Line b)
    {
        return (a.v1.p-b.v1.p).Length()<0.01 || (a.v1.p-b.v2.p).Length()<0.01
            || (a.v2.p-b.v1.p).Length()<0.01 || (a.v2.p-b.v2.p).Length()<0.01;
    }

    static bool WindBlocked(Actor body)
    {
        // UnderRoof reconoce el volumen geométrico del rancho de tres paredes;
        // sus colisiones son actores y por eso no aparecen como HitLine.
        if(CaelumThermalWorld.UnderRoof(body))return true;
        Line walls[8];int count=0;
        double z=body.Pos.Z+body.Height*0.5;
        for(int direction=0;direction<CaelumThermalData.SHELTER_RAYS;direction++)
        {
            FLineTraceData hit;
            if(!body.LineTrace(direction*360.0/CaelumThermalData.SHELTER_RAYS,
                CaelumThermalData.SHELTER_RANGE_MU,0,TRF_THRUACTORS|TRF_ABSPOSITION|TRF_NOSKY,
                z,body.Pos.X,body.Pos.Y,hit) || hit.HitLine==null)continue;
            bool duplicate=false;
            for(int i=0;i<count;i++)if(SameWall(walls[i],hit.HitLine)){duplicate=true;break;}
            if(!duplicate)walls[count++]=hit.HitLine;
        }
        // Tres segmentos arbitrarios no bastan: deben formar un recinto local
        // conectado. Se cuentan planos distintos, no subdivisiones de una pared.
        for(int first=0;first<count;first++)
        {
            bool reached[8];reached[first]=true;int linked=1;
            for(int pass=0;pass<count;pass++)for(int i=0;i<count;i++)
                if(!reached[i])for(int j=0;j<count;j++)
                    if(reached[j] && Connected(walls[i],walls[j]))
                    {reached[i]=true;linked++;break;}
            if(linked>=3)return true;
        }
        return false;
    }
}


class CA842ShelterBody : Actor
{int Index;Default {+NOINTERACTION +NOGRAVITY Radius 16;Height 56;} States {Spawn:TNT1 A -1;Stop;}}
class CA842ShelterFixture : EventHandler
{
    Array<CA842ShelterBody> Bodies;
    int SavedRevision;
    transient bool Checked;
    int Checks,Errors;
    void Check(bool valid,String message)
    {Checks++;if(!valid)Errors++;Console.Printf("CA842 CHECK %s %s",valid?"PASS":"FAIL",message);}
    override void WorldTick()
    {
        if(Checked)return;Checked=true;Checks=Errors=0;
        vector3 points[]={(-6000,-3000,0),(0,-3000,0),(6000,-3000,0),(-6000,3000,0),(0,3000,0),(6000,3000,0)};
        int expected[]={0,0,1,1,0,-1};
        bool fresh=SavedRevision==0;
        if(fresh)
        {
            for(int i=0;i<6;i++)
            {let probe=CA842ShelterBody(Actor.Spawn('CA842ShelterBody',points[i],NO_REPLACE));if(probe!=null)probe.Index=i;Bodies.Push(probe);}
            SavedRevision=1;
        }
        Check(SavedRevision==1,"saved_revision");Check(Bodies.Size()==6,"saved_body_count");
        for(int i=0;i<Bodies.Size();i++)
        {
            let probe=Bodies[i];Check(probe!=null,"saved_body");if(probe==null)continue;
            Check(probe.Index==i && probe.Pos==points[i] && probe.Height==56,"saved_identity_geometry");
            bool actual=CaelumThermalShelter.WindBlocked(probe),reference=CA842ShelterReference.WindBlocked(probe);
            Check(actual==reference,"original_geometry");
            if(expected[i]>=0)Check(actual==(expected[i]!=0),"authored_three_plane_boundary");
            for(int step=0;step<4;step++)
            {
                probe.SetOrigin(points[i]+(step*8,step*5,step*24),false);probe.Height=56+step*16;
                bool current=CaelumThermalShelter.WindBlocked(probe);
                Check(current==CA842ShelterReference.WindBlocked(probe),"moved_height_geometry");
                Check(current==CaelumThermalShelter.WindBlocked(probe),"repeat_stability");
            }
            probe.SetOrigin(points[i],false);probe.Height=56;
        }
        Console.Printf("CA842 FIXTURE_COMPLETE fresh=%d checks=%d errors=%d",fresh,Checks,Errors);
    }
}
