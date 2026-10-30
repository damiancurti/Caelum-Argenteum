// Perfil físico civil reutilizado del comerciante; no posee una tienda ni facción.
class CaelumRentalAgent : Actor
{
    static play bool ValidSpeaker(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || !user.HasActiveConversation()
            || user.player.ConversationPC!=user)return false;
        let speaker=CaelumRentalAgent(user.player.ConversationNPC);
        return speaker!=null && speaker.health>0
            && user.Distance3D(speaker)<=CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE && user.CheckSight(speaker);
    }
    static play void Guard(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.HasActiveConversation()
            || !(user.player.ConversationNPC is "CaelumRentalAgent") || ValidSpeaker(user))return;
        let speaker=user.player.ConversationNPC;speaker.bInConversation=false;
        if(user.player.ConversationFaceTalker)speaker.Angle=user.player.ConversationNPCAngle;
        user.player.ConversationNPC=null;user.player.ConversationPC=null;
    }
    static play void Sync(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        int quest=CaelumConstants.QUEST_FIND_HOUSE;
        user.SetPalomoDialogueToken("CaelumHouseRecognizedToken",record.QuestState[quest]==CaelumConstants.QUEST_STATE_ACTIVE
            && record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]==CaelumConstants.QUEST_STATE_COMPLETED);
        user.SetPalomoDialogueToken("CaelumHouseRestoredToken",record.HouseRestitutionConfirmed);
        let property=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE);
        user.SetPalomoDialogueToken("CaelumHouseContractToken",CaelumPropertyRules.Holds(user,property)
            && (property.Purchased || property.RentPayments>0));
        user.SetPalomoDialogueToken("CaelumHouseAbandonedToken",record.QuestState[quest]==CaelumConstants.QUEST_STATE_ABANDONED);
    }
    static play bool Open(CaelumPlayer user,CaelumRentalAgent agent)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || agent==null || !CaelumUseGeometry.AimedAt(user,agent))return false;
        // Los enlaces de página se resuelven al abrir la conversación nativa.
        Sync(user);
        if(!CaelumFactionCondition.OpenDialogue(user,agent,CaelumPortQuestData.RENTAL_CONVERSATION))return false;
        let record=user.GetPersistentCharacterState(false);
        if(record!=null && record.QuestState[CaelumConstants.QUEST_FIND_HOUSE]==CaelumConstants.QUEST_STATE_UNDISCOVERED)
            CaelumPortQuests.Begin(user,CaelumConstants.QUEST_FIND_HOUSE);
        Sync(user);return true;
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || !CaelumUseGeometry.AimedAt(user,self))return false;
        if((user.player.cmd.buttons&BT_USE)==0 || user.FolkloreInteractionUseLatched)return true;
        user.FolkloreInteractionUseLatched=true;user.FolkloreInteractionReleaseGuardTics=0;
        return Open(user,self);
    }
    Default
    {
        Radius 16; Height 57.6; Health 100; Scale 0.409091;
        +SOLID +USESPECIAL +INVULNERABLE +NOTARGET
        Tag "$CA_RENTAL_AGENT";
    }
    States { Spawn: DOID A -1; Stop; }
}
class CaelumHouseRecognizedToken : CaelumPalomoDialogueMarker {}
class CaelumHouseRestoredToken : CaelumPalomoDialogueMarker {}
class CaelumHouseAbandonedToken : CaelumPalomoDialogueMarker {}
class CaelumHouseContractToken : CaelumPalomoDialogueMarker {}
class CaelumHouseVerifyAction : CaelumPalomoDialogueAction
{ override bool Use(bool pickup){return CaelumPortQuests.VerifyHouse(CaelumPlayer(Owner));} }
class CaelumHouseResumeAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);if(!CaelumRentalAgent.ValidSpeaker(user))return false;
        bool result=CaelumPortQuests.Begin(user,CaelumConstants.QUEST_FIND_HOUSE);CaelumRentalAgent.Sync(user);return result;
    }
}
class CaelumRentalMenu : CaelumPortConversationMenu
{
    override void FormatSpeakerMessage()
    {
        let user=mPlayer==null?null:CaelumPlayer(mPlayer.mo);
        if(mCurNode!=null && mCurNode.UserData~=="rental_offer" && user!=null
            && user.FindInventory("CaelumHouseContractToken")!=null)
        {
            mDialogueLines=displayFont.BreakLines(StringTable.Localize("CA_RENTAL_EXISTING",false),SpeechWidth);return;
        }
        if(mCurNode!=null && mCurNode.UserData~=="rental_restored")
        {
            let record=History();String text=StringTable.Localize("CA_RENTAL_RESTORED",false);
            if(record!=null)text=text.."\n\n"..StringTable.Localize(record.HouseRefundPending>0
                ?"CA_RENTAL_REFUND_PENDING":"CA_RENTAL_REFUND_DONE",false);
            if(record!=null)text.Replace("%COPPER%",String.Format("%d",record.HouseRefundPending));
            mDialogueLines=displayFont.BreakLines(text,SpeechWidth);return;
        }
        Super.FormatSpeakerMessage();
    }
}
