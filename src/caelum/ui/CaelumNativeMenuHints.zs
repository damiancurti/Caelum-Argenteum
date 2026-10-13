// Decorar solo durante Drawer: las acciones, la busqueda y los titulos
// editables siempre conservan sus valores originales entre cuadros.
class CaelumNativeMenuHints : Object ui
{
    Array<OptionMenuItem> Items;
    Array<String> Originals;
    static String Hint(OptionMenuItem item)
    {
        if(item is "OptionMenuItemControlBase")
            return CaelumInputHints.KeyName(InputEvent.Key_Enter).."/"..CaelumInputHints.KeyName(InputEvent.Key_Backspace);
        if(item is "OptionMenuSliderBase" || item is "OptionMenuItemOptionBase" || item is "OptionMenuItemNumberField"
            || item is "OptionMenuItemScreenResolution")
            return CaelumInputHints.KeyName(InputEvent.Key_LeftArrow).."/"..CaelumInputHints.KeyName(InputEvent.Key_RightArrow);
        return CaelumInputHints.KeyName(InputEvent.Key_Enter);
    }
    static CaelumNativeMenuHints Begin(OptionMenuDescriptor desc)
    {
        let pass=new("CaelumNativeMenuHints");
        for(int i=0;i<desc.mItems.Size();i++)
        {
            let item=desc.mItems[i];
            if(item==null || !item.Selectable() || item is "OptionMenuItemStaticText" || item is "OptionMenuItemStaticTextSwitchable")continue;
            pass.Items.Push(item);pass.Originals.Push(item.mLabel);
            item.mLabel=CaelumInputHints.Label(StringTable.Localize(item.mLabel),Hint(item));
        }
        desc.mIndent=0;desc.CalcIndent();
        return pass;
    }
    void End()
    {
        for(int i=0;i<Items.Size();i++)Items[i].mLabel=Originals[i];
        Destroy();
    }
    // Recorre los destinos reales: conserva las clases especializadas del motor.
    static void Install()
    {
        Array<Name> names;
        names.Push('MainMenu');names.Push('OptionsMenu');names.Push('OptionsMenuSimple');names.Push('Colorpickermenu');
        names.Push('JoystickConfigMenu');names.Push('ReverbEdit');names.Push('ReverbSelect');names.Push('ReverbSave');
        names.Push('VideoModeMenu');
        for(int n=0;n<names.Size();n++)
        {
            let desc=MenuDescriptor.GetDescriptor(names[n]);if(desc==null)continue;
            let options=OptionMenuDescriptor(desc);let list=ListMenuDescriptor(desc);
            int count=options!=null?options.mItems.Size():list!=null?list.mItems.Size():0;
            for(int i=0;i<count;i++)
            {
                Name destination=options!=null?options.mItems[i].GetAction():list.mItems[i].GetAction();
                bool seen=false;for(int j=0;j<names.Size();j++)if(names[j]==destination){seen=true;break;}
                if(!seen && destination!='None')names.Push(destination);
            }
            if(options!=null)
            {
                if(names[n]=='Colorpickermenu' && desc.mClass==null)desc.mClass="CaelumHintColorpickerMenu";
                else if(desc.mClass==null || desc.mClass=="OptionMenu")desc.mClass="CaelumHintOptionMenu";
                else if(desc.mClass=="GLTextureGLOptions")desc.mClass="CaelumHintGLTextureGLOptions";
                else if(desc.mClass=="JoystickConfigMenu")desc.mClass="CaelumHintJoystickConfigMenu";
                else if(desc.mClass=="GameplayMenu")desc.mClass="CaelumHintGameplayMenu";
                else if(desc.mClass=="CompatibilityMenu")desc.mClass="CaelumHintCompatibilityMenu";
                else if(desc.mClass=="VideoModeMenu")desc.mClass="CaelumHintVideoModeMenu";
                else if(desc.mClass=="ColorpickerMenu")desc.mClass="CaelumHintColorpickerMenu";
                else if(desc.mClass=="ReverbEdit")desc.mClass="CaelumHintReverbEdit";
                else if(desc.mClass=="ReverbSelect")desc.mClass="CaelumHintReverbSelect";
                else if(desc.mClass=="ReverbSave")desc.mClass="CaelumHintReverbSave";
                else if(desc.mClass=="os_Menu")desc.mClass="CaelumHintos_Menu";
            }
            else if(list!=null)
            {
                if(desc.mClass==null || desc.mClass=="ListMenu")desc.mClass="CaelumHintListMenu";
                else if(desc.mClass=="LoadMenu")desc.mClass="CaelumHintLoadMenu";
                else if(desc.mClass=="SaveMenu")desc.mClass="CaelumHintSaveMenu";
            }
        }
    }
    static void SavedRows(LoadSaveMenu menu)
    {
        for(int row=0;row<menu.listboxRows && menu.TopItem+row<menu.manager.SavegameCount();row++)
        {
            int index=menu.TopItem+row;if(index==menu.Selected && menu.mEntering)continue;
            let node=menu.manager.GetSavegame(index);
            String label=CaelumInputHints.Fixed(node.SaveTitle,InputEvent.Key_Enter);
            double scale=Min(menu.FontScale,(menu.listboxWidth-4.0)/Max(1,NewConsoleFont.StringWidth(label)));
            int x=menu.listboxLeft+1,y=menu.listboxTop+menu.rowHeight*row;
            Screen.Clear(x,y,menu.listboxRight-1,y+menu.rowHeight,index==menu.Selected?Color(255,0,0,255):Color(255,0,0,0));
            int color=node.bOldVersion?Font.CR_RED:node.bMissingWads?Font.CR_YELLOW:index==menu.Selected?Font.CR_WHITE:Font.CR_TAN;
            Screen.DrawText(NewConsoleFont,color,x,y+1,label,DTA_SCALEX,scale,DTA_SCALEY,scale);
        }
    }
}

class CaelumHintListMenu : ListMenu
{
    override void Drawer()
    {
        Array<ListMenuItemTextItem> items;Array<String> originals;
        for(int i=0;i<mDesc.mItems.Size();i++)
        {
            let item=ListMenuItemTextItem(mDesc.mItems[i]);if(item==null || !item.Selectable())continue;
            items.Push(item);originals.Push(item.mText);
            item.mText=CaelumInputHints.Fixed(StringTable.Localize(item.mText),InputEvent.Key_Enter);
        }
        Super.Drawer();
        for(int i=0;i<items.Size();i++)items[i].mText=originals[i];
    }
}
class CaelumHintLoadMenu : LoadMenu
{override void Drawer(){Super.Drawer();CaelumNativeMenuHints.SavedRows(self);}}
class CaelumHintSaveMenu : SaveMenu
{override void Drawer(){Super.Drawer();CaelumNativeMenuHints.SavedRows(self);}}

class CaelumHintOptionMenu : OptionMenu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintGLTextureGLOptions : GLTextureGLOptions
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintJoystickConfigMenu : JoystickConfigMenu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintGameplayMenu : GameplayMenu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintCompatibilityMenu : CompatibilityMenu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintVideoModeMenu : VideoModeMenu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintColorpickerMenu : ColorpickerMenu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintReverbEdit : ReverbEdit
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintReverbSelect : ReverbSelect
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintReverbSave : ReverbSave
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}

class CaelumHintos_Menu : os_Menu
{
    override void Drawer()
    {let pass=CaelumNativeMenuHints.Begin(mDesc);Super.Drawer();pass.End();}
}
