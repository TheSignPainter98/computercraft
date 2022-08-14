package logger;

import haxe.Rest;

class Logger {
	@:isVar
	public static var verbosity(get, set): Verbosity;

	public static inline function set_verbosity(v: Verbosity): Verbosity {
		verbosity = v;
		return v;
	}

	private static inline function get_verbosity(): Verbosity {
		return verbosity;
	}

	public static function verbose(msg: Rest<Dynamic>) {
		if (verbosity >= Verbose)
			trace(msg);
	}

	public static function log(msg: Rest<Dynamic>) {
		if (verbosity >= Normal)
			trace(msg);
	}

	public static function err(msg: Rest<Dynamic>) {
		trace(msg);
	}
}
