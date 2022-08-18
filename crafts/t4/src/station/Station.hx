package station;

import argparse.ArgAccessor;
import argparse.ArgParser;
import argparse.Args;
import argparse.ProgSpec;
import cc.GPS;
import cc.OS;
import cc.Peripheral;
import config.Accessor;
import config.Config;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_REDNET_MESSAGE;
import events.OSEvent.EVENT_TIMER;
import haxe.ds.Option;
import haxe.Exception;
import lua.Table;
import server.Server;
import server.Server.PULSE_RESPONSE;
import server.Server.SERVER_PROTOCOL;
import server.Server.STATION_STATUS_DECLARE;
import rednetmgr.MessageTag;
import rednetmgr.RednetManager;
import location.Point;
import logger.Logger;
import extype.Result;
import extype.Unit;
import extype.Unit._;

class Station {
	public static inline final STATION_PROTOCOL = "t4-station";
	public static inline final PULSE: MessageTag<Unit> = "t4-station-pulse";

	private static final STATUS_EMISSION_PERIOD = new ArgAccessor<Int>();
	private static inline final STATUS_EMISSION_PERIOD_DEFAULT = 10;

	private static final NAME = new ArgAccessor<String>();

	private static var cliSpec: ProgSpec = {
		name: "t4 station",
		shortDesc: "t4 station",
		desc: "Aggregates station status information, such as the trains in the station, what they're doing and the status of the station's storage buffers",
		author: "The authors of t4",
		date: "2022",
		positionals: [
			{
				dest: NAME,
				desc: "Name of this station",
				type: String(null),
				trigger: {
					metavar: "name",
				},
			}
		],
		flags: [
			{
				dest: STATUS_EMISSION_PERIOD,
				desc: "The number of seconds between the successive messages to the central server",
				type: Int(null),
				dflt: STATUS_EMISSION_PERIOD_DEFAULT,
				trigger: {
					short: "-e",
					long: "--emit-every",
				},
			},
		],
	}

	private static final id: Int = OS.getComputerID();
	private static final stationHostname: String = 'station-#$id';
	private static var name: Null<String>;

	public static function main(args: Args, settings: Config): Result<Unit, String> {
		Logger.log("I am a station");

		final args = cliSpec.parse(args[Main.MACHINE_ARGS]).unite(args);
		if (args == null)
			return Failure("Failed to parse args");

		final rednet = new RednetManager();
		rednet.open(args[Main.MODEM], args[Main.DEBUG_MODE]);

		switch (init(rednet, args, settings)) {
			case Failure(err):
				return Failure(err);
			default:
		}

		rednet.addResponse(STATION_PROTOCOL, PULSE, (hdr, msg) -> rednet.sendDirect(SERVER_PROTOCOL, hdr.src, PULSE_RESPONSE, _));

		rednet.host(STATION_PROTOCOL, stationHostname);

		Logger.log('This station is `$name.\'');

		var emissionTimer = OS.startTimer(args[STATUS_EMISSION_PERIOD]);

		var emitter = new EventEmitter();

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednet.onRednetMessageEvent);
		emitter.addEventListener(EVENT_TIMER, (e) -> {
			Logger.verbose("A timer completed");
			if (e.get_id() == emissionTimer) {
				Logger.log('Sending status to server ${args[Main.NETWORK]}');
				rednet.send(SERVER_PROTOCOL, args[Main.NETWORK], STATION_STATUS_DECLARE, status());
				emissionTimer = OS.startTimer(args[STATUS_EMISSION_PERIOD]);
			}
		});

		emitter.listen();

		rednet.close();

		return Success(_);
	}

	public static function init(rednet: RednetManager, args: Args, settings: Config): Result<Unit, String> {
		name = args[NAME];

		// Get the location
		final location = {
			final loc: Null<GPSLocation> = GPS.locate();
			if (loc == null)
				return Failure('Failed to trilaterate location');
			for (axis in ['x', 'y', 'z'])
				if (Reflect.field(loc, axis) == null)
					return Failure('Failed to trilaterate location');
			loc;
		}

		return Success(_);
	}

	private static function status(): StationStatus {
		return {
			id: id,
			name: name,
			buffer: aggregateBufferStatus(),
			currentlyServicing: servicingStatus(),
		};
	}

	private static function updatePlatforms() {}

	private static function updateBuffers() {}

	private static function aggregateBufferStatus(): Option<StationBufferStatus> {
		return None;
	}

	private static function servicingStatus(): Array<StationPlatformOperation> {
		return [];
	}
}
