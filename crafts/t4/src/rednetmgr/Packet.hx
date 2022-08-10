package rednetmgr;

import server.model.SignalState;
import location.Point;
import haxe.ds.Option;

enum SignalToServerPacket {
	Register(connected: Array<Int>);
	State(id: Int, signal: SignalState);
	TrainPassthrough(id: Int, trainId: Int);
}

enum YardToServerPacket {
	RegisterTrain(name: String);
}

enum ServerToSignalPacket {
	RegisteredSignal(id: Int);
}

enum ServerToYardPacket {
	RegisteredTrain(id: Int);
}

enum StationToServerPacket {
	DeclareStation(id: Option<Int>, pointHint: Point);
}

enum ServerToStationPacket {
	AssignID(id: Int);
}
