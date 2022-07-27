package argparse;

@:structInit class Option implements ArgSpecTrigger {
	public var short: String;
	public var long: String;

	public inline function name(): String {
		return short;
	}

	public inline function signature(type: ArgType): String {
		var sigParts = [name()];
		var choicesSig = ArgSpec.choicesSignature(type);
		if (choicesSig != null)
			sigParts.push(choicesSig);
		return sigParts.join(" ");
	}
}
