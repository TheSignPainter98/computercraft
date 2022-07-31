package model;

@:structInit
class Train {
	var id: String;
	var name: String;
	var currentBlock: Block;
	var lastRoute: Array<Block>;
}
