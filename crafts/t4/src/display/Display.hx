package display;

import cc.OS;
import config.Config;

class Display {
	public static function main(args:Array<String>, settings:Config) {
		trace("I am a display.");

		while (true) {
			var event = OS.pullEventRaw();
			if (event[1] == "terminate")
				break;
			else if (event[1] == ConfigImpl.SAVE_INVALIDATED_EVENT)
				settings.save();
		}
	}
}
