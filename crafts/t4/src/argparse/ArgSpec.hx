package argparse;

@:structInit
class ArgSpec<T:ArgSpecTrigger> {
	public var dest: String;
	public var desc: Null<String> = null;
	public var trigger: T;
	public var type: ArgType;

	public function compare(other: ArgSpec<T>): Int {
		var k1 = name();
		var k2 = other.name();
		if (k1 < k2) {
			return -1;
		} else if (k1 == k2) {
			return 0;
		} else {
			return 1;
		}
	}

	public function mandatory(): Bool {
		return switch (type) {
			case Flag(_): false;
			case String(s, _): s == null;
			case Int(i, _): i == null;
			case Float(f, _): f == null;
			case List(_): false;
		}
	}

	public function name(): String {
		return trigger.name();
	}

	public inline function getDefault(): Null<Arg> {
		return return switch (type) {
			case Flag(b): Flag(!b);
			case String(s, _): String(s);
			case Int(i, _): Int(i);
			case Float(f, _): Float(f);
			case List(_): List([]);
		}
	}

	public inline function signature(): String {
		var inner = trigger.signature(type);
		if (!mandatory())
			return '[$inner]';
		return inner;
	}

	public static function choicesSignature(type: ArgType): Null<String> {
		var choices: Array<Any> = switch (type) {
			case Flag(_) | String(_, null) | Int(_, null) | Float(_, null): [];
			case String(_, choices): choices;
			case Int(_, choices): choices;
			case Float(_, choices): choices;
			default: [];
		}

		if (choices.length == 0)
			return null;
		return '{${choices.join(", ")}}';
	}
}
