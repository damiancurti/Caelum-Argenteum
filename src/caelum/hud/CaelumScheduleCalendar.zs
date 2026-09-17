// Interfaz local: consultar fechas no adelanta ni reancla la campaña.
class CaelumScheduleCalendar : Object
{
    static ui int Setting(String nameText)
    {
        if (consoleplayer < 0) return 0;
        let value = CVar.GetCVar(nameText, players[consoleplayer]);
        return value == null ? 0 : value.GetInt();
    }
    static ui void Set(String nameText, int number)
    {
        if (consoleplayer < 0) return;
        let value = CVar.GetCVar(nameText, players[consoleplayer]);
        if (value != null) value.SetInt(number);
    }
    static ui bool IsOpen() { return Setting("ca_calendar_open") != 0; }
    static ui void Close() { Set("ca_calendar_open", 0); Set("ca_calendar_detail", 0); }
    static ui int Today(CaelumPlayer user)
    {
        let clock = CaelumWorldClock(user.FindInventory("CaelumWorldClock"));
        let calendar = CaelumCalendarState(user.FindInventory("CaelumCalendarState"));
        return clock == null || calendar == null ? -1 : calendar.DateSerial(clock);
    }
    static ui void Open(CaelumPlayer user)
    {
        int day = Today(user); if (day < 0) return;
        Set("ca_calendar_day", day); Set("ca_calendar_event", 0);
        Set("ca_calendar_detail", 0); Set("ca_calendar_open", 1);
    }
    static ui int SelectedDay(CaelumPlayer user)
    { return Clamp(Setting("ca_calendar_day"), 0, CaelumCalendarRules.MAX_SERIAL); }
    static clearscope int ShiftMonth(int serial, int direction)
    {
        int month = (CaelumCalendarRules.YearForSerial(serial) - 1) * 12
            + CaelumCalendarRules.MonthForSerial(serial) - 1;
        month = Clamp(month + direction, 0, 9999 * 12 - 1);
        int year = month / 12 + 1; month = month % 12 + 1;
        return CaelumCalendarRules.ToSerial(year, month, Min(CaelumCalendarRules.DayForSerial(serial),
            CaelumCalendarRules.DaysInMonth(year, month)));
    }
    static clearscope void EntriesForDay(CaelumScheduleState agenda, int day, out Array<CaelumScheduledEvent> result)
    {
        result.Clear(); if (agenda == null) return;
        for (int i = 0; i < agenda.Events.Size(); i++)
        {
            let entry = agenda.Events[i];
            if (!entry.Visible || entry.FirstIndexOnDay(day) < 0) continue;
            result.Push(entry);
            // Las series se muestran ordenadas por su primera hora en el día.
            for (int j = result.Size() - 1; j > 0; j--)
            {
                let a = result[j-1]; let b = result[j];
                if (a.OccurrenceStamp(a.FirstIndexOnDay(day)) <= b.OccurrenceStamp(b.FirstIndexOnDay(day))) break;
                result[j-1] = b; result[j] = a;
            }
        }
    }
    static clearscope int CountOnDay(CaelumScheduleState agenda, int day)
    {
        int count = 0; if (agenda == null) return 0;
        for (int i = 0; i < agenda.Events.Size(); i++)
            if (agenda.Events[i].Visible && agenda.Events[i].FirstIndexOnDay(day) >= 0) count++;
        return count;
    }
    static ui bool Input(InputEvent e, CaelumPlayer user)
    {
        if (!IsOpen()) return false;
        if (e.Type == InputEvent.Type_KeyUp) return !(Bindings.GetBinding(e.KeyScan) ~== "+use");
        if (e.Type != InputEvent.Type_KeyDown) return false;
        bool detail = Setting("ca_calendar_detail") != 0;
        if (e.KeyScan == InputEvent.Key_Escape || e.KeyScan == InputEvent.Key_Pad_B
            || e.KeyString ~== "q" || e.KeyString ~== "f")
        {
            if (detail) Set("ca_calendar_detail", 0); else Close();
            return true;
        }
        if (e.KeyScan == InputEvent.Key_Tab) { Close(); return false; }
        int day = SelectedDay(user), newDay = day;
        if (!detail)
        {
            if (e.KeyScan == InputEvent.Key_LeftArrow || e.KeyScan == InputEvent.Key_Pad_DPad_Left) newDay--;
            if (e.KeyScan == InputEvent.Key_RightArrow || e.KeyScan == InputEvent.Key_Pad_DPad_Right) newDay++;
            if (e.KeyScan == InputEvent.Key_UpArrow || e.KeyScan == InputEvent.Key_Pad_DPad_Up) newDay -= 7;
            if (e.KeyScan == InputEvent.Key_DownArrow || e.KeyScan == InputEvent.Key_Pad_DPad_Down) newDay += 7;
            if (e.KeyScan == InputEvent.Key_PgUp || e.KeyScan == InputEvent.Key_Pad_LShoulder) newDay = ShiftMonth(day, -1);
            if (e.KeyScan == InputEvent.Key_PgDn || e.KeyScan == InputEvent.Key_Pad_RShoulder) newDay = ShiftMonth(day, 1);
            if (e.KeyString ~== "h" || e.KeyScan == InputEvent.Key_Home) newDay = Today(user);
        }
        if (newDay != day)
        {
            Set("ca_calendar_day", Clamp(newDay, 0, CaelumCalendarRules.MAX_SERIAL));
            Set("ca_calendar_event", 0); return true;
        }
        let agenda = CaelumScheduleState(user.FindInventory("CaelumScheduleState"));
        Array<CaelumScheduledEvent> entries; EntriesForDay(agenda, day, entries);
        int count = entries.Size(); if (count == 0) return true;
        int selected = Clamp(Setting("ca_calendar_event"), 0, count - 1);
        if (e.KeyString ~== "e" || e.KeyScan == InputEvent.Key_Pad_Y) selected = (selected + 1) % count;
        if (e.KeyString ~== "r" || e.KeyScan == InputEvent.Key_Pad_X) selected = (selected + count - 1) % count;
        Set("ca_calendar_event", selected);
        if (e.KeyScan == InputEvent.Key_Enter || e.KeyScan == InputEvent.Key_Pad_A)
            Set("ca_calendar_detail", detail ? 0 : 1);
        if (detail && (e.KeyString ~== "p" || e.KeyScan == InputEvent.Key_Pad_RTrigger))
            EventHandler.SendNetworkEvent("ca_event_action", entries[selected].EventId);
        return true;
    }
    static ui String Clip(Font font, String value, int width)
    {
        if (font.StringWidth(value) <= width) return value;
        let lines = font.BreakLines(value, width - font.StringWidth("..."));
        String result = lines.Count() > 0 ? lines.StringAt(0) .. "..." : "...";
        lines.Destroy(); return result;
    }
    static ui void Draw(CaelumJournalOverlay view, CaelumPlayer user)
    {
        Screen.Dim(0x05070A, 0.94, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        view.DrawPanel(16, 12, 608, 336);
        view.DrawCenteredText(view.TitleFont, Font.CR_GOLD, 320, 22, StringTable.Localize("CA_AGENDA_TITLE", false));
        int day = SelectedDay(user), today = Today(user);
        let clock = CaelumWorldClock(user.FindInventory("CaelumWorldClock"));
        let calendar = CaelumCalendarState(user.FindInventory("CaelumCalendarState"));
        view.DrawCenteredText(view.SmallFont, Font.CR_CYAN, 320, 60,
            calendar == null || clock == null ? "-" : calendar.FormatDate(clock));
        let agenda = CaelumScheduleState(user.FindInventory("CaelumScheduleState"));
        Array<CaelumScheduledEvent> entries; EntriesForDay(agenda, day, entries);
        int selected = Clamp(Setting("ca_calendar_event"), 0, Max(0, int(entries.Size()) - 1));
        if (Setting("ca_calendar_detail") != 0 && entries.Size() > 0)
        { DrawDetail(view, entries[selected]); return; }
        int year = CaelumCalendarRules.YearForSerial(day), month = CaelumCalendarRules.MonthForSerial(day);
        int first = CaelumCalendarRules.ToSerial(year, month, 1);
        int length = CaelumCalendarRules.DaysInMonth(year, month);
        view.DrawCenteredText(view.TextFont, Font.CR_GOLD, 183, 86,
            String.Format("%s %04d", StringTable.Localize(String.Format("CA_MONTH_%02d", month), false), year));
        for (int column = 0; column < 7; column++)
            view.DrawCenteredText(view.SmallFont, Font.CR_GRAY, 63 + column * 40, 112,
                StringTable.Localize(String.Format("CA_WEEK_%d", column), false));
        for (int number = 1; number <= length; number++)
        {
            int serial = first + number - 1, cell = first % 7 + number - 1;
            double x = 63 + (cell % 7) * 40, y = 133 + (cell / 7) * 24;
            int color = serial == day ? Font.CR_GOLD : serial == today ? Font.CR_CYAN : Font.CR_WHITE;
            view.DrawCenteredText(view.SmallFont, color, x, y,
                String.Format(serial == day ? "[%d]" : "%d", number));
            int marks = CountOnDay(agenda, serial);
            if (marks > 0) view.DrawCenteredText(view.SmallFont, Font.CR_GREEN, x, y + 10,
                String.Format("+%d", marks));
        }
        view.DrawTextLine(view.SmallFont, Font.CR_GRAY, 359, 89,
            String.Format("%02d/%02d/%04d  (%d)", CaelumCalendarRules.DayForSerial(day), month, year, entries.Size()));
        if (entries.Size() == 0) view.DrawParagraph(view.SmallFont, Font.CR_GRAY, 359, 122, 239,
            StringTable.Localize("CA_AGENDA_EMPTY", false));
        int offset = selected / 5 * 5;
        for (int row = 0; row < 5 && row + offset < int(entries.Size()); row++)
        {
            let entry = entries[row + offset]; int index = entry.FirstIndexOnDay(day);
            double stamp = entry.OccurrenceStamp(index);
            int minutes = int((stamp - CaelumScheduleRules.Stamp(day, 0)) * 60 / CaelumWorldClock.TicsPerHour());
            int color = row + offset == selected ? Font.CR_GOLD : Font.CR_WHITE;
            view.DrawTextLine(view.SmallFont, color, 359, 117 + row * 32,
                Clip(view.SmallFont, String.Format("%s %02d:%02d %s", row + offset == selected ? ">" : " ",
                    minutes / 60, minutes % 60, StringTable.Localize(entry.TitleKey, false)), 239));
            view.DrawTextLine(view.SmallFont, Font.CR_GRAY, 367, 129 + row * 32,
                Clip(view.SmallFont, String.Format("%s | %s", StringTable.Localize(CaelumScheduleRules.KindKey(entry.Kind), false),
                    StringTable.Localize(index < entry.Processed ? "CA_EVENT_OCCURRED" : "CA_EVENT_PLANNED", false)), 231));
        }
        view.DrawCenteredText(view.SmallFont, Font.CR_GRAY, 320, 280, StringTable.Localize("CA_AGENDA_LEGEND", false));
        view.DrawCenteredText(view.SmallFont, Font.CR_GRAY, 320, 301, StringTable.Localize("CA_AGENDA_HELP", false));
        view.DrawCenteredText(view.SmallFont, Font.CR_GRAY, 320, 319, StringTable.Localize("CA_AGENDA_HELP2", false));
    }
    static ui void DrawDetail(CaelumJournalOverlay view, CaelumScheduledEvent entry)
    {
        view.DrawCenteredText(view.TextFont, Font.CR_GOLD, 320, 89,
            Clip(view.TextFont, StringTable.Localize(entry.TitleKey, false), 548));
        view.DrawTextLine(view.SmallFont, Font.CR_WHITE, 48, 121, String.Format("%s | %s | %s",
            StringTable.Localize(CaelumScheduleRules.KindKey(entry.Kind), false), entry.MapName,
            StringTable.Localize(entry.StatusKey(), false)));
        view.DrawTextLine(view.SmallFont, Font.CR_WHITE, 48, 144, String.Format(StringTable.Localize("CA_AGENDA_FIRST", false),
            CaelumScheduleRules.DateText(entry.FirstStamp())));
        view.DrawTextLine(view.SmallFont, Font.CR_WHITE, 48, 163, String.Format(StringTable.Localize("CA_AGENDA_NEXT", false),
            CaelumScheduleRules.DateText(entry.NextStamp())));
        view.DrawTextLine(view.SmallFont, Font.CR_GRAY, 48, 182, String.Format(StringTable.Localize("CA_AGENDA_REPEAT", false),
            entry.RepeatMinutes, entry.Processed));
        String info = StringTable.Localize("CA_AGENDA_NOTICE_INFO", false);
        if (entry.Kind == CaelumScheduleRules.RENT) info = String.Format(StringTable.Localize("CA_AGENDA_RENT_INFO", false), entry.Value, entry.Debt());
        else if (entry.Kind == CaelumScheduleRules.SHIPMENT) info = String.Format(StringTable.Localize("CA_AGENDA_CARGO_INFO", false),
            entry.Value, StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL, entry.CargoMaterial), false), entry.CargoTier, entry.OriginMap, entry.MapName);
        else if (entry.Kind == CaelumScheduleRules.REGROWTH) info = String.Format(StringTable.Localize("CA_AGENDA_RESOURCE_INFO", false), StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL, entry.Value), false));
        else if (entry.Kind == CaelumScheduleRules.ROUTINE) info = StringTable.Localize("CA_AGENDA_ROUTINE_INFO", false);
        else if (entry.Kind == CaelumScheduleRules.SIEGE) info = StringTable.Localize("CA_AGENDA_SIEGE_INFO", false);
        else if (entry.Kind == CaelumScheduleRules.QUEST) info = StringTable.Localize("CA_AGENDA_QUEST_INFO", false);
        view.DrawParagraph(view.SmallFont, Font.CR_WHITE, 48, 210, 544, info);
        if (entry.Trial) view.DrawCenteredText(view.SmallFont, Font.CR_ORANGE, 320, 282, StringTable.Localize("CA_AGENDA_TRIAL", false));
        String actionKey = entry.Kind == CaelumScheduleRules.RENT ? "CA_AGENDA_PAY"
            : entry.Kind == CaelumScheduleRules.SHIPMENT ? "CA_AGENDA_COLLECT" : "CA_AGENDA_NO_ACTION";
        view.DrawCenteredText(view.SmallFont, Font.CR_GOLD, 320, 303, StringTable.Localize(actionKey, false));
        view.DrawCenteredText(view.SmallFont, Font.CR_GRAY, 320, 324, StringTable.Localize("CA_AGENDA_DETAIL_HELP", false));
    }
}
