package server;

import argparse.ArgAccessor;
import argparse.ArgParser;
import argparse.Args;
import argparse.ProgSpec;
import cc.OS;
import cc.Rednet;
import config.Config;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_REDNET_MESSAGE;
import events.OSEvent.EVENT_TERMINATE;
import events.OSEvent.RednetMessageEvent;
import rednetmgr.RednetManager;

class Server {
	public static inline final SERVER_PROTOCOL = "t4-server";

	private static var cliSpec: ProgSpec = {
		name: "t4-server",
		shortDesc: "t4 central server",
		desc: "Single source of truth for t4's belief about the current status of its network",
		author: "The authors of t4",
		date: "2022",
		license: [
			"This program is free software: you can redistribute it and/or modify",
			"it under the terms of the GNU General Public License as published by",
			"the Free Software Foundation, either version 3 of the License, or",
			"(at your option) any later version.",
			"",
			"This program is distributed in the hope that it will be useful,",
			"but WITHOUT ANY WARRANTY; without even the implied warranty of",
			"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the",
			"GNU General Public License for more details.",
			"",
			"You should have received a copy of the GNU General Public License",
			"along with this program.  If not, see <https://www.gnu.org/licenses/>.",
		],
	}

	public static function main(t4Args: Args, settings: Config) {
		trace("I am a server.");

		final args = cliSpec.parse(t4Args[Main.MACHINE_ARGS]);
		if (args == null)
			return;

		var emitter = new EventEmitter();
		var rednet = new RednetManager();

		rednet.open(args[Main.MODEM], t4Args[Main.DEBUG_MODE]);
		rednet.host(SERVER_PROTOCOL, args[Main.NETWORK]);

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednet.onRednetMessageEvent);

		emitter.listen();

		rednet.close();
	}
}
