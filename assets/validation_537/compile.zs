class CA234Compile : StaticEventHandler { override void WorldLoaded(WorldEvent e) { Console.Printf("CA234 MAP %s CHECKSUM %s",level.MapName,level.GetChecksum()); } }
