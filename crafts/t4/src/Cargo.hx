import cc.FileSystem;

using lua.NativeStringTools;

enum VerbDecl {
	VerbDecl(cargo: Cargo, load: Null<String>, unload: Null<String>);
}

abstract Cargo(String) to String {
	public static var loadVerb: Map<Cargo, String>;
	public static var unloadVerb: Map<Cargo, String>;

	private static var defaultVerbs = [
		VerbDecl("tea", "brewing", "spilling"),
		VerbDecl("water", "pouring in", "siphoning"),
		VerbDecl("lava", "pouring in", "oozing"),
		VerbDecl("coal", "shovelling", "dumping"),
		VerbDecl("sand", "shovelling", "pouring"),
		VerbDecl("concrete powder", "filling up on", "pouring"),
	];

	private static function __init__() {
		loadVerb = new Map();
		unloadVerb = new Map();

		for (defaultVerb in defaultVerbs) {
			switch (defaultVerb) {
				case VerbDecl(cargo, loadv, unloadv):
					if (loadv != null)
						loadVerb[cargo] = loadv;
					if (unloadv != null)
						loadVerb[cargo] = unloadv;
			}
		}
	}

	@:from
	public static inline function fromRawString(s: String): Cargo {
		return cast s.gsub(".*:", "");
	}

	public function load(): String {
		var verb = loadVerb[this];
		if (verb == null)
			verb = "loading";
		return '$verb $this';
	}

	public function unload(): String {
		var verb = unloadVerb[this];
		if (verb == null)
			verb = "unloading";
		return '$verb $this';
	}
}
