package signal;

import cc.OS;

class Signal {
	public static function main() {
		trace("I am a signal.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
