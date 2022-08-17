package server;

import argparse.ArgAccessor;
import argparse.ArgParser;
import argparse.Args;
import argparse.ProgSpec;
import cc.OS;
import cc.Rednet;
import config.Accessor;
import config.Config;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_REDNET_MESSAGE;
import events.OSEvent.EVENT_TERMINATE;
import events.OSEvent.RednetMessageEvent;
import extype.Result;
import extype.Tuple.Tuple2;
import extype.Unit;
import extype.Unit._;
import logger.Logger;
import rednetmgr.Header;
import rednetmgr.RednetManager;
import station.Station;
import station.StationDeclaration;
import station.StationStatus;
import server.model.Station as StationModel;

class Server {
	public static inline final SERVER_PROTOCOL = "t4-server";
	private static inline final KNOWN_STATIONS: Accessor<Map<Int, StationModel>> = "known-stations";

	private static var stationStatuses: Array<StationStatus> = [];

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

	public static function main(t4Args: Args, settings: Config): Result<Unit, String> {
		Logger.log("I am a server.");

		final args = cliSpec.parse(t4Args[Main.MACHINE_ARGS]);
		if (args == null)
			return Failure("Failed to parse args");

		var emitter = new EventEmitter();
		var rednet = new RednetManager();

		switch (rednet.open(t4Args[Main.MODEM], t4Args[Main.DEBUG_MODE])) {
			case Failure(err):
				return Failure(err);
			default:
		}
		rednet.host(SERVER_PROTOCOL, t4Args[Main.NETWORK]);

		rednet.addResponse(SERVER_PROTOCOL, Station.RESOLVE_ID, (hdr, msg) -> resolveID(rednet, settings, hdr, msg));

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednet.onRednetMessageEvent);

		emitter.listen();

		rednet.close();

		return Success(_);
	}

	private static function resolveID(rednet: RednetManager, settings: Config, hdr: Header, hint: StationDeclaration) {
		var knownStations = settings.setDefault(KNOWN_STATIONS, () -> new Map());

		final id = switch (hint.idSuggestion) {
			case Some(suggestedId):
				final model = knownStations[suggestedId];
				if (model == null || model.hostId == hdr.src)
					suggestedId;
				else
					freshStationId(knownStations);
			case None:
				freshStationId(knownStations);
		}

		final station: Dynamic = {
			id: id,
			hostId: hdr.src,
			name: hint.name,
		}
		knownStations[id] = station;

		rednet.sendDirect(hdr.protocol, hdr.src, Station.RESOLVE_ID_RESPONSE, id);

		settings.invalidate();
	}

	private static function freshStationId(known: Map<Int, Dynamic>): Int {
		while (true) {
			final rand = Std.int(Math.random());
			if (known[rand] == null)
				return rand;
		}
	}
}
