package argparse;

enum ArgType {
	ToFlag(store: Bool);
	ToString(dflt: Null<String>, choices: Null<Array<String>>);
	ToInt(dflt: Null<Int>, choices: Null<Array<Int>>);
	ToFloat(dflt: Null<Float>, choices: Null<Array<Float>>);
	ToList(type: ArgType);
}
