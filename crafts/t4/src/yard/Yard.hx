package yard;

import cc.OS;
import config.Config;
import config.Accessor;

class Yard {
	public static function main(args: Array<String>, settings: Config) {
		trace("I am a yard.");

		while (true) {
			var event = OS.pullEventRaw();
			if (event[1] == "terminate")
				break;
			else if (event[1] == ConfigImpl.SAVE_INVALIDATED_EVENT)
				settings.save();
		}
	}
}
