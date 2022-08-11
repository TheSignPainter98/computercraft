package station;

import haxe.ds.Option;

@:structInit
class StationStatus {
	public final id: Int;
	public final name: String;
	public final buffer: Option<StationBufferStatus>;
	public final currentlyServicing: Array<StationPlatformOperation>;
}
