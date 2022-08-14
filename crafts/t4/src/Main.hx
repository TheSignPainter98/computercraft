import argparse.ArgAccessor;
import argparse.ArgAction;
import argparse.ArgParser;
import argparse.ProgSpec;
import cc.Peripheral;
import cc.periphs.Monitor;
import cc.FileSystem.OpenFileMode;
import cc.FileSystem;
import cc.OS;
import cc.Term;
import cc.Vector;
import haxe.extern.Rest;
import lua.Lua;
import lua.Table;
import machine.Machine;
import config.Config;
import logger.Logger;
import logger.Verbosity;

using lua.NativeStringTools;

class Main {
	private static inline final ARG_SEP = '';

	public static final DIRECTIONS = ["top", "bottom", "left", "right", "front", "back"];

	public static final NETWORK = new ArgAccessor<String>();
	public static final MODEM = new ArgAccessor<String>();
	public static final DEBUG_MODE = new ArgAccessor<Bool>();
	public static final MACHINE = new ArgAccessor<Machine>();
	public static final MACHINE_ARGS = new ArgAccessor<Array<String>>();
	public static final SET_AUTO_START = new ArgAccessor<Bool>();
	private static final VERBOSITY = new ArgAccessor<Verbosity>();

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
				type: String([MachineDisplay, MachineGPSHost, MachineServer, MachineStation]),
				trigger: {
					metavar: "machine",
				},
			},
			{
				dest: MACHINE_ARGS,
				desc: "The arguments to pass to the machine",
				type: List(String(null), false),
				dflt: [],
				trigger: {
					metavar: "args",
					howMany: AtLeast(0),
				},
			}
		],
		flags: [
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
					short: "-N",
					long: "--no-autostart",
				},
			},
			{
				dest: VERBOSITY,
				desc: "Output quietly",
				type: Int(null),
				dflt: Verbosity.Normal,
				action: ArgAction.storeConst(Verbosity.Quiet),
				trigger: {
					short: "-q",
					long: "--quiet",
				},
			},
			{
				dest: VERBOSITY,
				desc: "Output verbosely",
				type: Int(null),
				dflt: Verbosity.Normal,
				action: ArgAction.storeConst(Verbosity.Verbose),
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

		Logger.verbosity = args[VERBOSITY];

		if (args[SET_AUTO_START])
			configureStartup();
		else
			deconfigureStartup();

		final machine = args[MACHINE];
		var config = new Config(machine);

		Logger.log('This is t4 running on computer ID: #${OS.getComputerID()}');

		switch (machine.exec(args, config)) {
			case Failure(err):
				Logger.err(err);
			default:
		}

		Logger.log("Good night");

		config.save(); // Just in case
	}

	private static function configureStartup() {
		final args = Sys.args();
		final fmtdArgs = args.map((s) -> '"${s.gsub(' ', ARG_SEP)}"').join(", ");
		final hook = 'shell.run("t4", $fmtdArgs)';

		final f = FileSystem.open("./startup.lua", OpenFileMode.Write);
		f.write(hook);
		f.close();
	}

	private static function deconfigureStartup() {
		FileSystem.delete("./startup.lua");
	}
}
