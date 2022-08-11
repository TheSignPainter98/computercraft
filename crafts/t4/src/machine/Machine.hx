package machine;

import argparse.Args;
import config.Config;
import display.Display;
import server.Server;
import station.Station;
import signal.Signal;
import yard.Yard;

@:enum
abstract Machine(String) from String to String {
	var MachineDisplay = 'display';
	var MachineServer = 'server';
	var MachineSignal = 'signal';
	var MachineStation = 'station';
	var MachineYard = 'yard';

	public inline function exec(parentArgs: Args, settings: Config) {
		switch (this) {
			case MachineDisplay:
				Display.main(parentArgs, settings);
			case MachineServer:
				Server.main(parentArgs, settings);
			case MachineSignal:
				Signal.main(parentArgs, settings);
			case MachineStation:
				Station.main(parentArgs, settings);
			case MachineYard:
				Yard.main(parentArgs, settings);
			default:
				trace("Er, you shouldn't be able to see this...");
		}
	}
}
