package argparse;

interface ArgSpecTrigger {
	function name():String;
	function signature(type:ArgType):String;
}
