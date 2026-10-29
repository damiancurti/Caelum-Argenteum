class CA416Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA416 %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    void Catalogue()
    {
        Check(!CaelumTransportRules.Route(0) && !CaelumTransportRules.Route(16),"legacy sewer/campaign identities remain outside the new network");
        Check(!CaelumTransportRules.Mode(1) && !CaelumTransportRules.Mode(2),"new transport catalogue accepts only the four approved vehicle types");
        Check(CaelumTransportData.Map(0)=="CABAIRES" && CaelumTransportData.Map(1)=="MAP03"
            && CaelumTransportData.Map(2)=="TCOAST","network retains the actual existing port/coast map identities");
        Check(Near(CaelumTransportRules.DistanceKm(19,6),402.336),"rail end-to-end distance converts the guidebook 250 miles");
        Check(Near(CaelumTransportRules.Hours(19,6),12),"derived rail running pace and intermediate stop total twelve hours");
        Check(Near(CaelumTransportRules.Hours(18,6)+CaelumTransportRules.Hours(10,6)+.25,12),"rail stop is counted once across the two segments");
        Check(Near(CaelumTransportRules.DistanceKm(17,6),3.6),"Barracas short rail segment retains its secondary-reference mileage");
        Check(CaelumTransportRules.Fare(19,6,1)==805 && CaelumTransportRules.Fare(19,6,2)==1610,
            "approved rail rate charges actual travelers with upward ticket rounding");
        Check(CaelumTransportRules.Fare(17,3,3)==25,"cart rounds the total party ticket instead of each member separately");
        Check(CaelumTransportRules.Fare(19,6,0)==0 && CaelumTransportRules.Fare(0,6,1)==0,"invalid route or empty party has no charge");
        for(int mode=3;mode<=6;mode++)
        {
            Check(Near(CaelumTransportRules.DistanceKm(10,mode),CaelumTransportRules.DistanceKm(11,mode)),"opposite route identities retain equal corridor length");
            Check(Near(CaelumTransportRules.DistanceKm(19,mode),CaelumTransportRules.DistanceKm(18,mode)+CaelumTransportRules.DistanceKm(10,mode)),"direct service follows the approved three-city chain");
            double hours=CaelumTransportRules.Hours(19,mode);
            Check(Near(CaelumTransportRules.MovingHours(19,mode,hours)*CaelumTransportData.SpeedKmh(mode),CaelumTransportRules.DistanceKm(19,mode)),"elapsed duration reaches exactly the paid destination");
            Check(Near(CaelumTransportRules.MovingHours(19,mode,hours+24),CaelumTransportRules.MovingHours(19,mode,hours)),"completed movement never overshoots its destination");
        }
        Check(Near(CaelumTransportRules.MovingHours(19,5,8),8)
            && Near(CaelumTransportRules.MovingHours(19,5,23.9),8)
            && Near(CaelumTransportRules.MovingHours(19,5,25),9),"horse rest intervals do not accumulate extra distance");
        Check(Near(CaelumTransportRules.MovingHours(19,3,24),8),"cart keeps the estimated twenty-four-kilometer working day");
        double firstLeg=CaelumTransportRules.Hours(18,6);
        Check(Near(CaelumTransportRules.MovingHours(19,6,firstLeg+.1),firstLeg),"train remains stationary during its Barracas stop");
        Check(CaelumTransportRules.NextDeparture(18,6,73800,0)==73800
            && CaelumTransportRules.NextDeparture(18,6,73801,0)==160200,"exact daily departure is catchable and the missed departure advances one day");
        Check(Near(CaelumTransportRules.NextDeparture(10,6,0,0),73800+(firstLeg+.25)*3600),"intermediate train departure follows terminal arrival plus its stop");
        Check(CaelumTransportRules.NextDeparture(19,4,28801,0)==28800+3*86400,"ship service follows its explicit estimated three-day timetable");
        Check(CaelumTransportRules.NextDeparture(10,3,12345,0)==12345
            && CaelumTransportRules.NextDeparture(10,5,12345,0)==12345,"cart and horse require no fixed departure schedule");
        Check(CaelumTransportRules.NextDeparture(0,6,12345,0)<0,"invalid service cannot create a timetable");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca416_catalogue")return;
        Passed=Failed=0;Catalogue();Console.Printf("CA416 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
