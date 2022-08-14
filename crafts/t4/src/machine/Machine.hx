package machine;

import argparse.Args;
import config.Config;
import display.Display;
import server.Server;
import station.Station;
import extype.Result;
import extype.Unit;

@:enum
abstract Machine(String) from String to String {
	var MachineDisplay = 'display';
	var MachineServer = 'server';
	var MachineStation = 'station';

	public inline function exec(parentArgs: Args, settings: Config): Result<Unit, String> {
		return switch (this) {
			case MachineDisplay:
				Display.main(parentArgs, settings);
			case MachineServer:
				Server.main(parentArgs, settings);
			case MachineStation:
				Station.main(parentArgs, settings);
			default:
				Failure('Er, you shouldn\'t be able to see this... no such machine $this?!');
		}
	}
}
