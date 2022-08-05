package packet;

import model.SignalState;

enum Packet {
	SignalToServer(pkt: SignalToServerPacket);
	YardToServer(pkt: YardToServerPacket);
	ServerToSignal(pkt: ServerToSignalPacket);
	ServerToYard(pkt: ServerToYardPacket);
}

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
