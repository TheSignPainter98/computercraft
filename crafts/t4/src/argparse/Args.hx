package argparse;

@:forward
abstract Args(Map<String, Arg>) from Map<String, Arg> to Map<String, Arg> {
	@:op([]) @:op(a.b)
	inline function get<T>(key: String): T {
		var val = this.get(key);
		if (val == null)
			throw new NoSuchArgumentException('No such argument "$key"');
		return cast Type.enumParameters(val)[0];
	}

	@:op([])
	inline function set(key: String, val: Arg) {
		this.set(key, val);
		return val;
	}
}
