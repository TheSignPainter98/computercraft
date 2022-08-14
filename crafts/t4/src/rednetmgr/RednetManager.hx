package rednetmgr;

import cc.ComputerCraft;
import cc.periphs.Modem;
import cc.Peripheral;
import cc.Rednet;
import logger.Logger;
import Main.Result;
import haxe.Exception;
import haxe.ds.Either;
import haxe.ds.Option;
import events.OSEvent.RednetMessageEvent;

typedef Protocol = String;
typedef Host = String;
typedef HostID = Int;

@:structInit
class HostedProtocol {
	public final protocol: Protocol;
	public final host: Host;
}

@:structInit
class Packet<T> {
	public final tag: MessageTag<T>;
	public final payload: T;
}

class RednetManager {
	private static inline final MAX_RETRIES = 5;
	private static inline final RETRY_INTERVAL = 0.25;

	private static var modem: Null<String>;

	private var responses: Map<Protocol, Map<MessageTag<Dynamic>, (HostID, Dynamic) -> Void>>;
	private var hostedProtocols: Array<HostedProtocol>;

	public function new() {
		responses = new Map();
		hostedProtocols = [];
	}

	public function open(modemName: String, ?debugMode: Bool): Result {
		if (rednetIsReady().match(None))
			return Ok;

		Logger.log('Opening rednet on $modemName');

		{
			final m: Modem = Peripheral.wrap(modemName);
			if (m == null)
				return Err('No wireless modem attached at $modemName');
			if (!(m.isWireless() || debugMode))
				return Err('Modem $modemName is not wireless');
		}

		modem = modemName;
		Rednet.open(modem);

		if (!Rednet.isOpen(modem))
			return Err('Failed to open connection with modem "$modem"');

		Logger.log('Connection open on $modem');

		return Ok;
	}

	public function host(protocol, host): Result {
		if (modem == null)
			return Err("Modem connection must be opened before hosting may begin");
		Rednet.host(protocol, host);
		Logger.verbose('Now hosting $protocol/$host');
		hostedProtocols.push({protocol: protocol, host: host});
		return Ok;
	}

	public function sendDirect<T>(recipient: Int, protocol: Protocol, tag: MessageTag<T>, msg: T): Result {
		switch (rednetIsReady()) {
			case Some(err):
				return Err(err);
			default:
		}

		final pkt = {
			tag: tag,
			payload: msg,
		};

		Logger.log('Sending to $protocol/$recipient a $tag');
		Logger.verbose('Message is: $msg');
		Rednet.send(recipient, pkt, protocol);

		return Ok;
	}

	public function send<T>(protocol: Protocol, host: Null<Host>, tag: MessageTag<T>, msg: T): Result {
		// DNS lookup
		final hosts = Rednet.lookup(protocol, host);
		final hostID = hosts[0];
		if (hostID == null)
			return Err('No host found for protocol $protocol');

		return sendDirect(hostID, protocol, tag, msg);
	}

	public function broadcast<T>(protocol: Protocol, tag: MessageTag<T>, msg: T): Result {
		switch (rednetIsReady()) {
			case Some(err):
				return Err(err);
			default:
		}

		final pkt = {
			tag: tag,
			payload: msg,
		}

		Logger.log('Broadcasting on protocol $protocol a $tag');
		Logger.verbose('Broadcasting: $msg');

		Rednet.broadcast(pkt, protocol);

		return Ok;
	}

	private function rednetIsReady(): Option<String> {
		if (modem != null && Rednet.isOpen(modem))
			return None;
		return Some("Modem connection must be opened before hosting may begin");
	}

	public function unhost() {
		while (hostedProtocols.length != 0) {
			final hosted = hostedProtocols.pop();
			Rednet.unhost(hosted.protocol, hosted.host);
		}
	}

	public function close() {
		if (modem != null) {
			Logger.log('Closing rednet on $modem');
			Rednet.close(modem);
			modem = null;
		}
	}

	public function addResponse<T>(protocol: Protocol, tag: MessageTag<T>, listener: (HostID, T) -> Void) {
		if (responses[protocol] == null) {
			responses[protocol] = new Map();
		}
		responses[protocol][tag] = listener;
	}

	public function receive<T>(protocol: Protocol, expectedTag: MessageTag<T>, maxAttempts = MAX_RETRIES): Either<String, T> {
		switch (rednetIsReady()) {
			case Some(err):
				return Left(err);
			default:
		}

		if (protocol != null) {
			var knownProto = false;
			for (hosted in hostedProtocols)
				if (hosted.protocol == protocol) {
					knownProto = true;
					break;
				}

			if (!knownProto)
				return Left('Protocol "$protocol" is unknown to this rednet manager and hence may never be received');
		}

		final recvd: Packet<T> = {
			var raw: Null<ReceivedMessage<Packet<Dynamic>>> = null;
			for (i in 1...1 + maxAttempts) {
				raw = Rednet.receive(protocol);
				if (raw.message.tag == expectedTag)
					break;
				else
					onRednetMessage(raw.protocol, raw.senderID, raw.message);
			}
			ComputerCraft.sleep(RETRY_INTERVAL);
			cast raw.message;
		}

		return Right(recvd.payload);
	}

	public function onRednetMessageEvent(e: RednetMessageEvent) {
		if (e == null)
			return;
		Logger.log('Got a rednet event from ${e.protocol}/${e.id}');
		Logger.verbose('Message is: ${e.message}');

		onRednetMessage(e.protocol, e.id, e.message);
	}

	private function onRednetMessage<T>(protocol: Protocol, senderID: Int, pkt: Packet<T>) {
		Logger.log('Gotten rednet message with protocol $protocol/$senderID: $pkt');
	}
}
