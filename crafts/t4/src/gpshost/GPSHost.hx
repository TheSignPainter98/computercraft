package gpshost;

import argparse.Args;
import argparse.ArgAccessor;
import argparse.ProgSpec;
import cc.Shell;
import config.Config;
import extype.Result;
import extype.Unit;
import extype.Unit._;

class GPSHost {
	private static var X = new ArgAccessor<Int>();
	private static var Y = new ArgAccessor<Int>();
	private static var Z = new ArgAccessor<Int>();

	private static final UNSPECIFIED = 0xdeadbeef;

	private static final cliSpec: ProgSpec = {
		name: "t4-gps",
		shortDesc: "t4 gps host",
		desc: "A GPS host for use with t4",
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
				dest: X,
				desc: "The x-location of this host",
				type: Int(null),
				trigger: {
					metavar: "x",
				}
			},
			{
				dest: Y,
				desc: "The y-location of this host",
				type: Int(null),
				trigger: {
					metavar: "y",
				}
			},
			{
				dest: Z,
				desc: "The z-location of this host",
				type: Int(null),
				trigger: {
					metavar: "z",
				}
			},
		],
	}

	public static function main(t4Args: Args, settings: Config): Result<Unit, String> {
		final args = cliSpec.parse(t4Args[Main.MACHINE_ARGS]);
		if (args == null)
			return Failure("Failed to parse args");

		Shell.run('gps', 'host', Std.string(args[X]), Std.string(args[Y]), Std.string(args[Z]));

		return Success(_);
	}
}
