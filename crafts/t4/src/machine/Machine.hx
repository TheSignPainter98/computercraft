package machine;

import config.Config;
import display.Display;
import server.Server;
import signal.Signal;
import yard.Yard;

@:enum
abstract Machine(String) from String to String {
	var MachineDisplay = 'display';
	var MachineSignal = 'signal';
	var MachineServer = 'server';
	var MachineYard = 'yard';

	public inline function exec(args: Array<String>, settings: Config) {
		switch (this) {
			case MachineDisplay:
				Display.main(args, settings);
			case MachineSignal:
				Signal.main(args, settings);
			case MachineServer:
				Server.main(args, settings);
			case MachineYard:
				Yard.main(args, settings);
			default:
				trace("Er, you shouldn't be able to see this...");
		}
	}
}
