package gpshost;

import argparse.Args;
import argparse.ArgAccessor;
import argparse.ProgSpec;
import cc.Shell;
import config.Config;
import extype.Result;
import extype.Unit;
import extype.Unit._;

private abstract Position(Array<String>) from Array<String> {
	private static final fieldMap = ["x" => 0, "y" => 1, "z" => 2];

	@:op(a.b)
	public function get(field: String): Null<String> {
		final idx = fieldMap[field];
		if (idx == null)
			return null;

		return this[idx];
	}
}

class GPSHost {
	private static var POSITION = new ArgAccessor<Position>();

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
				dest: POSITION,
				desc: "The position of the host (three integers)",
				type: List(String(null), true),
				trigger: {
					metavar: "position",
					howMany: Exactly(3),
				}
			},
		],
	}

	public static function main(args: Args, settings: Config): Result<Unit, String> {
		final args = cliSpec.parse(args[Main.MACHINE_ARGS]).unite(args);
		if (args == null)
			return Failure("Failed to parse args");

		final position: Position = args[POSITION];

		Shell.run('gps', 'host', position.x, position.y, position.z);

		return Success(_);
	}
}
