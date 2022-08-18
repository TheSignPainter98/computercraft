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

	public inline function unite(with: Null<Args>) {
		if (this == null || with == null)
			return null;

		final ret = this.copy();
		for (kvPair in with.keyValueIterator()) {
			ret[kvPair.key] = kvPair.value;
		}
		return ret;
	}
}
