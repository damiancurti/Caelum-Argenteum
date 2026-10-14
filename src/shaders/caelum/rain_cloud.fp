// Generado desde assets/rain_cloud/DESIGN.json; sin reloj ni estado de juego.
// Atenuar el contorno y excluir caras posteriores de la nube translúcida.
void SetupMaterial(inout Material material)
{
    SetMaterialProps(material, vTexCoord.st);
    vec3 outward = normalize(vWorldNormal.xyz);
    vec3 toEye = normalize(uCameraPos.xyz - pixelpos.xyz);
    float facing = max(0.0, dot(outward, toEye));
    material.Base.a *= step(0.0001, facing) * mix(0.2, 1.0, smoothstep(0.0, 0.7, facing));
}
