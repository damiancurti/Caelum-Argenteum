// Sólo enlaces a lugares ya escritos en los objetivos vigentes. No coordenadas
// nuevas ni destinos para secretos, enemigos, llaves o etapas futuras.
class CaelumQuestTrackingData : Object
{
    const REVISION = 1;
    // Reutiliza el símbolo propio de objetivos; tamaño sólo de presentación.
    static String MarkerIcon()
    {return "graphics/caelum/ui/hud/icons/ca_hud_combat_affected_targets.png";}
    static double MarkerSize()
    {return CaelumPoiData.ICON_SIZE+CaelumCartographyLayout.PADDING;}
    static String MapId(int quest)
    {
        if(quest==CaelumConstants.QUEST_MAIN_M00_THE_FOOL)return "MAP01";
        if(quest==CaelumConstants.QUEST_SEWERS || CaelumQuestCatalogue.IsRescue(quest))return "MAP02";
        if(quest==CaelumConstants.QUEST_PORT_SIEGE || CaelumPortQuestData.Defined(quest))return "MAP03";
        return "";
    }
    // La clave es la misma que el Diario eligió para la etapa actual.
    // LANGUAGE: indicaciones explícitas de habitación/planta o banco de Ronnie.
    static bool MatchesPoi(String stage,String poi)
    {
        if(stage=="CA_Q_DETAIL_M01_ARGENTO" || stage=="CA_Q_DETAIL_M01_RETURN_ARGENTO")
            return poi=="mansion-room-bedroom-argento";
        if(stage=="CA_Q_DETAIL_M01_CAELLA" || stage=="CA_Q_DETAIL_M01_RETURN_CAELLA")
            return poi=="mansion-room-bedroom-caella";
        if(stage=="CA_Q_DETAIL_M01_RONNIE")
            return poi=="mansion-room-bedroom-ronnie" || poi=="mansion-room-upper-workshop";
        if(stage=="CA_M01_DETAIL_READY")return poi=="mansion-room-bedroom-ronnie";
        if(stage=="CA_M01_RULO_DETAIL_OFFER")return poi=="mansion-room-bedroom-rulo";
        if(stage=="CA_M01_RULO_DETAIL_PRACTICE")return poi=="mansion-room-practice";
        if(stage=="CA_M01_RULO_DETAIL_DONE")return poi=="mansion-room-upper-workshop";
        if(stage=="CA_M01_DETAIL_GATHER")
            return poi=="mansion-station-2-4" || poi=="mansion-room-upper-workshop";
        return false;
    }
}
