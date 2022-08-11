package station;

import haxe.ds.Option;

@:structInit
class StationPlatform {
	final id: Int;
	var name: Option<String> = None;
	var operation: Option<StationPlatformOperation> = None;
}
