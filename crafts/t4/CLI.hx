import lua.Lua;
import lua.NativeStringTools;
import haxe.Exception;
import haxe.ValueException;
using StringTools;

final HELP_DEST = "@:HeLp_DeSt";
final LICENSE_DEST = "@:LiCeNsE_dEsT";

@:structInit class ProgSpec {
	public var name: String;
	public var helpOption: ArgSpec<Option> = {
		dest: HELP_DEST,
		desc: "Show this help and exit",
		type: ToFlag(true),
		trigger: {
			short: "-h",
			long: "--help",
		},
	};
	public var licenseOption: ArgSpec<Option> = {
		dest: LICENSE_DEST,
		desc: "Show license and exit",
		type: ToFlag(true),
		trigger: {
			short: "-l",
			long: "--license",
		},
	};
	public var version: String = "1.0.0";
	public var shortDesc: Null<String> = null;
	public var date: String;
	public var author: String;
	public var desc: Null<String>;
	public var license: Null<Array<String>> = null;
	public var options: Array<ArgSpec<Option>> = [];
	public var positionals: Array<ArgSpec<Positional>> = [];

	public function signature(): String {
		var maybeDesc = shortDesc != null ? " - " + shortDesc : "";
		return name + maybeDesc + " v" + version;
	}

	public function copyright(): String {
		return 'Copyright (C) $date $author';
	}
}

@:structInit class ArgSpec<T:ArgSpecTrigger> {
	public var dest: String;
	public var desc: Null<String> = null;
	public var trigger: T;
	public var type: ArgType;

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
		return
			return switch (type) {
				case ToFlag(b): Flag(!b);
				case ToString(s, _): String(s);
				case ToInt(i, _): Int(i);
				case ToFloat(f, _): Float(f);
				case ToList(_): List([]);
			}
	}
}

interface ArgSpecTrigger {
	function name(): String;
}

@:structInit class Positional implements ArgSpecTrigger {
	public var metavar: Null<String>;
	public var howMany: ListCount = Exactly(1);

	public inline function name(): String {
		return metavar;
	}
}

@:structInit class Option implements ArgSpecTrigger {
	public var short: String;
	public var long: String;

	public inline function name(): String {
		return short;
	}
}

enum ArgType {
	ToFlag(store: Bool);
	ToString(dflt: Null<String>, choices: Null<Array<String>>);
	ToInt(dflt: Null<Int>, choices: Null<Array<Int>>);
	ToFloat(dflt: Null<Float>, choices: Null<Array<Float>>);
	ToList(type: ArgType);
}

// @:structInit class PositionalArg {
//	public var dest: String;
//	public var mandatory: Bool = true;
//	public var metavar: Null<String> = null;
//	public var desc: Null<String> = null;
//	public var howMany: ListCount = Exactly(1);
//	public var dflt: Null<Arg> = null;

//	public inline function name(): String {
//		if (metavar != null)
//			return metavar;
//		return dest;
//	}
// }

// @:structInit class Option {
//	public var dest: String;
//	public var mandatory: Bool = false;
//	public var desc: Null<String>;
//	public var short: String;
//	public var long: String;
//	public var action: OptionAction = StoreTrue;
//	public var dflt: Null<Arg> = null;

//	public inline function name() {
//		return short;
//	}

//	public inline function getDefault(): Null<Arg> {
//		if (dflt != null)
//			return dflt;
//		return switch (action) {
//			case StoreTrue:
//				Flag(false);
//			case StoreFalse:
//				Flag(true);
//			default:
//				null;
//		}
//	}
// }

enum ListCount {
	AtLeast(n: Int);
	Exactly(n: Int);
}

// enum OptionAction {
//	StoreTrue;
//	StoreFalse;
//	Store;
// }

class NoSuchArgumentException extends Exception {}

@:forward
abstract Args(Map<String, Arg>) from Map<String, Arg> to Map<String, Arg> {
	@:op([]) @:op(a.b) inline function get<T>(key: String): T {
		var val = this.get(key);
		if (val == null)
			throw new NoSuchArgumentException('No such argument "$key"');
		return cast Type.enumParameters(val)[0];
	}

	@:op([]) inline function set(key: String, val: Arg) {
		this.set(key, val);
		return val;
	}
}

enum Arg {
	Flag(val: Bool);
	Int(int: Int);
	Float(float: Float);
	String(val: String);
	List(vals: Array<String>);
}

@:structInit class Token {
	public var dest: String;
	public var arg: Arg;
}

enum ParserState {
	Capture;
	CaptureOption(src: String, opt: ArgSpec<Option>);
	CapturePositionalList(dest: String, list: Array<String>);
}

class CLI {
	private var spec: ProgSpec;
	private var optionMap: Map<String, ArgSpec<Option>>;

	public function new(spec: ProgSpec) {
		this.spec = spec;
		spec.options = [ spec.helpOption, spec.licenseOption ].concat(spec.options);
		this.optionMap = [ for (o in spec.options) for (trigger in [o.trigger.short, o.trigger.long]) trigger => o ];
	}

	public function parse(args: Array<String>): Null<Args> {
		var toks = tokenise(args);
		if (toks == null)
			return null;

		return parseToks(toks);
	}

	private function tokenise(raw_args: Array<String>): Null<Array<Token>> {
		if (raw_args.length == 0)
			return [];

		var parserState = Capture;
		var positionalIterator = spec.positionals.iterator();
		var toks: Array<Token> = [];

		var arg: String;
		while ((arg = raw_args.shift()) != null) {
			switch (parserState) {
				case Capture:
					if (arg == "--") {
						var positional: Null<ArgSpec<Positional>> = null;
						while (positionalIterator.hasNext() && raw_args.length != 0) {
							positional = positionalIterator.next();
							switch (positional.trigger.howMany) {
								case Exactly(1):
									toks.push({
										dest: positional.dest,
										arg: String(raw_args[0]),
									});
								case Exactly(n):
									toks.push({
										dest: positional.dest,
										arg: List(raw_args.slice(0, n)),
									});
									raw_args = raw_args.slice(n);
								case AtLeast(_):
									toks.push({
										dest: positional.dest,
										arg: List(raw_args),
									});
									raw_args = [];
							}
						}

						if (positional == null) {
							showUsage("Cannot sink remaining arguments");
							return null;
						}

						// if (positional.trigger.howMany.match(Exactly(1))) {
						//	toks.push({
						//		dest: positional.dest,
						//		arg: String(raw_args[0]),
						//	});
						// } else {
						//	toks.push({
						//		dest: positional.dest,
						//		arg: List(raw_args),
						//	});
						// }

						return toks;
					} else if (arg.charAt(0) == "-") {
						for (i in 1...arg.length) {
							var dekebabedArg = "-" + arg.charAt(i);
							var optSpec = optionMap[dekebabedArg];
							if (optSpec != null)
								switch (optSpec.type) {
									case ToFlag(f):
										toks.push({dest: optSpec.dest, arg: Flag(f)});
									default:
										if (i < arg.length - 1)
											raw_args.unshift(arg.substr(i + 1));
										parserState = CaptureOption(dekebabedArg, optSpec);
										break;
								}
							else {
								showUsage('Unknown option: $dekebabedArg');
								return null;
							}
						}
					} else {
						if (!positionalIterator.hasNext()) {
							showUsage('Unmatched arguments: ${[arg].concat(raw_args).join(' ')}');
							return null;
						}

						var positional = positionalIterator.next();
						switch (positional.trigger.howMany) {
							case Exactly(1):
								toks.push({dest: positional.dest, arg: String(arg)});
							default:
								parserState = CapturePositionalList(positional.dest, [arg]);
						}
					}
				case CaptureOption(src, spec):
					if (arg.charAt(0) == "-") {
						showUsage('Option $src requires an argument');
						return null;
					}
					toks.push({dest: spec.dest, arg: String(arg)});
					parserState = Capture;
				case CapturePositionalList(dest, list):
					if (arg.charAt(0) == "-") {
						toks.push({dest: dest, arg: List(list)});
						raw_args.unshift(arg);
						parserState = Capture;
					} else {
						list.push(arg);
					}
			}
		}

		switch (parserState) {
			case Capture:
			case CaptureOption(src, spec):
				showUsage('Option $src requires an argument');
				return null;
			case CapturePositionalList(dest, list):
				toks.push({dest: dest, arg: List(list)});
		}

		return toks;
	}

	private function parseToks(toks: Array<Token>): Null<Args> {
		var args:Args = new Map();

		// Defaults
		insertDefaultsInto(args, spec.positionals);
		insertDefaultsInto(args, spec.options);

		for (tok in toks)
			args[tok.dest] = tok.arg;

		if (!handleSpecialArgs(args))
			return null;

		var problems = checkMandatoryArgs(args).concat(checkChoices(args));
		if (problems.length != 0) {
			showUsage(problems.join("\n"));
			return null;
		}

		removeSpecialArgs(args);
		return args;
	}

	private function insertDefaultsInto<T:ArgSpecTrigger>(args: Args, specs: Array<ArgSpec<T>>) {
		for (spec in specs) {
			var dflt = spec.getDefault();
			if (dflt != null)
				args[spec.dest] = dflt;
		}
	}

	private function checkChoices(args: Args): Array<String> {
		return checkChoicesOf(spec.options, args).concat(checkChoicesOf(spec.positionals, args));
	}

	private function checkChoicesOf<T:ArgSpecTrigger>(specs: Array<ArgSpec<T>>, args: Args): Array<String> {
		var problems = [];

		for (spec in specs) {
			var val = args[spec.dest];
			switch (spec.type) {
				case ToString(_, null) | ToInt(_, null) | ToFloat(_, null):
				case ToString(_, choices):
					var arg = args[spec.dest];
					if (arg == null)
						continue;

					checkChoiceSpec(spec, cast args[spec.dest], choices, problems);
				case ToInt(_, choices):
					var arg = args[spec.dest];
					if (arg == null)
						continue;

					var i = Std.parseInt(arg);
					if (i == null) {
						problems.push('Expected integer, got "$arg"');
						continue;
					}
					args[spec.dest] = Int(i);

					checkChoiceSpec(spec, i, choices, problems);
				case ToFloat(_, choices):
					var arg = args[spec.dest];
					if (arg == null)
						continue;

					var f = Std.parseFloat(arg);
					if (f == null) {
						problems.push('Expected float, got "$arg"');
						continue;
					}

					args[spec.dest] = Float(f);
					checkChoiceSpec(spec, f, choices, problems);
				default:
			}
		}

		return problems;
	}

	private function checkChoiceSpec<T:ArgSpecTrigger, S>(spec: ArgSpec<T>, val: Null<S>, choices: Array<S>, problems: Array<String>) {
		if (choices.indexOf(val) == -1)
			problems.push('Option ${spec.name()} got $val, expected one of: ${choices.join(", ")}');
	}

	private function checkMandatoryArgs(args: Args): Array<String> {
		var problems: Array<String> = [];

		for (option in spec.options)
			if (option.mandatory() && args[option.dest] == null)
				problems.push('Missing mandatory flag: ${option.name()}');

		for (positional in spec.positionals){
			if (positional.mandatory() && args[positional.dest] == null) {
				switch (positional.trigger.howMany) {
					case AtLeast(0):
					default:
						problems.push('Missing mandatory positional: ${positional.name()}');
				}
			}
		}

		return problems;
	}

	private function handleSpecialArgs(args: Args): Bool {
		if (args[HELP_DEST] == true) {
			showUsage();
			return false;
		}

		if (args[LICENSE_DEST] == true) {
			showLicense();
			return false;
		}

		return true;
	}

	private function removeSpecialArgs(args: Args) {
		args.remove(HELP_DEST);
		args.remove(LICENSE_DEST);
	}

	private function showLicense() {
		if (spec.license != null) {
			Lua.print([spec.signature(), spec.copyright(), "",].concat(spec.license).join("\n"));
		}
	}

	private function showUsage(?problem:String) {
		// TODO: complete me!, usage
		var msg = '

			usage: ${spec.name} [COMMAND]

			COMMANDS:

			^display Create a new display driver
			^help    Display help about a given command and exit
			^server  Create a new world server (one per world)
			^signal  Create a new signal
			^yard    Create a new train yard

			';
		if (problem != null)
			Lua.print(problem);
		Lua.print(
				msg.split("\n")
				.slice(1, -1)
				.map((s) -> s.substr(3).replace("^", "    "))
				.join("\n")
				);
	}
}
