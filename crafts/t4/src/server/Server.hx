package server;

import argparse.ArgAccessor;
import argparse.ArgParser;
import argparse.Args;
import argparse.ProgSpec;
import cc.OS;
import cc.Rednet;
import config.Accessor;
import config.Config;
import display.Display.DISPLAY_PROTOCOL;
import display.Display.NETWORK_STATUS;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_REDNET_MESSAGE;
import events.OSEvent.EVENT_TERMINATE;
import events.OSEvent.RednetMessageEvent;
import events.OSEvent.EVENT_TIMER;
import extype.Result;
import extype.Set;
import extype.Tuple.Tuple2;
import extype.Unit;
import extype.Unit._;
import logger.Logger;
import rednetmgr.Header;
import rednetmgr.RednetManager;
import rednetmgr.MessageTag;
import station.Station;
import station.Station.PULSE as STATION_PULSE;
import station.Station.STATION_PROTOCOL;
import station.StationDeclaration;
import station.StationStatus;
import server.model.Station as StationModel;

// import periphs.TrainNetworkObserver.TrainID;

enum TrainMovement {
	AwaitingSignal;
	AtStationPlatform;
	Moving(speed: Float);
}

@:structInit
class TrainStatus {
	public final name: String;
	public final id: String; // TODO(kcza): TrainID
	public final callingAtPlatforms: Array<String>; // TODO(kcza): StopID
	public final callingAt: Array<Int>; // TODO(kcza): refactor station ID to its own type?
	public final movement: TrainMovement;
}

@:structInit
class NetworkStatus {
	public final trains: Map<String, TrainStatus>;
	public final stations: Array<StationStatus>;
	public final routes: Array<Array<Int>>; // TODO: StationID

	public function new(trains: Map<String, TrainStatus>, stations: Array<StationStatus>) {
		this.trains = trains;
		this.stations = stations;
		this.routes = [ for (train in trains) computeRoute(train, stations) ];
	}

	private function computeRoute(trains: TrainStatus, stations: Array<StationStatus>): Array<Int> {
		return [ ]; // TODO(kcza): complete me!
	}
}

@:structInit
private class State {
	public var emissionTimer: Null<Int> = null;
	public var stationPulseTimer: Null<Int> = null;
	public var stationStatuses: Array<StationStatus>;
	public var aliveStations: Set<Int>;
	public var trainStatuses: Map<String, TrainStatus>; // TODO(kcza): TrainID

	public function purge() {
		stationStatuses = stationStatuses.filter((s) -> aliveStations.exists(s.id));
	}
}

class Server {
	public static inline final SERVER_PROTOCOL = "t4-server";
	public static inline final PULSE_RESPONSE: MessageTag<Unit> = "t4-server:pulse-response";
	public static inline final STATION_STATUS_DECLARE: MessageTag<StationStatus> = "t4-server-station-status-declare";

	private static inline final KNOWN_STATIONS: Accessor<Map<Int, StationModel>> = "known-stations";
	private static final EMISSION_PERIOD = new ArgAccessor<Int>();
	private static final PULSE_PERIOD = new ArgAccessor<Int>();

	private static final stationStatuses: Array<StationStatus> = [];

	private static final cliSpec: ProgSpec = {
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
		flags: [
			{
				dest: EMISSION_PERIOD,
				desc: "The number of seconds between the server passing its knowledge of the system status to displays",
				type: Int(null),
				dflt: 10,
				trigger: {
					short: "-e",
					long: "--emit-every",
				},
			},
			{
				dest: PULSE_PERIOD,
				desc: "The number of seconds between the server checking that its known stations are still alive",
				type: Int(null),
				dflt: 100,
				trigger: {
					short: "-p",
					long: "--check-pulse-every",
				},
			},
		],
	}

	public static function main(args: Args, settings: Config): Result<Unit, String> {
		Logger.log("I am a server.");

		final args = cliSpec.parse(args[Main.MACHINE_ARGS]).unite(args);
		if (args == null)
			return Failure("Failed to parse args");

		var emitter = new EventEmitter();
		var rednet = new RednetManager();

		final state: State = {
			stationStatuses: [],
			aliveStations: new Set(),
			trainStatuses: [],
		};

		switch (rednet.open(args[Main.MODEM], args[Main.DEBUG_MODE])) {
			case Failure(err):
				return Failure(err);
			default:
		}
		rednet.host(SERVER_PROTOCOL, args[Main.NETWORK]);

		rednet.addResponse(SERVER_PROTOCOL, PULSE_RESPONSE, (hdr, _) -> state.aliveStations.add(hdr.src));

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednet.onRednetMessageEvent);
		emitter.addEventListener(EVENT_TIMER, (e) -> {
			final timer = e.get_id();
			Logger.verbose('A timer completed, $timer');
			if (timer == state.emissionTimer) {
				Logger.log('Broadcasting system status');
				rednet.broadcast(DISPLAY_PROTOCOL, NETWORK_STATUS, aggregateNetworkStatus(state.trainStatuses, state.stationStatuses));

				// Reset timer
				state.emissionTimer = OS.startTimer(args[EMISSION_PERIOD]);
			} else if (timer == state.stationPulseTimer) {
				Logger.log('Checking station pulse');

				// Purge unresponsive stations from last check
				state.purge();

				rednet.broadcast(STATION_PROTOCOL, STATION_PULSE, _);

				// Reset timer
				state.stationPulseTimer = OS.startTimer(args[PULSE_PERIOD]);
			}
		});

		state.emissionTimer = OS.startTimer(args[EMISSION_PERIOD]);
		state.stationPulseTimer = OS.startTimer(args[PULSE_PERIOD]);

		emitter.listen();

		rednet.close();

		return Success(_);
	}

	private static function aggregateNetworkStatus(trainStatuses: Map<String, TrainStatus>, stationStatuses: Array<StationStatus>): NetworkStatus {
		return {
			trains: trainStatuses,
			stations: stationStatuses,
		}
	}
}
