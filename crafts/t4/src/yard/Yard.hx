package yard;

import cc.OS;

class Yard {
	public static function main(args: Array<String>) {
		trace("I am a yard.");

		while (true) {
			var event = OS.pullEvent();
		}
	}
}
