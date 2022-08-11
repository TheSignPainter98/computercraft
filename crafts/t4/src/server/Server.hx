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

	private static final NETWORK_NAME = new ArgAccessor<String>();
	private static final MODEM = new ArgAccessor<String>();

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
		positionals: [
			{
				dest: NETWORK_NAME,
				desc: "The name of the network which this server controls",
				type: String(null),
				dflt: "universe",
				trigger: {
					metavar: "network",
				},
			}
		],
		flags: [
			{
				dest: MODEM,
				desc: "Where the wireless router is attached",
				type: String(["top", "bottom", "left", "right", "front", "back"]),
				dflt: "top",
				trigger: {
					short: "-m",
					long: "--modem",
				}
			}
		]
	}

	public static function main(t4Args: Args, settings: Config) {
		trace("I am a server.");

		final args = cliSpec.parse(t4Args[Main.MACHINE_ARGS]);
		if (args == null)
			return;

		init(args, settings);

		var emitter = new EventEmitter();
		var rednetMgr = new RednetManager();

		rednetMgr.open(args[MODEM], t4Args[Main.DEBUG_MODE]);

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednetMgr.onRednetMessageEvent);

		emitter.listen();

		deinit(args, settings);
	}

	private static function init(args: Args, settings: Config) {
		Rednet.host(SERVER_PROTOCOL, args[NETWORK_NAME]);
	}

	private static function deinit(args: Args, settings: Config) {
		Rednet.unhost(SERVER_PROTOCOL, args[NETWORK_NAME]);
	}
}
