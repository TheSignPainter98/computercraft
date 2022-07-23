package yard;

import cc.OS;

class Yard {
	public static function main() {
		trace("I am a yard.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
