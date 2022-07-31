package argparse;

@:structInit class ProgSpec {
	public static final HELP_DEST = "@:HeLp_DeSt";
	public static final LICENSE_DEST = "@:LiCeNsE_dEsT";
	public static final VERSION_DEST = "@:VeRsIoN_dEsT!";

	public var name:String;
	public var helpOption:ArgSpec<Option> = {
		dest: HELP_DEST,
		desc: "Show this help and exit",
		type: ToFlag(true),
		trigger: {
			short: "-h",
			long: "--help",
		},
	};
	public var licenseOption:ArgSpec<Option> = {
		dest: LICENSE_DEST,
		desc: "Show license and exit",
		type: ToFlag(true),
		trigger: {
			short: "-l",
			long: "--license",
		},
	};
	public var versionOption:ArgSpec<Option> = {
		dest: VERSION_DEST,
		desc: "Outout version information and exit",
		type: ToFlag(true),
		trigger: {
			short: "-V",
			long: "--version",
		},
	};
	public var version:String = "1.0.0";
	public var shortDesc:Null<String> = null;
	public var date:String;
	public var author:String;
	public var desc:Null<String>;
	public var license:Null<Array<String>> = null;
	public var options:Array<ArgSpec<Option>> = [];
	public var positionals:Array<ArgSpec<Positional>> = [];

	public function signature():String {
		var maybeDesc = shortDesc != null ? " - " + shortDesc : "";
		return name + maybeDesc + " v" + version;
	}

	public function copyright():String {
		return 'Copyright (C) $date $author';
	}
}
