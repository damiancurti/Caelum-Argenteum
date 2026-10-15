// #251: valores aprobados; medidas del modelo y presentación sin efecto físico.
class CaelumArcaneCloudData : Object
{
    const REVISION=1;
    // Carreta actual: ca_covered_cart.obj X=[-41,41], MODELDEF Scale=1.
    const BASE_WIDTH=82.0;
    const SPEED_FACTOR=2.0;
    const RAIN_RECOVERY_RATIO=0.01;
    const STRIKES_PER_SECOND=3;
    // assets/rain_cloud/manifest.json: modelo normalizado de ancho 2.
    const MODEL_HEIGHT=0.9806830985212963;
    const MODEL_HALF_DEPTH=0.703128408709815;
    const MODEL_ALPHA=0.78;
    // Sólo gotas visuales; su número/vida no decide la recuperación.
    const RAIN_COLOR=0x798391;
    const RAIN_SPEED=8.0;
    const RAIN_SIZE=1.2;
    const RAIN_ALPHA=0.65;
    const RAIN_INTERVAL=3;
    const RAIN_DENSE_INTERVAL=9;
    const RAIN_TRACE_DISTANCE=32768.0;
    const RAIN_PHASE_STEP=137.507764;
    const RAIN_SEQUENCE_LENGTH=97;
}
