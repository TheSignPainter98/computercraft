package events;

enum OSEvent {
	Alarm(id: Int);
	Char(character: String);
	ComputerCommand(arguments: Array<String>);
	Disk(side: String);
	DiskEject(side: String);
	HttpCheck(url: String, success: Bool, reason: Null<String>);
	HttpFailure(url: String, error: String, response: Null<HTTPResponse>);
	HttpSuccess(url: String, response: HTTPResponse);
	Key(key: Int, hold: Bool);
	KeyUp(key: Int);
	ModemMessage(side: String, channel: Int, replyChannel: Int, message: Dynamic, distance: Float); // Test if float
	MonitorResize(id: String);
	MonitorTouch(id: String, x: Int, y: Int);
	MouseClick(button: Int, x: Int, y: Int);
	MouseDrag(button: Int, x: Int, y: Int);
	MouseScroll(direction: Int, x: Int, y: Int);
	MouseUp(button: Int, x: Int, y: Int);
	Paste(text: String);
	Peripheral(side: String);
	PeripheralDetach(side: String);
	RednetMessage(id: Int, message: Dynamic, protocol: Null<String>);
	Redstone;
	SpeakerAudioEmpty(id: String);
	TaskComplete(id: Int, success: Bool, error: Null<String>);
	TermResize;
	Terminate;
	Timer(id: Int);
	TurtleInventory;
	WebsocketClosed(url: String);
	WebsocketFailure(url: String, error: String);
	WebsocketMessage(url: String, body: String, binary: Bool);
	WebsocketSuccess(url: String, handle: Websocket);
}
