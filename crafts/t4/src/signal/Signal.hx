package signal;

import cc.OS;

class Signal {
	public static function main(args: Array<String>) {
		trace("I am a signal.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
