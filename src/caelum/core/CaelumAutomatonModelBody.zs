// Apariencia mecánica; el control de combate se integra por separado.
class CaelumAutomatonModelBody : Actor
{
    Default { Radius 26.666667; Height 93.333333; RenderRadius 112; +NOINTERACTION +NOGRAVITY }
    States
    {
    Spawn:
        Goto Inactive;
    Inactive:
    F0:
        TAM0 A -1;
        Stop;
    Idle:
    F1:
        TAM0 B -1;
        Stop;
    Walk:
    F2:
        TAM0 C 4;
    F3:
        TAM0 D 4;
    F4:
        TAM0 E 4;
    F5:
        TAM0 F 4;
    F6:
        TAM0 G 4;
    F7:
        TAM0 H 4;
    F8:
        TAM0 I 4;
    F9:
        TAM0 J 4;
        Goto Walk;
    Attack:
    F10:
        TAM0 K 2;
    F11:
        TAM0 L 2;
    F12:
        TAM0 M 2;
    F13:
        TAM0 N 2;
    F14:
        TAM0 O 2;
    F15:
        TAM0 P -1;
        Stop;
    Guard:
    F16:
        TAM0 Q -1;
        Stop;
    Fallen:
    F17:
        TAM0 R 5;
    F18:
        TAM0 S 5;
    F19:
        TAM0 T -1;
        Stop;
    }
}
