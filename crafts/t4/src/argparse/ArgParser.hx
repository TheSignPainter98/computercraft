package argparse;

import lua.Lua;
import lua.NativeStringTools;
using StringTools;

@:structInit class Token {
	public var dest: String;
	public var arg: Arg;
}

enum ParserState {
	Capture;
	CaptureOption(src: String, opt: ArgSpec<Option>);
	CapturePositionalList(dest: String, list: Array<String>);
}

class ArgParser {
	private var spec: ProgSpec;
	private var optionMap: Map<String, ArgSpec<Option>>;

	public function new(spec: ProgSpec) {
		this.spec = spec;
		spec.options = [ spec.helpOption, spec.licenseOption, spec.versionOption ].concat(spec.options);
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
					} else if (arg.charAt(0) == "-" && arg.length > 1) {
						if (arg.substr(0, 2) == "--") {
							var optSpec = optionMap[arg];
							if (optSpec != null) {
								switch (optSpec.type) {
									case ToFlag(f):
										toks.push({dest: optSpec.dest, arg: Flag(f)});
									default:
										parserState = CaptureOption(arg, optSpec);
								}
							} else {
								showUsage('Unknown option: $arg');
								return null;
							}
						} else
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
					if (arg.charAt(0) == "-" && arg != "-") {
						showUsage('Option $src requires an argument');
						return null;
					}
					toks.push({dest: spec.dest, arg: String(arg)});
					parserState = Capture;
				case CapturePositionalList(dest, list):
					if (arg.charAt(0) == "-" && arg != "-") {
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
					args[spec.dest] = Arg.Int(i);

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

					args[spec.dest] = Arg.Float(f);
					checkChoiceSpec(spec, f, choices, problems);
				default:
			}
		}

		return problems;
	}

	private function checkChoiceSpec<T:ArgSpecTrigger, S>(spec: ArgSpec<T>, val: Null<S>, choices: Array<S>, problems: Array<String>) {
		if (choices.indexOf(val) == -1)
			problems.push('Option "${spec.name()}" got $val, expected one of: ${choices.join(", ")}');
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
		if (args[ProgSpec.HELP_DEST] == true) {
			showHelp();
			return false;
		}

		if (args[ProgSpec.LICENSE_DEST] == true) {
			showLicense();
			return false;
		}

		if (args[ProgSpec.VERSION_DEST] == true) {
			showVersion();
			return false;
		}

		return true;
	}

	private function removeSpecialArgs(args: Args) {
		args.remove(ProgSpec.HELP_DEST);
		args.remove(ProgSpec.LICENSE_DEST);
		args.remove(ProgSpec.VERSION_DEST);
	}

	private function showLicense() {
		if (spec.license != null) {
			Lua.print([spec.signature(), spec.copyright(), "",].concat(spec.license).join("\n"));
		}
	}

	private function showVersion() {
		Lua.print('${spec.name} ${spec.version}');
	}

	private function showHelp() {
		showUsage();

		spec.positionals.sort((p1, p2) -> p1.compare(p2));
		var help = [""];

		help.push("DESCRIPTION");
		help.push("");
		help.push(spec.desc);

		if (spec.options.length != 0) {
			help.push("");
			help.push("OPTIONS");
			help.push("");

			for (opt in spec.options) {
				var choicesSig = ArgSpec.choicesSignature(opt.type);
				var choicesMark = "";
				if (choicesSig != null)
					choicesMark = ' $choicesSig';
				help.push('    ${opt.trigger.short}$choicesMark, ${opt.trigger.long}$choicesMark');
				help.push('        ${opt.desc}');
			}
		}
		if (spec.positionals.length != 0) {
			help.push("");
			help.push("ARGUMENTS");
			help.push("");

			for (pos in spec.positionals) {
				var choicesSig = ArgSpec.choicesSignature(pos.type);
				var choicesMark = "";
				if (choicesSig != null)
					choicesMark = ' (in $choicesSig)';
				help.push('    ${pos.name()}$choicesMark');
				help.push('        ${pos.desc}');
			}
		}

		if (help.length > 1)
			help.push("");

		Lua.print(help.join("\n"));
	}

	private function showUsage(?problem: String) {
		var usageParts = ["usage:", spec.name];

		spec.options.sort((o1, o2) -> o1.compare(o2));

		for (opt in spec.options)
			usageParts.push(opt.signature());

		for (pos in spec.positionals)
			usageParts.push(pos.signature());

		if (problem != null)
			Lua.print(problem);
		Lua.print(usageParts.join(" "));

		if (problem != null)
			Lua.print('For more information, try the ${spec.helpOption.trigger.long} flag.');
	}
}
