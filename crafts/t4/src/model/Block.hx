package model;

@:structInit
class Block {
	var id:Int;
	var currentBlock:Block;
	var boundarySignals:Array<Signal>;
	var bidirectionalBlock:Null<BidirectionalBlock>;
}
