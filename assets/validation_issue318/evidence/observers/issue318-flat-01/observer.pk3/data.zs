class CA318FlatData : Object {
const MANDINGAS=6000;
const SOLDIERS=1000;
const COLUMNS=100;
const SPACING=48;
const FRONT_X=64;
const YAW=133;
const PITCH=25;
static vector3 Camera(){return (6500,-8500,5000);}
static vector3 Position(int side,int i){return ((side==0?-1:1)*(FRONT_X+(i/COLUMNS)*SPACING),(i%COLUMNS-(COLUMNS-1)/2.0)*SPACING,0);}
}
