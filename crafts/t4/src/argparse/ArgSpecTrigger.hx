package argparse;

interface ArgSpecTrigger {
	function name(): String;
	function longName(): String;
	function signature(type: ArgType): String;
}
