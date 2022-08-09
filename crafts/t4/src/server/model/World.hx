package model;

@:structInit
class World {
	var name: String;
	var trains: Array<Train>;
	var stations: Array<Station>;
	var blocks: Array<Block>;
	var signals: Array<Signal>;
}
