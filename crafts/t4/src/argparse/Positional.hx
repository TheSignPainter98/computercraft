package argparse;

@:structInit
class Positional implements ArgSpecTrigger {
	public var metavar: Null<String>;
	public var howMany: ListCount = Exactly(1);

	public inline function name(): String {
		return metavar;
	}

	public inline function signature(type: ArgType): String {
		var content = ArgSpec.choicesSignature(type);
		if (content == null)
			content = metavar;
		return switch (howMany) {
			case Exactly(1): content;
			default: '$content...';
		}
	}
}
