// Issue #31: the former MAP01 track is reserved for chapter-end story
// intermissions. MAP01 now uses its MAPINFO music (CA_MUS02) directly, so
// starting a game or loading into MAP01 never plays the former MAP01 track
// first. #16 reproduce CA_MUS01 al confirmar el final del puerto; este
// registro queda reservado para futuras escenas entre capítulos.
class CaelumStoryIntermission : StaticEventHandler
{
}
