package display;

import cc.OS;

class Display {
	public static function main(args: Array<String>) Result {
		trace("I am a display.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
