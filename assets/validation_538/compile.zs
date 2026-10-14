class CA235Compile : StaticEventHandler { override void WorldLoaded(WorldEvent e) { Console.Printf("CA235 MAP %s CHECKSUM %s",level.MapName,level.GetChecksum()); } }
