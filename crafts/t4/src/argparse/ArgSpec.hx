package argparse;

@:structInit
class ArgSpec<T:ArgSpecTrigger, V> {
	public var dest: ArgAccessor<V>;
	public var desc: Null<String> = null;
	public var trigger: T;
	public var dflt: Null<V> = null;
	public var type: ArgType;
	public var parse(get, never): RawArgList->ParserFragmentResult<V>;
	public var action: Null<RawArgList->ParserFragmentResult<V>> = null;

	public inline function get_parse(): RawArgList->ParserFragmentResult<V> {
		return if (action != null) action; else type.defaultAction();
	}

	public function compare(other: ArgSpec<T, Dynamic>): Int {
		var k1 = longName().toLowerCase();
		var k2 = other.longName().toLowerCase();
		if (k1 < k2) {
			return -1;
		} else if (k1 == k2) {
			return 0;
		} else {
			return 1;
		}
	}

	public function mandatory(): Bool {
		return type != Flag && type != FalseFlag && dflt == null;
	}

	public function name(): String {
		return trigger.name();
	}

	public function longName(): String {
		return trigger.longName();
	}

	public inline function getDefault(): Null<Dynamic> {
		if (dflt != null)
			return dflt;
		if (!mandatory())
			return switch (type) {
				case Flag: false;
				case FalseFlag: true;
				case String(_): "";
				case Int(_): 0;
				case Float(_): 0.0;
				case List(_): [];
			}
		return null;
	}

	public function tokenise<T: ArgSpecTrigger, V>(args: RawArgList, toks: Array<Token<Dynamic>>, problems: Array<String>): RawArgList {
		final parseFragmentResult = parse(args);

		switch (parseFragmentResult.result) {
			case Left(err):
				problems.push(err);
			case Right(v):
				toks.push({
					dest: dest,
					arg: v,
				});
		}

		return args.map((l) -> l.slice(parseFragmentResult.shift));
	}

	public inline function signature(): String {
		var inner = trigger.signature(type);
		if (!mandatory())
			return '[$inner]';
		return inner;
	}

	public static function choicesSignature(type: ArgType): Null<String> {
		var choices: Array<Any> = switch (type) {
			case Flag | String(null) | Int(null) | Float(null): [];
			case String(choices): choices;
			case Int(choices): choices;
			case Float(choices): choices;
			default: [];
		}

		if (choices.length == 0)
			return null;
		return '{${choices.join(", ")}}';
	}
}
