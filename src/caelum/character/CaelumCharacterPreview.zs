/*
** State stepping / sprite drawing adapted from GZDoom playerdisplay.zs
** The player display for the player setup and class selection screen
**
**---------------------------------------------------------------------------
** Copyright 2010-2017 Christoph Oelckers
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** 1. Redistributions of source code must retain the above copyright
**    notice, this list of conditions and the following disclaimer.
** 2. Redistributions in binary form must reproduce the above copyright
**    notice, this list of conditions and the following disclaimer in the
**    documentation and/or other materials provided with the distribution.
** 3. The name of the author may not be used to endorse or promote products
**    derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
** IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
** OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
** IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
** NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
** THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**---------------------------------------------------------------------------
**
*/

// #148: el visor usa la misma API que ListMenuItemPlayerDisplay de GZDoom.
// Sólo recorre estados y dibuja texturas: no crea actores ni ejecuta acciones.
class CaelumCharacterPreview : Object ui
{
    State Frame;
    int FrameTics;
    int Rotation;
    bool Walking;
    bool Gloved;
    int Race, Sex, SkinTone, BeastForm;
    int Face, HairStyle, HairColor;
    double ActorHeight;

    void Reset()
    {
        let body=GetDefaultByType("CaelumPlayer");
        Frame=Walking ? body.SeeState : body.SpawnState;
        FrameTics=Frame==null ? 0 : Frame.Tics;
    }

    void Tick()
    {
        if(Frame==null)Reset();
        if(Frame!=null && Frame.Tics!=-1 && Frame.NextState!=null && --FrameTics<=0)
        {
            Frame=Frame.NextState;
            FrameTics=Frame.Tics;
        }
    }

    void Turn(int direction) { Rotation=(Rotation+direction+8)%8; }
    void ToggleWalking() { Walking=!Walking;Reset(); }

    void Draw(double centerX,double floorY,double zoom)
    {
        if(Frame==null)Reset();
        if(Frame==null)return;
        let body=GetDefaultByType("CaelumPlayer");
        TextureID texture; bool flip; Vector2 scale;
        int pose=CaelumAppearance.PoseFor(Frame.sprite,Frame.Frame);
        int visual=CaelumAppearance.SpriteFor(Race,Sex,BeastForm,SkinTone,pose,Gloved);
        if(visual<0)return;
        [texture,flip,scale]=Frame.GetSpriteTexture(Rotation*2,0,
            CaelumAppearance.ScaleFor(Race,Sex,BeastForm,ActorHeight>0?ActorHeight:body.Height,Gloved),visual,pose%26);
        if(!texture.IsValid())return;
        let size=TexMan.GetScaledSize(texture);
        // La escala corporal es la misma del mundo; el zoom sólo encuadra el visor.
        double pixels=Screen.GetHeight()/600.0;
        Screen.DrawTexture(texture,false,centerX*pixels,floorY*pixels,
            DTA_DestWidthF,size.X*scale.X*zoom*pixels,
            DTA_DestHeightF,size.Y*scale.Y*zoom*pixels,DTA_FlipX,flip);
        int head=CaelumAppearance.HeadSprite(Race,Sex,SkinTone,Face,HairStyle,HairColor);
        if(head<0)return;
        int group;Vector2 displacement;
        [group,displacement]=CaelumAppearanceDetailsRegistry.Anchor(Sex,Gloved,pose);
        [texture,flip,scale]=Frame.GetSpriteTexture(Rotation*2,0,scale,head,group);
        if(!texture.IsValid())return;
        size=TexMan.GetScaledSize(texture);
        Screen.DrawTexture(texture,false,(centerX+displacement.X*scale.X*zoom)*pixels,
            (floorY+displacement.Y*scale.Y*zoom)*pixels,
            DTA_DestWidthF,size.X*scale.X*zoom*pixels,
            DTA_DestHeightF,size.Y*scale.Y*zoom*pixels,DTA_FlipX,flip);
    }
}
