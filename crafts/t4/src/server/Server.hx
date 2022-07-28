package server;

import cc.OS;

class Server {
	public static function main(args: Array<String>) {
		trace("I am a server.");

		while (true) {
			var event = OS.pullEventRaw();
			if (event[1] == "terminate")
				break;
		}
	}
}
