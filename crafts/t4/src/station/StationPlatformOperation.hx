package station;

import haxe.ds.Option;

@:structInit
class StationPlatformOperation {
	public var trainID: Int;
	public var fuelling: Option<Cargo>;
	public var loading: Array<Cargo>;
	public var unloading: Array<Cargo>;
}
