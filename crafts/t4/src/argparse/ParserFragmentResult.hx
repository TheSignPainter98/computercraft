package argparse;

import haxe.ds.Either;

@:structInit
class ParserFragmentResult<V> {
	public var result: Either<String, V>;
	public var shift: Int;
}
