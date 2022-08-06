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
import packet.Packet;

class Server {
	public static inline final SERVER_PROTOCOL = "t4-server";

	private static final NETWORK_NAME = new ArgAccessor<String>();

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
			desc: "The name of the network which this server controlls (currently unused)",
			type: String(null),
			dflt: "universe",
			trigger: {
				metavar: "network",
			},
		}
		],
	}

	public static function main(argv: Array<String>, settings: Config) {
		trace("I am a server.");

		final parser = new ArgParser(cliSpec);
		final args = parser.parse(argv);
		if (args == null)
			return;

		init(args, settings);

		var emitter = new EventEmitter();

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, processRednetEvent);

		emitter.listen();
	}

	private static function init(args: Args, settings: Config) {
		Rednet.host(SERVER_PROTOCOL, args[NETWORK_NAME]);
	}

	private static function processRednetEvent(e: RednetMessageEvent) {
		if (e.protocol != SERVER_PROTOCOL)
			return;

		processPacket(e.message);
	}

	private static function processPacket(pkt: Packet) {
		trace('Got packet $pkt');
	}
}
