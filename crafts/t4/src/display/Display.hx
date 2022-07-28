package display;

import cc.OS;

class Display {
	public static function main(args: Array<String>) {
		trace("I am a display.");

		while (true) {
			var event = OS.pullEventRaw();
			if (event[1] == "terminate")
				break;
		}
	}
}
