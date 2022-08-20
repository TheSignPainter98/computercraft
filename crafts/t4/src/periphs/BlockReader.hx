package periphs;

import lua.Table.AnyTable;

extern class BlockReader {
	public function getBlockName(): String;
	public function getBlockData(): AnyTable;
}
