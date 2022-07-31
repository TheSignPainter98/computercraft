package argparse;

enum Arg {
	Flag(val:Bool);
	Int(int:Int);
	Float(float:Float);
	String(val:String);
	List(vals:Array<String>);
}
