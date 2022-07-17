// Compile with:
//
// $ cd src/hello_world/
// $ haxe build.hxml

// package hello_world; // Not necessary as this .hx is in the local root


import cc.OS.version;

typedef MyType = String
typedef Obj = { name: String }

interface Talk {
	function talk(x:Int): Void;
}

enum Location {
	Relative(x:Int, y:Int);
	Absolute(x:Int, y:Int);
}

class Main {
	static function main() {
		trace("Hello, world!");
	}
}

class HelloWorldHx implements Talk {
	static function main() {
		var x = 12;
		trace("hfjdks");
		trace("Hello, haxe-transpiled world!");
		trace('asdf $x');

		var o:Obj = { name: "Hello!" };
		trace(o);

		var l = Absolute(1, 2);
		trace(l);
		l = Relative(3, 4);
		trace(l);
		// trace(Color.white);
		trace("Hello, world! This is CC v" + version());

		trace("my name is methos");
	}

	public function talk(x:Int):Void {
		trace('Talking with $x');
	}
}
