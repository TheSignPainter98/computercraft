import cc.Vector;
import model.Signal;
import lua.Lua;
import haxe.extern.Rest;
import cc.OS;
import lua.Table;

class Main {
	public static function main() {
		haxe.macro.Compiler.includeFile("prepend.lua");

		// TODO Create an extern definition for _G.arg
		var t:Table<Int, String> = untyped __lua__("_G.arg");
		var args:Array<String> = Table.toArray(t);

		switch args[0] {
			case Machine.Display:
				// Display.Main();
				display.Display.main();
			case Machine.Server:
				server.Server.main();
			case Machine.Signal:
				signal.Signal.main();
			case Machine.Yard:
				yard.Yard.main();
			default:
				Lua.print("No command");
		}
	}
}
