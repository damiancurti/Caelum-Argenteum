class CA415MeanChecks : CA415AimChecks
{
    override void Math()
    {
        // QUADRATURE
        Check(Near(CaelumMeanAim.CarbineRectangle(-1,1,-1,1,1,10),0.1),"shared random spread axes remain correlated");
        Check(Near(CaelumMeanAim.CarbineRectangle(-1,1,-1,1,0,10),0.19),"zero minimum integrates finite centre density");
        Check(Near(CaelumMeanAim.SignedRectangle(-1,1,-1,1,2,20),0),"signed offsets preserve empty central band");
        Check(Near(CaelumMeanAim.SignedRectangle(-4,4,-4,4,2,4),1),"signed range all directions included");
        Check(Near(CaelumMeanAim.SignedRectangle(2,4,2,4,2,4),0.25),"independent signed axes assign quarter probability");
        Check(Near(CaelumMeanAim.SignedRectangle(1,3,1,3,2,4),0.0625),"partial signed bands overlap proportionally");
        Check(Near(CaelumMeanAim.SignedRectangle(-.1,.1,-.1,.1,0,0),1),"zero signed spread hits centre");
        Check(Near(CaelumMeanAim.CarbineRectangle(-.1,.1,-.1,.1,0,0),1),"zero carbine spread hits centre");
        Check(Near(CaelumMeanAim.CarbineRectangle(1,2,1,2,0,0),0),"direct aim misses offset rectangle");
        Check(Near(CaelumMeanAim.SignedAxis(1,3,2,2),.5),"degenerate signed spread retains two lobes");
        double nearHit=CaelumMeanAim.BodyProbability((0,0,32),(128,0,0),16,64,0,1,10);
        double farHit=CaelumMeanAim.BodyProbability((0,0,32),(1024,0,0),16,64,0,1,10);
        Check(nearHit>farHit && farHit>0,"recorded distance decreases angular body coverage");
        Check(CaelumMeanAim.BodyProbability((0,0,32),(128,0,0),16,64,8,1,10)>=nearHit,"projectile radius expands target silhouette");
        Check(Near(CaelumMeanAim.BodyProbability((0,0,32),(0,0,0),16,64,0,1,10),1),"origin inside expanded body is contact");
        Check(Near(CaelumMeanAim.BodyProbability((0,0,32),(128,0,0),16,64,0,0,0),1),"dispersion disabled preserves direct centre aim");
        double above=CaelumMeanAim.BodyProbability((0,0,0),(128,0,64),16,64,0,1,10);
        double below=CaelumMeanAim.BodyProbability((0,0,0),(128,0,-128),16,64,0,1,10);
        Check(Near(above,below),"elevated and lowered targets retain symmetric nominal aim");
        double start=MSTimeF(),checksum=0;
        for(int i=0;i<1600;i++)checksum+=CaelumMeanAim.BodyProbability((0,0,32),(128+i,0,0),16,64,0,1,10);
        Console.Printf("CA415A TIMING 1600 estimates_ms=%.6f checksum=%.9f",MSTimeF()-start,checksum);
        Check(checksum>0,"bounded estimates require no actor scans, projectiles or random draws");
    }
}
