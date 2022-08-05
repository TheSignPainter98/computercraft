package server;

import cc.OS;
import config.Config;
import events.Event;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_TERMINATE;

class Server {
	public static function main(args: Array<String>, settings: Config) {
		trace("I am a server.");

		var emitter = new EventEmitter();

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_TERMINATE, (_) -> emitter.stopListening());

		emitter.listen();
	}
}
