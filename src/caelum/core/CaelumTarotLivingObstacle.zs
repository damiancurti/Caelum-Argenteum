// Sólo esta familia explícita puede desaparecer mediante el pasivo de La Muerte.
// Reutiliza el árbol propio; los ejemplos de mapa se asignan por separado.
class CaelumTarotLivingObstacle : CaelumTreePlainsEspinillo
{
    bool DestroyByTarot(CaelumPlayer user)
    {
        if(bDestroyed || !CaelumPlayerAuthority.CanMutate(user) || user.health<=0
            || !CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),13)
            || user.Distance3D(self)>user.UseRange+Radius || !user.CheckSight(self))return false;
        CaelumContaminationStorage.Set(self,CaelumFoodData.MAX_CONTAMINATION);
        // La destrucción nativa se conserva en el hub; no entrega una cosecha ni un premio.
        Destroy();return true;
    }
}
