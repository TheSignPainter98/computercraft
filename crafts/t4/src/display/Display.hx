package display;

import argparse.Args;
import cc.Colors as Colours;
import cc.Colors.Color as Colour;
import cc.OS;
import config.Config;
import events.Event;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_REDNET_MESSAGE;
import events.OSEvent.EVENT_TERMINATE;
import extype.Result;
import extype.Unit;
import extype.Unit._;
import rednetmgr.MessageTag;
import rednetmgr.RednetManager;
import server.Server.NetworkStatus;
import logger.Logger;

class Display {
	public static inline final DISPLAY_PROTOCOL = "t4-display";
	public static inline final NETWORK_STATUS: MessageTag<NetworkStatus> = "network-status";

	public static function main(args: Args, settings: Config): Result<Unit, String> {
		Logger.log("I am a display.");

		var emitter = new EventEmitter();
		var rednet = new RednetManager();

		rednet.open(args[Main.MODEM], args[Main.DEBUG_MODE]);

		rednet.host(DISPLAY_PROTOCOL, displayHostName(OS.getComputerID()));

		rednet.addResponse(DISPLAY_PROTOCOL, NETWORK_STATUS, (_, net) -> updateDisplay(net));

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_TERMINATE, (_) -> emitter.stopListening());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednet.onRednetMessageEvent);

		emitter.listen();

		return Success(_);
	}

	private static function displayHostName(id: Int): String {
		return 't4-display:$id';
	}

	private static function updateDisplay(network: NetworkStatus) {
		trace('Updating display network to: $network');
	}
}
