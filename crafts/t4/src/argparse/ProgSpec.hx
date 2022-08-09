package argparse;

@:structInit
class ProgSpec {
	public static final HELP_DEST = new ArgAccessor<Bool>();
	public static final LICENSE_DEST = new ArgAccessor<Bool>();
	public static final VERSION_DEST = new ArgAccessor<Bool>();

	public var name: String;
	public var helpFlag: ArgSpec<Flag, Bool> = {
		dest: HELP_DEST,
		desc: "Show this help and exit",
		type: Flag,
		trigger: {
			short: "-h",
			long: "--help",
		},
	};
	public var licenseFlag: ArgSpec<Flag, Bool> = {
		dest: LICENSE_DEST,
		desc: "Show license and exit",
		type: Flag,
		trigger: {
			short: "-l",
			long: "--license",
		},
	};
	public var versionFlag: ArgSpec<Flag, Bool> = {
		dest: VERSION_DEST,
		desc: "Outout version information and exit",
		type: Flag,
		trigger: {
			short: "-V",
			long: "--version",
		},
	};
	public var version: String = "1.0.0";
	public var shortDesc: Null<String> = null;
	public var date: String;
	public var author: String;
	public var desc: Null<String>;
	public var license: Null<Array<String>> = null;
	public var flags: Array<ArgSpec<Flag, Dynamic>> = [];
	public var positionals: Array<ArgSpec<Positional, Dynamic>> = [];

	public function parse(argv: Array<String>): Args {
		final parser = new ArgParser(this);
		return parser.parse(argv);
	}

	public function signature(): String {
		var maybeDesc = shortDesc != null ? " - " + shortDesc : "";
		return name + maybeDesc + " v" + version;
	}

	public function copyright(): String {
		return 'Copyright (C) $date $author';
	}
}
