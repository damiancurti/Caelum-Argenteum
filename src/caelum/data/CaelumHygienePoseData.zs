// #502: superficies derivadas del modelo existente a 32 MU/m.
class CaelumHygienePoseData : Object
{
    const REVISION=1;
    // Superficies del modelo existente: asiento .52 m y fondo de bañera .22 m.
    const TOILET_SUPPORT=16.64;
    const TUB_SUPPORT=7.04;
    // Cámara del mobiliario de descanso; posición centrada sobre el sanitario.
    const SEATED_OFFSET=0.0;
    const CAMERA_MIN_DISTANCE=112.0;
    const CAMERA_HEIGHT_FACTOR=2.4;
    const SEATED_CAMERA_YAW=35.0;
    const LYING_CAMERA_YAW=90.0;
    const SEATED_CAMERA_PITCH=18.0;
    const LYING_CAMERA_PITCH=10.0;
}
