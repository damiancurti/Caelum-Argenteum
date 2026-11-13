// Generado desde MODULES.json; no cambia identidad ni equipo del dueño.
class CaelumDomingoModules : Object
{
    const COUNT=7;
    const CLOTHING=0;
    const ARMOR=1;
    const CAPE=2;
    const FACE=3;
    const HAIR=4;
    const WEAPON=5;
    const SHIELD=6;
    static play void SetVisible(Actor body,int slot,bool visible)
    {
        static const name files[]={'clothing.md3','armor.md3','cape.md3','face.md3','hair.md3','weapon.md3','shield.md3'};
        if(body==null || slot<0 || slot>=COUNT)return;
        body.A_ChangeModel('None',slot,"models/caelum/characters/domingo",files[slot],slot,"models/caelum/characters/domingo",'domingo_skin.png',visible?0:CMDL_HIDEMODEL);
    }
}
