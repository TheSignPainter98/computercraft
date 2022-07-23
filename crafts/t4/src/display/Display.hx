package display;

import cc.OS;

class Display {
	public static function main() {
		trace("I am a display.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
