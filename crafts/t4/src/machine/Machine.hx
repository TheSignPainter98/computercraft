package machine;

import config.Config;

@:enum
abstract Machine(String) from String to String {
	var Display = 'display';
	var Signal = 'signal';
	var Server = 'server';
	var Yard = 'yard';

	public inline function main(args: Array<String>, settings: Config) {
		trace('I am a $this');
		switch (this) {
			case Display:
				Display.main(args, settings);
			case Signal:
				Signal.main(args, settings);
			case Server:
				Server.main(args, settings);
			case Yard:
				Yard.main(args, settings);
			default:
				trace("Er, you shouldn't be able to see this...");
		}
	}
}
