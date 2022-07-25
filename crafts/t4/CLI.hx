import lua.Lua;
using StringTools;

inline final prog_name = "t4";

// enum CLIAction {
//	SetAutoStart(args: Array<String>);
//	ExecuteMachine(action: (Array<String>)->ActionResult, machineArgs: Array<String>);
//	ShowHelp;
//	BadUsage(msg: String);
// }
final HELP_DEST = "@:HeLp_DeSt";
final LICENSE_DEST = "@:LiCeNsE_dEsT";

@:structInit class ProgSpec {
	public var name: String;
	public var helpOption: Option = {
		dest: HELP_DEST,
		short: "-h",
		long: "--help",
		desc: "Show this help and exit",
	};
	public var licenseOption: Option = {
		dest: LICENSE_DEST,
		short: "-l",
		long: "--license",
		desc: "Show license and exit",
	};
	public var version: String = "1.0.0";
	public var shortDescription: Null<String> = null;
	public var description: Null<String>;
	public var licenseInfo: Null<String> = null;
	public var options: Array<Option> = [];
	public var positionals: Array<PositionalArg> = [];

	public function shortDesc(): String {
		var maybeDesc = shortDescription != null ? " - " + shortDescription : "";
		return name + maybeDesc + " " + version;
	}
}

@:structInit class PositionalArg {
	public var dest: String;
	public var mandatory: Bool = true;
	public var metavar: Null<String> = null;
	public var desc: Null<String> = null;
	public var howMany: ArgCount = Exactly(1);

	public function name(): String {
		if (metavar != null)
			return metavar;
		return dest;
	}
}

@:structInit class Option {
	public var dest: String;
	public var mandatory: Bool = false;
	public var desc: Null<String>;
	public var short: String;
	public var long: String;
	public var action: OptionAction = StoreTrue;

	public function name() {
		return short;
	}
}

enum ArgCount {
	AtLeast(n: Int);
	Exactly(n: Int);
}

enum OptionAction {
	StoreTrue;
	StoreFalse;
	Store;
}

typedef Args = Map<String, Arg>;

enum Arg {
	Flag(val: Bool);
	// Int(int: Int);
	String(val: String);
	List(vals: Array<String>);
}

enum Token {
	TFlag(dest: String, val: Bool);
	TOption(dest: String, val: String);
	TList(dest: String, vals: Array<String>);
}


enum ParserState {
	Capture;
	CaptureOption(src: String, opt: Option);
	CapturePositionalList(dest: String, list: Array<String>);
}

class CLI {
	private var spec: ProgSpec;
	private var optionMap: Map<String, Option>;

	public function new(spec: ProgSpec) {
		this.spec = spec;
		var options = [ spec.helpOption, spec.licenseOption ].concat(spec.options);
		this.optionMap = [ for (o in options) for (trigger in [o.short, o.long]) trigger => o ];
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
		var toks = [];

		var arg: String;
		while ((arg = raw_args.shift()) != null) {
			switch (parserState) {
				case Capture:
					if (arg == "--") {
						var positional: Null<PositionalArg> = null;
						while (positionalIterator.hasNext()) {
							positional = positionalIterator.next();
							if (switch (positional.howMany) {
								case AtLeast(n): raw_args.length >= n;
								case Exactly(n): raw_args.length == n;
							}) {

							}
						}

						if (positional == null) {
							showUsage("Cannot sink remaining arguments");
							return null;
						}

						// if (positional.howMany == One) {
						//	if (raw_args.length != 1) {
						//		showUsage('${positional.dest} takes exactly one argument, got ${raw_args.length}');
						//		return null;
						//	}
						//	toks.push(Option(positional.dest, raw_args[0]));
						//	return toks;
						// }

						toks.push(TList(positional.dest, raw_args));
						return toks;
					} else if (arg.charAt(0) == "-") { // TODO(kcza) kebab short flag usage
						var optSpec = optionMap[arg];
						if (optSpec != null)
							switch (optSpec.action) {
								case StoreTrue:
									toks.push(TFlag(optSpec.dest, true));
								case StoreFalse:
									toks.push(TFlag(optSpec.dest, false));
								case Store:
									parserState = CaptureOption(arg, optSpec);
							}
						else {
							showUsage('Unknown option: $arg');
							return null;
						}
					} else {
						if (!positionalIterator.hasNext()) {
							showUsage('Unmatched arguments: ${[arg].concat(raw_args).join(' ')}');
							return null;
						}

						var positional = positionalIterator.next();
						switch (positional.howMany) {
							case Exactly(n): // TODO: handle n
								toks.push(TOption(positional.dest, arg));
							case AtLeast(n): // TODO: handle n
								toks.push(TList(positional.dest, [arg].concat(raw_args)));
							default:
								parserState = CapturePositionalList(positional.dest, [arg]);
						}
					}
				case CaptureOption(src, spec):
					if (arg.charAt(0) == "-") {
						showUsage('Option $src requires an argument');
						return null;
					}
					toks.push(TOption(spec.dest, arg));
					parserState = Capture;
				case CapturePositionalList(dest, list): // TODO(kcza): get this working!
					if (arg.charAt(0) == "-") {
						toks.push(TList(dest, list));
						parserState = Capture;
					} else {
						list.push(arg);
					}
			}
		}

		return toks;
	}

	private function parseToks(toks: Array<Token>): Null<Args> {
		var args:Args = new Map();

		for (tok in toks)
			switch (tok) {
				case TFlag(dest, val): args[dest] = Flag(true); //Flag(val);
				case TOption(dest, val): args[dest] = String(val);
				case TList(dest, vals): args[dest] = List(vals);
			}

		if (!handleSpecialArgs(args))
			return null;

		if (!checkMandatoryArgs(args)) {
			return null;
		}
		return args;
	}

	private function checkMandatoryArgs(args: Args): Bool {
		var ret = true;
		var problems: Array<String> = [];

		for (option in spec.options)
			if (option.mandatory && args[option.dest] == null) {
				problems.push('Missing mandatory option ${option.name()}');
				ret = false;
			}

		for (positional in spec.positionals)
			if (positional.mandatory && args[positional.dest] == null) {
				switch (positional.howMany) {
					case AtLeast(0):
					default:
						problems.push('Missing ${positional.name()}');
						ret = false;
				}
			}

		if (!ret)
			showUsage(problems.join("\n"));
		return ret;
	}

	private function handleSpecialArgs(args: Args): Bool {
		if (args[HELP_DEST].match(Flag(true))) {
			showUsage();
			return false;
		}

		if (args[LICENSE_DEST].match(Flag(true))) {
			showLicense();
			return false;
		}

		return true;
	}

	private function showLicense() {
		if (spec.licenseInfo != null)
			Lua.print(spec.shortDesc() + "\n" + spec.licenseInfo);
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

// I know, but that's rather the point, don't you think?
// For if it were not for this tapping, how would you really know that my keyboard is indeed superior to that whch comes as standard on this laptop which I see before me? This laptop which, if I do so correctly recall, you failed to bring with us on our present excursion...

// class CLIActionUtils {
//	public static function execute(action: CLIAction): ActionResult {
//		return switch (action) {
//			case SetAutoStart(args): _setAutoStart(args);
//			case ExecuteMachine(f, args): f(args);
//			case ShowHelp: _showUsage();
//			case BadUsage(msg): _showUsage(msg);
//		};
//	}

// }
