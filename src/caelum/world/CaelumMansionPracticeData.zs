// Datos generados desde assets/map01_mansion/PRACTICE.json.
class CaelumMansionPracticeData : Object
{
    static vector3 Position() { return (368,480,0); }
    static bool Contains(vector3 position)
    {
        return position.X > 40 && position.X < 696
            && position.Y > 88 && position.Y < 628
            && Abs(position.Z - 0) < 48;
    }
}
