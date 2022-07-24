import cc.Vector;
import model.Signal;
import lua.Lua;
import haxe.extern.Rest;
import cc.OS;
import lua.Table;

class Main {
	public static function main() {
		haxe.macro.Compiler.includeFile("prepend.lua");

		var args:Array<String> = Sys.args();

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
