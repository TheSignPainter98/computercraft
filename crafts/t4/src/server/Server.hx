package server;

import cc.OS;

class Server {
	public static function main() {
		trace("I am a server.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
