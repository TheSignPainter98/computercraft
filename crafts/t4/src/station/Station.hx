package station;

import argparse.ArgAccessor;
import argparse.ArgParser;
import argparse.Args;
import argparse.ProgSpec;
import cc.GPS;
import cc.Rednet;
import cc.Peripheral;
import config.Accessor;
import config.Config;
import events.EventEmitter;
import events.CustomEvent.EVENT_SAVE_INVALIDATED;
import events.OSEvent.EVENT_REDNET_MESSAGE;
import haxe.ds.Option;
import haxe.ds.Either;
import haxe.Exception;
import lua.Table;
import server.Server;
import rednetmgr.MessageTag;
import rednetmgr.Packet.StationToServerPacket;
import rednetmgr.RednetManager;
import location.Point;
import Main.Result;

@:structInit
class StationDecl {
	public final stationID: Int;
	public final location: Point;
}

class Station {
	public static inline final STATION_PROTOCOL = "t4-station";
	public static inline final STATUS_REQUEST: MessageTag<Void> = "t4-station-request-status";
	public static inline final STATUS_DECLARE: MessageTag<StationStatus> = "t4-station-declare-status";
	public static inline final RESOLVE_ID: MessageTag<Option<Int>> = "t4-station-resolve-id";
	public static inline final RESOLVE_ID_RESPONSE: MessageTag<Int> = "t4-station-id-resolve-response";

	private static final NAME = new ArgAccessor<String>();

	private static inline final ID: Accessor<Int> = "id";

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
	}

	// private static var serverID: Int;
	private static var id: Int;
	private static var name: Null<String>;

	public static function main(t4Args: Args, settings: Config) {
		trace("I am a station");

		final args = cliSpec.parse(t4Args[Main.MACHINE_ARGS]);
		if (args == null)
			return;

		final rednet = new RednetManager(t4Args[Main.VERBOSITY]);
		rednet.open(t4Args[Main.MODEM], t4Args[Main.DEBUG_MODE]);

		switch (init(rednet, args, settings)) {
			case Err(err):
				trace(err);
				return;
			default:
		}

		rednet.addResponse(STATION_PROTOCOL, STATUS_REQUEST, (src, _) -> rednet.send(Server.SERVER_PROTOCOL, t4Args[Main.NETWORK], STATUS_DECLARE, status()));

		trace('This station is `$name.\'');

		var emitter = new EventEmitter();

		emitter.addEventListener(EVENT_SAVE_INVALIDATED, (_) -> settings.save());
		emitter.addEventListener(EVENT_REDNET_MESSAGE, rednet.onRednetMessageEvent);

		emitter.listen();

		rednet.close();
	}

	public static function init(rednet: RednetManager, args: Args, settings: Config): Result {
		name = args[NAME];

		// Get the location
		final location = {
			final loc = GPS.locate();
			if (loc == null)
				return Err('Failed to trilaterate location');
			loc;
		}

		id = switch (negotiateID(rednet, settings, location)) {
			case Left(err): return Err(err);
			case Right(id): id;
		};
		trace(id);

		rednet.host(STATION_PROTOCOL, stationProtocolHostname(id));

		return Ok;
	}

	public static function negotiateID(rednet: RednetManager, options: Config, loc: Point): Either<String, Int> {
		var initialID = options[ID];
		final msg = {
			if (initialID == null)
				None
			else
				Some(initialID);
		}
		switch (rednet.send(Server.SERVER_PROTOCOL, null, RESOLVE_ID, msg)) {
			case Err(e):
				return Left(e);
			default:
		}

		return switch (rednet.receive(Server.SERVER_PROTOCOL, RESOLVE_ID_RESPONSE)) {
			case Left(err): Left(err);
			case Right(id):
				options[ID] = id;
				return Right(id);
		}
	}

	private static function stationProtocolHostname(id: Int): String {
		return 'station-#$id';
	}

	public static function status(): StationStatus {
		return null;
		return {
			id: id,
			name: name,
			buffer: aggregateBufferStatus(),
			currentlyServicing: servicingStatus(),
		};
	}

	public static function updatePlatforms() {}

	public static function updateBuffers() {}

	public static function aggregateBufferStatus(): Option<StationBufferStatus> {
		return None;
	}

	public static function servicingStatus(): Array<StationPlatformOperation> {
		return [];
	}
}
