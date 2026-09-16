// Use recorre actores en planta. Cada interacción nueva comprueba también
// la altura y la dirección de la mirada antes de quedarse con la pulsación.
class CaelumUseGeometry : Object play
{
    static bool AimedAt(CaelumPlayer user, Actor object)
    {
        if (user == null || user.player == null || object == null) return false;
        vector3 start = user.Pos + (0, 0, user.ViewHeight);
        vector3 direction = (Cos(user.Angle)*Cos(user.Pitch),
            Sin(user.Angle)*Cos(user.Pitch), -Sin(user.Pitch));
        vector2 offset = start.XY-object.Pos.XY;
        double near = 0;
        double far = Max(1.0, user.UseRange);
        double a = direction.X*direction.X+direction.Y*direction.Y;
        double c = offset.X*offset.X+offset.Y*offset.Y-object.Radius*object.Radius;
        if (a < 0.000001) { if (c > 0) return false; }
        else
        {
            double b = offset.X*direction.X+offset.Y*direction.Y;
            double discriminant = b*b-a*c;
            if (discriminant < 0) return false;
            double root = Sqrt(discriminant);
            near = Max(near, (-b-root)/a);
            far = Min(far, (-b+root)/a);
        }
        if (Abs(direction.Z) < 0.000001)
        {
            if (start.Z < object.Pos.Z || start.Z > object.Pos.Z+object.Height) return false;
        }
        else
        {
            double bottom = (object.Pos.Z-start.Z)/direction.Z;
            double top = (object.Pos.Z+object.Height-start.Z)/direction.Z;
            near = Max(near, Min(bottom, top));
            far = Min(far, Max(bottom, top));
        }
        return far >= near;
    }
}
