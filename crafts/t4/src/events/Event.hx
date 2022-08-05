package events;

import haxe.Constraints.Function;

abstract Event<T>(String) {
	public inline function new(name) {
		this = name;
	}
}
