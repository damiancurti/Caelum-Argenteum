// Proyección compartida por Diario y cartela. Lee las mismas instantáneas,
// nunca busca actores ni deduce coordenadas desde una misión activa.
class CaelumQuestTrackingView : Object ui
{
    static String Objective(CaelumPlayer user,int quest)
    {
        if(user==null || quest<0 || quest>=CaelumConstants.QUEST_DEFINED_COUNT
            || user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_UNDISCOVERED)return "";
        String key;
        if(quest==CaelumConstants.QUEST_MAIN_M00_THE_FOOL)
            key=CaelumJournalOverlay.GetQuestDetailStageKey(user,quest);
        else if(quest==CaelumConstants.QUEST_SEWERS)
            key=user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED?"CA_Q_SEWER_DONE":"CA_Q_SEWER_ACTIVE";
        else if(CaelumQuestCatalogue.IsRescue(quest))
            key=user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED?"CA_Q_RESCUE_DONE"
                :user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_FAILED?"CA_Q_RESCUE_DEAD":"CA_Q_RESCUE_ACTIVE";
        else if(quest==CaelumConstants.QUEST_PORT_SIEGE)
            key=user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED?"CA_DEMO_PORT_DONE":"CA_DEMO_PORT_ACTIVE";
        else if(CaelumSideQuestRules.IsDefined(quest))
            key=user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_FAILED?"CA_Q_SIDE_DETAIL_FAILED"
                :user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_ABANDONED?"CA_Q_SIDE_DETAIL_ABANDONED"
                :user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_COMPLETED?"CA_Q_SIDE_DETAIL_COMPLETE"
                :quest==CaelumConstants.QUEST_TRIAL_ROUTE?"CA_Q_SIDE_DETAIL_ROUTE":"CA_Q_SIDE_DETAIL_WAIT";
        else key="CA_Q_GUARD_CAPTAIN_DETAIL";
        String text=StringTable.Localize(key,false);
        text.Replace("%COUNT%",String.Format("%d",user.MainM00ConvincedCountSnapshot));
        text.Replace("%MAGIC_COUNT%",String.Format("%d",user.MainM00MagicPracticeSnapshot));
        text.Replace("%RUNES%",String.Format("%d",user.MainM00RuneSequenceSnapshot));
        text.Replace("%STARTER%",CaelumMainM00StarterRules.GetName(user.MainM00StarterOptionSnapshot));
        return text;
    }
    static clearscope bool Targets(CaelumPlayer user,int quest,CaelumKnownPoi fact)
    {
        return user!=null && fact!=null && quest>=0 && quest<CaelumConstants.QUEST_DEFINED_COUNT
            && user.JournalQuestState[quest]==CaelumConstants.QUEST_STATE_ACTIVE
            && quest==CaelumConstants.QUEST_MAIN_M00_THE_FOOL && fact.MapId==CaelumQuestTrackingData.MapId(quest)
            && CaelumQuestTrackingData.MatchesPoi(CaelumJournalOverlay.GetQuestDetailStageKey(user,quest),fact.PoiId);
    }
    // La marca nativa y el rótulo usan exactamente la misma etapa y conocimiento.
    static clearscope bool TrackedTarget(CaelumPlayer user,CaelumKnownPoi fact)
    {
        if(user==null || fact==null || fact.MapId!=level.MapName)return false;
        for(int quest=0;quest<CaelumConstants.QUEST_DEFINED_COUNT;quest++)
            if(CaelumQuestTracking.Active(user,quest) && Targets(user,quest,fact))return true;
        return false;
    }
    static String Location(CaelumPlayer user,int quest)
    {
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if(record==null || user.JournalQuestState[quest]!=CaelumConstants.QUEST_STATE_ACTIVE)return "";
        String places;
        for(int i=0;i<record.KnownPois.Size();i++)
            if(Targets(user,quest,record.KnownPois[i]))
            {
                if(places.Length()>0)places=places.."; ";
                places=places..StringTable.Localize(record.KnownPois[i].NameKey,false);
            }
        String map=CaelumQuestTrackingData.MapId(quest);
        int id=CaelumWorldCatalogue.LocationForMap(map);
        bool known=places.Length()>0 || (CaelumWorldCatalogue.IsLocation(id) && record.WorldLocationVisited[id]);
        if(!known)return StringTable.Localize("CA_TRACK_POSITION_UNKNOWN",false);
        String prefix=StringTable.Localize(map==level.MapName?"CA_TRACK_LOCAL":"CA_TRACK_OTHER_MAP",false);
        String name=StringTable.Localize(CaelumWorldCatalogue.LocationNameKey(id),false);
        return prefix..": "..name.." | "..(places.Length()>0?places:StringTable.Localize("CA_TRACK_POSITION_UNKNOWN",false));
    }
    static String Detail(CaelumPlayer user,int quest)
    {
        if(user.JournalQuestState[quest]!=CaelumConstants.QUEST_STATE_ACTIVE)
            return StringTable.Localize("CA_TRACK_FINISHED",false);
        return StringTable.Localize(CaelumQuestTracking.Selected(user,quest)?"CA_TRACK_SELECTED":"CA_TRACK_NOT_SELECTED",false)
            .."\n"..Location(user,quest);
    }
    static String FirstLine(Font font,String text,int width)
    {
        let lines=font.BreakLines(text,Max(1,width-font.StringWidth("...")));
        String result=lines.Count()>0?lines.StringAt(0):"";
        if(lines.Count()>1)result=result.."...";
        lines.Destroy();return result;
    }
    static void MapRows(CaelumPlayer user,Font font,int width,int budget,out Array<String> rows)
    {
        int total=0,shown=0;
        for(int q=0;q<CaelumConstants.QUEST_DEFINED_COUNT;q++)if(CaelumQuestTracking.Active(user,q))total++;
        if(total==0 || budget<=0)return;
        int capacity=total>budget/2?Max(0,(budget-1)/2):budget/2;
        for(int q=0;q<CaelumConstants.QUEST_DEFINED_COUNT;q++)if(CaelumQuestTracking.Active(user,q))
        {
            if(shown>=capacity)break;
            rows.Push(FirstLine(font,StringTable.Localize(CaelumQuestCatalogue.TitleKey(q),false)..": "..Objective(user,q),width));
            rows.Push(FirstLine(font,Location(user,q),width));
            budget-=2;shown++;
        }
        if(shown<total && budget>0)
            rows.Push(FirstLine(font,String.Format(StringTable.Localize("CA_TRACK_MORE",false),total-shown),width));
    }
}
