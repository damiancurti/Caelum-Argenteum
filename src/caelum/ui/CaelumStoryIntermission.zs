// Issue #31: the former MAP01 track is reserved for chapter-end story
// intermissions. MAP01 now uses its MAPINFO music (CA_MUS02) directly, so
// starting a game or loading into MAP01 never plays the former MAP01 track
// first. The main campaign does not yet expose runtime chapter boundaries,
// so this handler performs no music changes for now and remains the
// registration point for those future intermissions.
class CaelumStoryIntermission : StaticEventHandler
{
}
