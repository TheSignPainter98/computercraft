package logger;

import lua.Lua;
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
			_log(msg);
	}

	public static function log(msg: Rest<Dynamic>) {
		if (verbosity >= Normal)
			_log(msg);
	}

	public static function err(msg: Rest<Dynamic>) {
		_log(msg);
	}

	private static function _log(msg: Array<Dynamic>) {
		Lua.print([ for (part in msg) Std.string(part) ].join(' '));
	}
}
