package argparse;

@:structInit
class Token<T> {
	public var dest: ArgAccessor<T>;
	public var arg: T;
}
