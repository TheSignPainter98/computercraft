package argparse;

abstract ArgAccessor<T>(Int) to Int {
	private static var ctr: Int = 0;

	public inline function new() {
		this = ctr++;
	}
}
