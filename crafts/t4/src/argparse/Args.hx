package argparse;

@:forward
abstract Args(Map<Int, Dynamic>) from Map<Int, Dynamic> to Map<Int, Dynamic> {
	public inline function new() {
		this = new Map<Int, Dynamic>();
	}

	@:op([])
	inline function get<T>(key: ArgAccessor<T>): Null<T>
		return this[key];

	@:op([])
	inline function set<T>(key: ArgAccessor<T>, val: T)
		this[key] = val;
}
