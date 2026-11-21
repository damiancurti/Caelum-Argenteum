        // Fixture only: sweep current light and live dimensions against immutable 114.
        int lightValues[8]={-30,0,1,32,127,254,255,300};
        int lightChecks=0;int lightFailures=0;
        Observer.Angle=0;Observer.SetOrigin((0,0,0),false);
        for(int li=0;li<8;li++)for(int hi=0;hi<2;hi++)
        for(int insight=0;insight<2;insight++)for(int stealth=0;stealth<2;stealth++)
        {
            Subject.CurSector.SetLightLevel(lightValues[li]);
            Subject.Height=hi==0?28:112;Observer.CombatEffectiveInsight=insight==0?0:100;
            Subject.CombatAgility=stealth==0?0:100;
            double oldRange=CA851BaselinePerception.Range(Observer,Subject);
            double newRange=CaelumVisualPerception.Range(Observer,Subject);
            bool equal=oldRange==newRange;lightChecks++;if(!equal)lightFailures++;
            for(int side=-1;side<=1;side++)
            {
                Subject.SetOrigin((Max(0.0,oldRange+side*0.001),0,0),false);
                bool wasVisible=CA851BaselinePerception.CanSee(Observer,Subject);
                bool isVisible=CaelumVisualPerception.CanSee(Observer,Subject);
                bool selected=Known(Subject);
                bool outside=CaelumVisualPerception.OutsideGroupReach(Observer,Subject,
                    CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)
                    *CaelumVisualPerception.InsightFactor(Observer));
                equal=wasVisible==isVisible && selected==wasVisible;
                if(level.GetPortalGroupCount()==1 && outside)
                    equal=equal && !wasVisible && !CA851BaselinePerception.Touching(Observer,Subject);
                lightChecks++;if(!equal)lightFailures++;
            }
        }
        Subject.Height=56;Subject.CombatAgility=0;Observer.CombatEffectiveInsight=0;
        Subject.SetOrigin((256,0,0),false);Subject.CurSector.SetLightLevel(255);
        // Test shared ally evidence using the same candidate order and fresh private records.
        let lightPopulation=CaelumPopulationState.Get();bool lightDense=lightPopulation.HighDensity;
        lightPopulation.HighDensity=true;
        let lightGroup=Observer.SiegeCombatant.GroupCandidates;
        if(Subject.SiegeCombatant==null)Subject.SiegeCombatant=new("CaelumSiegeCombatant");
        Subject.SiegeCombatant.Body=Subject;
        Subject.SiegeCombatant.CommandLeader=Observer.SiegeCombatant;
        Subject.SiegeCombatant.Encounter=Observer.SiegeCombatant.Encounter;
        Subject.bFriendly=true;lightGroup.Candidates.Clear();lightGroup.Members.Clear();
        lightGroup.Members.Push(Subject.SiegeCombatant);lightGroup.Ready=true;lightGroup.SampleTic=level.time;
        for(int li=0;li<8;li++)for(int position=0;position<3;position++)
        {
            Subject.CurSector.SetLightLevel(lightValues[li]);
            Subject.SetOrigin((position==0?32.005:position==1?256:1800,0,0),false);
            bool sameAlly=CA851LocalParity.Same(Observer);lightChecks++;if(!sameAlly)lightFailures++;
        }
        lightGroup.Members.Clear();Subject.bFriendly=false;lightPopulation.HighDensity=lightDense;
        Subject.SetOrigin((256,0,0),false);Subject.CurSector.SetLightLevel(255);
        Checks+=lightChecks;Failures+=lightFailures;
        Console.Printf("CA873 LIGHT_EDGES checks=%d failures=%d result=%s",lightChecks,lightFailures,lightFailures==0?"PASS":"FAIL");
