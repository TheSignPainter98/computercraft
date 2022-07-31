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
			case ToFlag(_): false;
			case ToString(s, _): s == null;
			case ToInt(i, _): i == null;
			case ToFloat(f, _): f == null;
			case ToList(_): false;
		}
	}

	public function name(): String {
		return trigger.name();
	}

	public inline function getDefault(): Null<Arg> {
		return return switch (type) {
			case ToFlag(b): Flag(!b);
			case ToString(s, _): String(s);
			case ToInt(i, _): Int(i);
			case ToFloat(f, _): Float(f);
			case ToList(_): List([]);
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
			case ToFlag(_) | ToString(_, null) | ToInt(_, null) | ToFloat(_, null): [];
			case ToString(_, choices): choices;
			case ToInt(_, choices): choices;
			case ToFloat(_, choices): choices;
			default: [];
		}

		if (choices.length == 0)
			return null;
		return '{${choices.join(", ")}}';
	}
}
