Check(Near(CaelumContaminationObjectBalance.Evolve(80,0,10,0.04,1800),60),"rain without exposure subtracts twenty degrees");
Check(Near(CaelumContaminationObjectBalance.Evolve(80,0,10,0.04,3600),40),"rain washing repeats without an episode cap");
Check(Near(CaelumContaminationObjectBalance.Evolve(0,80,0,0.16,10),Sqrt(24.6)),"dry sword exposure exact from clean state");
Check(Near(CaelumContaminationObjectBalance.Evolve(80,40,0,0.16,1000),80),"dry air never cleans a dirtier object");
Check(Near(CaelumContaminationObjectBalance.Evolve(2,4,10,0.01,1800),0),"rain dominates exposure on a tiny object");
for(int i=0;i<5;i++){
    double area=i==0?0.01:i==1?0.04:i==2?0.16:i==3?1:8;
    double a=CaelumContaminationObjectBalance.Evolve(0,4,10,area,1800),b=0;
    for(int j=0;j<60;j++)b=CaelumContaminationObjectBalance.Evolve(b,4,10,area,30);
    Check(Near(a,b) && a>=0 && a<=4,String.Format("rising rain balance is independent of interval split area %.2f",area));
    a=CaelumContaminationObjectBalance.Evolve(12,20,10,area,1800);b=12;
    for(int j=0;j<60;j++)b=CaelumContaminationObjectBalance.Evolve(b,20,10,area,30);
    Check(Near(a,b) && a>=0 && a<=20,String.Format("both sides of equilibrium are stable area %.2f",area));
}
Check(Near(CaelumContaminationObjectBalance.Evolve(0.1,0.2,10,0.04,1800),0),"rain handles ambient below the ratio floor");
Check(Near(CaelumContaminationObjectBalance.Evolve(0.1,0.2,10,8,1800),0.2),"strong exposure clamps at sub-unit ambient");
