package model;

import haxe.ds.Vector;

@:structInit
class Signal {
	var id: Int;
	var bordering: Array<Int>;
	var state: SignalState;
}
