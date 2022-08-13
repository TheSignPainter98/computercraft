import argparse.ArgAccessor;
import argparse.ArgAction;
import argparse.ArgParser;
import argparse.ProgSpec;
import cc.FileSystem.OpenFileMode;
import cc.FileSystem;
import cc.Vector;
import haxe.extern.Rest;
import lua.Lua;
import lua.Table;
import machine.Machine;
import config.Config;

using lua.NativeStringTools;

enum Result {
	Ok;
	Err(err: String);
}

class Main {
	private static inline final ARG_SEP = '';

	public static final DIRECTIONS = [ "top", "bottom", "left", "right", "front", "back" ];

	public static final NETWORK = new ArgAccessor<String>();
	public static final MODEM = new ArgAccessor<String>();
	public static final DEBUG_MODE = new ArgAccessor<Bool>();
	public static final BIND_MONITOR = new ArgAccessor<Null<String>>();
	public static final MACHINE = new ArgAccessor<Machine>();
	public static final MACHINE_ARGS = new ArgAccessor<Array<String>>();
	public static final SET_AUTO_START = new ArgAccessor<Bool>();
	public static final VERBOSE = new ArgAccessor<Array<String>>();

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
				dest: MACHINE,
				desc: "The type of machine this computer represents",
				type: String([MachineDisplay, MachineServer, MachineSignal, MachineStation, MachineYard]),
				trigger: {
					metavar: "machine",
				},
			},
			{
				dest: MACHINE_ARGS,
				desc: "The arguments to pass to the machine",
				type: List(String(null), AtLeast(0)),
				dflt: [],
				trigger: {
					metavar: "args",
					howMany: AtLeast(0),
				},
			}
		],
		flags: [
			{
				dest: BIND_MONITOR,
				desc: "Set which display to redirect output into",
				type: String(DIRECTIONS),
				dflt: "",
				trigger: {
					short: "-D",
					long: "--display",
				},
			},
			{
				dest: DEBUG_MODE,
				desc: "Enable debugging mode (disables some checks)",
				type: Flag,
				trigger: {
					short: "-d",
					long: "--debug",
				}
			},
			{
				dest: MODEM,
				desc: "Where the wireless router is attached",
				type: String(Main.DIRECTIONS),
				dflt: "back",
				trigger: {
					short: "-m",
					long: "--modem",
				}
			},
			{
				dest: NETWORK,
				desc: "The t4 network which this machine belongs to",
				type: String(null),
				dflt: "universe",
				trigger: {
					short: "-n",
					long: "--network",
				},
			},
			{
				dest: SET_AUTO_START,
				desc: "Don't use the arguments supplied this invokation in subsequent startups",
				type: FalseFlag,
				trigger: {
					short: "-n",
					long: "--no-autostart",
				},
			},
			{
				dest: VERBOSE,
				desc: "Output quietly",
				type: Int(null),
				dflt: 1,
				action: ArgAction.storeConst(0),
				trigger: {
					short: "-q",
					long: "--quiet",
				},
			},
			{
				dest: VERBOSE,
				desc: "Output verbosely",
				type: Int(null),
				dflt: 1,
				action: ArgAction.storeConst(2),
				trigger: {
					short: "-v",
					long: "--verbose",
				}
			},
		],
	};

	private static function __init__() {
		haxe.macro.Compiler.includeFile("prepend.lua");
	}

	public static function main() {
		var argv = Sys.args().map((s) -> s.gsub(ARG_SEP, " "));

		var parser = new ArgParser(cliSpec);
		var args = parser.parse(argv);
		if (args == null) {
			return;
		}

		if (args[SET_AUTO_START])
			configureStartup(args[BIND_MONITOR]);
		else
			deconfigureStartup();

		final machine = args[MACHINE];
		var config = new Config(machine);

		machine.exec(args, config);

		trace("Good night");

		config.save(); // Just in case
	}

	private static function configureStartup(display: Null<String>) {
		var args = Sys.args();
		var fmtdArgs = args.map((s) -> '"${s.gsub(' ', ARG_SEP)}"').join(", ");

		var startup = [];
		if (display != "")
			startup.push('term.redirect(peripheral.find("$display"))');
		startup.push('shell.run("t4", $fmtdArgs)');

		var slug = startup.join('\n');

		var f = FileSystem.open("./startup.lua", OpenFileMode.Write);
		f.write(slug);
		f.close();
	}

	private static function deconfigureStartup() {
		FileSystem.delete("./startup.lua");
	}
}
