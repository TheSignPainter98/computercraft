import CLI;
import cc.FileSystem.OpenFileMode;
import cc.FileSystem;
import cc.Vector;
import haxe.extern.Rest;
import lua.Lua;
import lua.Table;
import model.Signal;

enum ActionResult {
	Ok;
	Err(?err: String);
}

class Main {
	private static var cliSpec: ProgSpec = {
		name: "t4",
		shortDescription: "Trainable train-track tracker",
		description: "Trainable train-track tracker, a tracker which tracks trains on train tracks, and which trains on train timetables",
		licenseInfo: "
Copyright (C) 2022 The authors of t4

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
	",
		positionals: [
		{
			dest: "machine",
			desc: "The type of machine this computer represents",
		},
		{
			dest: "machine_args",
			desc: "The arguments to pass to the machine",
			mandatory: true,
			howMany: AtLeast(0),
		}
		],
		options: [],
	};

	public static function main() {
		haxe.macro.Compiler.includeFile("prepend.lua");

		var parser = new CLI(cliSpec);
		var args = parser.parse(Sys.args());
		if (args == null) {
			return;
		}

		trace(args);

		switch (args["setAutoStart"]) {
		case Flag(true): _setAutoStart(Sys.args());
		default:
		}
	}

	private static function _setAutoStart(args:Array<String>): ActionResult {
		var fmtd_args = args.map((s) -> '"$s"').join(", ");
		var slug = 'shell.run("t4", $fmtd_args)';

		var hook = [
			// completions,
			slug,
		].join("\n");

		var f = FileSystem.open("./startup.lua", OpenFileMode.Write);
		f.write(hook);
		f.close();

		return Ok;
	}
}
