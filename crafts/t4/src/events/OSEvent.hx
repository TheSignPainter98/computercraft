package events;

import lua.Table;
import cc.HTTP.Websocket;
import cc.HTTP.HTTPResponse;

abstract AlarmEvent(Table<Int, Dynamic>) {
	public var id(get, never): Int;

	public inline function get_id(): Int {
		return this[2];
	}
}

abstract CharEvent(Table<Int, Dynamic>) {
	public var character(get, never): String;

	public inline function get_character(): String {
		return this[2];
	}
}

abstract ComputerCommandEvent(Table<Int, Dynamic>) {
	public function get_arguments(): Array<String> {
		var arr = Table.toArray(this);
		arr.shift();
		return arr;
	}
}

abstract DiskEvent(Table<Int, Dynamic>) {
	public var side(get, never): String;

	public inline function get_side(): String {
		return this[2];
	}
}

abstract DiskEjectEvent(Table<Int, Dynamic>) {
	public var side(get, never): String;

	public inline function get_side(): String {
		return this[2];
	}
}

abstract HttpCheckEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;
	public var success(get, never): Bool;
	public var reason(get, never): Null<String>;

	public inline function get_url(): String {
		return this[2];
	}

	public inline function get_success(): Bool {
		return this[3];
	}

	public inline function get_reason(): Null<String> {
		return this[4];
	}
}

abstract HttpFailureEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;
	public var error(get, never): String;
	public var response(get, never): Null<HTTPResponse>;

	public inline function get_url(): String {
		return this[2];
	}

	public inline function get_error(): String {
		return this[3];
	}

	public inline function get_response(): Null<HTTPResponse> {
		return this[4];
	}
}

abstract HttpSuccessEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;
	public var response(get, never): HTTPResponse;

	public inline function get_url(): String {
		return this[2];
	}

	public inline function get_response(): HTTPResponse {
		return this[3];
	}
}

abstract KeyEvent(Table<Int, Dynamic>) {
	public var key(get, never): Int;
	public var hold(get, never): Bool;

	public inline function get_key(): Int {
		return this[2];
	}

	public inline function get_hold(): Bool {
		return this[3];
	}
}

abstract KeyUpEvent(Table<Int, Dynamic>) {
	public var key(get, never): Int;

	public inline function get_key(): Int {
		return this[2];
	}
}

abstract ModemMessageEvent(Table<Int, Dynamic>) {
	public var side(get, never): String;
	public var channel(get, never): Int;
	public var replyChannel(get, never): Int;
	public var message(get, never): Dynamic;
	public var distance(get, never): Float;

	public inline function get_side(): String {
		return this[2];
	}

	public inline function get_channel(): Int {
		return this[3];
	}

	public inline function get_replyChannel(): Int {
		return this[4];
	}

	public inline function get_message(): Dynamic {
		return this[5];
	}

	public inline function get_distance(): Float {
		return this[6];
	}
}

abstract MonitorResizeEvent(Table<Int, Dynamic>) {
	public var id(get, never): String;

	public inline function get_id(): String {
		return this[2];
	}
}

abstract MonitorTouchEvent(Table<Int, Dynamic>) {
	public var id(get, never): String;
	public var x(get, never): Int;
	public var y(get, never): Int;

	public inline function get_id(): String {
		return this[2];
	}

	public inline function get_x(): Int {
		return this[3];
	}

	public inline function get_y(): Int {
		return this[4];
	}
}

abstract MouseClickEvent(Table<Int, Dynamic>) {
	public var button(get, never): Int;
	public var x(get, never): Int;
	public var y(get, never): Int;

	public inline function get_button(): Int {
		return this[2];
	}

	public inline function get_x(): Int {
		return this[3];
	}

	public inline function get_y(): Int {
		return this[4];
	}
}

abstract MouseDragEvent(Table<Int, Dynamic>) {
	public var button(get, never): Int;
	public var x(get, never): Int;
	public var y(get, never): Int;

	public inline function get_button(): Int {
		return this[2];
	}

	public inline function get_x(): Int {
		return this[3];
	}

	public inline function get_y(): Int {
		return this[4];
	}
}

abstract MouseScrollEvent(Table<Int, Dynamic>) {
	public var direction(get, never): Int;
	public var x(get, never): Int;
	public var y(get, never): Int;

	public inline function get_direction(): Int {
		return this[2];
	}

	public inline function get_x(): Int {
		return this[3];
	}

	public inline function get_y(): Int {
		return this[4];
	}
}

abstract MouseUpEvent(Table<Int, Dynamic>) {
	public var button(get, never): Int;
	public var x(get, never): Int;
	public var y(get, never): Int;

	public inline function get_button(): Int {
		return this[2];
	}

	public inline function get_x(): Int {
		return this[3];
	}

	public inline function get_y(): Int {
		return this[4];
	}
}

abstract PasteEvent(Table<Int, Dynamic>) {
	public var text(get, never): String;

	public inline function get_text(): String {
		return this[2];
	}
}

abstract PeripheralEvent(Table<Int, Dynamic>) {
	public var side(get, never): String;

	public inline function get_side(): String {
		return this[2];
	}
}

abstract PeripheralDetachEvent(Table<Int, Dynamic>) {
	public var side(get, never): String;

	public inline function get_side(): String {
		return this[2];
	}
}

abstract RednetMessageEvent(Table<Int, Dynamic>) {
	public var id(get, never): Int;
	public var message(get, never): Dynamic;
	public var protocol(get, never): Null<String>;

	public inline function get_id(): Int {
		return this[2];
	}

	public inline function get_message(): Dynamic {
		return this[3];
	}

	public inline function get_protocol(): Null<String> {
		return this[4];
	}
}

abstract RedstoneEvent(Table<Int, Dynamic>) {}

abstract SpeakerAudioEmptyEvent(Table<Int, Dynamic>) {
	public var id(get, never): String;

	public inline function get_id(): String {
		return this[2];
	}
}

abstract TaskCompleteEvent(Table<Int, Dynamic>) {
	public var id(get, never): Int;
	public var success(get, never): Bool;
	public var error(get, never): Null<String>;

	public inline function get_id(): Int {
		return this[2];
	}

	public inline function get_success(): Bool {
		return this[3];
	}

	public inline function get_error(): Null<String> {
		return this[4];
	}
}

abstract TermResizeEvent(Table<Int, Dynamic>) {}
abstract TerminateEvent(Table<Int, Dynamic>) {}

abstract TimerEvent(Table<Int, Dynamic>) {
	public var id(get, never): Int;

	public inline function get_id(): Int {
		return this[2];
	}
}

abstract TurtleInventoryEvent(Table<Int, Dynamic>) {}

abstract WebsocketClosedEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;

	public inline function get_url(): String {
		return this[2];
	}
}

abstract WebsocketFailureEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;
	public var error(get, never): String;

	public inline function get_url(): String {
		return this[2];
	}

	public inline function get_error(): String {
		return this[3];
	}
}

abstract WebsocketMessageEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;
	public var body(get, never): String;
	public var binary(get, never): Bool;

	public inline function get_url(): String {
		return this[2];
	}

	public inline function get_body(): String {
		return this[3];
	}

	public inline function get_binary(): Bool {
		return this[4];
	}
}

abstract WebsocketSuccessEvent(Table<Int, Dynamic>) {
	public var url(get, never): String;
	public var handle(get, never): Websocket;

	public inline function get_url(): String {
		return this[2];
	}

	public inline function get_handle(): Websocket {
		return this[3];
	}
}

class OSEvent {
	public static inline var EVENT_ALARM = new Event<AlarmEvent>("alarm");
	public static inline var EVENT_CHAR = new Event<CharEvent>("char");
	public static inline var EVENT_COMPUTER_COMMAND = new Event<ComputerCommandEvent>("computer_command");
	public static inline var EVENT_DISK = new Event<DiskEvent>("disk");
	public static inline var EVENT_DISK_EJECT = new Event<DiskEjectEvent>("disk_eject");
	public static inline var EVENT_HTTP_CHECK = new Event<HttpCheckEvent>("http_check");
	public static inline var EVENT_HTTP_FAILURE = new Event<HttpFailureEvent>("http_failure");
	public static inline var EVENT_HTTP_SUCCESS = new Event<HttpSuccessEvent>("http_success");
	public static inline var EVENT_KEY = new Event<KeyEvent>("key");
	public static inline var EVENT_KEY_UP = new Event<KeyUpEvent>("key_up");
	public static inline var EVENT_MODEM_MESSAGE = new Event<ModemMessageEvent>("modem_message");
	public static inline var EVENT_MONITOR_RESIZE = new Event<MonitorResizeEvent>("monitor_resize");
	public static inline var EVENT_MONITOR_TOUCH = new Event<MonitorTouchEvent>("monitor_touch");
	public static inline var EVENT_MOUSE_CLICK = new Event<MouseClickEvent>("mouse_click");
	public static inline var EVENT_MOUSE_DRAG = new Event<MouseDragEvent>("mouse_drag");
	public static inline var EVENT_MOUSE_SCROLL = new Event<MouseScrollEvent>("mouse_scroll");
	public static inline var EVENT_MOUSE_UP = new Event<MouseUpEvent>("mouse_up");
	public static inline var EVENT_PASTE = new Event<PasteEvent>("paste");
	public static inline var EVENT_PERIPHERAL = new Event<PeripheralEvent>("peripheral");
	public static inline var EVENT_PERIPHERAL_DETACH = new Event<PeripheralDetachEvent>("peripheral_detach");
	public static inline var EVENT_REDNET_MESSAGE = new Event<RednetMessageEvent>("rednet_message");
	public static inline var EVENT_REDSTONE = new Event<RedstoneEvent>("redstone");
	public static inline var EVENT_SPEAKER_AUDIO_EMPTY = new Event<SpeakerAudioEmptyEvent>("speaker_audio_empty");
	public static inline var EVENT_TASK_COMPLETE = new Event<TaskCompleteEvent>("task_complete");
	public static inline var EVENT_TERM_RESIZE = new Event<TermResizeEvent>("term_resize");
	public static inline var EVENT_TERMINATE = new Event<TerminateEvent>("terminate");
	public static inline var EVENT_TIMER = new Event<TimerEvent>("timer");
	public static inline var EVENT_TURTLE_INVENTORY = new Event<TurtleInventoryEvent>("turtle_inventory");
	public static inline var EVENT_WEBSOCKET_CLOSED = new Event<WebsocketClosedEvent>("websocket_closed");
	public static inline var EVENT_WEBSOCKET_FAILURE = new Event<WebsocketFailureEvent>("websocket_failure");
	public static inline var EVENT_WEBSOCKET_MESSAGE = new Event<WebsocketMessageEvent>("websocket_message");
	public static inline var EVENT_WEBSOCKET_SUCCESS = new Event<WebsocketSuccessEvent>("websocket_success");
}
