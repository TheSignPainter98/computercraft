package display;

import cc.OS;
import config.Config;
import events.Event;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_TERMINATE;

class Display {
	public static function main(args: Array<String>, settings: Config) {
		trace("I am a display.");

		var emitter = new EventEmitter();

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_TERMINATE, (_) -> emitter.stopListening());

		emitter.listen();
	}
}
