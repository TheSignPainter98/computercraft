package server.model;

import rednetmgr.HostID;

@:structInit
class Station {
	public final id: Int;
	public final hostId: HostID;
	public final name: String;
}
