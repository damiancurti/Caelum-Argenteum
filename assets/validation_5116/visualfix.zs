// Follow-up #163: actual psprite timing and native front/back depth captures.
class CA163Visualfix : CA163Inputs
{
    double PreviousRotation,AccumulatedRotation;
    int RotationSamples;
    CaelumBolasFlight VisualBinding;
    int RopeCount()
    {
        int count=0;let it=ThinkerIterator.Create("CaelumBolasRopes");
        while(it.Next()!=null)count++;
        return count;
    }
    override void WorldTick()
    {
        Super.WorldTick();
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(Stage==20 && Age>=5 && Age<=40)
        {
            let view=u.player.FindPSprite(50);
            if(view!=null)
            {
                if(Age>5)
                {
                    double delta=view.rotation-PreviousRotation;
                    while(delta>180)delta-=360;while(delta< -180)delta+=360;
                    AccumulatedRotation+=delta;RotationSamples++;
                }
                PreviousRotation=view.rotation;
            }
            if(Age==40)
            {
                Console.Printf("CA163 SPIN samples=%d degrees=%.6f",RotationSamples,AccumulatedRotation);
                Check("actual spinning psprite makes three turns in 35 tics",RotationSamples==35 && Abs(AccumulatedRotation+1080)<0.001);
                Check("faster spin retains one-second accuracy cap",u.BolasPreparedTics==35);
                Check("spin leaves the hand unrotated",u.player.FindPSprite(52)!=null && u.player.FindPSprite(52).rotation==0);
            }
        }
        if(Stage>=21 && Stage<=25 && Age==1)
        {
            if(VisualBinding==null)
            {
                TargetBody=Body();TargetBody.SetOrigin((2300,2300,0),false);
                VisualBinding=Bind(u,TargetBody);
            }
            double angle=(Stage-21)%4*90;
            vector2 offset=Actor.AngleToVector(angle,96);
            u.SetOrigin(TargetBody.Pos-(offset.X,offset.Y,0),false);u.Angle=angle;u.Pitch=0;
            VisualBinding.Remaining=175;
        }
        if(Stage>=21 && Stage<=24 && Age==3)
        {
            vector2 forward=Actor.AngleToVector(u.Angle);
            Check(String.Format("front/rear native depth at heading %d",int(u.Angle)),
                (VisualBinding.Ropes[0].WorldOffset.XY Dot forward)<0
                && (VisualBinding.BackRopes[0].WorldOffset.XY Dot forward)>0);
            Check(String.Format("exactly four attached layers at heading %d",int(u.Angle)),RopeCount()==4);
        }
        if(Stage>=26 && Stage<=29 && Age==1)
        {
            VisualBinding.Remaining=175;
            TargetBody.bINVISIBLE=Stage>=28;
            for(int i=0;i<2;i++)
            {
                VisualBinding.Ropes[i].bINVISIBLE=true;
                VisualBinding.BackRopes[i].bINVISIBLE=Stage==27 || Stage==29;
            }
        }
        if(Stage==30 && Age==1)
        {
            let item=VisualBinding.SourceItem;VisualBinding.Resolve(false);
            Check("release removes all four rope layers",RopeCount()==0);
            Check("visual release retains the same recoverable item",item!=null && item.Owner==null && item.Durability==1);
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
