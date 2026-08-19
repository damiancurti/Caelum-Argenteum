// Clase base para objetos de escenario que pueden desplazarse por fuerza física.
// Las subclases aportan sprite, dimensiones, masa y cualquier sonido propio.
class CaelumMovableProp : Actor
{
    // args[0] expresa el requisito como PhysicalPushMultiplier × 100.
    // Ejemplo de formato técnico: 150 representa un multiplicador 1.50.
    // Un valor <= 0 se considera sin configurar y bloquea el movimiento.
    double GetRequiredPhysicalPower()
    {
        if (args[0] <= 0) { return -1.0; }
        return args[0] / 100.0;
    }

    bool CanBePushedWith(double physicalPower)
    {
        double requiredPower = GetRequiredPhysicalPower();
        return requiredPower > 0.0
            && Max(0.0, physicalPower) >= requiredPower;
    }

    // Aplica un único impulso reutilizando la potencia física calculada por el
    // jugador. No modifica la fórmula ni crea una segunda estadística de fuerza.
    bool TryPushFrom(Actor pusher, double physicalPower, double pushForce)
    {
        if (pusher == null || !CanBePushedWith(physicalPower))
        {
            return false;
        }

        double pushAngle = VectorAngle(
            Pos.X - pusher.Pos.X,
            Pos.Y - pusher.Pos.Y
        );
        Thrust(Max(0.0, pushForce), pushAngle);
        return true;
    }

    Default
    {
        +SOLID
        +SHOOTABLE
        +INVULNERABLE
        -PUSHABLE
        Gravity 1.0;
    }
}
