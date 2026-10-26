Check(Abs(CaelumContaminationObjectBalance.Evolve(0,4,10,0.04,1800)-1.439998540098)<0.00002,"independent RK4 reference case 1");
Check(Abs(CaelumContaminationObjectBalance.Evolve(12,20,10,0.04,1800)-7.739342801120)<0.00002,"independent RK4 reference case 2");
Check(Abs(CaelumContaminationObjectBalance.Evolve(12,20,10,0.01,1800)-1.843025606569)<0.00002,"independent RK4 reference case 3");
Check(Abs(CaelumContaminationObjectBalance.Evolve(0,0.2,10,0.16,60)-0.000000000000)<0.00002,"independent RK4 reference case 4");
Check(Abs(CaelumContaminationObjectBalance.Evolve(0.5,4,2,0.16,30)-1.842556276319)<0.00002,"independent RK4 reference case 5");
Check(Abs(CaelumContaminationObjectBalance.Evolve(80,20,10,0.04,6500)-13.215057749971)<0.00002,"independent RK4 reference case 6");
