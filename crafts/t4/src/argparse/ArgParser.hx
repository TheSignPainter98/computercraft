package argparse;

import lua.Lua;
import lua.NativeStringTools;

using StringTools;

class ArgParser {
	private var spec: ProgSpec;
	private var flagMap: Map<String, ArgSpec<Flag, Dynamic>>;

	public function new(spec: ProgSpec) {
		this.spec = spec;

		var preflags = [cast spec.helpFlag, cast spec.versionFlag];
		if (spec.license != null)
			preflags.push(cast spec.licenseFlag);

		spec.flags = preflags.concat(spec.flags);
		this.flagMap = [
			for (f in spec.flags)
				for (trigger in [f.trigger.short, f.trigger.long])
					trigger => f
		];
	}

	public function parse(args: Array<String>): Null<Args> {
		var toks = tokenise(args);
		if (toks == null)
			return null;

		return parseToks(toks);
	}

	private function tokenise(rawArgs: Array<String>): Null<Array<Token<Dynamic>>> {
		if (rawArgs.length == 0)
			return [];

		var positionalIterator = spec.positionals.iterator();
		var toks: Array<Token<Dynamic>> = [];

		var remainderDeclIndex = rawArgs.indexOf("--");
		var remainderArgs: RawArgList = Verbatim(if (remainderDeclIndex != -1) rawArgs.slice(remainderDeclIndex + 1); else []);

		var parseable_args: RawArgList = Parseable(if (remainderDeclIndex != -1) rawArgs.slice(0, remainderDeclIndex); else rawArgs);
		var problems: Array<String> = [];

		var arg: String;
		while ((arg = parseable_args.shift()) != null) {
			if (arg.charAt(0) == '-' && arg.length > 1) {
				if (arg.charAt(1) == '-') {
					// Long flags
					var flagSpec = flagMap[arg];
					if (flagSpec != null) {
						parseable_args = flagSpec.tokenise(parseable_args, toks, problems);
					} else {
						showUsage('Unknown flag: $arg');
						return null;
					}
				} else {
					// Short flags
					for (i in 1...arg.length) {
						var dekebabedArg = "-" + arg.charAt(i);
						var flagSpec = flagMap[dekebabedArg];
						if (flagSpec != null) {
							final unskewer = i < arg.length - 1;
							if (unskewer)
								parseable_args.unshift(arg.substr(i + 1));
							var initialLength = parseable_args.length;
							parseable_args = flagSpec.tokenise(parseable_args, toks, problems);
							if (parseable_args.length != initialLength)
								break;
							else if (unskewer)
								parseable_args.shift();
						} else {
							showUsage('Unknown flag: $dekebabedArg');
							return null;
						}
					}
				}
			} else {
				// Positional
				if (!positionalIterator.hasNext()) {
					parseable_args.unshift(arg);
					showUsage('Unmatched arguments: ${parseable_args.join(' ')}');
					return null;
				}

				var positional = positionalIterator.next();

				parseable_args.unshift(arg);
				parseable_args = positional.tokenise(parseable_args, toks, problems);
			}
		}

		// Parse remainder args into positionals
		var positional: Null<ArgSpec<Positional, Dynamic>> = null;
		while (remainderArgs.length != 0 && positionalIterator.hasNext())
			remainderArgs = positionalIterator.next().tokenise(remainderArgs, toks, problems);

		return toks;
	}

	private function parseToks(toks: Array<Token<Dynamic>>): Null<Args> {
		var args = new Args();

		// Defaults
		insertDefaultsInto(args, spec.positionals);
		insertDefaultsInto(args, spec.flags);

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

	private function insertDefaultsInto<T: ArgSpecTrigger>(args: Args, specs: Array<ArgSpec<T, Dynamic>>) {
		for (spec in specs) {
			var dflt = spec.getDefault();
			if (dflt != null)
				args[spec.dest] = dflt;
		}
	}

	private function checkChoices(args: Args): Array<String> {
		return checkChoicesOf(spec.flags, args).concat(checkChoicesOf(spec.positionals, args));
	}

	private function checkChoicesOf<T: ArgSpecTrigger>(specs: Array<ArgSpec<T, Dynamic>>, args: Args): Array<String> {
		var problems = [];

		for (spec in specs) {
			var val = args[spec.dest];
			switch (spec.type) {
				case String(null) | Int(null) | Float(null):
				case String(choices):
					var arg = args[spec.dest];
					if (arg == null)
						continue;

					checkChoiceSpec(spec, cast args[spec.dest], choices, problems);
				case Int(choices):
					var arg = args[spec.dest];
					if (arg == null)
						continue;

					var i = Std.parseInt(arg);
					if (i == null) {
						problems.push('Expected integer, got "$arg"');
						continue;
					}
					args[spec.dest] = i;

					checkChoiceSpec(spec, i, choices, problems);
				case Float(choices):
					var arg = args[spec.dest];
					if (arg == null)
						continue;

					var f = Std.parseFloat(arg);
					if (f == null) {
						problems.push('Expected float, got "$arg"');
						continue;
					}

					args[spec.dest] = f;

					checkChoiceSpec(spec, f, choices, problems);
				default:
			}
		}

		return problems;
	}

	private function checkChoiceSpec<T: ArgSpecTrigger, S>(spec: ArgSpec<T, Dynamic>, val: Null<S>, choices: Array<S>, problems: Array<String>) {
		if (val != spec.dflt && choices.indexOf(val) == -1)
			problems.push('Flag "${spec.name()}" got $val, expected one of: ${choices.join(", ")}');
	}

	private function checkMandatoryArgs(args: Args): Array<String> {
		var problems: Array<String> = [];

		for (flag in spec.flags)
			if (flag.mandatory() && args[flag.dest] == null)
				problems.push('Missing mandatory flag: ${flag.name()}');

		for (positional in spec.positionals) {
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
		Lua.print([spec.signature(), spec.copyright(), "",].concat(spec.license).join("\n"));
	}

	private function showVersion() {
		Lua.print('${spec.name} ${spec.version}');
	}

	private function showHelp() {
		showUsage();

		var help = [""];

		help.push("DESCRIPTION");
		help.push("");
		help.push(spec.desc);

		if (spec.flags.length != 0) {
			help.push("");
			help.push("OPTIONS");

			for (flag in spec.flags) {
				var choicesSig = ArgSpec.choicesSignature(flag.type);
				var choicesMark = "";
				if (choicesSig != null)
					choicesMark = ' $choicesSig';
				help.push("");
				help.push('    ${flag.trigger.short}$choicesMark, ${flag.trigger.long}$choicesMark');
				help.push('        ${flag.desc}');
			}
		}
		if (spec.positionals.length != 0) {
			help.push("");
			help.push("ARGUMENTS");

			for (pos in spec.positionals) {
				var choicesSig = ArgSpec.choicesSignature(pos.type);
				var choicesMark = "";
				if (choicesSig != null)
					choicesMark = ' (in $choicesSig)';
				help.push("");
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

		spec.flags.sort((o1, o2) -> o1.compare(o2));

		for (flag in spec.flags)
			usageParts.push(flag.signature());

		for (pos in spec.positionals)
			usageParts.push(pos.signature());

		if (problem != null)
			Lua.print(problem);
		Lua.print(usageParts.join(" "));

		if (problem != null)
			Lua.print('For more information, try the ${spec.helpFlag.trigger.long} flag.');
	}
}
