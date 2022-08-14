package events;

import cc.OS;
import lua.Os;
import haxe.Constraints;
import logger.Logger;

class EventEmitter {
	var listeners: Map<Event<Dynamic>, Function> = new Map();
	var listening: Bool;

	public function new() {}

	public function addEventListener<T>(event: Event<T>, listener: T->Void) {
		listeners.set(event, listener);
	}

	public function listen() {
		Logger.log('Listening for events...');
		listening = true;
		while (listening) {
			var e = OS.pullEventRaw();
			if (this.listeners.exists(e[1]))
				this.listeners[e[1]](e);
			else if (e[1] == "terminate")
				break;
		}
	}

	public function stopListening() {
		listening = false;
	}
}
