import argparse.ArgParser;
import argparse.ProgSpec;
import cc.FileSystem.OpenFileMode;
import cc.FileSystem;
import cc.Vector;
import display.Display;
import haxe.extern.Rest;
import lua.Lua;
import lua.Table;
import model.Signal;
import server.Server;
import signal.Signal;
import yard.Yard;
import config.Config;
import packet.Packet;

enum Result {
	Ok;
	Err(err: String);
}

class Main {
	private static var cliSpec: ProgSpec = {
		name: "t4",
		shortDesc: "Trainable train-track tracker",
		desc: "Trainable train-track tracker: a tracker which tracks trains on train tracks and trains to track tracks which trains use.",
		author: "The authors of t4",
		date: "2022",
		license: [
			"This program is free software: you can redistribute it and/or modify",
			"it under the terms of the GNU General Public License as published by",
			"the Free Software Foundation, either version 3 of the License, or",
			"(at your option) any later version.",
			"",
			"This program is distributed in the hope that it will be useful,",
			"but WITHOUT ANY WARRANTY; without even the implied warranty of",
			"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the",
			"GNU General Public License for more details.",
			"",
			"You should have received a copy of the GNU General Public License",
			"along with this program.  If not, see <https://www.gnu.org/licenses/>.",
		],
		positionals: [
			{
				dest: "machine",
				desc: "The type of machine this computer represents",
				type: ToString(null, ["display", "server", "signal", "yard"]),
				trigger: {
					metavar: "machine",
				},
			},
			{
				dest: "machine_args",
				desc: "The arguments to pass to the machine",
				type: ToList(ToString(null, null)),
				trigger: {
					metavar: "args",
					howMany: AtLeast(0),
				},
			}
		],
		options: [
			{
				dest: "setAutoStart",
				desc: "Don't use the arguments supplied this invokation in subsequent startups",
				type: ToFlag(false),
				trigger: {
					short: "-n",
					long: "--no-autostart",
				},
			},
			{
				dest: "verbose",
				desc: "Output verbosely",
				type: ToFlag(true),
				trigger: {
					short: "-v",
					long: "--verbose",
				},
			}
		],
	};

	public static function main() {
		haxe.macro.Compiler.includeFile("prepend.lua");
		var args = Sys.args();

		var parser = new ArgParser(cliSpec);
		var args = parser.parse(Sys.args());
		if (args == null) {
			return;
		}

		if (args.setAutoStart)
			configureStartup();
		else
			deconfigureStartup();

		var config = new Config(args.machine);

		args.machine.main(args.machine_args, config);

		trace("Good night");

		config.save(); // Just in case
	}

	private static function configureStartup() {
		var args = Sys.args();
		var fmtdArgs = args.map((s) -> '"$s"').join(", ");
		var hook = 'shell.run("t4", $fmtdArgs)';

		var f = FileSystem.open("./startup.lua", OpenFileMode.Write);
		f.write(hook);
		f.close();
	}

	private static function deconfigureStartup() {
		FileSystem.delete("./startup.lua");
	}
}
