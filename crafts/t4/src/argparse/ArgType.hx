package argparse;

enum ArgType {
	Flag(store: Bool);
	String(dflt: Null<String>, choices: Null<Array<String>>);
	Int(dflt: Null<Int>, choices: Null<Array<Int>>);
	Float(dflt: Null<Float>, choices: Null<Array<Float>>);
	List(type: ArgType);
}
