class CA236Compile : StaticEventHandler { override void WorldLoaded(WorldEvent e) { Console.Printf("CA236 MAP %s CHECKSUM %s",level.MapName,level.GetChecksum()); } }
