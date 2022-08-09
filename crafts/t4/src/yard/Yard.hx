package yard;

import argparse.Args;
import cc.OS;
import config.Config;
import events.Event;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_TERMINATE;

class Yard {
	public static function main(args: Args, settings: Config) {
		trace("I am a yard.");

		var emitter = new EventEmitter();

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_TERMINATE, (_) -> emitter.stopListening());

		emitter.listen();
	}
}
